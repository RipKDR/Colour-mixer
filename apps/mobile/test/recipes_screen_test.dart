import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/core/appwrite/appwrite_client.dart';
import 'package:chromastudio/core/appwrite/appwrite_config.dart';
import 'package:chromastudio/features/recipes/recipe_sync.dart';
import 'package:chromastudio/features/recipes/recipes_provider.dart';
import 'package:chromastudio/features/recipes/recipes_screen.dart';

import 'support/cloud_fakes.dart';

void main() {
  group('RecipesScreen widget', () {
    testWidgets('renders empty state when no recipes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: RecipesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('No saved recipes yet'), findsOneWidget);
      expect(find.text('Save current mix'), findsWidgets);
    });

    testWidgets('shows import and save actions in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: RecipesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Import recipe JSON'), findsOneWidget);
      expect(find.byTooltip('Save current mix'), findsOneWidget);
      expect(find.byTooltip('Sync now'), findsNothing);
    });

    testWidgets('hides Sync now when signed out even if configured',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipesProvider.overrideWith((ref) async => []),
            appwriteConfigProvider.overrideWithValue(
              const AppwriteConfig(
                endpoint: 'https://cloud.appwrite.io/v1',
                projectId: 'test-project',
              ),
            ),
            appwriteClientProvider.overrideWithValue(null),
            cloudAuthProvider.overrideWithValue(FakeCloudAuth()),
          ],
          child: const MaterialApp(home: RecipesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Sync now'), findsNothing);
    });

    testWidgets('shows Sync now when signed in', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipesProvider.overrideWith((ref) async => []),
            appwriteConfigProvider.overrideWithValue(
              const AppwriteConfig(
                endpoint: 'https://cloud.appwrite.io/v1',
                projectId: 'test-project',
              ),
            ),
            appwriteClientProvider.overrideWithValue(null),
            cloudAuthProvider.overrideWithValue(
              FakeCloudAuth(
                user: const CloudUser(id: 'u1', email: 'painter@example.com'),
              ),
            ),
          ],
          child: const MaterialApp(home: RecipesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Sync now'), findsOneWidget);
    });

    testWidgets('disables Sync now while a sync is in flight', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipesProvider.overrideWith((ref) async => []),
            appwriteConfigProvider.overrideWithValue(
              const AppwriteConfig(
                endpoint: 'https://cloud.appwrite.io/v1',
                projectId: 'test-project',
              ),
            ),
            appwriteClientProvider.overrideWithValue(null),
            cloudAuthProvider.overrideWithValue(
              FakeCloudAuth(
                user: const CloudUser(id: 'u1', email: 'painter@example.com'),
              ),
            ),
            recipeSyncInFlightProvider.overrideWith((ref) => true),
          ],
          child: const MaterialApp(home: RecipesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Syncing…'), findsOneWidget);
      final button = tester.widget<IconButton>(find.byTooltip('Syncing…'));
      expect(button.onPressed, isNull);
    });
  });
}
