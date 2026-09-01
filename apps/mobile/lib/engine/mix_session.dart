import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog.dart';
import 'chroma_engine.dart';
import 'mediums.dart';
import 'native_engine.dart';

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
    this.showDryingPreview = false,
    this.lockRatios = false,
    this.swatchBackground = SwatchBackground.white,
    this.quantityUnit = QuantityUnit.parts,
    this.mediumId,
    this.mediumAmount = 0,
    this.dryingTime = DryingTime.oneWeek,
    this.binder = 'acrylic',
    this.isLoading = false,
  });

  final List<MixEntry> entries;
  final MixMode mode;
  final MixResult? result;
  final bool showUndertone;
  final bool showDryingPreview;
  final bool lockRatios;
  final SwatchBackground swatchBackground;
  final QuantityUnit quantityUnit;
  final String? mediumId;
  final double mediumAmount;
  final DryingTime dryingTime;
  final String binder;
  final bool isLoading;

  List<double> get weights => entries.map((e) => e.weight).toList();

  MixSessionState copyWith({
    List<MixEntry>? entries,
    MixMode? mode,
    MixResult? result,
    bool? showUndertone,
    bool? showDryingPreview,
    bool? lockRatios,
    SwatchBackground? swatchBackground,
    QuantityUnit? quantityUnit,
    String? mediumId,
    double? mediumAmount,
    DryingTime? dryingTime,
    String? binder,
    bool? isLoading,
    bool clearMedium = false,
  }) {
    return MixSessionState(
      entries: entries ?? this.entries,
      mode: mode ?? this.mode,
      result: result ?? this.result,
      showUndertone: showUndertone ?? this.showUndertone,
      showDryingPreview: showDryingPreview ?? this.showDryingPreview,
      lockRatios: lockRatios ?? this.lockRatios,
      swatchBackground: swatchBackground ?? this.swatchBackground,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      mediumId: clearMedium ? null : (mediumId ?? this.mediumId),
      mediumAmount: mediumAmount ?? this.mediumAmount,
      dryingTime: dryingTime ?? this.dryingTime,
      binder: binder ?? this.binder,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final engineBackendProvider = FutureProvider<EngineBackend>((ref) async {
  return createEngineBackend();
});

final engineProvider = FutureProvider<ChromaEngine>((ref) async {
  final backend = await ref.watch(engineBackendProvider.future);
  final pigments = {for (final p in backend.listPigments()) p.id: p};
  return ChromaEngine(pigments);
});

class MixSessionNotifier extends StateNotifier<MixSessionState> {
  MixSessionNotifier(EngineBackend backend, MediumLibrary? mediums)
      : _backend = backend,
        _mediums = mediums,
        super(
          MixSessionState(
            entries: [
              MixEntry(pigmentId: 'ultramarine_blue'),
              MixEntry(pigmentId: 'hansa_yellow'),
            ],
            mode: MixMode.precision,
            result: _computeMix(
              backend,
              mediums,
              [
                const MixComponent(pigmentId: 'ultramarine_blue', weight: 1),
                const MixComponent(pigmentId: 'hansa_yellow', weight: 1),
              ],
              null,
              0,
            ),
          ),
        );

  MixSessionNotifier._placeholder()
      : _backend = null,
        _mediums = null,
        super(
          const MixSessionState(
            entries: [],
            mode: MixMode.precision,
            result: null,
            isLoading: true,
          ),
        );

  final EngineBackend? _backend;
  final MediumLibrary? _mediums;
  Timer? _debounce;

  static MixResult _computeMix(
    EngineBackend backend,
    MediumLibrary? mediums,
    List<MixComponent> components,
    String? mediumId,
    double mediumAmount,
  ) {
    var result = backend.mix(components);
    if (mediumId != null && mediums != null && mediumAmount > 0) {
      final medium = mediums.get(mediumId);
      if (medium != null) {
        result = applyMedium(result, medium, mediumAmount);
      }
    }
    return result;
  }

  void setMode(MixMode mode) => state = state.copyWith(mode: mode);

  void toggleUndertone() =>
      state = state.copyWith(showUndertone: !state.showUndertone);

  void toggleDryingPreview() =>
      state = state.copyWith(showDryingPreview: !state.showDryingPreview);

  void toggleLockRatios() =>
      state = state.copyWith(lockRatios: !state.lockRatios);

  void setSwatchBackground(SwatchBackground bg) =>
      state = state.copyWith(swatchBackground: bg);

  void setQuantityUnit(QuantityUnit unit) =>
      state = state.copyWith(quantityUnit: unit);

  void setMedium(String? id, double amount) {
    state = state.copyWith(
      mediumId: id,
      mediumAmount: amount,
      clearMedium: id == null,
    );
    _scheduleMix();
  }

  void setDryingTime(DryingTime time) =>
      state = state.copyWith(dryingTime: time);

  void setBinder(String binder) => state = state.copyWith(binder: binder);

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
      final total = entries.fold<double>(0, (s, e) => s + e.weight);
      final ratio = total > 0 ? entries[index].weight / total : 0;
      final newTotal = ratio == 0 ? weight : weight / ratio;
      for (var i = 0; i < entries.length; i++) {
        final r = total > 0 ? entries[i].weight / total : 0;
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
    final backend = _backend;
    if (backend == null) return;
    final components = state.entries
        .where((e) => e.weight > 0)
        .map((e) => MixComponent(pigmentId: e.pigmentId, weight: e.weight))
        .toList();
    final result = _computeMix(
      backend,
      _mediums,
      components,
      state.mediumId,
      state.mediumAmount,
    );
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
  final backendAsync = ref.watch(engineBackendProvider);
  final mediumsAsync = ref.watch(mediumLibraryProvider);
  return backendAsync.when(
    data: (backend) => MixSessionNotifier(
      backend,
      mediumsAsync.valueOrNull,
    ),
    loading: () => MixSessionNotifier._placeholder(),
    error: (_, __) => MixSessionNotifier._placeholder(),
  );
});
