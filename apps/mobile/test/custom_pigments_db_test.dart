import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/features/pigments/custom_pigments_provider.dart';
import 'package:chromastudio/features/recipes/database.dart';

CustomPigment _rowJson(String reflectanceJson, {String id = 'custom_test'}) {
  return CustomPigment(
    id: id,
    name: 'Studio Grey',
    reflectanceJson: reflectanceJson,
    opacity: 0.8,
    tintingStrength: 1.1,
    binder: 'oil',
    createdAt: DateTime.utc(2026, 9, 1),
  );
}

CustomPigment _row(List<double> reflectance, {String id = 'custom_test'}) {
  return _rowJson(jsonEncode(reflectance), id: id);
}

void main() {
  test('customPigmentToModel rebuilds a PigmentModel from a stored row', () {
    final model = customPigmentToModel(_row(List.filled(41, 0.5)));

    expect(model.id, 'custom_test');
    expect(model.name, 'Studio Grey');
    expect(model.binder, 'oil');
    expect(model.opacity, 0.8);
    expect(model.reflectance, hasLength(41));
  });

  test('customPigmentToModel rejects a spectrum that is not 41 samples', () {
    expect(
      () => customPigmentToModel(_row(List.filled(40, 0.5))),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => customPigmentToModel(_row(List.filled(42, 0.5))),
      throwsA(isA<FormatException>()),
    );
  });

  test('customPigmentToModel rejects out-of-range reflectance samples', () {
    expect(
      () => customPigmentToModel(
        _row(List<double>.generate(41, (i) => i == 10 ? -0.1 : 0.5)),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => customPigmentToModel(
        _row(List<double>.generate(41, (i) => i == 10 ? 1.1 : 0.5)),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('validateCustomReflectance rejects non-finite samples', () {
    expect(
      () => validateCustomReflectance(
        List<double>.generate(41, (i) => i == 3 ? double.nan : 0.5),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => validateCustomReflectance(
        List<double>.generate(41, (i) => i == 3 ? double.infinity : 0.5),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('customPigmentToModel rejects reflectanceJson that is not a number array', () {
    expect(
      () => customPigmentToModel(_rowJson('{}')),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => customPigmentToModel(
        _rowJson(jsonEncode(List<Object>.filled(41, '0.5'))),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('customPigmentModelsFromRows skips invalid rows and keeps valid ones', () {
    final good = _row(List.filled(41, 0.5), id: 'good');
    final badLength = _row(List.filled(40, 0.5), id: 'bad');
    final badShape = _rowJson('{}', id: 'not-array');

    final models = customPigmentModelsFromRows([good, badLength, badShape]);

    expect(models, hasLength(1));
    expect(models.single.id, 'good');
  });
}
