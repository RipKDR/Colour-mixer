import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/features/match/color_match.dart';

void main() {
  group('parseRecipeJson', () {
    test('parses chromastudio-recipe-v1', () {
      const raw = '''
{
  "format": "chromastudio-recipe-v1",
  "name": "Test green",
  "notes": "",
  "lab": {"L": 50, "a": -10, "b": 20},
  "colorArgb": 4283215696,
  "pigments": [
    {"id": "ultramarine_blue", "weight": 1},
    {"id": "hansa_yellow", "weight": 2}
  ]
}
''';
      final recipe = parseRecipeJson(raw);
      expect(recipe, isNotNull);
      expect(recipe!.name, 'Test green');
      expect(recipe.entries.length, 2);
      expect(recipe.entries[1].weight, 2);
    });

    test('rejects unknown format', () {
      expect(parseRecipeJson('{"format":"other"}'), isNull);
    });
  });
}
