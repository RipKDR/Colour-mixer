import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../recipes/database.dart';

final inventoryRefreshProvider = StateProvider<int>((ref) => 0);

final inventoryProvider = FutureProvider<List<InventoryItem>>((ref) async {
  ref.watch(inventoryRefreshProvider);
  return ref.watch(databaseProvider).getAllInventory();
});

void refreshInventory(WidgetRef ref) {
  ref.read(inventoryRefreshProvider.notifier).state++;
}

String amountLabel(double fraction) {
  if (fraction >= 0.95) return 'Full';
  if (fraction >= 0.7) return '¾ full';
  if (fraction >= 0.45) return '½ full';
  if (fraction >= 0.2) return '¼ full';
  if (fraction >= 0.05) return 'Almost empty';
  return 'Empty';
}
