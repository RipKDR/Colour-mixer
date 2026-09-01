import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/features/pigments/custom_pigments_provider.dart';
import 'package:chromastudio/features/recipes/database.dart';

CustomPigment _row(String reflectanceJson) {
  return CustomPigment(
    id: 'custom_test',
    name: 'Studio Grey',
    reflectanceJson: reflectanceJson,
    opacity: 0.8,
    tintingStrength: 1.1,
    binder: 'oil',
    createdAt: DateTime.utc(2026, 9, 1),
  );
}

void main() {
  test('customPigmentToModel rebuilds a PigmentModel from a stored row', () {
    final model = customPigmentToModel(
      _row(jsonEncode(List.filled(Colorimetry.spectrumSamples, 0.5))),
    );

    expect(model.id, 'custom_test');
    expect(model.name, 'Studio Grey');
    expect(model.binder, 'oil');
    expect(model.opacity, 0.8);
    expect(model.reflectance, hasLength(Colorimetry.spectrumSamples));
  });

  test('customPigmentToModel rejects a spectrum that is not 41 samples', () {
    expect(
      () => customPigmentToModel(_row(jsonEncode(List.filled(80, 0.5)))),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => customPigmentToModel(_row(jsonEncode(List.filled(10, 0.5)))),
      throwsA(isA<FormatException>()),
    );
  });

  test('customPigmentToModel rejects non-numeric or out-of-range samples', () {
    final withNull = List<Object?>.filled(Colorimetry.spectrumSamples, 0.5);
    withNull[3] = null;
    expect(
      () => customPigmentToModel(_row(jsonEncode(withNull))),
      throwsA(isA<FormatException>()),
    );

    final high = List<double>.filled(Colorimetry.spectrumSamples, 0.5);
    high[0] = 1.5;
    expect(
      () => customPigmentToModel(_row(jsonEncode(high))),
      throwsA(isA<FormatException>()),
    );

    final low = List<double>.filled(Colorimetry.spectrumSamples, 0.5);
    low[0] = -0.1;
    expect(
      () => customPigmentToModel(_row(jsonEncode(low))),
      throwsA(isA<FormatException>()),
    );
  });
}
