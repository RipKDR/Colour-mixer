# CLAUDE.md — Agent Operating Manual for ChromaStudio

This file tells any AI agent (Claude, Cursor, etc.) how to work on this repository
effectively. Read this first, then `docs/HANDOVER.md` for where the last session
left off, and `docs/DESIGN.md` for architecture.

## What this project is

**ChromaStudio** is a spectral paint-mixing app for fine artists (oil/acrylic/watercolour).
It predicts real pigment mixing using Kubelka–Munk theory over 41-sample reflectance
spectra (380–780 nm, 10 nm steps), not naive RGB blending. Flutter UI + Rust engine.

- GitHub: https://github.com/RipKDR/Colour-mixer (default branch `main`, the only branch)
- Monorepo. The Flutter app lives in `apps/mobile/`, the Rust engine in
  `packages/chroma_engine/`, the FFI plugin in `packages/chroma_engine_ffi/`.

## Environment specifics (this dev VM)

- Flutter SDK is vendored at `/agent/flutter` — use `/agent/flutter/bin/flutter`,
  it is NOT on PATH.
- Rust stable (1.83) is on PATH (`cargo`, `rustc`).
- `gh` CLI is at `/exec-daemon/gh` (on PATH). It may or may not be authenticated in a
  fresh VM; check `gh auth status`. Git user is configured.
- There is a `flutter/` directory at repo root (the vendored SDK). Do not commit it —
  it is untracked/ignored; leave it alone.

## Commands you will actually use

All commands below assume the repo root is `/agent` (adjust if different).

```bash
# Rust engine: test + build the shared library (needed for native-backed Flutter tests)
cd packages/chroma_engine && cargo test --release && cargo build --release

# Flutter: analyze and test (run from apps/mobile)
cd apps/mobile && /agent/flutter/bin/flutter analyze
cd apps/mobile && /agent/flutter/bin/flutter test

# Drift codegen (after editing database.dart tables)
cd apps/mobile && /agent/flutter/bin/dart run build_runner build --delete-conflicting-outputs

# Desktop Linux build of the native engine + copy (convenience script)
./tools/build_engine.sh

# Mobile native builds (Android needs cargo-ndk + NDK; iOS needs a Mac)
./tools/build_mobile.sh android   # or: ios
```

## Critical gotchas

1. **Rebuild Rust before Flutter tests when you touch the FFI surface.**
   The Dart FFI loader (`packages/chroma_engine_ffi/lib/chroma_engine_ffi.dart`)
   prefers `/agent/packages/chroma_engine/target/release/libchroma_engine.so` on Linux
   and verifies required symbols (`chroma_init`, `chroma_get_pigment_reflectance`)
   before accepting a library. A stale `.so` silently falls back to the Dart engine.
   If you add an FFI function: add it to `src/api.rs`, rebuild with
   `cargo build --release`, add it to the required-symbols check, then run Flutter tests.
2. **The engine exists twice.** The reference implementation is pure Dart
   (`apps/mobile/lib/engine/chroma_engine.dart`); the native one is Rust
   (`packages/chroma_engine/src/`). Any mixing/colorimetry change must be mirrored in
   both or their results diverge. Tests cover the Dart side; `cargo test` covers Rust.
3. **CI has no native library for the Flutter job** — Flutter tests must pass with the
   Dart fallback engine. Never write a test that requires the native backend.
4. **`fromJson`/DB codegen:** `database.g.dart` is committed. Regenerate with
   build_runner after schema edits and bump `schemaVersion` + add a migration in
   `database.dart` (currently version 2).
5. **Never block the UI isolate with the solver.** `MixSolver` runs via
   `compute(solveMixRequest, SolveRequest(...))` — keep it that way.

## Workflow conventions used in this repo

- **TDD**: write the failing test first (see `apps/mobile/test/` for style), watch it
  fail, implement minimally, watch it pass. This caught a real `labToSrgb` bug.
- **Verification before claiming done**: run `flutter analyze` + `flutter test` +
  `cargo test --release` and read the output before saying anything passes.
- Imports at top of file only; no inline imports.
- Exhaustive `switch` over enums (Dart analyzer enforces missing cases; keep it that way).
- Commit messages: imperative summary line, no prefix convention beyond optional `feat:`.
- Push to `main` (no PR flow is set up; the repo owner works directly on main).
  CI (`.github/workflows/ci.yml`) runs Rust tests/build and Flutter analyze/test on push.

## Repository map

```
apps/mobile/               Flutter app (package name: chromastudio)
  lib/core/                router, theme, settings providers, haptics
  lib/engine/              Dart engine: chroma_engine.dart (KM + colorimetry),
                           mix_session.dart (Riverpod state), native_engine.dart (FFI backend),
                           mix_solver.dart, mediums.dart, catalog.dart, mix_cost.dart, mix_shader.dart
  lib/features/<feature>/  one folder per screen/feature (see docs/FEATURES.md)
  assets/pigments/         all_pigments.json (20 pigments, bundled)
  assets/data/brands/      6 brand catalogs (JSON)
  assets/shaders/          mix_blend.frag (palette blend preview)
  test/                    6 test files, 21 tests
packages/chroma_engine/    Rust engine (cargo lib, cdylib + staticlib)
packages/chroma_engine_ffi/ Flutter FFI plugin (loader + Android/iOS scaffolding)
data/                      source-of-truth pigment/brand data (mirrored into assets)
tools/                     build_engine.sh, build_mobile.sh, generate_pigments.py
docs/                      DESIGN.md, ENGINE.md, HANDOVER.md, ROADMAP.md, FEATURES.md, adr/
```

## Where to start for common tasks

| Task | Start here |
|------|------------|
| New screen | `lib/core/router.dart` (route) + new folder in `lib/features/` |
| Mixing/colour math | `lib/engine/chroma_engine.dart` AND `packages/chroma_engine/src/` |
| New FFI function | `packages/chroma_engine/src/api.rs` + `lib/engine/native_engine.dart` + loader symbol check |
| Recipe/inventory persistence | `lib/features/recipes/database.dart` (+ build_runner) |
| New pigment/brand data | `data/`, mirror into `apps/mobile/assets/`, `lib/engine/catalog.dart` |
| Solver behaviour | `lib/engine/mix_solver.dart` + `test/mix_solver_test.dart` |
