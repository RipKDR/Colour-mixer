---
artifact_contract: "ce-handoff/v1"
created_at: "2026-09-01T00:45:00Z"
title: "ChromaStudio session handover — Phase 4 in progress, repo live on GitHub"
summary: "Full state of the ChromaStudio build: Phases 1-3 complete, Phase 4 well underway, all tests green, pushed to RipKDR/Colour-mixer main."
keywords: ["chromastudio", "flutter", "rust", "kubelka-munk", "spectral-mixing", "handover"]
cwd: "/agent"
repository: "RipKDR/Colour-mixer"
branch: "main"
head: "eb5f437"
resume_focus: "Android device build, iOS build on Mac, or golden screen tests"
---

# Session Handover

Read `CLAUDE.md` (repo root) first for environment and commands. This document is
the narrative: what happened, what state everything is in, and what comes next.

## TL;DR

ChromaStudio was built from scratch in this session series: a Flutter + Rust
spectral paint-mixing app. Phases 1–3 of the roadmap are complete, Phase 4 is in
progress. Everything is committed and pushed to
https://github.com/RipKDR/Colour-mixer on `main` (head `eb5f437`, the only branch).
At handover time: `flutter analyze` clean, 21/21 Flutter tests pass, 10/10 Rust
tests pass.

## Verified state at handover

Commands run and confirmed in this session (see CLAUDE.md for exact invocations):

- `flutter analyze` → "No issues found!"
- `flutter test` → 21 tests, all pass (native Rust engine loads with full spectra
  locally; tests also pass on Dart fallback, which is what CI uses)
- `cargo test --release` → 10 tests pass (6 unit + 4 integration)
- Remote head verified equal to local head; working tree clean.

## Commit history (all on main)

| Commit | What it delivered |
|--------|-------------------|
| `c9a1df0` | Phase 1 MVP: Rust KM engine, Flutter app, palette/precision mix modes, 20 pigments |
| `11315e1` | Native Rust FFI on Linux, recipes screen, Linux build script |
| `f7f1328` | Phase 2 start: Learn challenges, inventory, painting preview |
| `6836757` | Phase 2 complete: mediums, drying preview, glaze simulator, brand catalog, recipe share, cost warnings |
| `6fdcbc2` | Phase 3: virtual light booth, PDF export, FFI plugin package, brand expansion |
| `02eae19` | Native full-spectra FFI (OnceLock thread safety), mobile plugin scaffolding |
| `bfd6d05` | Phase 4 start: color match screen, recipe JSON import, palette shader, metamerism alerts, Holbein catalog |
| `64df6e8` | Mix solver ("Suggest recipe"), photo eyedropper, **labToSrgb inverse fix** |
| `eb5f437` | Solver in background isolate + inventory-only suggestion filter |

## Decisions and constraints that matter

1. **Dual engine, Dart is the reference.** The Rust engine accelerates; the Dart
   engine (`apps/mobile/lib/engine/chroma_engine.dart`) is the always-available
   fallback and the source of truth for tests. Changes must be mirrored.
2. **The FFI loader verifies symbols** before trusting a native library, because a
   stale `.so` once caused confusing failures (missing
   `chroma_get_pigment_reflectance`). Don't weaken this check.
3. **Rust statics use `OnceLock`**, not `static mut` — parallel tests SIGSEGV'd
   before this. Don't regress it.
4. **labToSrgb bug (fixed in `64df6e8`):** the Lab→XYZ inverse previously applied the
   forward cube-root nonlinearity. A TDD roundtrip test caught it
   (`test/srgb_to_lab_test.dart`). All Lab→RGB swatches before that commit were
   slightly wrong.
5. **Solver design:** greedy subset search (≤3 pigments from the 8 nearest
   single-pigment candidates) + multiplicative coordinate descent on CIEDE2000.
   Chosen over gradient methods for simplicity and robustness; runs in an isolate.
6. **No PR workflow.** Owner pushes straight to `main`. The old working branch
   `cursor/chromastudio-mvp-e582` was deleted after merging into `main` (identical).

## Security note (IMPORTANT)

The repo owner pasted a **classic GitHub PAT with very broad scopes into plain
chat** during this session (2026-09-01). It was used to authenticate `gh` on the
session VM (`~/.config/gh/hosts.yml`). The owner was advised to:
1. Revoke that token at https://github.com/settings/tokens
2. Replace it with a fine-grained, repo-scoped token stored as a `GITHUB_TOKEN`
   secret in Cursor Dashboard → Cloud Agents → Secrets.

If you are a future agent: check `gh auth status`; do not assume credentials exist,
and never echo tokens.

## Known gaps / fragile areas

- **Pigment spectra are synthetic.** `tools/generate_pigments.py` produces
  plausible gaussian/sigmoid reflectance curves (regenerated after the CIE CMF
  fix — the old curves for blues/greens/purples were inverted and only looked
  right under the old fabricated CMFs). Replacing them with measured spectra
  (e.g. from artist-paint spectral databases) would be a big accuracy win.
- **D50/TL84/LED SPDs are approximations**, not the CIE/IES tables. D65 and
  Illuminant A behaviour are the trustworthy ones.

- **Mobile native builds are untested.** `tools/build_mobile.sh` and the
  `chroma_engine_ffi` Android/iOS scaffolding (jniLibs, podspec) exist but have never
  run against a real NDK/Xcode. Android needs `cargo-ndk` + NDK installed; iOS needs
  a Mac. The app still works everywhere via the Dart engine fallback.
- **The palette-mode fragment shader** (`assets/shaders/mix_blend.frag`) is only
  exercised visually, no golden tests.
- **Learn challenges** have a fixed lesson list; progress persists in Drift
  (`LessonProgress` table) but there's no spaced-repetition or difficulty curve.
- **Inventory cost model** assumes tube price covers `tubeSizeMl` (fallback 37 ml).
- **Brand data lives in two places**: `data/brands/` at repo root is the source of
  truth, mirrored into `apps/mobile/assets/data/brands/`. Keep them in sync when
  editing brand catalogs.
- The photo eyedropper averages 3×3 pixels of gamma-encoded sRGB; no colour
  management of camera input (assumes the photo is sRGB).

## Plausible next steps (in rough priority)

1. **Android device build** — install `cargo-ndk` + NDK, run
   `./tools/build_mobile.sh android`, test the native engine on a device/emulator.
2. **iOS build** — needs a Mac with Xcode; validate `chroma_engine_ffi` podspec.
3. **Golden tests** for palette shader and key screens (widget tests now cover
   Mix, Color Match, and Recipes empty state).
4. **Measured pigment spectra** — replace synthetic curves in `data/pigments/`.
5. **Camera colour management** for eyedropper/swatch capture (currently assumes sRGB).

## Authoritative references

- `CLAUDE.md` — how to work in this repo (commands, gotchas, conventions)
- `docs/DESIGN.md` — architecture and data flow
- `docs/ENGINE.md` — colour science + FFI ABI details
- `docs/ROADMAP.md` — phase-by-phase status
- `docs/FEATURES.md` — feature-to-file map
- `docs/adr/001-flutter-rust-architecture.md` — original architecture decision
- `README.md` — user-facing overview and feature list
