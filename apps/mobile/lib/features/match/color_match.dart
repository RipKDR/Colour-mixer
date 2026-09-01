import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/chroma_engine.dart';
import '../../engine/mix_session.dart';

class ColorTarget {
  const ColorTarget({required this.lab, this.name});

  final LabColor lab;
  final String? name;

  ColorTarget copyWith({LabColor? lab, String? name}) =>
      ColorTarget(lab: lab ?? this.lab, name: name ?? this.name);
}

class MatchAnalysis {
  const MatchAnalysis({
    required this.deltaE,
    required this.target,
    required this.current,
    required this.isMetamericRisk,
    required this.maxIlluminantDeltaE,
  });

  final double deltaE;
  final LabColor target;
  final LabColor? current;
  final bool isMetamericRisk;
  final double maxIlluminantDeltaE;
}

final colorTargetProvider = StateProvider<ColorTarget?>((ref) => null);

final matchAnalysisProvider = Provider<MatchAnalysis?>((ref) {
  final target = ref.watch(colorTargetProvider);
  final result = ref.watch(mixSessionProvider).result;
  if (target == null || result == null) return null;

  final deltaE = Colorimetry.ciede2000(result.lab, target.lab);

  var maxShift = 0.0;
  for (final illuminant in Illuminant.values) {
    if (illuminant == Illuminant.d65) continue;
    final under = Colorimetry.spectrumToLabUnder(result.reflectance, illuminant);
    final shift = Colorimetry.ciede2000(result.lab, under);
    if (shift > maxShift) maxShift = shift;
  }

  return MatchAnalysis(
    deltaE: deltaE,
    target: target.lab,
    current: result.lab,
    isMetamericRisk: maxShift > 4.0,
    maxIlluminantDeltaE: maxShift,
  );
});

/// Parse ChromaStudio recipe JSON (v1) for import.
class ParsedRecipe {
  const ParsedRecipe({
    required this.name,
    required this.notes,
    required this.entries,
    required this.labL,
    required this.labA,
    required this.labB,
    required this.colorValue,
  });

  final String name;
  final String notes;
  final List<MixEntry> entries;
  final double labL;
  final double labA;
  final double labB;
  final int colorValue;
}

ParsedRecipe? parseRecipeJson(String raw) {
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    if (map['format'] != 'chromastudio-recipe-v1') return null;

    final pigments = (map['pigments'] as List).cast<Map<String, dynamic>>();
    final entries = pigments
        .map(
          (p) => MixEntry(
            pigmentId: p['id'] as String,
            weight: (p['weight'] as num).toDouble(),
          ),
        )
        .toList();

    final lab = map['lab'] as Map<String, dynamic>?;
    return ParsedRecipe(
      name: map['name'] as String? ?? 'Imported recipe',
      notes: map['notes'] as String? ?? '',
      entries: entries,
      labL: (lab?['L'] as num?)?.toDouble() ?? 50,
      labA: (lab?['a'] as num?)?.toDouble() ?? 0,
      labB: (lab?['b'] as num?)?.toDouble() ?? 0,
      colorValue: map['colorArgb'] as int? ?? 0xFF808080,
    );
  } catch (_) {
    return null;
  }
}

String matchScoreLabel(double deltaE) {
  if (deltaE < 1) return 'Imperceptible difference';
  if (deltaE < 2) return 'Excellent match';
  if (deltaE < 5) return 'Good — acceptable for most work';
  if (deltaE < 10) return 'Visible difference — keep adjusting';
  return 'Far from target';
}
