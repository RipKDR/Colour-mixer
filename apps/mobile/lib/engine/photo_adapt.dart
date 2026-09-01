import 'dart:math' as math;

import 'chroma_engine.dart';

/// Bradford CAT matrix (CIE).
const _bradford = [
  [0.8951, 0.2664, -0.1614],
  [-0.7502, 1.7135, 0.0367],
  [0.0389, -0.0685, 1.0296],
];

/// Inverse Bradford CAT matrix.
const _bradfordInv = [
  [0.9869929, -0.1470543, 0.1599627],
  [0.4323053, 0.5183603, 0.0492912],
  [-0.0085287, 0.0400428, 0.9684867],
];

/// D65 XYZ used by [Colorimetry.xyzToLab] when no white is passed.
const d65Xyz = (95.047, 100.0, 108.883);

(double, double, double) _mul3(
  List<List<double>> m,
  (double, double, double) v,
) {
  return (
    m[0][0] * v.$1 + m[0][1] * v.$2 + m[0][2] * v.$3,
    m[1][0] * v.$1 + m[1][1] * v.$2 + m[1][2] * v.$3,
    m[2][0] * v.$1 + m[2][1] * v.$2 + m[2][2] * v.$3,
  );
}

double _linearizeSrgb(double c) {
  final x = c.clamp(0.0, 1.0);
  return x <= 0.04045 ? x / 12.92 : math.pow((x + 0.055) / 1.055, 2.4).toDouble();
}

/// Gamma-encoded sRGB (0..1) to XYZ (D65, scaled so Y=100 for white).
(double, double, double) srgbToXyz((double, double, double) srgb) {
  final rl = _linearizeSrgb(srgb.$1);
  final gl = _linearizeSrgb(srgb.$2);
  final bl = _linearizeSrgb(srgb.$3);
  return (
    (rl * 0.4124 + gl * 0.3576 + bl * 0.1805) * 100,
    (rl * 0.2126 + gl * 0.7152 + bl * 0.0722) * 100,
    (rl * 0.0193 + gl * 0.1192 + bl * 0.9505) * 100,
  );
}

/// Bradford chromatic adaptation of [xyz] from [srcWhite] to [dstWhite].
(double, double, double) bradfordAdapt(
  (double, double, double) xyz,
  (double, double, double) srcWhite,
  (double, double, double) dstWhite,
) {
  final lms = _mul3(_bradford, xyz);
  final src = _mul3(_bradford, srcWhite);
  final dst = _mul3(_bradford, dstWhite);
  final scaled = (
    src.$1.abs() < 1e-9 ? lms.$1 : lms.$1 * (dst.$1 / src.$1),
    src.$2.abs() < 1e-9 ? lms.$2 : lms.$2 * (dst.$2 / src.$2),
    src.$3.abs() < 1e-9 ? lms.$3 : lms.$3 * (dst.$3 / src.$3),
  );
  return _mul3(_bradfordInv, scaled);
}

/// Convert a photo sample to Lab, optionally adapting from a gray/white card
/// in the same image to D65. [whiteReference] is gamma-encoded sRGB 0..1.
///
/// A missing or near-black white card falls back to unadapted [Colorimetry.srgbToLab].
LabColor srgbToLabAdapted(
  (double, double, double) srgb, {
  (double, double, double)? whiteReference,
}) {
  if (whiteReference == null) {
    return Colorimetry.srgbToLab(srgb.$1, srgb.$2, srgb.$3);
  }
  final srcWhite = srgbToXyz(whiteReference);
  if (srcWhite.$2 < 1.0) {
    return Colorimetry.srgbToLab(srgb.$1, srgb.$2, srgb.$3);
  }
  final adapted = bradfordAdapt(srgbToXyz(srgb), srcWhite, d65Xyz);
  return Colorimetry.xyzToLab(
    adapted.$1,
    adapted.$2,
    adapted.$3,
    white: d65Xyz,
  );
}
