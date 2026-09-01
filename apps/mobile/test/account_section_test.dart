import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/core/appwrite/appwrite_client.dart';
import 'package:chromastudio/core/appwrite/appwrite_config.dart';
import 'package:chromastudio/features/account/account_section.dart';

import 'support/cloud_fakes.dart';

const _configured = AppwriteConfig(
  endpoint: 'https://cloud.appwrite.io/v1',
  projectId: 'test-project',
);

Future<void> _pumpAccount(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: Scaffold(body: AccountSection())),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AccountSection', () {
    testWidgets('shows unconfigured message when dart-defines are empty',
        (tester) async {
      await _pumpAccount(
        tester,
        overrides: [
          appwriteConfigProvider.overrideWithValue(
            const AppwriteConfig(endpoint: '', projectId: ''),
          ),
        ],
      );

      expect(find.text('Cloud sync not configured'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
    });

    testWidgets('shows sign-in form when configured and signed out',
        (tester) async {
      await _pumpAccount(
        tester,
        overrides: [
          appwriteConfigProvider.overrideWithValue(_configured),
          appwriteClientProvider.overrideWithValue(null),
          cloudAuthProvider.overrideWithValue(FakeCloudAuth()),
        ],
      );

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.byKey(const Key('account-email')), findsOneWidget);
    });

    testWidgets('shows signed-in email and Sign out', (tester) async {
      await _pumpAccount(
        tester,
        overrides: [
          appwriteConfigProvider.overrideWithValue(_configured),
          appwriteClientProvider.overrideWithValue(null),
          cloudAuthProvider.overrideWithValue(
            FakeCloudAuth(
              user: const CloudUser(id: 'u1', email: 'painter@example.com'),
            ),
          ),
        ],
      );

      expect(find.text('painter@example.com'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
    });

    testWidgets('Sign in updates status via session refresh', (tester) async {
      final auth = FakeCloudAuth();
      await _pumpAccount(
        tester,
        overrides: [
          appwriteConfigProvider.overrideWithValue(_configured),
          appwriteClientProvider.overrideWithValue(null),
          cloudAuthProvider.overrideWithValue(auth),
        ],
      );

      await tester.enterText(
        find.byKey(const Key('account-email')),
        'painter@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('account-password')),
        'password1',
      );
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(auth.signInCalls, 1);
      expect(find.text('painter@example.com'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });
  });
}
