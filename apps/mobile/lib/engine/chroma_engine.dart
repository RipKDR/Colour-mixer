import 'dart:math' as math;
import 'dart:ui';

class PigmentModel {
  const PigmentModel({
    required this.id,
    required this.name,
    required this.pigmentCodes,
    required this.reflectance,
    required this.opacity,
    required this.tintingStrength,
    required this.toxicity,
    required this.binder,
    required this.lab,
    required this.color,
  });

  final String id;
  final String name;
  final List<String> pigmentCodes;
  final List<double> reflectance;
  final double opacity;
  final double tintingStrength;
  final String toxicity;
  final String binder;
  final LabColor lab;
  final Color color;

  factory PigmentModel.fromJson(Map<String, dynamic> json) {
    final reflectance = (json['reflectance'] as List).cast<double>();
    final lab = Colorimetry.spectrumToLab(reflectance);
    final srgb = Colorimetry.spectrumToSrgb(reflectance);
    return PigmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      pigmentCodes: (json['pigment_codes'] as List).cast<String>(),
      reflectance: reflectance,
      opacity: (json['opacity'] as num).toDouble(),
      tintingStrength: (json['tinting_strength'] as num).toDouble(),
      toxicity: json['toxicity'] as String,
      binder: json['binder'] as String,
      lab: lab,
      color: Color.fromARGB(
        255,
        (srgb.$1 * 255).round(),
        (srgb.$2 * 255).round(),
        (srgb.$3 * 255).round(),
      ),
    );
  }
}

class LabColor {
  const LabColor(this.l, this.a, this.b);
  final double l;
  final double a;
  final double b;
}

class MixComponent {
  const MixComponent({required this.pigmentId, required this.weight});
  final String pigmentId;
  final double weight;
}

class MixResult {
  const MixResult({
    required this.lab,
    required this.color,
    required this.massTone,
    required this.undertone,
  });

  final LabColor lab;
  final Color color;
  final Color massTone;
  final Color undertone;
}

class Colorimetry {
  static const spectrumSamples = 41;

  static double reflectanceToKs(double r) {
    final clamped = r.clamp(0.001, 0.999);
    final term = 1.0 - clamped;
    return (term * term) / (2.0 * clamped);
  }

  static double ksToReflectance(double ks) {
    final k = math.max(0.0, ks);
    return 1.0 + k - math.sqrt(k * k + 2.0 * k);
  }

  static double _wavelength(int index) => 380.0 + index * 10.0;

  static double _cmfX(double wl) {
    if (wl < 440) return 0.001368 * (wl - 380) / 60;
    if (wl < 490) return 0.0143 + 0.0956 * (wl - 440) / 50;
    if (wl < 520) return 0.13438 + 0.2146 * (wl - 490) / 30;
    if (wl < 560) return 0.34828 + 0.0601 * (wl - 520) / 40;
    if (wl < 590) return 0.40826 - 0.0401 * (wl - 560) / 30;
    if (wl < 640) return 0.36826 - 0.2000 * (wl - 590) / 50;
    return 0.16826 - 0.16826 * (wl - 640) / 140;
  }

  static double _cmfY(double wl) {
    if (wl < 440) return 0.000039 * (wl - 380) / 60;
    if (wl < 490) return 0.0040 + 0.3960 * (wl - 440) / 50;
    if (wl < 520) return 0.4 + 0.4 * (wl - 490) / 30;
    if (wl < 560) return 0.8 - 0.2 * (wl - 520) / 40;
    if (wl < 590) return 0.6 - 0.1 * (wl - 560) / 30;
    if (wl < 640) return 0.5 - 0.3 * (wl - 590) / 50;
    return 0.2 - 0.2 * (wl - 640) / 140;
  }

  static double _cmfZ(double wl) {
    if (wl < 440) return 0.006450 * (wl - 380) / 60;
    if (wl < 490) return 0.0645 + 0.3040 * (wl - 440) / 50;
    if (wl < 520) return 0.3686 + 0.0314 * (wl - 490) / 30;
    if (wl < 560) return 0.4 - 0.1 * (wl - 520) / 40;
    if (wl < 590) return 0.3 - 0.15 * (wl - 560) / 30;
    if (wl < 640) return 0.15 - 0.1 * (wl - 590) / 50;
    return 0.05 - 0.05 * (wl - 640) / 140;
  }

  static double _d65(double wl) {
    if (wl < 500) return 0.5 + 0.5 * (wl - 380) / 120;
    if (wl < 600) return 1.0;
    return 1.0 - 0.5 * (wl - 600) / 180;
  }

  static (double, double, double) spectrumToXyz(List<double> reflectance) {
    var x = 0.0, y = 0.0, z = 0.0, yNorm = 0.0;
    for (var i = 0; i < reflectance.length; i++) {
      final wl = _wavelength(i);
      final illum = _d65(wl);
      final r = reflectance[i].clamp(0.0, 1.0);
      x += r * _cmfX(wl) * illum;
      y += r * _cmfY(wl) * illum;
      z += r * _cmfZ(wl) * illum;
      yNorm += _cmfY(wl) * illum;
    }
    if (yNorm <= 0) return (0, 0, 0);
    return (x / yNorm * 100, y / yNorm * 100, z / yNorm * 100);
  }

  static LabColor xyzToLab(double x, double y, double z) {
    double f(double t) =>
        t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : (903.3 * t + 16) / 116;
    const xn = 95.047, yn = 100.0, zn = 108.883;
    return LabColor(
      116.0 * f(y / yn) - 16.0,
      500.0 * (f(x / xn) - f(y / yn)),
      200.0 * (f(y / yn) - f(z / zn)),
    );
  }

  static LabColor spectrumToLab(List<double> reflectance) {
    final (x, y, z) = spectrumToXyz(reflectance);
    return xyzToLab(x, y, z);
  }

  static (double, double, double) xyzToSrgb(double x, double y, double z) {
    final xr = x / 100, yr = y / 100, zr = z / 100;
    final r = xr * 3.2406 + yr * -1.5372 + zr * -0.4986;
    final g = xr * -0.9689 + yr * 1.8758 + zr * 0.0415;
    final b = xr * 0.0557 + yr * -0.2040 + zr * 1.0570;
    double gamma(double c) =>
        c <= 0.0031308 ? 12.92 * c : 1.055 * math.pow(c, 1 / 2.4) - 0.055;
    return (gamma(r).clamp(0, 1), gamma(g).clamp(0, 1), gamma(b).clamp(0, 1));
  }

  static (double, double, double) spectrumToSrgb(List<double> reflectance) {
    final (x, y, z) = spectrumToXyz(reflectance);
    return xyzToSrgb(x, y, z);
  }

  static (double, double, double) labToSrgb(double l, double a, double b) {
    double f(double t) =>
        t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : (903.3 * t + 16) / 116;
    const xn = 95.047, yn = 100.0, zn = 108.883;
    final yv = (l + 16) / 116;
    final xv = a / 500 + yv;
    final zv = yv - b / 200;
    final x = f(xv) * xn;
    final y = f(yv) * yn;
    final z = f(zv) * zn;
    return xyzToSrgb(x, y, z);
  }

  static Color srgbToColor((double, double, double) srgb) => Color.fromARGB(
        255,
        (srgb.$1 * 255).round(),
        (srgb.$2 * 255).round(),
        (srgb.$3 * 255).round(),
      );

  static List<double> mixSpectraKs(
    List<double> a,
    List<double> b,
    double t,
  ) {
    final result = <double>[];
    for (var i = 0; i < a.length; i++) {
      final ks = reflectanceToKs(a[i]) * (1 - t) + reflectanceToKs(b[i]) * t;
      result.add(ksToReflectance(ks));
    }
    return result;
  }

  /// CIEDE2000 colour difference between two Lab colours.
  static double ciede2000(LabColor a, LabColor b) {
    return ciede2000Tuple((a.l, a.a, a.b), (b.l, b.a, b.b));
  }

  static double ciede2000Tuple((double, double, double) lab1, (double, double, double) lab2) {
    final (l1, a1, b1) = lab1;
    final (l2, a2, b2) = lab2;

    final c1 = math.sqrt(a1 * a1 + b1 * b1);
    final c2 = math.sqrt(a2 * a2 + b2 * b2);
    final cBar = (c1 + c2) / 2;

    final g = 0.5 *
        (1 -
            math.sqrt(
                math.pow(cBar, 7) / (math.pow(cBar, 7) + math.pow(25, 7)),
            ));

    final a1p = a1 * (1 + g);
    final a2p = a2 * (1 + g);
    final c1p = math.sqrt(a1p * a1p + b1 * b1);
    final c2p = math.sqrt(a2p * a2p + b2 * b2);

    final h1p = math.atan2(b1, a1p) * 180 / math.pi % 360;
    final h2p = math.atan2(b2, a2p) * 180 / math.pi % 360;

    final dl = l2 - l1;
    final dc = c2p - c1p;

    double dh;
    if (c1p * c2p < 1e-10) {
      dh = 0;
    } else if ((h2p - h1p).abs() <= 180) {
      dh = h2p - h1p;
    } else if (h2p <= h1p) {
      dh = h2p - h1p + 360;
    } else {
      dh = h2p - h1p - 360;
    }
    dh = 2 * math.sqrt(c1p * c2p) * math.sin(dh * math.pi / 360);

    final lBar = (l1 + l2) / 2;
    final cBarp = (c1p + c2p) / 2;

    double hBar;
    if (c1p * c2p < 1e-10) {
      hBar = h1p + h2p;
    } else if ((h1p - h2p).abs() <= 180) {
      hBar = (h1p + h2p) / 2;
    } else if (h1p + h2p < 360) {
      hBar = (h1p + h2p + 360) / 2;
    } else {
      hBar = (h1p + h2p - 360) / 2;
    }

    final t = 1 -
        0.17 * math.cos((hBar - 30) * math.pi / 180) +
        0.24 * math.cos(2 * hBar * math.pi / 180) +
        0.32 * math.cos((3 * hBar + 6) * math.pi / 180) -
        0.20 * math.cos((4 * hBar - 63) * math.pi / 180);

    final sl = 1 + 0.015 * (lBar - 50) * (lBar - 50) / math.sqrt(20 + (lBar - 50) * (lBar - 50));
    final sc = 1 + 0.045 * cBarp;
    final sh = 1 + 0.015 * cBarp * t;

    final rt = -2 *
        math.sqrt(math.pow(cBarp, 7) / (math.pow(cBarp, 7) + math.pow(25, 7))) *
        math.exp(-math.pow((hBar - 275) / 25, 2) * 60 * math.pi / 180) *
        math.sin(2 * hBar * math.pi / 180);

    final term1 = math.pow(dl / sl, 2);
    final term2 = math.pow(dc / sc, 2);
    final term3 = math.pow(dh / sh, 2);
    final term4 = rt * (dc / sc) * (dh / sh);

    return math.sqrt(term1 + term2 + term3 + term4);
  }
}

class ChromaEngine {
  ChromaEngine(this._pigments);

  final Map<String, PigmentModel> _pigments;

  List<PigmentModel> get allPigments =>
      _pigments.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  PigmentModel? getPigment(String id) => _pigments[id];

  MixResult mix(List<MixComponent> components) {
    if (components.isEmpty) {
      return MixResult(
        lab: const LabColor(50, 0, 0),
        color: const Color(0xFF808080),
        massTone: const Color(0xFF808080),
        undertone: const Color(0xFF808080),
      );
    }

    final total = components.fold<double>(0, (s, c) => s + c.weight);
    if (total <= 0) {
      return MixResult(
        lab: const LabColor(50, 0, 0),
        color: const Color(0xFF808080),
        massTone: const Color(0xFF808080),
        undertone: const Color(0xFF808080),
      );
    }

    final ksMixed = List<double>.filled(Colorimetry.spectrumSamples, 0);
    for (final component in components) {
      final pigment = _pigments[component.pigmentId];
      if (pigment == null) continue;
      final normalized = component.weight / total;
      final effective = normalized * pigment.tintingStrength;
      for (var i = 0; i < pigment.reflectance.length; i++) {
        ksMixed[i] +=
            Colorimetry.reflectanceToKs(pigment.reflectance[i]) * effective;
      }
    }

    final reflectance = ksMixed.map(Colorimetry.ksToReflectance).toList();
    final lab = Colorimetry.spectrumToLab(reflectance);
    final srgb = Colorimetry.spectrumToSrgb(reflectance);
    final massTone = Colorimetry.srgbToColor(srgb);

    final white = _pigments['titanium_white'];
    Color undertone = massTone;
    if (white != null) {
      final undertoneSpec =
          Colorimetry.mixSpectraKs(white.reflectance, reflectance, 0.1);
      undertone =
          Colorimetry.srgbToColor(Colorimetry.spectrumToSrgb(undertoneSpec));
    }

    return MixResult(
      lab: lab,
      color: massTone,
      massTone: massTone,
      undertone: undertone,
    );
  }
}

enum QuantityUnit { parts, percent, grams, milliliters, drops, teaspoons, scoops }

class RatioDisplay {
  const RatioDisplay({
    required this.parts,
    required this.percent,
    required this.grams,
  });
  final String parts;
  final String percent;
  final String grams;
}

List<RatioDisplay> formatRatios(List<double> weights, QuantityUnit unit) {
  double toGrams(double v) {
    switch (unit) {
      case QuantityUnit.grams:
        return v;
      case QuantityUnit.milliliters:
        return v * 1.15;
      case QuantityUnit.drops:
        return v * 0.05;
      case QuantityUnit.teaspoons:
        return v * 5.0;
      case QuantityUnit.scoops:
        return v * 2.0;
      default:
        return v;
    }
  }

  final grams = weights.map(toGrams).toList();
  final total = grams.fold<double>(0, (a, b) => a + b);
  if (total <= 0) {
    return weights
        .map((_) => const RatioDisplay(parts: '0', percent: '0%', grams: '0g'))
        .toList();
  }
  final minG = grams.reduce(math.min);
  return List.generate(weights.length, (i) {
    final partsVal = minG > 0 ? grams[i] / minG : 0.0;
    final pct = grams[i] / total * 100;
    return RatioDisplay(
      parts: partsVal.toStringAsFixed(1),
      percent: '${pct.toStringAsFixed(1)}%',
      grams: '${weights[i].toStringAsFixed(2)}g',
    );
  });
}
