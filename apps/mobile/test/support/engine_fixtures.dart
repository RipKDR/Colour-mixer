import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/engine/native_engine.dart';
import 'package:chromastudio/features/pigments/custom_pigments_provider.dart';

PigmentModel testPigment(
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

ChromaEngine testChromaEngine() {
  final blue = testPigment(
    'blue',
    'Blue',
    List.generate(41, (i) {
      final wl = 380.0 + i * 10;
      return wl < 500 ? 0.6 - (wl - 380) / 600 : 0.08;
    }),
  );
  final yellow = testPigment(
    'yellow',
    'Yellow',
    List.generate(41, (i) {
      final wl = 380.0 + i * 10;
      return wl > 520 ? 0.7 : 0.1;
    }),
  );
  final white = testPigment('titanium_white', 'White', List.filled(41, 0.95));
  return ChromaEngine({
    'blue': blue,
    'yellow': yellow,
    'titanium_white': white,
  });
}

Future<DartEngineBackend> testEngineBackend() async {
  return DartEngineBackend(testChromaEngine());
}

Future<ChromaEngine> testEngineWithAllPigments() async {
  final jsonStr =
      await rootBundle.loadString('assets/pigments/all_pigments.json');
  final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
  final pigments = {
    for (final item in list) item['id'] as String: PigmentModel.fromJson(item),
  };
  return ChromaEngine(pigments);
}

/// Avoids opening Drift/SQLite in widget tests that construct a mix session.
Override emptyCustomPigmentsOverride() =>
    customPigmentModelsProvider.overrideWith((ref) async => []);
