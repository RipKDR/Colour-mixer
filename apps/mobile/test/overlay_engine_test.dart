import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/engine/overlay_engine.dart';

import 'support/engine_fixtures.dart';

void main() {
  test('OverlayEngineBackend lists extra pigments', () async {
    final inner = await testEngineBackend();
    final extra = testPigment(
      'custom_1',
      'My Red',
      List.filled(41, 0.4),
    );
    final overlay = OverlayEngineBackend(inner, [extra]);

    expect(overlay.listPigments().map((p) => p.id), contains('custom_1'));
    expect(overlay.listPigments().length, inner.listPigments().length + 1);
  });

  test('mix with a custom pigment uses the overlay Dart path', () async {
    final inner = await testEngineBackend();
    final extra = testPigment(
      'custom_blueish',
      'Custom',
      List.generate(41, (i) {
        final wl = 380.0 + i * 10;
        return wl < 500 ? 0.55 : 0.08;
      }),
    );
    final overlay = OverlayEngineBackend(inner, [extra]);

    final result = overlay.mix([
      const MixComponent(pigmentId: 'custom_blueish', weight: 1),
      const MixComponent(pigmentId: 'titanium_white', weight: 1),
    ]);

    expect(result.lab.l, greaterThan(20));
  });

  test('catalog-only mix on an overlay matches the inner backend', () async {
    final inner = await testEngineBackend();
    final extra = testPigment(
      'custom_1',
      'My Red',
      List.filled(41, 0.4),
    );
    final overlay = OverlayEngineBackend(inner, [extra]);
    const components = [
      MixComponent(pigmentId: 'titanium_white', weight: 1),
      MixComponent(pigmentId: 'blue', weight: 1),
    ];

    final innerResult = inner.mix(components);
    final overlayResult = overlay.mix(components);

    expect(overlayResult.lab.l, closeTo(innerResult.lab.l, 1e-9));
    expect(overlayResult.lab.a, closeTo(innerResult.lab.a, 1e-9));
    expect(overlayResult.lab.b, closeTo(innerResult.lab.b, 1e-9));
  });
}
