import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';

void main() {
  group('srgbToLab', () {
    test('roundtrips with labToSrgb for in-gamut colours', () {
      const lab = LabColor(55, 20, -30);
      final (r, g, b) = Colorimetry.labToSrgb(lab.l, lab.a, lab.b);
      final back = Colorimetry.srgbToLab(r, g, b);
      expect(back.l, closeTo(lab.l, 1.0));
      expect(back.a, closeTo(lab.a, 1.5));
      expect(back.b, closeTo(lab.b, 1.5));
    });

    test('white maps to high L near-neutral', () {
      final lab = Colorimetry.srgbToLab(1.0, 1.0, 1.0);
      expect(lab.l, greaterThan(95));
      expect(lab.a.abs(), lessThan(2));
      expect(lab.b.abs(), lessThan(2));
    });

    test('pure red has positive a', () {
      final lab = Colorimetry.srgbToLab(1.0, 0.0, 0.0);
      expect(lab.a, greaterThan(40));
    });
  });
}
