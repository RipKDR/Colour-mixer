import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/engine/mix_solver.dart';

PigmentModel _pigment(
  String id,
  String name,
  List<double> reflectance, {
  double opacity = 0.9,
}) {
  final lab = Colorimetry.spectrumToLab(reflectance);
  final srgb = Colorimetry.spectrumToSrgb(reflectance);
  return PigmentModel(
    id: id,
    name: name,
    pigmentCodes: const [],
    reflectance: reflectance,
    opacity: opacity,
    tintingStrength: 1.0,
    toxicity: 'low',
    binder: 'acrylic',
    lab: lab,
    color: Color.fromARGB(
      255,
      (srgb.$1 * 255).round(),
      (srgb.$2 * 255).round(),
      (srgb.$3 * 255).round(),
    ),
  );
}

ChromaEngine _testEngine() {
  final blue = _pigment(
    'blue',
    'Blue',
    List.generate(41, (i) {
      final wl = 380.0 + i * 10;
      return wl < 500 ? 0.6 - (wl - 380) / 600 : 0.08;
    }),
  );
  final yellow = _pigment(
    'yellow',
    'Yellow',
    List.generate(41, (i) {
      final wl = 380.0 + i * 10;
      return wl > 520 ? 0.7 : 0.1;
    }),
  );
  final white = _pigment('titanium_white', 'White', List.filled(41, 0.95));
  return ChromaEngine({
    'blue': blue,
    'yellow': yellow,
    'titanium_white': white,
  });
}

void main() {
  group('MixSolver', () {
    test('recovers ratios for a reachable green target', () {
      final engine = _testEngine();
      // Target: known 1:1 blue+yellow mix.
      final target = engine.mix([
        const MixComponent(pigmentId: 'blue', weight: 1),
        const MixComponent(pigmentId: 'yellow', weight: 1),
      ]).lab;

      final solution = MixSolver(engine).solve(target);

      expect(solution, isNotNull);
      expect(solution!.deltaE, lessThan(2.0));
      expect(solution.components, isNotEmpty);
      expect(solution.components.length, lessThanOrEqualTo(4));
    });

    test('solution components have positive normalized weights', () {
      final engine = _testEngine();
      final solution = MixSolver(engine).solve(const LabColor(70, 5, 15));

      expect(solution, isNotNull);
      final total = solution!.components.fold<double>(0, (s, c) => s + c.weight);
      expect(total, closeTo(1.0, 0.001));
      for (final c in solution.components) {
        expect(c.weight, greaterThan(0));
      }
    });

    test('returns null when no pigments available', () {
      final empty = ChromaEngine(const {});
      expect(MixSolver(empty).solve(const LabColor(50, 0, 0)), isNull);
    });

    test('restrictTo limits suggestions to owned pigments', () {
      final engine = _testEngine();
      // Green target normally needs blue+yellow; restrict to yellow+white.
      final target = engine.mix([
        const MixComponent(pigmentId: 'blue', weight: 1),
        const MixComponent(pigmentId: 'yellow', weight: 1),
      ]).lab;

      final solution = MixSolver(engine).solve(
        target,
        restrictTo: {'yellow', 'titanium_white'},
      );

      expect(solution, isNotNull);
      for (final c in solution!.components) {
        expect(['yellow', 'titanium_white'], contains(c.pigmentId));
      }
    });

    test('restrictTo with no matching pigments returns null', () {
      final engine = _testEngine();
      final solution = MixSolver(engine).solve(
        const LabColor(50, 0, 0),
        restrictTo: {'nonexistent'},
      );
      expect(solution, isNull);
    });

    test('solveMixRequest entry point works via compute', () async {
      final engine = _testEngine();
      final request = SolveRequest(
        pigments: {for (final p in engine.allPigments) p.id: p},
        target: const LabColor(70, 5, 15),
      );

      final suggestions = await compute(solveMixRequest, request);

      expect(suggestions, isNotEmpty);
      expect(suggestions.first.components, isNotEmpty);
    });
  });

  group('MixSolver alternatives', () {
    test('solveAlternatives returns up to 3 diverse suggestions', () {
      final engine = _testEngine();
      final target = engine.mix([
        const MixComponent(pigmentId: 'blue', weight: 1),
        const MixComponent(pigmentId: 'yellow', weight: 1),
      ]).lab;

      final suggestions = MixSolver(engine).solveAlternatives(target);

      expect(suggestions, isNotEmpty);
      expect(suggestions.length, lessThanOrEqualTo(3));
      // Each alternative uses a distinct pigment set.
      final sets = suggestions
          .map((s) => (s.components.map((c) => c.pigmentId).toList()..sort())
              .join('+'))
          .toSet();
      expect(sets.length, suggestions.length);
    });

    test('alternatives are ranked best-first by penalised score', () {
      final engine = _testEngine();
      final suggestions =
          MixSolver(engine).solveAlternatives(const LabColor(70, 5, 15));

      for (var i = 1; i < suggestions.length; i++) {
        expect(
          suggestions[i - 1].score,
          lessThanOrEqualTo(suggestions[i].score),
        );
      }
    });

    test('prefers fewer pigments when deltaE is comparable', () {
      final engine = _testEngine();
      // Target is exactly the yellow masstone: a 1-pigment recipe is
      // available, so the penalty must rank it above any multi-pigment
      // recipe that only marginally improves deltaE.
      final yellowLab = engine.mix([
        const MixComponent(pigmentId: 'yellow', weight: 1),
      ]).lab;

      final best = MixSolver(engine).solve(yellowLab);

      expect(best, isNotNull);
      expect(best!.components.length, 1);
      expect(best.components.single.pigmentId, 'yellow');
    });

    test('suggestion exposes weighted opacity and translucency flag', () {
      final glazeLike = _pigment(
        'glaze',
        'Glaze',
        List.generate(41, (i) => 0.5),
        opacity: 0.3,
      );
      final engine = ChromaEngine({'glaze': glazeLike});

      final best = MixSolver(engine).solve(glazeLike.lab);

      expect(best, isNotNull);
      expect(best!.opacity, closeTo(0.3, 0.001));
      expect(best.isTranslucent, isTrue);
    });

    test('opaque single-pigment suggestion is not flagged translucent', () {
      final engine = _testEngine();
      final best = MixSolver(engine).solve(
        engine.mix([
          const MixComponent(pigmentId: 'titanium_white', weight: 1),
        ]).lab,
      );

      expect(best, isNotNull);
      expect(best!.opacity, closeTo(0.9, 0.01));
      expect(best.isTranslucent, isFalse);
    });
  });
}
