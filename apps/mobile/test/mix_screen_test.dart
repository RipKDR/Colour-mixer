import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/engine/mix_session.dart';
import 'package:chromastudio/engine/native_engine.dart';
import 'package:chromastudio/features/mix/mix_screen.dart';

import 'support/engine_fixtures.dart';

void main() {
  group('MixScreen widget', () {
    late DartEngineBackend backend;

    setUp(() async {
      backend = await testEngineBackend();
    });

    Future<void> pumpMixScreen(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            engineBackendProvider.overrideWith((ref) => Future.value(backend)),
            emptyCustomPigmentsOverride(),
          ],
          child: const MaterialApp(home: MixScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders mix title and mode switcher', (tester) async {
      await pumpMixScreen(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Mix'),
        ),
        findsOneWidget,
      );
      expect(find.text('Palette'), findsOneWidget);
      expect(find.text('Precision'), findsOneWidget);
    });

    testWidgets('defaults to precision mode with pigment controls', (tester) async {
      await pumpMixScreen(tester);

      expect(find.text('Precision'), findsOneWidget);
      expect(find.byIcon(Icons.handyman_outlined), findsOneWidget);
    });

    testWidgets('switches to palette mode', (tester) async {
      await pumpMixScreen(tester);

      await tester.tap(find.text('Palette'));
      await tester.pumpAndSettle();

      expect(find.text('Palette'), findsOneWidget);
    });
  });
}
