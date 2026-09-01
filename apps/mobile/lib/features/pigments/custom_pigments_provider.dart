import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/chroma_engine.dart';
import '../recipes/database.dart';

final customPigmentsRefreshProvider = StateProvider<int>((ref) => 0);

List<double> parseCustomReflectance(String reflectanceJson, {String id = ''}) {
  Object? decoded;
  try {
    decoded = jsonDecode(reflectanceJson);
  } catch (e) {
    throw FormatException(
      'Custom pigment "$id" reflectanceJson is not valid JSON: $e',
    );
  }
  if (decoded is! List) {
    throw FormatException(
      'Custom pigment "$id" reflectanceJson must be a JSON array',
    );
  }
  final reflectance = <double>[];
  for (var i = 0; i < decoded.length; i++) {
    final raw = decoded[i];
    if (raw is! num) {
      throw FormatException(
        'Custom pigment "$id" reflectance[$i] must be a number, got $raw',
      );
    }
    reflectance.add(raw.toDouble());
  }
  const n = Colorimetry.spectrumSamples;
  if (reflectance.length != n) {
    throw FormatException(
      'Custom pigment "$id" reflectance must have $n samples, '
      'got ${reflectance.length}',
    );
  }
  for (var i = 0; i < n; i++) {
    final v = reflectance[i];
    if (!v.isFinite || v < 0 || v > 1) {
      throw FormatException(
        'Custom pigment "$id" reflectance[$i] must be finite in 0..1, got $v',
      );
    }
  }
  return reflectance;
}

PigmentModel customPigmentToModel(CustomPigment row) {
  final reflectance = parseCustomReflectance(row.reflectanceJson, id: row.id);
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

/// Last successfully loaded custom pigments. Unchanged when a reload fails,
/// so mix/engine overlays do not drop paints the user already mixed with.
class UsableCustomPigments extends StateNotifier<List<PigmentModel>> {
  UsableCustomPigments() : super(const []);

  void accept(List<PigmentModel> next) => state = next;
}

final usableCustomPigmentsProvider =
    StateNotifierProvider<UsableCustomPigments, List<PigmentModel>>((ref) {
  final notifier = UsableCustomPigments();
  ref.listen<AsyncValue<List<PigmentModel>>>(
    customPigmentModelsProvider,
    (previous, next) {
      next.whenData(notifier.accept);
    },
    fireImmediately: true,
  );
  return notifier;
});

void refreshCustomPigments(WidgetRef ref) {
  ref.read(customPigmentsRefreshProvider.notifier).state++;
}
