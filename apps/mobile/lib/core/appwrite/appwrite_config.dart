class AppwriteConfig {
  const AppwriteConfig({
    required this.endpoint,
    required this.projectId,
    this.databaseId = 'chromastudio',
    this.collectionId = 'recipes',
  });

  factory AppwriteConfig.fromEnvironment() => const AppwriteConfig(
        endpoint: String.fromEnvironment('APPWRITE_ENDPOINT'),
        projectId: String.fromEnvironment('APPWRITE_PROJECT_ID'),
      );

  final String endpoint;
  final String projectId;
  final String databaseId;
  final String collectionId;

  bool get isConfigured => endpoint.isNotEmpty && projectId.isNotEmpty;
}
