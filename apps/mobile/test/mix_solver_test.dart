import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/engine/mix_solver.dart';

PigmentModel _pigment(String id, String name, List<double> reflectance) {
  final lab = Colorimetry.spectrumToLab(reflectance);
  final srgb = Colorimetry.spectrumToSrgb(reflectance);
  return PigmentModel(
    id: id,
    name: name,
    pigmentCodes: const [],
    reflectance: reflectance,
    opacity: 0.9,
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

      final suggestion = await compute(solveMixRequest, request);

      expect(suggestion, isNotNull);
      expect(suggestion!.components, isNotEmpty);
    });
  });
}
