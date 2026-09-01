import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/features/learn/learn_screen.dart';

void main() {
  testWidgets('Learn screen shows Up next on the first incomplete lesson',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lessonProgressProvider.overrideWith((ref) async => {}),
        ],
        child: const MaterialApp(home: LearnScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Up next'), findsOneWidget);
    expect(find.text('Mix a Primary Green'), findsOneWidget);
  });
}
