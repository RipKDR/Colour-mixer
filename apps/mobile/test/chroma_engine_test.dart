import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';

void main() {
  group('ChromaEngine', () {
    late ChromaEngine engine;

    setUp(() {
      engine = ChromaEngine({
        'blue': PigmentModel(
          id: 'blue',
          name: 'Blue',
          pigmentCodes: ['PB29'],
          reflectance: List.generate(41, (i) {
            final wl = 380.0 + i * 10;
            return wl < 500 ? 0.6 - (wl - 380) / 600 : 0.08;
          }),
          opacity: 0.9,
          tintingStrength: 1.0,
          toxicity: 'low',
          binder: 'acrylic',
          lab: const LabColor(30, 10, -50),
          color: const Color(0xFF2244AA),
        ),
        'yellow': PigmentModel(
          id: 'yellow',
          name: 'Yellow',
          pigmentCodes: ['PY74'],
          reflectance: List.generate(41, (i) {
            final wl = 380.0 + i * 10;
            return wl > 520 ? 0.7 : 0.1;
          }),
          opacity: 0.9,
          tintingStrength: 1.0,
          toxicity: 'low',
          binder: 'acrylic',
          lab: const LabColor(85, -5, 80),
          color: const Color(0xFFFFDD00),
        ),
        'titanium_white': PigmentModel(
          id: 'titanium_white',
          name: 'White',
          pigmentCodes: ['PW6'],
          reflectance: List.filled(41, 0.95),
          opacity: 1.0,
          tintingStrength: 0.3,
          toxicity: 'low',
          binder: 'acrylic',
          lab: const LabColor(98, 0, 0),
          color: const Color(0xFFFFFFFF),
        ),
      });
    });

    test('blue and yellow mix produces green', () {
      final result = engine.mix([
        const MixComponent(pigmentId: 'blue', weight: 1),
        const MixComponent(pigmentId: 'yellow', weight: 1),
      ]);
      expect(result.color.g, greaterThan(result.color.r));
      expect(result.color.g, greaterThan(result.color.b));
    });

    test('white tints colour', () {
      final pure = engine.mix([
        const MixComponent(pigmentId: 'blue', weight: 1),
      ]);
      final tinted = engine.mix([
        const MixComponent(pigmentId: 'blue', weight: 1),
        const MixComponent(pigmentId: 'titanium_white', weight: 1),
      ]);
      expect(tinted.lab.l, greaterThan(pure.lab.l));
    });

    test('formatRatios produces valid output', () {
      final ratios = formatRatios([1, 2, 1], QuantityUnit.parts);
      expect(ratios.length, 3);
      expect(ratios[1].percent, contains('%'));
    });
  });

  group('Colorimetry', () {
    test('white spectrum has high L', () {
      final lab = Colorimetry.spectrumToLab(List.filled(41, 0.95));
      expect(lab.l, greaterThan(90));
    });

    test('K/S roundtrip', () {
      const r = 0.5;
      final ks = Colorimetry.reflectanceToKs(r);
      final r2 = Colorimetry.ksToReflectance(ks);
      expect((r - r2).abs(), lessThan(0.01));
    });
  });
}
