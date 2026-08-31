import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

/// Increment to invalidate [recipesProvider].
final recipesRefreshProvider = StateProvider<int>((ref) => 0);

final recipesProvider = FutureProvider<List<MixRecipe>>((ref) async {
  ref.watch(recipesRefreshProvider);
  final db = ref.watch(databaseProvider);
  return db.getAllRecipes();
});

void refreshRecipes(WidgetRef ref) {
  ref.read(recipesRefreshProvider.notifier).state++;
}
