import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/features/pigments/custom_pigments_screen.dart';

import 'support/engine_fixtures.dart';

void main() {
  testWidgets('Custom pigments screen shows empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          emptyCustomPigmentsOverride(),
        ],
        child: const MaterialApp(home: CustomPigmentsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom pigments'), findsOneWidget);
    expect(find.text('Add pigment'), findsOneWidget);
    expect(
      find.textContaining('synthesizes a reflectance curve'),
      findsOneWidget,
    );
  });
}
