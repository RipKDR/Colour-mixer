import 'chroma_engine.dart';

/// Serializable request so the solver can run in a background isolate
/// via [compute].
class SolveRequest {
  const SolveRequest({
    required this.pigments,
    required this.target,
    this.restrictTo,
    this.maxPigments = 3,
  });

  final Map<String, PigmentModel> pigments;
  final LabColor target;
  final Set<String>? restrictTo;
  final int maxPigments;
}

/// Top-level entry point for `compute()`.
MixSuggestion? solveMixRequest(SolveRequest request) {
  return MixSolver(ChromaEngine(request.pigments)).solve(
    request.target,
    maxPigments: request.maxPigments,
    restrictTo: request.restrictTo,
  );
}

class MixSuggestion {
  const MixSuggestion({
    required this.components,
    required this.deltaE,
    required this.result,
  });

  /// Normalized components (weights sum to 1.0).
  final List<MixComponent> components;
  final double deltaE;
  final MixResult result;
}

/// Suggests pigment recipes matching a target Lab colour using the
/// spectral engine. Searches small pigment subsets and refines weights
/// with coordinate descent on CIEDE2000.
class MixSolver {
  MixSolver(this._engine);

  final ChromaEngine _engine;

  /// [restrictTo] limits the search to the given pigment ids (e.g. the
  /// user's inventory). Null means all pigments are available.
  MixSuggestion? solve(
    LabColor target, {
    int maxPigments = 3,
    Set<String>? restrictTo,
  }) {
    var pigments = _engine.allPigments;
    if (restrictTo != null) {
      pigments = pigments.where((p) => restrictTo.contains(p.id)).toList();
    }
    if (pigments.isEmpty) return null;

    // Rank pigments by single-pigment closeness to the target.
    final ranked = [...pigments]..sort((a, b) {
        final da = Colorimetry.ciede2000(a.lab, target);
        final db = Colorimetry.ciede2000(b.lab, target);
        return da.compareTo(db);
      });
    final pool = ranked.take(8).toList();

    MixSuggestion? best;

    void consider(List<PigmentModel> subset) {
      final refined = _refineWeights(subset, target);
      if (best == null || refined.deltaE < best!.deltaE) {
        best = refined;
      }
    }

    for (var i = 0; i < pool.length; i++) {
      consider([pool[i]]);
      if (maxPigments < 2) continue;
      for (var j = i + 1; j < pool.length; j++) {
        consider([pool[i], pool[j]]);
        if (maxPigments < 3) continue;
        for (var k = j + 1; k < pool.length; k++) {
          consider([pool[i], pool[j], pool[k]]);
        }
      }
    }

    return best;
  }

  MixSuggestion _refineWeights(List<PigmentModel> subset, LabColor target) {
    var weights = List<double>.filled(subset.length, 1.0);

    double evaluate(List<double> w) {
      final components = [
        for (var i = 0; i < subset.length; i++)
          MixComponent(pigmentId: subset[i].id, weight: w[i]),
      ];
      final mixed = _engine.mix(components);
      return Colorimetry.ciede2000(mixed.lab, target);
    }

    var bestScore = evaluate(weights);

    // Multiplicative coordinate descent with a shrinking step.
    var step = 2.0;
    for (var round = 0; round < 6; round++) {
      var improved = false;
      for (var i = 0; i < weights.length; i++) {
        for (final factor in [step, 1 / step]) {
          final trial = [...weights];
          trial[i] = (trial[i] * factor).clamp(0.01, 100.0);
          final score = evaluate(trial);
          if (score < bestScore) {
            bestScore = score;
            weights = trial;
            improved = true;
          }
        }
      }
      if (!improved) {
        step *= 0.6;
        if (step <= 1.05) break;
      }
    }

    final total = weights.fold<double>(0, (s, w) => s + w);
    final components = [
      for (var i = 0; i < subset.length; i++)
        MixComponent(pigmentId: subset[i].id, weight: weights[i] / total),
    ];
    final result = _engine.mix(components);
    return MixSuggestion(
      components: components,
      deltaE: Colorimetry.ciede2000(result.lab, target),
      result: result,
    );
  }
}
