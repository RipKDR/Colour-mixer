import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';

import '../match/color_match.dart';
import 'database.dart';

Future<ParsedRecipe?> pickAndParseRecipeFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;

  final file = result.files.first;
  final String raw;
  if (file.bytes != null) {
    raw = utf8.decode(file.bytes!);
  } else if (file.path != null) {
    raw = await File(file.path!).readAsString();
  } else {
    return null;
  }
  return parseRecipeJson(raw);
}

Future<int> saveParsedRecipe(AppDatabase db, ParsedRecipe recipe) {
  final pigmentData = jsonEncode(
    recipe.entries
        .map((e) => {'id': e.pigmentId, 'weight': e.weight})
        .toList(),
  );
  return db.insertRecipe(
    MixRecipesCompanion.insert(
      name: recipe.name,
      notes: Value(recipe.notes),
      pigmentData: pigmentData,
      labL: recipe.labL,
      labA: recipe.labA,
      labB: recipe.labB,
      colorValue: recipe.colorValue,
    ),
  );
}
