import 'dart:typed_data';
import 'dart:ui' show Color;

import '../../engine/chroma_engine.dart';
import '../../engine/photo_adapt.dart';
import '../match/color_match.dart';

/// How closely a photographed swatch matches the predicted mix.
enum SwatchVerdict {
  imperceptible,
  excellent,
  good,
  visible,
  far,
}

/// Maps ΔE to a verdict tier using the same thresholds as [matchScoreLabel].
SwatchVerdict verdictForDeltaE(double deltaE) {
  if (deltaE < 1) return SwatchVerdict.imperceptible;
  if (deltaE < 2) return SwatchVerdict.excellent;
  if (deltaE < 5) return SwatchVerdict.good;
  if (deltaE < 10) return SwatchVerdict.visible;
  return SwatchVerdict.far;
}

String swatchVerdictLabel(SwatchVerdict verdict) {
  switch (verdict) {
    case SwatchVerdict.imperceptible:
      return 'Imperceptible difference';
    case SwatchVerdict.excellent:
      return 'Excellent match';
    case SwatchVerdict.good:
      return 'Good — acceptable for most work';
    case SwatchVerdict.visible:
      return 'Visible difference — keep adjusting';
    case SwatchVerdict.far:
      return 'Far from target';
  }
}

class AdaptedSample {
  const AdaptedSample({
    required this.lab,
    required this.color,
    required this.comparison,
  });

  final LabColor lab;
  final Color color;
  final SwatchComparison comparison;
}

/// Recomputes Lab / display colour / ΔE from a stored sRGB sample when the
/// white-card reference changes (no need to retap the photo).
AdaptedSample adaptSample({
  required (double, double, double) sampledSrgb,
  required LabColor mixLab,
  (double, double, double)? whiteReference,
}) {
  final lab = srgbToLabAdapted(sampledSrgb, whiteReference: whiteReference);
  return AdaptedSample(
    lab: lab,
    color: Colorimetry.srgbToColor(Colorimetry.labToSrgb(lab.l, lab.a, lab.b)),
    comparison: SwatchComparison.compare(swatchLab: lab, referenceLab: mixLab),
  );
}

class SwatchComparison {
  const SwatchComparison({
    required this.swatchLab,
    required this.referenceLab,
    required this.deltaE,
    required this.verdict,
  });

  final LabColor swatchLab;
  final LabColor referenceLab;
  final double deltaE;
  final SwatchVerdict verdict;

  factory SwatchComparison.compare({
    required LabColor swatchLab,
    required LabColor referenceLab,
  }) {
    final deltaE = Colorimetry.ciede2000(swatchLab, referenceLab);
    return SwatchComparison(
      swatchLab: swatchLab,
      referenceLab: referenceLab,
      deltaE: deltaE,
      verdict: verdictForDeltaE(deltaE),
    );
  }
}

/// Averages a square neighbourhood in raw RGBA bytes and converts to Lab.
///
/// [radius] is half-width in pixels (default 7 → 15×15 patch). Clamps at
/// image edges. Photo pixels are treated as gamma-encoded sRGB. Pass
/// [whiteReference] (sRGB 0..1 of a gray/white card in the same photo) to
/// Bradford-adapt the sample to D65.
LabColor sampleLabFromRgba(
  ByteData pixels,
  int imageWidth,
  int imageHeight,
  int centerX,
  int centerY, {
  int radius = 7,
  (double, double, double)? whiteReference,
}) {
  final srgb = sampleSrgbFromRgba(
    pixels,
    imageWidth,
    imageHeight,
    centerX,
    centerY,
    radius: radius,
  );
  if (srgb == null) {
    return const LabColor(50, 0, 0);
  }
  return srgbToLabAdapted(srgb, whiteReference: whiteReference);
}

/// Averaged gamma-encoded sRGB (0..1), or null if the window is empty.
(double, double, double)? sampleSrgbFromRgba(
  ByteData pixels,
  int imageWidth,
  int imageHeight,
  int centerX,
  int centerY, {
  int radius = 7,
}) {
  var r = 0, g = 0, b = 0, n = 0;
  for (var y = centerY - radius; y <= centerY + radius; y++) {
    for (var x = centerX - radius; x <= centerX + radius; x++) {
      if (x < 0 || y < 0 || x >= imageWidth || y >= imageHeight) continue;
      final offset = (y * imageWidth + x) * 4;
      r += pixels.getUint8(offset);
      g += pixels.getUint8(offset + 1);
      b += pixels.getUint8(offset + 2);
      n++;
    }
  }
  if (n == 0) return null;
  return (r / n / 255.0, g / n / 255.0, b / n / 255.0);
}
