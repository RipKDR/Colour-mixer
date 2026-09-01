import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/appwrite/appwrite_client.dart';

/// Bump after sign-in / register / sign-out so [cloudUserProvider] reloads.
final cloudSessionTickProvider = StateProvider<int>((ref) => 0);

final cloudUserProvider = FutureProvider<CloudUser?>((ref) async {
  ref.watch(cloudSessionTickProvider);
  final auth = ref.watch(cloudAuthProvider);
  if (auth == null) return null;
  return auth.currentUser();
});

void refreshCloudSession(WidgetRef ref) {
  ref.read(cloudSessionTickProvider.notifier).state++;
}
