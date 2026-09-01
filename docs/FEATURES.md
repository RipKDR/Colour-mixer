# Feature → File Map

Where every user-facing feature lives. Paths relative to repo root;
`lib/` means `apps/mobile/lib/`.

## Mixing

| Feature | Screens / UI | Logic |
|---------|--------------|-------|
| Mix hub (mode switch, tool shortcuts) | `lib/features/mix/mix_screen.dart` | `lib/engine/mix_session.dart` |
| Palette mode (blobs + palette knife) | `lib/features/mix/palette_mode.dart` | shader: `lib/engine/mix_shader.dart` + `apps/mobile/assets/shaders/mix_blend.frag` |
| Precision mode (sliders, mediums, drying, warnings) | `lib/features/mix/precision_mode.dart` | `lib/engine/mediums.dart`, `lib/engine/mix_cost.dart` |
| Spectral engine (KM, colorimetry, illuminants) | — | `lib/engine/chroma_engine.dart` (Dart) · `packages/chroma_engine/src/` (Rust) · loader `packages/chroma_engine_ffi/` · bridge `lib/engine/native_engine.dart` |

## Colour matching (Phase 4)

| Feature | Screens / UI | Logic |
|---------|--------------|-------|
| Color Match (Lab target, live ΔE, presets) | `lib/features/match/color_match_screen.dart` | `lib/features/match/color_match.dart` (`colorTargetProvider`, `matchAnalysisProvider`) |
| Photo eyedropper | `lib/features/match/photo_eyedropper_screen.dart` | `Colorimetry.srgbToLab` + optional Bradford white-card adapt (`lib/engine/photo_adapt.dart`) |
| Swatch capture (photo vs mix) | `lib/features/swatch/swatch_capture_screen.dart` | `lib/features/swatch/swatch_compare.dart` |
| Suggest recipe (solver + inventory filter + isolate) | suggestion sheet in `color_match_screen.dart` | `lib/engine/mix_solver.dart` |
| Metamerism alerts | match screen + light booth | illuminant sweep in `color_match.dart` / `light_booth_screen.dart` |

## Simulation tools

| Feature | File |
|---------|------|
| Glaze simulator | `lib/features/glaze/glaze_screen.dart` (+ `GlazeSimulator` in `lib/engine/mediums.dart`) |
| Virtual light booth | `lib/features/light_booth/light_booth_screen.dart` |
| Painting preview (photo overlay + blend modes) | `lib/features/preview/preview_screen.dart` |
| Canvas (freeform painting) | `lib/features/canvas/canvas_screen.dart` |

## Library & data

| Feature | File |
|---------|------|
| Brand catalog browser (6 brands) | `lib/features/catalog/brand_catalog_screen.dart` + `lib/engine/catalog.dart` + `apps/mobile/assets/data/brands/*.json` |
| Custom pigment entry (Lab → synthesized spectrum) | `lib/features/pigments/custom_pigments_screen.dart` | `lib/engine/spectrum_from_lab.dart`, overlay `lib/engine/overlay_engine.dart`, Drift `CustomPigments` |

## Recipes & inventory

| Feature | File |
|---------|------|
| Saved recipes (CRUD) | `lib/features/recipes/recipes_screen.dart`, `recipes_provider.dart` |
| Database (Drift, schema v2) | `lib/features/recipes/database.dart` (+ committed `database.g.dart`) |
| Share text / PDF export / JSON export | `lib/features/recipes/recipe_export.dart` + handlers in `recipes_screen.dart` |
| JSON import (`chromastudio-recipe-v1`) | `lib/features/recipes/recipe_import.dart`; parser `parseRecipeJson` in `lib/features/match/color_match.dart` |
| Inventory ("Stock"), mix cost, low-stock warnings | `lib/features/inventory/` + `lib/engine/mix_cost.dart` |

## Learning

| Feature | File |
|---------|------|
| Mixing challenges with ΔE scoring | `lib/features/learn/learn_screen.dart` (progress via `LessonProgress` table; ranking in `learn_rank.dart`) |

## App infrastructure

| Concern | File |
|---------|------|
| Routing (shell + tool routes) | `lib/core/router.dart` |
| Theme (light/dark, high contrast) | `lib/core/theme.dart` |
| Settings (theme, units, contrast, engine status, tool links) | `lib/features/settings/settings_screen.dart`, `lib/core/settings_provider.dart` |
| Haptics wrapper | `lib/core/haptics.dart` |
| App entry | `lib/main.dart` |
| CI | `.github/workflows/ci.yml` |
| Native build scripts | `tools/build_engine.sh` (Linux), `tools/build_mobile.sh` (Android/iOS) |
