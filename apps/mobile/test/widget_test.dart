import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/main.dart';

void main() {
  testWidgets('App loads with loading indicator', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ChromaStudioApp()),
    );
    expect(find.text('Loading pigment database…'), findsOneWidget);
  });
}
