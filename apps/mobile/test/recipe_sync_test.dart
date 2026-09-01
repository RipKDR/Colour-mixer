import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/core/appwrite/appwrite_client.dart';
import 'package:chromastudio/features/match/color_match.dart';
import 'package:chromastudio/features/recipes/database.dart';
import 'package:chromastudio/features/recipes/recipe_sync.dart';

import 'support/cloud_fakes.dart';

MixRecipe _sample({int id = 1, String? cloudId}) {
  return MixRecipe(
    id: id,
    name: 'Sunset',
    notes: 'warm',
    pigmentData: jsonEncode([
      {'id': 'ultramarine_blue', 'weight': 1.0},
      {'id': 'hansa_yellow', 'weight': 2.0},
    ]),
    labL: 50,
    labA: 10,
    labB: 20,
    colorValue: 0xFFCC8844,
    cloudId: cloudId,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  group('recipe document mapping', () {
    test('round-trips chromastudio-recipe-v1 payload', () {
      final recipe = _sample();
      final data = recipeToDocumentData(recipe, 'user-1');

      expect(data['userId'], 'user-1');
      expect(data['name'], 'Sunset');
      expect(data['payloadJson'], contains('chromastudio-recipe-v1'));

      final parsed = parseRecipeJson(data['payloadJson'] as String);
      expect(parsed, isNotNull);
      expect(parsed!.name, 'Sunset');
      expect(parsed.entries.length, 2);
      expect(parsed.entries[1].weight, 2.0);

      final companion = documentToRecipeCompanion(
        CloudRecipeDocument(id: 'doc-1', data: data),
      );
      expect(companion.name.value, 'Sunset');
      expect(companion.notes.value, 'warm');
      expect(companion.labL.value, 50);
      expect(companion.cloudId.value, 'doc-1');
    });

    test('falls back to field attributes when payloadJson is missing', () {
      final companion = documentToRecipeCompanion(
        const CloudRecipeDocument(
          id: 'doc-2',
          data: {
            'name': 'Field only',
            'notes': '',
            'pigmentData': '[]',
            'labL': 40,
            'labA': 1,
            'labB': 2,
            'colorValue': 0xFF112233,
          },
        ),
      );
      expect(companion.name.value, 'Field only');
      expect(companion.labL.value, 40);
      expect(companion.cloudId.value, 'doc-2');
    });
  });

  group('push and pull with fakes', () {
    test('push assigns cloudId; pull inserts missing cloud rows only', () async {
      final store = FakeRecipeStore([_sample()]);
      final cloud = FakeCloudRecipes();
      var next = 0;

      final pushed = await pushRecipes(
        store: store,
        cloud: cloud,
        userId: 'user-1',
        newDocumentId: () => 'cloud-${++next}',
      );
      expect(pushed, 1);
      expect(store.rows.single.cloudId, 'cloud-1');
      expect(cloud.docs['cloud-1']?.data['name'], 'Sunset');

      final remote = recipeToDocumentData(_sample(id: 99), 'user-1');
      await cloud.upsertRecipe(
        documentId: 'cloud-remote',
        data: remote,
        userId: 'user-1',
      );

      final pulled = await pullRecipes(
        store: store,
        cloud: cloud,
        userId: 'user-1',
      );
      expect(pulled, 1);
      expect(store.rows.length, 2);
      expect(
        store.rows.where((r) => r.cloudId == 'cloud-remote'),
        isNotEmpty,
      );

      final pulledAgain = await pullRecipes(
        store: store,
        cloud: cloud,
        userId: 'user-1',
      );
      expect(pulledAgain, 0);
      expect(store.rows.length, 2);
    });

    test('syncRecipes pushes then pulls', () async {
      final store = FakeRecipeStore([_sample()]);
      final cloud = FakeCloudRecipes();
      final result = await syncRecipes(
        store: store,
        cloud: cloud,
        userId: 'user-1',
        newDocumentId: () => 'id-1',
      );
      expect(result.pushed, 1);
      expect(result.pulled, 0);
      expect(store.rows.single.cloudId, 'id-1');
    });
  });
}
