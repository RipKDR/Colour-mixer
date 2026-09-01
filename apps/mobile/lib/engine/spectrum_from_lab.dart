import 'dart:math' as math;

import 'chroma_engine.dart';

double _clampR(double v) => v.clamp(0.001, 0.999);

double _hueToWavelengthNm(double a, double b) {
  var deg = math.atan2(b, a) * 180 / math.pi;
  if (deg < 0) deg += 360;
  // Lab hue 0° = red, 90° = yellow, 180° = green, 270° = blue.
  if (deg < 90) {
    return 630 - (deg / 90) * 55; // 630 → 575
  }
  if (deg < 180) {
    return 575 - ((deg - 90) / 90) * 45; // 575 → 530
  }
  if (deg < 270) {
    return 530 - ((deg - 180) / 90) * 80; // 530 → 450
  }
  return 450 + ((deg - 270) / 90) * 180; // 450 → 630 (magenta wrap)
}

List<double> _evaluate(double base, double amp, double center, double width) {
  return [
    for (var i = 0; i < Colorimetry.spectrumSamples; i++)
      _clampR(
        base +
            amp *
                math.exp(
                  -0.5 *
                      math.pow((380.0 + i * 10 - center) / width, 2).toDouble(),
                ),
      ),
  ];
}

double _score(List<double> spectrum, LabColor target) {
  return Colorimetry.ciede2000(Colorimetry.spectrumToLab(spectrum), target);
}

/// Build a 41-sample reflectance curve whose masstone Lab is close to [target].
///
/// Uses a Gaussian bump on a gray floor and coordinate descent on CIEDE2000.
/// Good enough for user-entered custom paints; not a measured spectrum.
List<double> spectrumFromLab(LabColor target) {
  final chroma = math.sqrt(target.a * target.a + target.b * target.b);
  var base = (target.l / 100).clamp(0.03, 0.92);
  var amp = (chroma / 90).clamp(0.0, 0.75);
  var center = chroma < 4 ? 550.0 : _hueToWavelengthNm(target.a, target.b);
  var width = chroma < 4 ? 200.0 : 55.0;

  var spectrum = _evaluate(base, amp, center, width);
  var best = _score(spectrum, target);

  var step = 1.0;
  for (var round = 0; round < 10; round++) {
    var improved = false;
    for (final delta in [
      () => base += 0.04 * step,
      () => base -= 0.04 * step,
      () => amp += 0.05 * step,
      () => amp -= 0.05 * step,
      () => center += 12 * step,
      () => center -= 12 * step,
      () => width += 8 * step,
      () => width -= 8 * step,
    ]) {
      final saved = (base, amp, center, width);
      delta();
      base = base.clamp(0.01, 0.95);
      amp = amp.clamp(0.0, 0.9);
      center = center.clamp(400.0, 700.0);
      width = width.clamp(20.0, 220.0);
      final trial = _evaluate(base, amp, center, width);
      final score = _score(trial, target);
      if (score < best) {
        best = score;
        spectrum = trial;
        improved = true;
      } else {
        base = saved.$1;
        amp = saved.$2;
        center = saved.$3;
        width = saved.$4;
      }
    }
    if (!improved) {
      step *= 0.5;
      if (step < 0.08) break;
    }
  }

  return spectrum;
}

PigmentModel pigmentFromLab({
  required String id,
  required String name,
  required LabColor target,
  double opacity = 0.9,
  double tintingStrength = 1.0,
  String binder = 'acrylic',
}) {
  final reflectance = spectrumFromLab(target);
  final lab = Colorimetry.spectrumToLab(reflectance);
  final srgb = Colorimetry.spectrumToSrgb(reflectance);
  return PigmentModel(
    id: id,
    name: name,
    pigmentCodes: const ['custom'],
    reflectance: reflectance,
    opacity: opacity,
    tintingStrength: tintingStrength,
    toxicity: 'unknown',
    binder: binder,
    lab: lab,
    color: Colorimetry.srgbToColor(srgb),
  );
}
