import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'support/engine_fixtures.dart';

void main() {
  group('Dart↔Rust parity tests', () {
    late ChromaEngine engine;

    setUpAll(() async {
      engine = await testEngineWithAllPigments();
    });

    test('blue_yellow_mix_produces_green_both_sides', () {
      // This test exercises the same mix on the Dart side that the Rust
      // integration test verifies: ultramarine_blue (1:1) + hansa_yellow.
      // Both engines must produce:
      // - Green-dominant sRGB (G > R, G > B)
      // - Negative a* (green in Lab)
      // - Finite, in-range reflectance (41 samples)
      //
      // The test runs pure Dart (no FFI), so it passes in CI.
      final result = engine.mix([
        MixComponent(pigmentId: 'ultramarine_blue', weight: 1.0),
        MixComponent(pigmentId: 'hansa_yellow', weight: 1.0),
      ]);

      // Color properties: green should dominate.
      expect(result.color.g, greaterThan(result.color.r));
      expect(result.color.g, greaterThan(result.color.b));

      // Lab: negative a* indicates green.
      expect(result.lab.a, lessThan(0.0));

      // Reflectance: must be 41 samples, all finite, all in [0, 1].
      expect(result.reflectance.length, equals(41));
      for (var i = 0; i < result.reflectance.length; i++) {
        final r = result.reflectance[i];
        expect(r.isFinite, true, reason: 'sample $i not finite');
        expect(r, greaterThanOrEqualTo(0.0), reason: 'sample $i < 0');
        expect(r, lessThanOrEqualTo(1.0), reason: 'sample $i > 1');
      }

      // Reflectance is not all zeros (pigment mixing should produce real data).
      final hasContent = result.reflectance.any((r) => r > 0.01);
      expect(hasContent, true);
    });

    test('blue_red_mix_produces_valid_mixed_result', () {
      final blue = engine.mix([
        MixComponent(pigmentId: 'ultramarine_blue', weight: 1.0),
      ]);
      final red = engine.mix([
        MixComponent(pigmentId: 'cadmium_red_light', weight: 1.0),
      ]);
      final result = engine.mix([
        MixComponent(pigmentId: 'ultramarine_blue', weight: 1.0),
        MixComponent(pigmentId: 'cadmium_red_light', weight: 1.0),
      ]);

      expect(result.reflectance.length, equals(41));
      for (var i = 0; i < result.reflectance.length; i++) {
        final r = result.reflectance[i];
        expect(r.isFinite, true, reason: 'sample $i not finite');
        expect(r, greaterThanOrEqualTo(0.0), reason: 'sample $i < 0');
        expect(r, lessThanOrEqualTo(1.0), reason: 'sample $i > 1');
      }

      expect(result.reflectance.any((r) => r > 0.01), isTrue);
      expect(
        result.lab.l != blue.lab.l ||
            result.lab.a != blue.lab.a ||
            result.lab.b != blue.lab.b,
        isTrue,
      );
      expect(
        result.lab.l != red.lab.l ||
            result.lab.a != red.lab.a ||
            result.lab.b != red.lab.b,
        isTrue,
      );
    });

    test('pure_pigment_mix_reproduces_its_own_masstone', () {
      // Reproduces Rust test: a mix of just one pigment (at 1.0 weight)
      // should reproduce that pigment's own Lab values within tolerance.
      // Tests: tinting strength normalization works the same way.
      const tolerance = 0.01;
      final testPigmentIds = [
        'titanium_white',
        'ivory_black',
        'cadmium_red_light',
      ];

      for (final id in testPigmentIds) {
        final pigment = engine.getPigment(id);
        expect(pigment, isNotNull, reason: 'pigment $id not found');

        final mixed = engine.mix([
          MixComponent(pigmentId: id, weight: 1.0),
        ]);

        final direct = Colorimetry.spectrumToLab(pigment!.reflectance);

        expect(mixed.lab.l, closeTo(direct.l, tolerance));
        expect(mixed.lab.a, closeTo(direct.a, tolerance));
        expect(mixed.lab.b, closeTo(direct.b, tolerance));
      }
    });

    test('white_tints_color_increases_lightness', () {
      // Reproduces Rust test: adding white should increase L*.
      const pureId = 'cadmium_red_light';
      final pure = engine.mix([
        MixComponent(pigmentId: pureId, weight: 1.0),
      ]);

      final tinted = engine.mix([
        MixComponent(pigmentId: pureId, weight: 1.0),
        MixComponent(pigmentId: 'titanium_white', weight: 1.0),
      ]);

      expect(tinted.lab.l, greaterThan(pure.lab.l));
    });

    test('mixing_empty_list_returns_neutral_gray', () {
      // Edge case: empty mix should return neutral mid-gray (L=50, a=0, b=0).
      final result = engine.mix([]);
      expect(result.lab.l, closeTo(50.0, 0.1));
      expect(result.lab.a, closeTo(0.0, 0.1));
      expect(result.lab.b, closeTo(0.0, 0.1));
    });

    test('missing_pigment_skipped_gracefully', () {
      // Mixing with a non-existent pigment ID should skip it and mix the rest.
      final result = engine.mix([
        MixComponent(pigmentId: 'ultramarine_blue', weight: 1.0),
        MixComponent(pigmentId: 'nonexistent_pigment', weight: 1.0),
      ]);

      // Should equal just pure blue.
      final pureBlue = engine.mix([
        MixComponent(pigmentId: 'ultramarine_blue', weight: 1.0),
      ]);

      const tolerance = 0.01;
      expect(result.lab.l, closeTo(pureBlue.lab.l, tolerance));
      expect(result.lab.a, closeTo(pureBlue.lab.a, tolerance));
      expect(result.lab.b, closeTo(pureBlue.lab.b, tolerance));
    });
  });
}
