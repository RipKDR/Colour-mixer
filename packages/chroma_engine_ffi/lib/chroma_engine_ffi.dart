import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Platform-specific candidates for loading `libchroma_engine`.
class ChromaEngineFfi {
  ChromaEngineFfi._();

  static const libraryBaseName = 'chroma_engine';

  /// Explicit override for development and testing.
  static const _envOverride = 'CHROMA_ENGINE_LIB';

  /// Every symbol the Dart binding looks up; a library missing any of these
  /// is stale or foreign and must be rejected so the app falls back to the
  /// Dart engine instead of failing at first use.
  static const _requiredSymbols = [
    'chroma_init',
    'chroma_pigment_count',
    'chroma_get_pigment',
    'chroma_get_pigment_reflectance',
    'chroma_free_string',
    'chroma_mix',
  ];

  /// Ordered list of library open targets for the current platform.
  static List<ChromaLibraryTarget> targetsForCurrentPlatform() {
    final override = Platform.environment[_envOverride];
    final targets = <ChromaLibraryTarget>[
      if (override != null && override.isNotEmpty)
        ChromaLibraryTarget.file(override),
    ];
    if (Platform.isLinux) {
      final devBuild = _devBuildPath('lib$libraryBaseName.so');
      targets.addAll([
        // Flutter Linux bundles place shared libraries next to the executable.
        ChromaLibraryTarget.file(
          p.join(p.dirname(Platform.resolvedExecutable), 'lib',
              'lib$libraryBaseName.so'),
        ),
        const ChromaLibraryTarget.file('libchroma_engine.so'),
        if (devBuild != null) ChromaLibraryTarget.file(devBuild),
      ]);
    } else if (Platform.isAndroid) {
      targets.add(const ChromaLibraryTarget.file('lib$libraryBaseName.so'));
    } else if (Platform.isMacOS) {
      targets.addAll(const [
        ChromaLibraryTarget.file('lib$libraryBaseName.dylib'),
        ChromaLibraryTarget.process(),
      ]);
    } else if (Platform.isIOS) {
      targets.add(const ChromaLibraryTarget.process());
    } else if (Platform.isWindows) {
      targets.add(const ChromaLibraryTarget.file('$libraryBaseName.dll'));
    }
    return targets;
  }

  /// Walks up from the working directory looking for a local cargo release
  /// build (monorepo development and `flutter test` runs).
  static String? _devBuildPath(String fileName) {
    var dir = Directory.current;
    for (var depth = 0; depth < 6; depth++) {
      final candidate = p.join(
        dir.path,
        'packages',
        'chroma_engine',
        'target',
        'release',
        fileName,
      );
      if (File(candidate).existsSync()) return candidate;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return null;
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

  static bool _hasRequiredSymbols(DynamicLibrary lib) =>
      _requiredSymbols.every(lib.providesSymbol);
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
