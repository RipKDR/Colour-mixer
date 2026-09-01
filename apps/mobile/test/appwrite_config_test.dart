import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/core/appwrite/appwrite_config.dart';

void main() {
  test('isConfigured is false when endpoint or project is empty', () {
    expect(
      const AppwriteConfig(endpoint: '', projectId: 'proj').isConfigured,
      isFalse,
    );
    expect(
      const AppwriteConfig(endpoint: 'https://cloud.appwrite.io/v1', projectId: '')
          .isConfigured,
      isFalse,
    );
  });

  test('isConfigured is true when endpoint and project are set', () {
    const config = AppwriteConfig(
      endpoint: 'https://cloud.appwrite.io/v1',
      projectId: 'proj',
    );
    expect(config.isConfigured, isTrue);
    expect(config.databaseId, 'chromastudio');
    expect(config.collectionId, 'recipes');
  });
}
