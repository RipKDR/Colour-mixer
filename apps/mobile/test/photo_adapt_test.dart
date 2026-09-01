import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/engine/photo_adapt.dart';

void main() {
  group('srgbToLabAdapted', () {
    test('D65 white reference leaves sRGB samples unchanged', () {
      const white = (1.0, 1.0, 1.0);
      const sample = (0.8, 0.15, 0.12);
      final adapted = srgbToLabAdapted(sample, whiteReference: white);
      final direct = Colorimetry.srgbToLab(sample.$1, sample.$2, sample.$3);

      expect(adapted.l, closeTo(direct.l, 0.05));
      expect(adapted.a, closeTo(direct.a, 0.05));
      expect(adapted.b, closeTo(direct.b, 0.05));
    });

    test('null white reference is the same as unadapted srgbToLab', () {
      const sample = (0.2, 0.5, 0.8);
      final adapted = srgbToLabAdapted(sample, whiteReference: null);
      final direct = Colorimetry.srgbToLab(sample.$1, sample.$2, sample.$3);

      expect(adapted.l, closeTo(direct.l, 1e-9));
      expect(adapted.a, closeTo(direct.a, 1e-9));
      expect(adapted.b, closeTo(direct.b, 1e-9));
    });

    test('warm white pulls a gray sample toward neutral Lab', () {
      // Warm tungsten-ish photo white (high R, low B).
      const warmWhite = (1.0, 0.82, 0.55);
      // A surface that looks the same as that white in the photo — a gray card.
      final unadapted = Colorimetry.srgbToLab(
        warmWhite.$1,
        warmWhite.$2,
        warmWhite.$3,
      );
      final adapted = srgbToLabAdapted(warmWhite, whiteReference: warmWhite);

      expect(adapted.a.abs(), lessThan(unadapted.a.abs()));
      expect(adapted.b.abs(), lessThan(unadapted.b.abs()));
      expect(adapted.a.abs(), lessThan(2.0));
      expect(adapted.b.abs(), lessThan(2.0));
    });

    test('near-black white reference falls back to unadapted', () {
      const sample = (0.4, 0.3, 0.2);
      final adapted = srgbToLabAdapted(
        sample,
        whiteReference: (0.0, 0.0, 0.0),
      );
      final direct = Colorimetry.srgbToLab(sample.$1, sample.$2, sample.$3);

      expect(adapted.l, closeTo(direct.l, 1e-9));
      expect(adapted.a, closeTo(direct.a, 1e-9));
    });
  });
}
