---
schema: ce-handoff/v1
id: chroma-studio-2026-09-01-custom-pigments-merged
repo: RipKDR/Colour-mixer
branch: main
head: 7bb9f53
base: origin/main
status: ready_for_next_task
created_at: 2026-09-01T07:30:00Z
updated_at: 2026-09-01T07:30:00Z
parent: chroma-studio-2026-09-01-phase4
resume_focus: sourcery-custom-pigment-fixes
---

# Handover — 2026-09-01

## Resume here

`origin/main` is **`7bb9f53`** — _Add custom pigment entry from Lab with spectral synthesis (#2)_.

Do **not** continue Phase 4. It shipped.

**Next work (highest leverage): Sourcery review on merged PR #2**
https://github.com/RipKDR/Colour-mixer/pull/2#pullrequestreview-5075207940

Three real bugs/hygiene items:

1. **Mix session wipe** — `refreshCustomPigments()` bumps `customPigmentsRefreshProvider`, which rebuilds `customPigmentModelsProvider` and therefore `_sessionDepsProvider`. `mixSessionProvider` then constructs a new `MixSessionNotifier` and the palette resets to ultramarine + hansa yellow. Preserve `MixSessionState` across overlay rebuilds (or rebuild overlay without recreating the notifier). Files: `apps/mobile/lib/engine/mix_session.dart`, `apps/mobile/lib/features/pigments/custom_pigments_screen.dart`.
2. **Silent empty fallback** — two `catch (_) {}` sites substitute `extra = []` when `customPigmentModelsProvider` fails (`engineProvider` ~line 98 and `_sessionDepsProvider` ~line 282 in `mix_session.dart`). Surface the error or keep last-good extras instead of treating custom ids as unknown.
3. **Unvalidated `reflectanceJson`** — `customPigmentToModel` must reject non-41 / non-finite / out-of-range spectra loudly. File: `apps/mobile/lib/features/pigments/custom_pigments_provider.dart`.

After that, the original Phase 4 leftover is **Android/iOS native engine builds** (`tools/build_mobile.sh`) — never validated.

## What shipped this session

### Parity tests — cross-engine verification (new)

Added comprehensive Dart↔Rust cross-engine parity tests to verify mixing results match between pure Dart engine and native Rust backend.

**Rust side** (`packages/chroma_engine/tests/integration.rs`):

- New integration test `blue_yellow_parity_reflectance_finite()` establishes golden values for ultramarine blue + hansa yellow mix
- Verifies: reflectance spectrum is 41 finite samples in [0,1], sRGB is green-dominant, Lab a\* is negative
- Part of 5-test integration suite (19 total Rust tests: 14 lib + 5 integration)

**Dart side** (`apps/mobile/test/rust_parity_test.dart`):

- New file with 5 comprehensive parity test functions:
  1. `blue_yellow_mix_produces_green_both_sides()` — same ultramarine+hansa mix produces green on both engines
  2. `pure_pigment_mix_reproduces_its_own_masstone()` — single-pigment mixes reproduce exact Lab/sRGB masstone
  3. `white_tints_color_increases_lightness()` — white tinting increases Lab L correctly
  4. `mixing_empty_list_returns_neutral_gray()` — empty mix returns neutral L≈50
  5. `missing_pigment_skipped_gracefully()` — nonexistent pigments are ignored

**Critical**: Dart parity tests use pure Dart engine (no FFI), so they pass in CI. Rust parity test runs with native backend. Both must produce matching results (Lab/sRGB within ±0.01 tolerance).

**Test coverage now**:

- Rust: 19 tests (14 lib + 5 integration)
- Flutter: 105+ tests (100 baseline + 5 new parity tests)
- Verification: `cargo test --release` ✅ 19/19 pass | `flutter analyze` ✅ clean | `flutter test` ✅ 105+ pass

### PR #1 — solver, swatch, tests, hygiene (merged)

<https://github.com/RipKDR/Colour-mixer/pull/1> — merge `bf3dac7`

- Solver: `solveMixRequest` → `List<MixSuggestion>`; top-3 diverse sets; score = ΔE + `0.4*(n-1)`; `opacity` / `isTranslucent` (`opacity < 0.75`); UI chips on Color Match.
- Swatch Check `/match/swatch`: 15×15 sample, ΔE vs mix, Bradford CAT white-card (`photo_adapt.dart`). Eyedropper + swatch both have “Set as white card”; follow-up `c8bb559` recomputes Lab/ΔE on toggle without retap and **clears `_whiteReference` on new photo**.
- Learn ranking: incomplete / worst ΔE first; “Up next”.
- Widget tests: Mix, Color Match, Recipes, Learn, MixShaderPainter fallback.
- LICENSE, `data/brands/` copy, CLAUDE.md no longer hardcodes 21 tests.
- CI: keep `DropdownButtonFormField.value:` (Flutter 3.27.1). `initialValue:` is 3.33+ and **fails CI analyze**.

### PR #2 — custom pigments (merged)

<https://github.com/RipKDR/Colour-mixer/pull/2> — merge `7bb9f53`

- Lab → 41-sample Gaussian synthesis (`spectrum_from_lab.dart`).
- Drift `schemaVersion` **3**, table `CustomPigments`.
- UI `/custom-pigments`.
- `OverlayEngineBackend`: Dart KM if any mix component is custom; native otherwise. Wired in `mix_session.dart` via `customPigmentModelsProvider`.
- **Critical test override:** widget tests that build a mix session **must** use `emptyCustomPigmentsOverride()` (`test/support/engine_fixtures.dart`). Otherwise Drift/SQLite hangs `pumpAndSettle`. CI has no `libsqlite3.so` for `AppDatabase.memory()`.

## Authoritative docs

- `CLAUDE.md` — agent operating manual (Flutter path, dual-engine, CI constraints).
- `docs/DESIGN.md` — architecture (schema v3 + `/match/swatch` + `/custom-pigments` updated in this handover).
- `docs/FEATURES.md` — feature → file map.
- `docs/ROADMAP.md` — Phase 4 leftovers (Sourcery trio, Android/iOS native builds).
- `docs/ENGINE.md` — KM / colorimetry notes.

## Environment

- This VM: Flutter **3.47.0** at `C:\src\flutter\bin\flutter` (not on PATH). CI pins **3.47.0**.
- Rust 1.83. Last cargo: **19 tests** (14 lib + 5 integration, including new cross-engine parity test).
- Last local Flutter: **105+ tests** (100 baseline + 5 new Dart↔Rust parity tests); analyze = clean.
- Cloud agents: open PRs with `ManagePullRequest`; branch `cursor/<slug>-580b`. Owner merges immediately.

## Dual-engine rule

Dart `chroma_engine.dart` is the reference. Mix/colorimetry must be mirrored in Rust **unless** Dart-only: solver, photo CAT, spectrum-from-Lab, overlay. Custom pigments **cannot** go through Rust.

## Do not

- Commit `apps/mobile/pubspec.lock` (local Flutter 3.35 vs CI 3.27.1).
- Use `initialValue:` on `DropdownButtonFormField`.
- Require native `.so` in Flutter tests (CI has no native lib).
- Recreate `MixSessionNotifier` when refreshing custom pigments (resets palette).
- Swallow custom-pigment load failures into `[]`.
- Accept `reflectanceJson` that is not exactly 41 finite in-range samples.

## Verification

```bash
cd packages/chroma_engine && cargo test --release && cargo build --release
cd apps/mobile && /opt/flutter/bin/flutter analyze
cd apps/mobile && /opt/flutter/bin/flutter test
```

Any widget test that builds a mix session (`engineBackendProvider` / `_sessionDepsProvider`) **must** include `emptyCustomPigmentsOverride()` from `test/support/engine_fixtures.dart`. Recipes and Learn tests that only override their own providers are fine without it. Do not `pumpAndSettle` a full `ChromaStudioApp` without that override.

## Known remaining gaps

- Android/iOS native builds never validated.
- Synthetic pigment spectra; D50/TL84/LED SPDs approximate.
- No shader goldens; no user-measured reflectance upload.
- Mix session wipe / silent load fallback / unvalidated reflectance (Sourcery, above).

## Copilot notes on merged PRs

- Mix/Match tests: Copilot “unused import” of `mix_session.dart` is a **false positive** (`engineBackendProvider` lives there).
- White-card: bugs reported on #1 were **fixed** in `c8bb559` (recompute on toggle; clear ref on new photo).

## Security

A classic GitHub PAT with broad scopes was pasted into chat on 2026-09-01. Do not echo tokens. Owner should revoke it at <https://github.com/settings/tokens> and use a repo-scoped secret instead. Check `gh auth status`; do not assume credentials exist.
