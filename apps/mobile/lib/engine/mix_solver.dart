import 'chroma_engine.dart';

/// Serializable request so the solver can run in a background isolate
/// via [compute].
class SolveRequest {
  const SolveRequest({
    required this.pigments,
    required this.target,
    this.restrictTo,
    this.maxPigments = 3,
    this.maxAlternatives = 3,
  });

  final Map<String, PigmentModel> pigments;
  final LabColor target;
  final Set<String>? restrictTo;
  final int maxPigments;
  final int maxAlternatives;
}

/// Top-level entry point for `compute()`. Returns ranked alternatives,
/// best first (empty when no pigments are available).
List<MixSuggestion> solveMixRequest(SolveRequest request) {
  return MixSolver(ChromaEngine(request.pigments)).solveAlternatives(
    request.target,
    maxPigments: request.maxPigments,
    maxAlternatives: request.maxAlternatives,
    restrictTo: request.restrictTo,
  );
}

class MixSuggestion {
  const MixSuggestion({
    required this.components,
    required this.deltaE,
    required this.result,
    required this.opacity,
    required this.score,
  });

  /// Normalized components (weights sum to 1.0).
  final List<MixComponent> components;
  final double deltaE;
  final MixResult result;

  /// Weight-averaged opacity of the recipe (0 transparent .. 1 opaque).
  final double opacity;

  /// Ranking score: deltaE plus a penalty per extra pigment, so simpler
  /// recipes win when the colour match is comparable.
  final double score;

  /// Recipes below this opacity read as glazes rather than body colour.
  bool get isTranslucent => opacity < 0.75;
}

/// Suggests pigment recipes matching a target Lab colour using the
/// spectral engine. Searches small pigment subsets, refines weights with
/// coordinate descent on CIEDE2000, and ranks candidates by
/// deltaE + pigment-count penalty.
class MixSolver {
  MixSolver(this._engine);

  final ChromaEngine _engine;

  /// Extra score added per pigment beyond the first. Keeps the solver from
  /// preferring a marginal deltaE gain at the cost of a fussier recipe.
  static const double pigmentCountPenalty = 0.4;

  /// Best single suggestion, or null when no pigments are available.
  MixSuggestion? solve(
    LabColor target, {
    int maxPigments = 3,
    Set<String>? restrictTo,
  }) {
    final all = solveAlternatives(
      target,
      maxPigments: maxPigments,
      maxAlternatives: 1,
      restrictTo: restrictTo,
    );
    return all.isEmpty ? null : all.first;
  }

  /// Up to [maxAlternatives] suggestions with distinct pigment sets,
  /// ranked best-first by [MixSuggestion.score].
  ///
  /// [restrictTo] limits the search to the given pigment ids (e.g. the
  /// user's inventory). Null means all pigments are available.
  List<MixSuggestion> solveAlternatives(
    LabColor target, {
    int maxPigments = 3,
    int maxAlternatives = 3,
    Set<String>? restrictTo,
  }) {
    var pigments = _engine.allPigments;
    if (restrictTo != null) {
      pigments = pigments.where((p) => restrictTo.contains(p.id)).toList();
    }
    if (pigments.isEmpty) return const [];

    // Rank pigments by single-pigment closeness to the target.
    final ranked = [...pigments]..sort((a, b) {
        final da = Colorimetry.ciede2000(a.lab, target);
        final db = Colorimetry.ciede2000(b.lab, target);
        return da.compareTo(db);
      });
    final pool = ranked.take(8).toList();

    // Best refined suggestion per distinct pigment set.
    final bySet = <String, MixSuggestion>{};

    void consider(List<PigmentModel> subset) {
      final refined = _refineWeights(subset, target);
      final key = (refined.components.map((c) => c.pigmentId).toList()..sort())
          .join('+');
      final existing = bySet[key];
      if (existing == null || refined.score < existing.score) {
        bySet[key] = refined;
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

    final rankedSuggestions = bySet.values.toList()
      ..sort((a, b) => a.score.compareTo(b.score));
    return rankedSuggestions.take(maxAlternatives).toList();
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
    final deltaE = Colorimetry.ciede2000(result.lab, target);
    var opacity = 0.0;
    for (var i = 0; i < subset.length; i++) {
      opacity += (weights[i] / total) * subset[i].opacity;
    }
    return MixSuggestion(
      components: components,
      deltaE: deltaE,
      result: result,
      opacity: opacity,
      score: deltaE + pigmentCountPenalty * (subset.length - 1),
    );
  }
}
