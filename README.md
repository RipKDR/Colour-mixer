# ChromaStudio

Premium mobile colour mixing laboratory for fine artists. Spectral Kubelka-Munk pigment mixing with virtual palette and precision modes.

## Structure

```
chromastudio/
├── apps/mobile/           # Flutter app (iOS, Android, Linux)
├── packages/chroma_engine/ # Rust spectral mixing engine
├── data/pigments/         # Pigment spectral reflectance data
└── tools/                 # Data generation scripts
```

## Quick Start

### Rust Engine

```bash
cd packages/chroma_engine
cargo test
```

### Flutter App

```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Optional: build native Rust engine for Linux FFI
../../tools/build_engine.sh

# Run (Linux desktop)
LD_LIBRARY_PATH=../../packages/chroma_engine/target/release flutter run -d linux
```

Settings → Mixing engine shows **Rust (native FFI)** when the `.so` is loaded, otherwise **Dart**.

## Phase 1 Features

- Spectral Kubelka-Munk mixing (41-sample reflectance, 20 pigments)
- Virtual Palette mode with draggable blobs and palette knife
- Precision mode with multi-unit ratio display
- Basic round-brush canvas with undo/redo
- Offline recipe save/load (SQLite via Drift)
- Dark mode and accessibility semantics

## License

Proprietary - ChromaStudio v1.0
