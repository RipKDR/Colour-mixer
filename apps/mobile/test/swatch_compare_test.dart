import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/features/match/color_match.dart';
import 'package:chromastudio/features/swatch/swatch_compare.dart';

ByteData _solidRgba(int width, int height, int r, int g, int b) {
  final data = Uint8List(width * height * 4);
  for (var i = 0; i < width * height; i++) {
    final o = i * 4;
    data[o] = r;
    data[o + 1] = g;
    data[o + 2] = b;
    data[o + 3] = 255;
  }
  return ByteData.sublistView(data);
}

void main() {
  group('sampleLabFromRgba', () {
    test('uniform colour returns that colour in Lab', () {
      final pixels = _solidRgba(50, 50, 200, 40, 40);
      final lab = sampleLabFromRgba(pixels, 50, 50, 25, 25);

      final expected = Colorimetry.srgbToLab(200 / 255, 40 / 255, 40 / 255);
      expect(lab.l, closeTo(expected.l, 0.5));
      expect(lab.a, closeTo(expected.a, 0.5));
      expect(lab.b, closeTo(expected.b, 0.5));
    });

    test('larger radius smooths a noisy neighbourhood', () {
      final data = Uint8List(20 * 20 * 4);
      for (var y = 0; y < 20; y++) {
        for (var x = 0; x < 20; x++) {
          final o = (y * 20 + x) * 4;
          final v = (x + y) % 2 == 0 ? 200 : 180;
          data[o] = v;
          data[o + 1] = v;
          data[o + 2] = v;
          data[o + 3] = 255;
        }
      }
      final pixels = ByteData.sublistView(data);
      final small = sampleLabFromRgba(pixels, 20, 20, 10, 10, radius: 0);
      final large = sampleLabFromRgba(pixels, 20, 20, 10, 10, radius: 3);

      expect(large.l, isNot(small.l));
      expect(large.l, closeTo(75, 8));
    });

    test('edge tap clamps window without throwing', () {
      final pixels = _solidRgba(10, 10, 100, 150, 200);
      final lab = sampleLabFromRgba(pixels, 10, 10, 0, 0, radius: 7);

      expect(lab.l, greaterThan(0));
    });
  });

  group('SwatchComparison', () {
    test('identical Lab yields near-zero deltaE', () {
      const lab = LabColor(55, 10, -20);
      final cmp = SwatchComparison.compare(
        swatchLab: lab,
        referenceLab: lab,
      );

      expect(cmp.deltaE, lessThan(0.01));
      expect(cmp.verdict, SwatchVerdict.imperceptible);
    });

    test('verdict tiers at boundary values', () {
      expect(verdictForDeltaE(0.5), SwatchVerdict.imperceptible);
      expect(verdictForDeltaE(1.5), SwatchVerdict.excellent);
      expect(verdictForDeltaE(3.0), SwatchVerdict.good);
      expect(verdictForDeltaE(7.0), SwatchVerdict.visible);
      expect(verdictForDeltaE(12.0), SwatchVerdict.far);
    });

    test('swatchVerdictLabel matches matchScoreLabel thresholds', () {
      expect(
        swatchVerdictLabel(SwatchVerdict.excellent),
        matchScoreLabel(1.5),
      );
      expect(
        swatchVerdictLabel(SwatchVerdict.good),
        matchScoreLabel(3.0),
      );
    });
  });
}
