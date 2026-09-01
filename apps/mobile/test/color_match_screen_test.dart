import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/engine/mix_session.dart';
import 'package:chromastudio/engine/native_engine.dart';
import 'package:chromastudio/features/match/color_match.dart';
import 'package:chromastudio/features/match/color_match_screen.dart';

import 'support/engine_fixtures.dart';

void main() {
  group('ColorMatchScreen widget', () {
    late DartEngineBackend backend;

    setUp(() async {
      backend = await testEngineBackend();
    });

    Future<void> pumpMatchScreen(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            engineBackendProvider.overrideWith((ref) => Future.value(backend)),
            colorTargetProvider.overrideWith((ref) => null),
            emptyCustomPigmentsOverride(),
          ],
          child: const MaterialApp(home: ColorMatchScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders title and target controls', (tester) async {
      await pumpMatchScreen(tester);

      expect(find.text('Color Match'), findsOneWidget);
      expect(find.text('Set as match target'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('From photo'),
        80,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('From photo'), findsOneWidget);
      expect(find.text('Suggest recipe'), findsOneWidget);
      expect(find.text('Check swatch'), findsOneWidget);
    });

    testWidgets('shows Lab sliders', (tester) async {
      await pumpMatchScreen(tester);

      expect(find.textContaining('L (lightness)'), findsOneWidget);
      expect(find.textContaining('a (green'), findsOneWidget);
      expect(find.textContaining('b (blue'), findsOneWidget);
    });

    testWidgets('skin base preset updates lightness label', (tester) async {
      await pumpMatchScreen(tester);

      await tester.tap(find.text('Skin base'));
      await tester.pumpAndSettle();

      expect(find.textContaining('L (lightness): 68'), findsOneWidget);
    });
  });
}
