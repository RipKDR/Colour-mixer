import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chromastudio/engine/catalog.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/engine/mediums.dart';
import 'package:chromastudio/engine/mix_session.dart';
import 'package:chromastudio/features/pigments/custom_pigments_provider.dart';

import 'support/engine_fixtures.dart';

Future<void> _waitUntilReady(ProviderContainer container) async {
  for (var i = 0; i < 100; i++) {
    if (!container.read(mixSessionProvider).isLoading) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('mix session stayed in the loading placeholder');
}

void main() {
  test('refreshing custom pigments does not reset mix entries or mode', () async {
    final backend = await testEngineBackend();
    final container = ProviderContainer(
      overrides: [
        engineBackendProvider.overrideWith((ref) async => backend),
        mediumLibraryProvider.overrideWith((ref) async => MediumLibrary({})),
        customPigmentModelsProvider.overrideWith((ref) async {
          ref.watch(customPigmentsRefreshProvider);
          return <PigmentModel>[];
        }),
      ],
    );
    addTearDown(container.dispose);
    container.listen(mixSessionProvider, (_, __) {});

    await _waitUntilReady(container);

    final notifier = container.read(mixSessionProvider.notifier);
    notifier.setMode(MixMode.palette);
    notifier.addPigment('titanium_white');

    expect(
      container.read(mixSessionProvider).entries.map((e) => e.pigmentId),
      contains('titanium_white'),
    );
    expect(container.read(mixSessionProvider).mode, MixMode.palette);

    container.read(customPigmentsRefreshProvider.notifier).state++;
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final after = container.read(mixSessionProvider);
    expect(after.isLoading, isFalse);
    expect(after.mode, MixMode.palette);
    expect(
      after.entries.map((e) => e.pigmentId),
      contains('titanium_white'),
    );
  });

  test('engineProvider keeps last-good extras when custom pigments fail to load',
      () async {
    final backend = await testEngineBackend();
    var extrasShouldFail = false;
    final extraPigment = testPigment(
      'custom_keep',
      'Keep me',
      List.filled(41, 0.4),
    );
    final container = ProviderContainer(
      overrides: [
        engineBackendProvider.overrideWith((ref) async => backend),
        mediumLibraryProvider.overrideWith((ref) async => MediumLibrary({})),
        customPigmentModelsProvider.overrideWith((ref) async {
          ref.watch(customPigmentsRefreshProvider);
          if (extrasShouldFail) {
            throw StateError('custom pigment store unavailable');
          }
          return [extraPigment];
        }),
      ],
    );
    addTearDown(container.dispose);

    final first = await container.read(engineProvider.future);
    expect(first.getPigment('custom_keep'), isNotNull);

    extrasShouldFail = true;
    container.read(customPigmentsRefreshProvider.notifier).state++;

    final second = await container.read(engineProvider.future);
    expect(second.getPigment('custom_keep'), isNotNull);
  });

  test('engineProvider logs a stack trace when custom pigments fail to load',
      () async {
    final previousPrint = debugPrint;
    final logs = <String>[];
    debugPrint = (message, {wrapWidth}) {
      logs.add(message ?? '');
    };
    addTearDown(() => debugPrint = previousPrint);

    final backend = await testEngineBackend();
    var extrasShouldFail = false;
    final extraPigment = testPigment(
      'custom_keep',
      'Keep me',
      List.filled(41, 0.4),
    );
    final container = ProviderContainer(
      overrides: [
        engineBackendProvider.overrideWith((ref) async => backend),
        mediumLibraryProvider.overrideWith((ref) async => MediumLibrary({})),
        customPigmentModelsProvider.overrideWith((ref) async {
          ref.watch(customPigmentsRefreshProvider);
          if (extrasShouldFail) {
            throw StateError('custom pigment store unavailable');
          }
          return [extraPigment];
        }),
      ],
    );
    addTearDown(container.dispose);

    await container.read(engineProvider.future);
    extrasShouldFail = true;
    container.read(customPigmentsRefreshProvider.notifier).state++;
    await container.read(engineProvider.future);

    final logged = logs.join('\n');
    expect(logged, contains('custom pigment store unavailable'));
    expect(logged, contains('#0'));
  });
}
