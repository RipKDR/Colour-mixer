import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chromastudio/engine/catalog.dart';
import 'package:chromastudio/engine/chroma_engine.dart';
import 'package:chromastudio/engine/mediums.dart';
import 'package:chromastudio/engine/mix_session.dart';
import 'package:chromastudio/engine/native_engine.dart';
import 'package:chromastudio/features/pigments/custom_pigments_provider.dart';

import 'support/engine_fixtures.dart';

class _SessionIds extends ConsumerWidget {
  const _SessionIds();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(mixSessionProvider);
    final engine = ref.watch(engineProvider);
    if (session.isLoading || engine.isLoading) {
      return const Text('loading');
    }
    return Text(session.entries.map((e) => e.pigmentId).join(','));
  }
}

void main() {
  late DartEngineBackend backend;
  late PigmentModel extra;

  setUp(() async {
    backend = await testEngineBackend();
    extra = testPigment(
      'custom_1',
      'Mine',
      List.filled(Colorimetry.spectrumSamples, 0.4),
    );
  });

  Future<ProviderContainer> pumpSession(
    WidgetTester tester, {
    required Future<List<PigmentModel>> Function(Ref ref) loadExtras,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          engineBackendProvider.overrideWith((ref) async => backend),
          mediumLibraryProvider.overrideWith(
            (ref) async => MediumLibrary({}),
          ),
          customPigmentModelsProvider.overrideWith(loadExtras),
        ],
        child: const MaterialApp(home: Scaffold(body: _SessionIds())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('loading'), findsNothing);
    return ProviderScope.containerOf(
      tester.element(find.byType(_SessionIds)),
    );
  }

  testWidgets('refreshing custom pigments does not reset mix entries',
      (tester) async {
    var extras = [extra];
    final container = await pumpSession(
      tester,
      loadExtras: (ref) async {
        ref.watch(customPigmentsRefreshProvider);
        return extras;
      },
    );

    container.read(mixSessionProvider.notifier).addPigment('titanium_white');
    await tester.pump();
    expect(find.textContaining('titanium_white'), findsOneWidget);

    extras = [
      extra,
      testPigment(
        'custom_2',
        'Other',
        List.filled(Colorimetry.spectrumSamples, 0.3),
      ),
    ];
    container.read(customPigmentsRefreshProvider.notifier).state++;
    await tester.pumpAndSettle();

    expect(find.textContaining('titanium_white'), findsOneWidget);
  });

  testWidgets('failed custom pigment reload keeps the mix session',
      (tester) async {
    var shouldFail = false;
    final container = await pumpSession(
      tester,
      loadExtras: (ref) async {
        ref.watch(customPigmentsRefreshProvider);
        if (shouldFail) {
          throw Exception('db down');
        }
        return [extra];
      },
    );

    container.read(mixSessionProvider.notifier).addPigment('titanium_white');
    await tester.pump();
    expect(find.textContaining('titanium_white'), findsOneWidget);

    shouldFail = true;
    container.read(customPigmentsRefreshProvider.notifier).state++;
    await tester.pumpAndSettle();

    expect(find.textContaining('titanium_white'), findsOneWidget);
    expect(
      container.read(engineProvider).valueOrNull?.getPigment('custom_1'),
      isNotNull,
    );
  });
}
