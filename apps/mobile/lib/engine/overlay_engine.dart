import 'chroma_engine.dart';
import 'native_engine.dart';

/// Native or Dart engine plus user-defined pigments.
///
/// Mixes that include a custom pigment always run through the Dart KM
/// engine (the Rust library only knows the bundled catalog).
class OverlayEngineBackend implements EngineBackend {
  OverlayEngineBackend(this._inner, List<PigmentModel> extra)
      : _extra = List.unmodifiable(extra),
        _extraIds = {for (final p in extra) p.id} {
    if (_extra.isNotEmpty) {
      _dart = ChromaEngine({
        for (final p in [..._inner.listPigments(), ..._extra]) p.id: p,
      });
    }
  }

  final EngineBackend _inner;
  final List<PigmentModel> _extra;
  final Set<String> _extraIds;
  ChromaEngine? _dart;

  @override
  Future<void> init() => _inner.init();

  @override
  List<PigmentModel> listPigments() => [..._inner.listPigments(), ..._extra];

  @override
  MixResult mix(List<MixComponent> components) {
    final dart = _dart;
    if (dart != null) {
      if (components.any((c) => _extraIds.contains(c.pigmentId))) {
        return dart.mix(components);
      }
    }
    return _inner.mix(components);
  }

  @override
  bool get hasFullSpectra => _inner.hasFullSpectra;
}
