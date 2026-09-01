# chroma_engine_ffi

Flutter FFI plugin for the ChromaStudio Rust `chroma_engine` native library.

## Build native libraries

```bash
# From repo root
./tools/build_mobile.sh android   # → android/src/main/jniLibs/
./tools/build_mobile.sh ios       # → ios/Frameworks/libchroma_engine.a
./tools/build_engine.sh           # Linux desktop .so
```

## Android

After `build_mobile.sh android`, the `.so` files are placed under
`android/src/main/jniLibs/<abi>/`. Flutter bundles them automatically via `ffiPlugin: true`.

## iOS

After `build_mobile.sh ios`, run `pod install` in `apps/mobile/ios`. The podspec
vends `Frameworks/libchroma_engine.a` when present. Symbols are resolved via
`DynamicLibrary.process()`.

## Dart usage

```dart
import 'package:chroma_engine_ffi/chroma_engine_ffi.dart';

final lib = ChromaEngineFfi.tryOpen();
```

The mobile app falls back to the Dart spectral engine when the native library is unavailable.

## FFI API (Rust)

- `chroma_init()` / `chroma_pigment_count()`
- `chroma_get_pigment(index, out)`
- `chroma_get_pigment_reflectance(index, out, 41)`
- `chroma_mix(ids, weights, count, out)` — `CMixResult` includes 41-sample reflectance
- `chroma_color_difference(l1,a1,b1,l2,a2,b2)`
