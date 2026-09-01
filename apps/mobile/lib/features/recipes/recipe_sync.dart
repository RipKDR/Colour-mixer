import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../core/appwrite/appwrite_client.dart';
import '../match/color_match.dart';
import 'database.dart';
import 'recipe_export.dart';

abstract class RecipeStore {
  Future<List<MixRecipe>> getAllRecipes();
  Future<void> setRecipeCloudId(int id, String cloudId);
  Future<MixRecipe?> getRecipeByCloudId(String cloudId);
  Future<int> insertRecipe(MixRecipesCompanion recipe);
}

class DriftRecipeStore implements RecipeStore {
  DriftRecipeStore(this.db);

  final AppDatabase db;

  @override
  Future<List<MixRecipe>> getAllRecipes() => db.getAllRecipes();

  @override
  Future<void> setRecipeCloudId(int id, String cloudId) =>
      db.setRecipeCloudId(id, cloudId);

  @override
  Future<MixRecipe?> getRecipeByCloudId(String cloudId) =>
      db.getRecipeByCloudId(cloudId);

  @override
  Future<int> insertRecipe(MixRecipesCompanion recipe) =>
      db.insertRecipe(recipe);
}

class RecipeSyncResult {
  const RecipeSyncResult({required this.pushed, required this.pulled});

  final int pushed;
  final int pulled;
}

Map<String, dynamic> recipeToDocumentData(MixRecipe recipe, String userId) {
  return {
    'name': recipe.name,
    'notes': recipe.notes,
    'pigmentData': recipe.pigmentData,
    'labL': recipe.labL,
    'labA': recipe.labA,
    'labB': recipe.labB,
    'colorValue': recipe.colorValue,
    'payloadJson': recipeToJson(recipe),
    'userId': userId,
  };
}

MixRecipesCompanion documentToRecipeCompanion(CloudRecipeDocument doc) {
  final data = doc.data;
  final payload = data['payloadJson'] as String?;
  final parsed = payload != null ? parseRecipeJson(payload) : null;
  if (parsed != null) {
    final pigmentData = jsonEncode(
      parsed.entries
          .map((e) => {'id': e.pigmentId, 'weight': e.weight})
          .toList(),
    );
    return MixRecipesCompanion.insert(
      name: parsed.name,
      notes: Value(parsed.notes),
      pigmentData: pigmentData,
      labL: parsed.labL,
      labA: parsed.labA,
      labB: parsed.labB,
      colorValue: parsed.colorValue,
      cloudId: Value(doc.id),
    );
  }

  return MixRecipesCompanion.insert(
    name: data['name'] as String? ?? 'Cloud recipe',
    notes: Value(data['notes'] as String? ?? ''),
    pigmentData: data['pigmentData'] as String? ?? '[]',
    labL: _asDouble(data['labL'], 50),
    labA: _asDouble(data['labA'], 0),
    labB: _asDouble(data['labB'], 0),
    colorValue: _asInt(data['colorValue'], 0xFF808080),
    cloudId: Value(doc.id),
  );
}

double _asDouble(dynamic value, double fallback) {
  if (value is num) return value.toDouble();
  return fallback;
}

int _asInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.round();
  return fallback;
}

Future<int> pushRecipes({
  required RecipeStore store,
  required CloudRecipes cloud,
  required String userId,
  required String Function() newDocumentId,
}) async {
  final recipes = await store.getAllRecipes();
  var pushed = 0;
  for (final recipe in recipes) {
    final documentId = recipe.cloudId ?? newDocumentId();
    await cloud.upsertRecipe(
      documentId: documentId,
      data: recipeToDocumentData(recipe, userId),
      userId: userId,
    );
    if (recipe.cloudId == null) {
      await store.setRecipeCloudId(recipe.id, documentId);
    }
    pushed++;
  }
  return pushed;
}

Future<int> pullRecipes({
  required RecipeStore store,
  required CloudRecipes cloud,
  required String userId,
}) async {
  final docs = await cloud.listOwned(userId);
  var pulled = 0;
  for (final doc in docs) {
    final existing = await store.getRecipeByCloudId(doc.id);
    if (existing != null) continue;
    await store.insertRecipe(documentToRecipeCompanion(doc));
    pulled++;
  }
  return pulled;
}

Future<RecipeSyncResult> syncRecipes({
  required RecipeStore store,
  required CloudRecipes cloud,
  required String userId,
  required String Function() newDocumentId,
}) async {
  final pushed = await pushRecipes(
    store: store,
    cloud: cloud,
    userId: userId,
    newDocumentId: newDocumentId,
  );
  final pulled = await pullRecipes(
    store: store,
    cloud: cloud,
    userId: userId,
  );
  return RecipeSyncResult(pushed: pushed, pulled: pulled);
}
