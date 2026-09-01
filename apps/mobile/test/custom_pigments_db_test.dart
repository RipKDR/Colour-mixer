import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/features/pigments/custom_pigments_provider.dart';
import 'package:chromastudio/features/recipes/database.dart';

void main() {
  test('customPigmentToModel rebuilds a PigmentModel from a stored row', () {
    final row = CustomPigment(
      id: 'custom_test',
      name: 'Studio Grey',
      reflectanceJson: jsonEncode(List.filled(41, 0.5)),
      opacity: 0.8,
      tintingStrength: 1.1,
      binder: 'oil',
      createdAt: DateTime.utc(2026, 9, 1),
    );

    final model = customPigmentToModel(row);

    expect(model.id, 'custom_test');
    expect(model.name, 'Studio Grey');
    expect(model.binder, 'oil');
    expect(model.opacity, 0.8);
    expect(model.reflectance, hasLength(41));
  });
}
