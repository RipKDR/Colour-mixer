import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/core/appwrite/appwrite_client.dart';
import 'package:chromastudio/features/match/color_match.dart';
import 'package:chromastudio/features/recipes/database.dart';
import 'package:chromastudio/features/recipes/recipe_sync.dart';

import 'support/cloud_fakes.dart';

MixRecipe _sample({
  int id = 1,
  String? cloudId,
  String? cloudUserId,
}) {
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
    cloudUserId: cloudUserId,
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
        userId: 'user-1',
      );
      expect(companion.name.value, 'Sunset');
      expect(companion.notes.value, 'warm');
      expect(companion.labL.value, 50);
      expect(companion.cloudId.value, 'doc-1');
      expect(companion.cloudUserId.value, 'user-1');
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
        userId: 'user-1',
      );
      expect(companion.name.value, 'Field only');
      expect(companion.labL.value, 40);
      expect(companion.cloudId.value, 'doc-2');
      expect(companion.cloudUserId.value, 'user-1');
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
      expect(store.rows.single.cloudUserId, 'user-1');
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

    test('push rebinds cloudId when the signed-in user changes', () async {
      final store = FakeRecipeStore([
        _sample(cloudId: 'old-user-doc', cloudUserId: 'user-a'),
      ]);
      final cloud = FakeCloudRecipes();

      await pushRecipes(
        store: store,
        cloud: cloud,
        userId: 'user-b',
        newDocumentId: () => 'new-user-doc',
      );

      expect(store.rows.single.cloudId, 'new-user-doc');
      expect(store.rows.single.cloudUserId, 'user-b');
      expect(cloud.docs.containsKey('old-user-doc'), isFalse);
      expect(cloud.docs['new-user-doc']?.data['userId'], 'user-b');
    });

    test('push reuses cloudId for the same owner', () async {
      final store = FakeRecipeStore([
        _sample(cloudId: 'doc-1', cloudUserId: 'user-1'),
      ]);
      final cloud = FakeCloudRecipes();
      var minted = 0;

      await pushRecipes(
        store: store,
        cloud: cloud,
        userId: 'user-1',
        newDocumentId: () {
          minted++;
          return 'should-not-mint';
        },
      );

      expect(minted, 0);
      expect(store.rows.single.cloudId, 'doc-1');
      expect(cloud.docs.keys, ['doc-1']);
    });

    test('syncRecipes pushes then pulls', () async {
      final store = FakeRecipeStore([_sample()]);
      final cloud = FakeCloudRecipes();
      final gate = RecipeSyncGate();
      final result = await syncRecipes(
        store: store,
        cloud: cloud,
        userId: 'user-1',
        newDocumentId: () => 'id-1',
        gate: gate,
      );
      expect(result, isNotNull);
      expect(result!.pushed, 1);
      expect(result.pulled, 0);
      expect(store.rows.single.cloudId, 'id-1');
    });

    test('overlapping syncRecipes skips the second run', () async {
      final store = FakeRecipeStore([_sample()]);
      final cloud = FakeCloudRecipes(
        upsertDelay: const Duration(milliseconds: 80),
      );
      final gate = RecipeSyncGate();

      final first = syncRecipes(
        store: store,
        cloud: cloud,
        userId: 'user-1',
        newDocumentId: () => 'id-1',
        gate: gate,
      );
      final second = syncRecipes(
        store: store,
        cloud: cloud,
        userId: 'user-1',
        newDocumentId: () => 'id-2',
        gate: gate,
      );

      final results = await Future.wait([first, second]);
      expect(results.whereType<RecipeSyncResult>().length, 1);
      expect(results.where((r) => r == null).length, 1);
      expect(cloud.upsertCalls, 1);
      expect(store.rows.single.cloudId, 'id-1');
    });
  });

  group('collectCursorPages', () {
    test('walks full pages then a short page', () async {
      final pages = [
        ['a', 'b'],
        ['c', 'd'],
        ['e'],
      ];
      var calls = 0;
      final cursors = <String?>[];

      final all = await collectCursorPages<String>(
        pageSize: 2,
        idOf: (id) => id,
        fetchPage: ({cursorAfter}) async {
          cursors.add(cursorAfter);
          return pages[calls++];
        },
      );

      expect(all, ['a', 'b', 'c', 'd', 'e']);
      expect(cursors, [null, 'b', 'd']);
    });

    test('stops on an empty first page', () async {
      final all = await collectCursorPages<String>(
        pageSize: 2,
        idOf: (id) => id,
        fetchPage: ({cursorAfter}) async => [],
      );
      expect(all, isEmpty);
    });
  });
}
