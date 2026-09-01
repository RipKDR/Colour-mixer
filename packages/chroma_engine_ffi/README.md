# chroma_engine_ffi

Flutter FFI helpers for loading the ChromaStudio Rust `chroma_engine` native library on mobile and desktop.

## Building for Android

```bash
# Install cargo-ndk, then from repo root:
./tools/build_mobile.sh android
```

Copy resulting `.so` files into `android/app/src/main/jniLibs/<abi>/libchroma_engine.so`.

## Building for iOS

```bash
./tools/build_mobile.sh ios
```

Link the produced static library in Xcode (Runner target → Build Phases → Link Binary With Libraries).

## Usage

```dart
import 'package:chroma_engine_ffi/chroma_engine_ffi.dart';

final lib = ChromaEngineFfi.tryOpen();
```

The mobile app falls back to the Dart spectral engine when the native library is not packaged.
