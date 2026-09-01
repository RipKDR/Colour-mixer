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

## Phase 2 Features

- **Learn** — 3 interactive colour-mixing challenges with CIEDE2000 ΔE scoring
- **Inventory** — Track paint tubes, amount left, and estimated value
- **Painting Preview** — Import a photo and overlay your current mix (blend modes + opacity)
- **Mediums** — Gel, glazing liquid, and flow improver with spectral dilution in Precision mode
- **Drying preview** — Wet vs dry swatch comparison (binder + dry-time aware)
- **Glaze simulator** — Layer translucent glazes over a base surface spectrally
- **Brand catalog** — Browse Golden and Winsor & Newton paints; add to mix
- **Recipe share** — Export recipe ratios and Lab values via system share sheet
- **Cost warnings** — Inventory-based cost estimate and low-stock alerts on mix
- Native Rust FFI on Linux (Settings shows active engine)

## License

Proprietary - ChromaStudio v1.0
