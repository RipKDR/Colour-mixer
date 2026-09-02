# ChromaStudio Roadmap & Status

Status as of 2026-09-01 (`main` @ `7bb9f53`, PRs #1 and #2 merged). ✅ done · 🔶 partial · ⬜ not started

## Phase 1 — MVP ✅

- ✅ Rust Kubelka–Munk spectral mixing engine (+ Dart reference implementation)
- ✅ Flutter app shell: bottom nav, theming (light/dark), go_router
- ✅ Palette mode (drag blobs, palette-knife mixing) & Precision mode (sliders)
- ✅ 20-pigment dataset with reflectance spectra
- ✅ CIEDE2000 colour difference
- ✅ Recipe saving (Drift/SQLite)

## Phase 2 — Craft tools ✅

- ✅ Mediums (dilution/gloss/drying modifiers per binder)
- ✅ Drying preview (wet→dry shift, oil yellowing)
- ✅ Glaze simulator (layered translucent stacking)
- ✅ Brand catalog browser
- ✅ Recipe sharing (plain text)
- ✅ Inventory ("Stock") with cost-of-mix + low-stock warnings
- ✅ Learn challenges (ΔE-scored mixing exercises, progress persisted)
- ✅ Painting preview (photo overlay with blend modes)

## Phase 3 — Pro colour ✅

- ✅ Virtual light booth (D65/D50/A/TL84/cool+warm LED)
- ✅ PDF recipe export
- ✅ Native full-spectra FFI (`CMixResult.reflectance`, `chroma_get_pigment_reflectance`)
- ✅ Thread-safe Rust engine (`OnceLock`)
- ✅ `chroma_engine_ffi` Flutter plugin package (Android/iOS scaffolding)
- ✅ Recipe JSON export (`chromastudio-recipe-v1`)
- ✅ Brand expansion (6 brands: W&N, Golden, Liquitex, Daniel Smith, Schmincke, Holbein)
- ✅ High-contrast accessibility mode, haptic feedback

## Phase 4 — Matching & intelligence 🔶 (shipped except mobile native builds)

- ✅ Color Match screen (Lab target, live ΔE, presets)
- ✅ Metamerism alerts (light booth + match screen, >4 ΔE threshold)
- ✅ Recipe JSON import (load-to-mix or save)
- ✅ Palette mix fragment shader (GPU blend preview)
- ✅ Mix solver — "Suggest recipe" (subset search + coordinate descent on ΔE)
- ✅ Photo eyedropper target picking (3×3 averaged sample → Lab)
- ✅ Inventory-aware solver ("Only suggest from my paints")
- ✅ Solver in background isolate (`compute`)
- ✅ Solver refinements: multiple alternative recipes, pigment-count penalty,
  opacity/translucency annotation on suggestions
- ✅ Swatch capture (photograph painted swatch vs predicted mix, ΔE verdict)
- ✅ Widget tests for Mix, Color Match, and Recipes screens
- ✅ Camera white-card chromatic adaptation (Bradford CAT to D65)
- ✅ Learn ranking (incomplete / weakest ΔE first, “Up next”)
- ✅ Custom pigment entry (Lab → synthesized 41-sample reflectance, Drift)
- ✅ Sourcery follow-up on PR #2: preserve mix session when custom pigments
  refresh; do not swallow load errors into `[]`; validate 41-sample
  `reflectanceJson` (`mix_session.dart`, `custom_pigments_provider.dart`)
- 🔶 Cloud recipe sync (email/password, explicit Push/Pull via `package:appwrite`;
  Drift stays authoritative; no community sharing / realtime / OAuth)
- ✅ Android device build validated — `./tools/build_mobile.sh android` (cargo-ndk 4.1.2, NDK 27.1, arm64-v8a + armeabi-v7a + x86_64), release APK installed on Pixel 9 (API 35) emulator; logcat confirmed `ChromaStudio: native Rust engine loaded (full spectra)`
- ⬜ iOS build validated (needs a Mac)
- ⬜ Precision-mode layout overflow on small screens (RenderFlex overflow in `precision_mode.dart` `_MiniSwatch` Column — cosmetic, screen scrolls but swatch column clips)

## Later / ideas (unscheduled)

- Golden tests for screens; broader widget test coverage
- User-measured reflectance curves (replace Lab synthesis)
- Recipe community sharing / realtime / OAuth / inventory+custom-pigment cloud sync
