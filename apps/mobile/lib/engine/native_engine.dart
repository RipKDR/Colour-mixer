import 'dart:convert';
import 'dart:ffi';

import 'package:chroma_engine_ffi/chroma_engine_ffi.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'chroma_engine.dart';

/// Backend for spectral mixing — native Rust when available, Dart otherwise.
abstract class EngineBackend {
  Future<void> init();
  List<PigmentModel> listPigments();
  MixResult mix(List<MixComponent> components);
  bool get hasFullSpectra;
}

class DartEngineBackend implements EngineBackend {
  DartEngineBackend(this._inner);
  final ChromaEngine _inner;

  static Future<DartEngineBackend> create() async {
    final jsonStr =
        await rootBundle.loadString('assets/pigments/all_pigments.json');
    final list = (jsonDecode(jsonStr) as List).cast<Map<String, dynamic>>();
    final pigments = {
      for (final item in list) item['id'] as String: PigmentModel.fromJson(item),
    };
    return DartEngineBackend(ChromaEngine(pigments));
  }

  @override
  Future<void> init() async {}

  @override
  List<PigmentModel> listPigments() => _inner.allPigments;

  @override
  MixResult mix(List<MixComponent> components) => _inner.mix(components);

  @override
  bool get hasFullSpectra => true;
}

final class NativePigmentInfo extends Struct {
  external Pointer<Char> id;
  external Pointer<Char> name;
  @Double()
  external double opacity;
  @Double()
  external double tintingStrength;
  @Double()
  external double labL;
  @Double()
  external double labA;
  @Double()
  external double labB;
  @Double()
  external double srgbR;
  @Double()
  external double srgbG;
  @Double()
  external double srgbB;
}

final class NativeMixResult extends Struct {
  @Double()
  external double labL;
  @Double()
  external double labA;
  @Double()
  external double labB;
  @Double()
  external double srgbR;
  @Double()
  external double srgbG;
  @Double()
  external double srgbB;
  @Double()
  external double massR;
  @Double()
  external double massG;
  @Double()
  external double massB;
  @Double()
  external double undertoneR;
  @Double()
  external double undertoneG;
  @Double()
  external double undertoneB;
  @Array(Colorimetry.spectrumSamples)
  external Array<Double> reflectance;
}

class NativeEngineBackend implements EngineBackend {
  NativeEngineBackend(this._lib);

  final DynamicLibrary _lib;
  late final int Function() _init;
  late final int Function() _pigmentCount;
  late final int Function(int, Pointer<NativePigmentInfo>) _getPigment;
  late final int Function(int, Pointer<Double>, int) _getPigmentReflectance;
  late final void Function(Pointer<Char>) _freeString;
  late final int Function(
    Pointer<Pointer<Char>>,
    Pointer<Double>,
    int,
    Pointer<NativeMixResult>,
  ) _mixFn;
  List<PigmentModel>? _pigments;

  static Future<NativeEngineBackend?> tryLoad() async {
    if (kIsWeb) return null;
    try {
      final lib = ChromaEngineFfi.tryOpen();
      if (lib == null) return null;
      final engine = NativeEngineBackend(lib);
      await engine.init();
      return engine;
    } catch (e) {
      debugPrint('ChromaStudio: native engine unavailable: $e');
      return null;
    }
  }

  @override
  Future<void> init() async {
    _init = _lib.lookupFunction<Uint32 Function(), int Function()>('chroma_init');
    _pigmentCount = _lib
        .lookupFunction<Uint32 Function(), int Function()>('chroma_pigment_count');
    _getPigment = _lib.lookupFunction<
        Int32 Function(Uint32, Pointer<NativePigmentInfo>),
        int Function(int, Pointer<NativePigmentInfo>)>('chroma_get_pigment');
    _getPigmentReflectance = _lib.lookupFunction<
        Int32 Function(Uint32, Pointer<Double>, Uint32),
        int Function(int, Pointer<Double>, int)>('chroma_get_pigment_reflectance');
    _freeString = _lib.lookupFunction<Void Function(Pointer<Char>),
        void Function(Pointer<Char>)>('chroma_free_string');
    _mixFn = _lib.lookupFunction<
        Int32 Function(
          Pointer<Pointer<Char>>,
          Pointer<Double>,
          Uint32,
          Pointer<NativeMixResult>,
        ),
        int Function(
          Pointer<Pointer<Char>>,
          Pointer<Double>,
          int,
          Pointer<NativeMixResult>,
        )>('chroma_mix');
    _init();
    _pigments = _readPigments();
  }

  List<PigmentModel> _readPigments() {
    final count = _pigmentCount();
    final out = calloc<NativePigmentInfo>();
    final reflectanceBuf = calloc<Double>(Colorimetry.spectrumSamples);
    final list = <PigmentModel>[];
    try {
      for (var i = 0; i < count; i++) {
        if (_getPigment(i, out) != 0) continue;
        final info = out.ref;
        final id = info.id.cast<Utf8>().toDartString();
        final name = info.name.cast<Utf8>().toDartString();
        _freeString(info.id);
        _freeString(info.name);

        final reflectance = List<double>.filled(Colorimetry.spectrumSamples, 0);
        if (_getPigmentReflectance(
              i,
              reflectanceBuf,
              Colorimetry.spectrumSamples,
            ) ==
            0) {
          for (var j = 0; j < Colorimetry.spectrumSamples; j++) {
            reflectance[j] = reflectanceBuf[j];
          }
        }

        list.add(PigmentModel(
          id: id,
          name: name,
          pigmentCodes: const [],
          reflectance: reflectance,
          opacity: info.opacity,
          tintingStrength: info.tintingStrength,
          toxicity: 'unknown',
          binder: 'acrylic',
          lab: LabColor(info.labL, info.labA, info.labB),
          color: _toColor(info.srgbR, info.srgbG, info.srgbB),
        ));
      }
    } finally {
      calloc.free(out);
      calloc.free(reflectanceBuf);
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  List<double> _arrayToList(Array<Double> array) {
    return List.generate(
      Colorimetry.spectrumSamples,
      (i) => array[i],
    );
  }

  Color _toColor(double r, double g, double b) => Color.fromARGB(
        255,
        (r * 255).round(),
        (g * 255).round(),
        (b * 255).round(),
      );

  @override
  List<PigmentModel> listPigments() => _pigments ?? [];

  @override
  bool get hasFullSpectra => true;

  @override
  MixResult mix(List<MixComponent> components) {
    if (components.isEmpty) {
      final empty = List<double>.filled(Colorimetry.spectrumSamples, 0.5);
      return MixResult(
        lab: const LabColor(50, 0, 0),
        color: const Color(0xFF808080),
        massTone: const Color(0xFF808080),
        undertone: const Color(0xFF808080),
        reflectance: empty,
      );
    }

    final count = components.length;
    final idPtrs = calloc<Pointer<Char>>(count);
    final weights = calloc<Double>(count);
    final out = calloc<NativeMixResult>();

    try {
      for (var i = 0; i < count; i++) {
        idPtrs[i] = components[i].pigmentId.toNativeUtf8().cast<Char>();
        weights[i] = components[i].weight;
      }
      if (_mixFn(idPtrs, weights, count, out) != 0) {
        throw StateError('Native mix failed');
      }
      final r = out.ref;
      return MixResult(
        lab: LabColor(r.labL, r.labA, r.labB),
        color: _toColor(r.srgbR, r.srgbG, r.srgbB),
        massTone: _toColor(r.massR, r.massG, r.massB),
        undertone: _toColor(r.undertoneR, r.undertoneG, r.undertoneB),
        reflectance: _arrayToList(r.reflectance),
      );
    } finally {
      for (var i = 0; i < count; i++) {
        calloc.free(idPtrs[i].cast<Utf8>());
      }
      calloc.free(idPtrs);
      calloc.free(weights);
      calloc.free(out);
    }
  }
}

Future<EngineBackend> createEngineBackend() async {
  final native = await NativeEngineBackend.tryLoad();
  if (native != null) {
    debugPrint('ChromaStudio: native Rust engine loaded (full spectra)');
    return native;
  }
  debugPrint('ChromaStudio: using Dart engine');
  return DartEngineBackend.create();
}
