import 'dart:ffi';
import 'dart:io';

/// Platform-specific candidates for loading `libchroma_engine`.
class ChromaEngineFfi {
  ChromaEngineFfi._();

  static const libraryBaseName = 'chroma_engine';

  /// Ordered list of library open targets for the current platform.
  static List<ChromaLibraryTarget> targetsForCurrentPlatform() {
    if (Platform.isLinux) {
      return [
        const ChromaLibraryTarget.file('lib$libraryBaseName.so'),
        const ChromaLibraryTarget.file(
          '/agent/packages/chroma_engine/target/release/lib$libraryBaseName.so',
        ),
      ];
    }
    if (Platform.isAndroid) {
      return [const ChromaLibraryTarget.file('lib$libraryBaseName.so')];
    }
    if (Platform.isMacOS) {
      return [
        const ChromaLibraryTarget.file('lib$libraryBaseName.dylib'),
        const ChromaLibraryTarget.process(),
      ];
    }
    if (Platform.isIOS) {
      return [const ChromaLibraryTarget.process()];
    }
    if (Platform.isWindows) {
      return [const ChromaLibraryTarget.file('$libraryBaseName.dll')];
    }
    return const [];
  }

  /// Attempt to open the native library, returning null when unavailable.
  static DynamicLibrary? tryOpen() {
    for (final target in targetsForCurrentPlatform()) {
      try {
        final lib = switch (target.kind) {
          ChromaLibraryKind.file => DynamicLibrary.open(target.path!),
          ChromaLibraryKind.process => DynamicLibrary.process(),
        };
        if (_hasRequiredSymbols(lib)) return lib;
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static bool _hasRequiredSymbols(DynamicLibrary lib) {
    lib.lookupFunction<Uint32 Function(), int Function()>('chroma_init');
    lib.lookupFunction<
        Int32 Function(Uint32, Pointer<Double>, Uint32),
        int Function(int, Pointer<Double>, int)>('chroma_get_pigment_reflectance');
    return true;
  }
}

enum ChromaLibraryKind { file, process }

class ChromaLibraryTarget {
  const ChromaLibraryTarget.file(this.path) : kind = ChromaLibraryKind.file;
  const ChromaLibraryTarget.process()
      : path = null,
        kind = ChromaLibraryKind.process;

  final ChromaLibraryKind kind;
  final String? path;
}
