import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chroma_engine.dart';

class MixEntry {
  MixEntry({required this.pigmentId, this.weight = 1.0});
  final String pigmentId;
  double weight;
}

enum MixMode { palette, precision }

enum SwatchBackground { white, black, grey, custom }

class MixSessionState {
  const MixSessionState({
    required this.entries,
    required this.mode,
    required this.result,
    this.showUndertone = false,
    this.lockRatios = false,
    this.swatchBackground = SwatchBackground.white,
    this.quantityUnit = QuantityUnit.parts,
    this.isLoading = false,
  });

  final List<MixEntry> entries;
  final MixMode mode;
  final MixResult? result;
  final bool showUndertone;
  final bool lockRatios;
  final SwatchBackground swatchBackground;
  final QuantityUnit quantityUnit;
  final bool isLoading;

  List<double> get weights => entries.map((e) => e.weight).toList();

  MixSessionState copyWith({
    List<MixEntry>? entries,
    MixMode? mode,
    MixResult? result,
    bool? showUndertone,
    bool? lockRatios,
    SwatchBackground? swatchBackground,
    QuantityUnit? quantityUnit,
    bool? isLoading,
  }) {
    return MixSessionState(
      entries: entries ?? this.entries,
      mode: mode ?? this.mode,
      result: result ?? this.result,
      showUndertone: showUndertone ?? this.showUndertone,
      lockRatios: lockRatios ?? this.lockRatios,
      swatchBackground: swatchBackground ?? this.swatchBackground,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final engineProvider = FutureProvider<ChromaEngine>((ref) async {
  final jsonStr =
      await rootBundle.loadString('assets/pigments/all_pigments.json');
  final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
  final pigments = {
    for (final item in list) item['id'] as String: PigmentModel.fromJson(item),
  };
  return ChromaEngine(pigments);
});

class MixSessionNotifier extends StateNotifier<MixSessionState> {
  MixSessionNotifier(ChromaEngine engine)
      : _engine = engine,
        super(
          MixSessionState(
            entries: [
              MixEntry(pigmentId: 'ultramarine_blue'),
              MixEntry(pigmentId: 'hansa_yellow'),
            ],
            mode: MixMode.precision,
            result: engine.mix([
              const MixComponent(pigmentId: 'ultramarine_blue', weight: 1),
              const MixComponent(pigmentId: 'hansa_yellow', weight: 1),
            ]),
          ),
        );

  MixSessionNotifier._placeholder()
      : _engine = null,
        super(
          const MixSessionState(
            entries: [],
            mode: MixMode.precision,
            result: null,
            isLoading: true,
          ),
        );

  final ChromaEngine? _engine;
  Timer? _debounce;

  void setMode(MixMode mode) => state = state.copyWith(mode: mode);

  void toggleUndertone() =>
      state = state.copyWith(showUndertone: !state.showUndertone);

  void toggleLockRatios() =>
      state = state.copyWith(lockRatios: !state.lockRatios);

  void setSwatchBackground(SwatchBackground bg) =>
      state = state.copyWith(swatchBackground: bg);

  void setQuantityUnit(QuantityUnit unit) =>
      state = state.copyWith(quantityUnit: unit);

  void addPigment(String pigmentId) {
    if (state.entries.any((e) => e.pigmentId == pigmentId)) return;
    final entries = [...state.entries, MixEntry(pigmentId: pigmentId)];
    state = state.copyWith(entries: entries);
    _scheduleMix();
  }

  void removePigment(int index) {
    if (state.entries.length <= 1) return;
    final entries = [...state.entries]..removeAt(index);
    state = state.copyWith(entries: entries);
    _scheduleMix();
  }

  void setWeight(int index, double weight) {
    if (weight < 0) weight = 0;
    final entries = [...state.entries];
    if (state.lockRatios && entries.isNotEmpty) {
      final ratio = entries[index].weight /
          entries.fold<double>(0, (s, e) => s + e.weight);
      final newTotal = weight / (ratio == 0 ? 1 : ratio);
      for (var i = 0; i < entries.length; i++) {
        final r = entries[i].weight /
            entries.fold<double>(0, (s, e) => s + e.weight);
        entries[i].weight = newTotal * r;
      }
    } else {
      entries[index].weight = weight;
    }
    state = state.copyWith(entries: entries);
    _scheduleMix();
  }

  void setEntriesFromPalette(List<MixEntry> entries) {
    state = state.copyWith(entries: entries);
    _scheduleMix();
  }

  void _scheduleMix() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 16), _recompute);
  }

  void _recompute() {
    if (_engine == null) return;
    final components = state.entries
        .where((e) => e.weight > 0)
        .map((e) => MixComponent(pigmentId: e.pigmentId, weight: e.weight))
        .toList();
    final result = _engine.mix(components);
    state = state.copyWith(result: result);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final mixSessionProvider =
    StateNotifierProvider<MixSessionNotifier, MixSessionState>((ref) {
  final engineAsync = ref.watch(engineProvider);
  return engineAsync.when(
    data: (engine) => MixSessionNotifier(engine),
    loading: () => MixSessionNotifier._placeholder(),
    error: (_, __) => MixSessionNotifier._placeholder(),
  );
});
