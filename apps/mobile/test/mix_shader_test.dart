import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/mix_shader.dart';

void main() {
  testWidgets('MixShaderPainter fallback paints without a fragment shader',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomPaint(
          size: const Size(64, 64),
          painter: MixShaderPainter(
            center: const Offset(32, 32),
            radius: 24,
            colorA: Colors.blue,
            colorB: Colors.yellow,
            progress: 0.4,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  test('shouldRepaint is true when progress changes', () {
    final a = MixShaderPainter(
      center: Offset.zero,
      radius: 10,
      colorA: Colors.red,
      colorB: Colors.blue,
      progress: 0.2,
    );
    final b = MixShaderPainter(
      center: Offset.zero,
      radius: 10,
      colorA: Colors.red,
      colorB: Colors.blue,
      progress: 0.8,
    );

    expect(a.shouldRepaint(b), isTrue);
    expect(a.shouldRepaint(a), isFalse);
  });
}
