# ChromaStudio — Architecture & Design

Companion docs: `docs/ENGINE.md` (colour science + FFI), `docs/FEATURES.md`
(feature-to-file map), `docs/adr/001-flutter-rust-architecture.md` (original ADR).

## High-level shape

```
┌─────────────────────────────── apps/mobile (Flutter) ───────────────────────────────┐
│  features/* screens  ──(Riverpod)──►  engine/mix_session.dart  (MixSessionNotifier) │
│                                             │                                       │
│                                             ▼                                       │
│                                   EngineBackend (interface)                         │
│                                   ├── DartEngineBackend  ← always available         │
│                                   └── NativeEngineBackend ← via dart:ffi            │
└──────────────────────────────────────────────┼──────────────────────────────────────┘
                                               │ C ABI (packages/chroma_engine_ffi)
                                               ▼
                              packages/chroma_engine (Rust, cdylib)
                              Kubelka–Munk mix • colorimetry • drying
```

- **UI never computes colour itself.** Screens dispatch to `mixSessionProvider`;
  results (`MixResult`: Lab, sRGB colour, 41-sample reflectance, gloss, medium)
  flow back through Riverpod.
- **Backend selection is automatic.** `engineBackendProvider` tries the native
  library first (symbol-verified); otherwise uses the Dart engine. The Settings
  screen displays which backend is active ("full spectra" vs "Lab only" historic
  label; native now returns full spectra too).

## State management (Riverpod)

| Provider | File | Role |
|----------|------|------|
| `engineBackendProvider` | `engine/mix_session.dart` | async; picks native vs Dart backend |
| `engineProvider` | `engine/mix_session.dart` | `FutureProvider<ChromaEngine>`; pigment map for UI |
| `mixSessionProvider` | `engine/mix_session.dart` | current mix: entries, weights, medium, mode, result |
| `colorTargetProvider` | `features/match/color_match.dart` | optional Lab target for matching |
| `matchAnalysisProvider` | `features/match/color_match.dart` | derived ΔE + metamerism risk vs target |
| `inventoryProvider` | `features/inventory/inventory_provider.dart` | Drift-backed tube list |
| `recipesProvider` | `features/recipes/recipes_provider.dart` | saved recipes |
| `themeModeProvider`, `highContrastProvider`, unit settings | `core/settings_provider.dart` | app settings |
| `mixShaderProvider` | `engine/mix_shader.dart` | loads `mix_blend.frag` FragmentShader |

`MixSessionNotifier` debounces recomputes (`_scheduleMix`) so slider drags don't
thrash the engine.

## Navigation (go_router)

`core/router.dart`. A `StatefulShellRoute.indexedStack` provides the bottom nav
with six branches: `/mix`, `/canvas`, `/recipes`, `/learn`, `/inventory`,
`/settings`. Full-screen tool routes sit outside the shell: `/preview`, `/glaze`,
`/catalog`, `/light-booth`, `/match`, and nested `/match/eyedropper`.

## Persistence (Drift/SQLite)

`features/recipes/database.dart`, generated code committed in `database.g.dart`.
`schemaVersion = 2`. Tables:

- **Recipes** — name, notes, pigment entries (JSON), Lab + ARGB snapshot, binder.
- **InventoryItems** — pigmentId, brand, tube size ml, price, remaining fraction.
- **LessonProgress** — per-lesson best ΔE for Learn challenges.

Migration strategy: `onUpgrade` adds the v2 tables. Any schema change requires a
version bump + migration + `build_runner` regeneration.

## Data pipeline

- Source of truth: `data/pigments/all_pigments.json` (20 pigments; identity,
  pigment codes, 41-sample reflectance, opacity, tinting strength, toxicity,
  binder). Generated/curated via `tools/generate_pigments.py`.
- Bundled copies: `apps/mobile/assets/pigments/` and
  `apps/mobile/assets/data/brands/` (6 brands: Winsor & Newton, Golden, Liquitex,
  Daniel Smith, Schmincke, Holbein). Brand JSON maps marketing names → pigment ids
  + series/price info; loaded by `engine/catalog.dart`.
- The Rust engine embeds the same pigment data at build time (see
  `packages/chroma_engine/src/pigment.rs`).

## Key domain flows

**Mixing:** entries (pigmentId + weight) → engine converts reflectance → K/S,
mixes weighted K/S (Kubelka–Munk), converts back → reflectance → XYZ (D65 2°
observer) → Lab + sRGB. Mediums adjust spectra/gloss; drying simulation shifts
wet→dry (binder-dependent, oil yellowing); glaze simulator stacks translucent
layers over a base.

**Colour match:** target comes from sliders, presets, or the photo eyedropper
(3×3-averaged sample → `Colorimetry.srgbToLab`). `matchAnalysisProvider` computes
CIEDE2000 vs the current mix and max ΔE shift across illuminants (D50,
incandescent, fluorescent, LED) — >4 ΔE flags metamerism.

**Suggest recipe (solver):** `MixSolver` ranks pigments by single-pigment ΔE to
the target, searches subsets ≤3 from the top 8, refines weights by multiplicative
coordinate descent on CIEDE2000. Optional `restrictTo` limits to inventory
pigment ids. Runs off-thread via `compute(solveMixRequest, SolveRequest)`.

**Recipe share/import:** plain-text share, PDF export (`pdf` package), and
machine-readable `chromastudio-recipe-v1` JSON (export + import via
`file_picker`; parser in `features/match/color_match.dart::parseRecipeJson`).

## Design principles observed in the codebase

1. **Spectra over RGB everywhere** — RGB is a terminal rendering step only.
2. **Dart engine is the reference implementation**; Rust must match it. Tests pin
   the Dart behaviour; Rust has its own unit/integration tests.
3. **Graceful degradation** — every native/hardware capability (FFI, camera,
   haptics, shader) has a fallback or a no-op path so tests and CI stay green.
4. **Feature-folder layout** — one folder per screen under `lib/features/`,
   engine/domain logic under `lib/engine/`, cross-cutting under `lib/core/`.
5. **TDD for engine/domain code** — see `apps/mobile/test/`; UI is covered thinly
   (one widget smoke test) — acceptable for now, flagged in HANDOVER.

## CI

`.github/workflows/ci.yml`, two jobs on push to `main`/`cursor/**` and PRs:

- **rust**: `cargo test` + `cargo build --release` in `packages/chroma_engine`.
- **flutter**: Flutter 3.27.1, `pub get`, `build_runner build`, `analyze`, `test`.
  Note: this job has no native `.so`, so tests run on the Dart fallback engine —
  by design; never write a test requiring the native backend.
