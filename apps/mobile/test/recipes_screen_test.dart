import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/features/recipes/recipes_provider.dart';
import 'package:chromastudio/features/recipes/recipes_screen.dart';

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
    });
  });
}
