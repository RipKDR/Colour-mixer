import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appwrite_config.dart';

class CloudUser {
  const CloudUser({required this.id, required this.email});

  final String id;
  final String email;
}

abstract class CloudAuth {
  Future<CloudUser?> currentUser();
  Future<void> signIn({required String email, required String password});
  Future<void> register({required String email, required String password});
  Future<void> signOut();
}

class CloudRecipeDocument {
  const CloudRecipeDocument({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}

abstract class CloudRecipes {
  Future<String> upsertRecipe({
    required String documentId,
    required Map<String, dynamic> data,
    required String userId,
  });

  Future<List<CloudRecipeDocument>> listOwned(String userId);
}

final appwriteConfigProvider = Provider<AppwriteConfig>(
  (ref) => AppwriteConfig.fromEnvironment(),
);

final appwriteClientProvider = Provider<Client?>((ref) {
  final config = ref.watch(appwriteConfigProvider);
  if (!config.isConfigured) return null;
  return Client()
    ..setEndpoint(config.endpoint)
    ..setProject(config.projectId);
});

final cloudAuthProvider = Provider<CloudAuth?>((ref) {
  final client = ref.watch(appwriteClientProvider);
  if (client == null) return null;
  return AppwriteCloudAuth(Account(client));
});

final cloudRecipesProvider = Provider<CloudRecipes?>((ref) {
  final client = ref.watch(appwriteClientProvider);
  if (client == null) return null;
  return AppwriteCloudRecipes(
    Databases(client),
    ref.watch(appwriteConfigProvider),
  );
});

class AppwriteCloudAuth implements CloudAuth {
  AppwriteCloudAuth(this._account);

  final Account _account;

  @override
  Future<CloudUser?> currentUser() async {
    try {
      final user = await _account.get();
      return CloudUser(id: user.$id, email: user.email);
    } on AppwriteException catch (e) {
      if (e.code == 401) return null;
      rethrow;
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
    );
    await signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _account.deleteSession(sessionId: 'current');
  }
}

class AppwriteCloudRecipes implements CloudRecipes {
  AppwriteCloudRecipes(this._databases, this._config);

  final Databases _databases;
  final AppwriteConfig _config;

  @override
  Future<String> upsertRecipe({
    required String documentId,
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    final doc = await _databases.upsertDocument(
      databaseId: _config.databaseId,
      collectionId: _config.collectionId,
      documentId: documentId,
      data: data,
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.write(Role.user(userId)),
      ],
    );
    return doc.$id;
  }

  @override
  Future<List<CloudRecipeDocument>> listOwned(String userId) async {
    final result = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.collectionId,
      queries: [
        Query.equal('userId', userId),
        Query.limit(100),
      ],
    );
    return [
      for (final doc in result.documents)
        CloudRecipeDocument(
          id: doc.$id,
          data: Map<String, dynamic>.from(doc.data),
        ),
    ];
  }
}
