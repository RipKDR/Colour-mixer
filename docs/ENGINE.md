# ChromaStudio Engine — Colour Science & FFI Reference

The engine exists in two synchronized implementations:

- **Dart (reference):** `apps/mobile/lib/engine/chroma_engine.dart`
- **Rust (native):** `packages/chroma_engine/src/` — exposed over a C ABI, loaded
  by `packages/chroma_engine_ffi/lib/chroma_engine_ffi.dart` and consumed by
  `apps/mobile/lib/engine/native_engine.dart`

Any change to mixing or colorimetry must land in **both**.

## Spectral model

- Reflectance spectra: **41 samples, 380–780 nm at 10 nm steps**
  (`SPECTRUM_SAMPLES = 41` in Rust, mirrored in Dart).
- 20 pigments bundled (`data/pigments/all_pigments.json` / embedded in Rust):
  titanium_white, ivory_black, cadmium_red_light, cadmium_yellow,
  ultramarine_blue, phthalo_blue_gs, phthalo_green, yellow_ochre, burnt_sienna,
  raw_umber, alizarin_crimson, quinacridone_magenta, hansa_yellow, pyrrole_red,
  dioxazine_purple, cerulean_blue, viridian, naples_yellow, burnt_umber,
  paynes_gray.
- Each pigment: reflectance, opacity, tinting strength, pigment codes (e.g. PW6),
  toxicity, binder affinity.

## Kubelka–Munk mixing

1. Per wavelength: `K/S = (1 − R)² / (2R)` (reflectance clamped away from 0/1).
2. Weighted average of K/S across components; effective weight =
   `w·s / Σ(wⱼ·sⱼ)` (tinting strength sets *relative* dominance only, so a
   pure pigment always reproduces its own masstone).
3. Back-convert: `R = 1 + K/S − sqrt((K/S)² + 2·K/S)`.

This models subtractive pigment behaviour (blue + yellow → green), which plain
RGB averaging cannot.

## Colorimetry (Dart `Colorimetry` class; Rust `colorimetry.rs`)

- `spectrumToXyz` — real CIE 1931 2° observer tables and the CIE D65 SPD,
  sampled at the engine's 41 points (380–780 nm / 10 nm). Illuminant-aware
  variants `spectrumToLabUnder` / `spectrumToColorUnder` take an `Illuminant`.
- **Illuminants** (Dart enum): `d65` (CIE table), `d50`, `incandescent` (A,
  red-heavy `(wl/560)^5`), `fluorescent` (TL84 approx), `coolLed` (450 nm blue
  pump + phosphor), `warmLed` — used by the light booth and metamerism checks.
- `xyzToLab` normalizes against the white point computed from the engine's own
  CMF/illuminant integrals (≈95.02, 100, 108.81 for D65 at 10 nm sampling), so
  a perfect reflector is exactly Lab (100, 0, 0). `spectrumToLabUnder`
  normalizes to the *chosen illuminant's* white, so neutrals stay neutral
  under every light. The sRGB↔Lab matrix paths use the standard constants
  (95.047, 100.0, 108.883).
- `srgbToLab(r, g, b)` — gamma-decode → linear RGB → XYZ (sRGB D65 matrix) → Lab.
  Added for the photo eyedropper; roundtrip-tested against `labToSrgb`.
- `labToSrgb` — **fixed in commit `64df6e8`**: the Lab inverse nonlinearity now
  correctly cubes `f` (was applying the forward cube-root twice). Guarded by
  `test/srgb_to_lab_test.dart` roundtrip test.
- `ciede2000(lab1, lab2)` — full CIEDE2000 ΔE implementation, used for matching,
  learning challenge scores, solver objective, and metamerism detection
  (threshold: >4 ΔE shift across illuminants ⇒ metameric risk).

## Mediums, drying, glazing (`apps/mobile/lib/engine/mediums.dart`)

- `MediumLibrary`: per-binder mediums with dilution/gloss/drying modifiers that
  scale the mixed spectrum.
- `DryingSimulator`: wet→dry shift (value change, binder-specific; oils yellow
  slightly). Rust counterpart in `src/drying.rs`.
- `GlazeSimulator`: stacks translucent layers — per layer, transmittance blends
  the underlying reflectance with the glaze spectrum.

## Mix solver (`apps/mobile/lib/engine/mix_solver.dart`, Dart-only)

- Objective: minimize CIEDE2000 to a target Lab.
- Search: rank all pigments by single-pigment ΔE; take top 8; evaluate all
  subsets of size 1–3; refine each subset's weights with multiplicative
  coordinate descent (step 2.0 shrinking to ≤1.05, weights clamped 0.01–100,
  ≤6 rounds).
- Output: `MixSuggestion` with normalized weights (sum = 1.0), predicted ΔE and
  full `MixResult`.
- `restrictTo: Set<String>` limits candidates (inventory-only mode).
- Isolate entry point: `solveMixRequest(SolveRequest)` for `compute()`.
- Tests: `apps/mobile/test/mix_solver_test.dart` (6 tests incl. compute path).

## Rust FFI ABI (`packages/chroma_engine/src/api.rs`)

Engine state is a `static ENGINE: OnceLock<EngineState>` (thread-safe; do NOT
revert to `static mut` — parallel tests crashed under it).

| Function | Purpose |
|----------|---------|
| `chroma_init() -> u32` | initialize engine, returns pigment count |
| `chroma_pigment_count() -> u32` | pigment count |
| `chroma_get_pigment(index, *CPigmentInfo) -> i32` | pigment metadata by index |
| `chroma_get_pigment_reflectance(index, *f64, count) -> i32` | copy 41 reflectance samples (count must equal 41) |
| `chroma_mix(ids, weights, n, *CMixResult) -> i32` | KM mix → Lab, sRGB, and full reflectance (`CMixResult.reflectance: [f64; 41]`) |
| `chroma_color_difference(...) -> f64` | CIEDE2000 |
| `chroma_free_string(*c_char)` | free Rust-allocated strings |

### Library loading (`packages/chroma_engine_ffi`)

`ChromaEngineFfi.tryOpen()` iterates platform-specific candidate paths and
**verifies required symbols** (`chroma_init`, `chroma_get_pigment_reflectance`)
before accepting a library; otherwise the app falls back to the Dart engine.

- **Linux (dev/test):** prefers `/agent/packages/chroma_engine/target/release/libchroma_engine.so`
  (machine-local path — adjust if the repo moves), then bundled locations.
- **Android:** `libchroma_engine.so` from jniLibs
  (`packages/chroma_engine_ffi/android/src/main/jniLibs/<abi>/`); populate via
  `./tools/build_mobile.sh android` (cargo-ndk 4.1.2 + NDK 28.2.13676358).
  Validated on the Pixel 9 (API 35) emulator; the APK log confirms the native
  Rust engine loads with full spectra.
- **iOS:** static lib `Frameworks/libchroma_engine.a` vended by the podspec;
  build on a Mac via `./tools/build_mobile.sh ios`. **Untested.**

### Adding an FFI function — checklist

1. Implement + export in `src/api.rs` (`#[no_mangle] pub extern "C"`).
2. `cargo test --release && cargo build --release`.
3. Bind in `apps/mobile/lib/engine/native_engine.dart`.
4. If it's load-bearing, add to `_hasRequiredSymbols` in
   `packages/chroma_engine_ffi/lib/chroma_engine_ffi.dart`.
5. Mirror behaviour in the Dart engine if applicable; add Dart tests.
6. Run the full Flutter suite — it must pass on both backends.

## Test inventory (verified 2026-09-02: 100 Flutter + 18 Rust, all green)

| File | Covers |
|------|--------|
| `test/chroma_engine_test.dart` | KM mixing (blue+yellow→green, white tinting), K/S roundtrip, illuminant Lab differences, ratio formatting |
| `test/ciede2000_test.dart` | ΔE identity/positivity, labToSrgb validity |
| `test/srgb_to_lab_test.dart` | sRGB↔Lab roundtrip (regression guard for the labToSrgb fix), white/red sanity |
| `test/mix_solver_test.dart` | solver recovery of known mixes, weight normalization, empty/restricted pools, compute() entry point |
| `test/recipe_import_test.dart` | `chromastudio-recipe-v1` JSON parse/reject |
| `test/widget_test.dart` | app boot smoke test |
| Rust `cargo test` | KM math, colorimetry, drying, FFI api integration (6 unit + 4 integration) |
