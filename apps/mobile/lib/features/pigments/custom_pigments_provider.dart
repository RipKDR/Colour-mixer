import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/chroma_engine.dart';
import '../recipes/database.dart';

final customPigmentsRefreshProvider = StateProvider<int>((ref) => 0);

PigmentModel customPigmentToModel(CustomPigment row) {
  final reflectance = (jsonDecode(row.reflectanceJson) as List)
      .map((v) => (v as num).toDouble())
      .toList();
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
  return rows.map(customPigmentToModel).toList();
});

void refreshCustomPigments(WidgetRef ref) {
  ref.read(customPigmentsRefreshProvider.notifier).state++;
}
