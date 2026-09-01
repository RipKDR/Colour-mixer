import 'package:chromastudio/core/appwrite/appwrite_client.dart';
import 'package:chromastudio/features/recipes/database.dart';
import 'package:chromastudio/features/recipes/recipe_sync.dart';
import 'package:drift/drift.dart' show Value;

class FakeCloudAuth implements CloudAuth {
  FakeCloudAuth({this.user});

  CloudUser? user;
  int signInCalls = 0;
  int registerCalls = 0;
  int signOutCalls = 0;
  Object? nextError;

  @override
  Future<CloudUser?> currentUser() async => user;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    _throwIfQueued();
    user = CloudUser(id: 'user-1', email: email);
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    registerCalls++;
    _throwIfQueued();
    user = CloudUser(id: 'user-1', email: email);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _throwIfQueued();
    user = null;
  }

  void _throwIfQueued() {
    final error = nextError;
    nextError = null;
    if (error != null) throw error;
  }
}

class FakeCloudRecipes implements CloudRecipes {
  FakeCloudRecipes({this.upsertDelay});

  final Duration? upsertDelay;
  final Map<String, CloudRecipeDocument> docs = {};
  int upsertCalls = 0;

  @override
  Future<String> upsertRecipe({
    required String documentId,
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    upsertCalls++;
    final delay = upsertDelay;
    if (delay != null) await Future<void>.delayed(delay);
    docs[documentId] = CloudRecipeDocument(
      id: documentId,
      data: Map<String, dynamic>.from(data),
    );
    return documentId;
  }

  @override
  Future<List<CloudRecipeDocument>> listOwned(String userId) async {
    return [
      for (final doc in docs.values)
        if (doc.data['userId'] == userId) doc,
    ];
  }
}

class FakeRecipeStore implements RecipeStore {
  FakeRecipeStore(this.rows);

  final List<MixRecipe> rows;
  int _nextId = 100;

  @override
  Future<List<MixRecipe>> getAllRecipes() async => List.of(rows);

  @override
  Future<void> setRecipeCloudId(
    int id,
    String cloudId, {
    required String userId,
  }) async {
    final index = rows.indexWhere((r) => r.id == id);
    rows[index] = rows[index].copyWith(
      cloudId: Value(cloudId),
      cloudUserId: Value(userId),
    );
  }

  @override
  Future<MixRecipe?> getRecipeByCloudId(String cloudId) async {
    for (final row in rows) {
      if (row.cloudId == cloudId) return row;
    }
    return null;
  }

  @override
  Future<int> insertRecipe(MixRecipesCompanion recipe) async {
    final cloudId = recipe.cloudId.present ? recipe.cloudId.value : null;
    if (cloudId != null) {
      final existing = await getRecipeByCloudId(cloudId);
      if (existing != null) {
        throw StateError('Duplicate cloudId $cloudId');
      }
    }
    final id = _nextId++;
    rows.add(
      MixRecipe(
        id: id,
        name: recipe.name.value,
        notes: recipe.notes.present ? recipe.notes.value : '',
        pigmentData: recipe.pigmentData.value,
        labL: recipe.labL.value,
        labA: recipe.labA.value,
        labB: recipe.labB.value,
        colorValue: recipe.colorValue.value,
        cloudId: cloudId,
        cloudUserId:
            recipe.cloudUserId.present ? recipe.cloudUserId.value : null,
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    return id;
  }
}
