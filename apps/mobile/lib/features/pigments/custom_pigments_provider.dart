import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/chroma_engine.dart';
import '../recipes/database.dart';

final customPigmentsRefreshProvider = StateProvider<int>((ref) => 0);

void validateCustomReflectance(List<double> reflectance, {String? pigmentId}) {
  final label =
      pigmentId == null ? 'custom pigment' : 'custom pigment $pigmentId';
  if (reflectance.length != Colorimetry.spectrumSamples) {
    throw FormatException(
      '$label: expected ${Colorimetry.spectrumSamples} samples, '
      'got ${reflectance.length}',
    );
  }
  for (var i = 0; i < reflectance.length; i++) {
    final r = reflectance[i];
    if (!r.isFinite || r < 0 || r > 1) {
      throw FormatException(
        '$label: sample $i is $r (need finite values in 0..1)',
      );
    }
  }
}

List<PigmentModel> customPigmentModelsFromRows(List<CustomPigment> rows) {
  final models = <PigmentModel>[];
  for (final row in rows) {
    try {
      models.add(customPigmentToModel(row));
    } catch (e) {
      debugPrint('ChromaStudio: skipping custom pigment ${row.id}: $e');
    }
  }
  return models;
}

PigmentModel customPigmentToModel(CustomPigment row) {
  final reflectance = (jsonDecode(row.reflectanceJson) as List)
      .map((v) => (v as num).toDouble())
      .toList();
  validateCustomReflectance(reflectance, pigmentId: row.id);
  final lab = Colorimetry.spectrumToLab(reflectance);
  final srgb = Colorimetry.spectrumToSrgb(reflectance);
  return PigmentModel(
    id: row.id,
    name: row.name,
    pigmentCodes: const ['custom'],
    reflectance: reflectance,
    opacity: row.opacity,
    tintingStrength: row.tintingStrength,
    toxicity: 'unknown',
    binder: row.binder,
    lab: lab,
    color: Colorimetry.srgbToColor(srgb),
  );
}

final customPigmentModelsProvider =
    FutureProvider<List<PigmentModel>>((ref) async {
  ref.watch(customPigmentsRefreshProvider);
  final rows = await ref.watch(databaseProvider).getAllCustomPigments();
  return customPigmentModelsFromRows(rows);
});

void refreshCustomPigments(WidgetRef ref) {
  ref.read(customPigmentsRefreshProvider.notifier).state++;
}
