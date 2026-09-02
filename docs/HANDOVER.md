---
schema: ce-handoff/v1
id: chroma-studio-2026-09-02-repo-cleanup
repo: RipKDR/Colour-mixer
branch: main
head: 79da855
base: origin/main
status: ready_for_next_task
created_at: 2026-09-02T11:45:00Z
updated_at: 2026-09-02T11:45:00Z
parent: chroma-studio-2026-09-01-custom-pigments-merged
resume_focus: none — repo is caught up
---

# Handover — 2026-09-02

## Resume here

`origin/main` is **`79da855`**. Everything from the previous handover
(mix-session wipe, silent `[]` fallback, unvalidated `reflectanceJson`,
Android native build) has shipped and merged: PRs #1–#3 and #5–#8. PR #4
duplicated #5/#6's fixes against a stale base and was closed unmerged.

There is no outstanding feature work queued. Highest-leverage remaining
items are the "Later / ideas" list in `docs/ROADMAP.md` (golden tests,
user-measured reflectance curves, iOS build validation — needs a Mac) and
general Phase 4 polish.

**Repo hygiene done this session** (PR #9, `claude/github-repo-cleanup-aviuzu`):

- Removed `.codacy/` (machine-local Codacy CLI baseline, accidentally
  committed) and three empty/scratch `apps/mobile/*.txt` files.
- Removed `agent-tools/<uuid>.txt` — a scraped LinkedIn page (`agent-tools/`
  is `.gitignore`d but this file was force-added back on the Phase 1 MVP
  commit and never caught).
- Closed PR #4 (stale, `mergeable_state: dirty`, superseded by #5/#6).
- **Not done — needs the repo owner**: 11 branches are fully merged into
  `main` (verified via `merge-base --is-ancestor`) and safe to delete —
  remote branch deletion isn't available in this session:
  `cursor/appwrite-recipe-cloud-sync-eeea`, `cursor/chromastudio-mvp-e582`,
  `cursor/copilot-pigment-error-hygiene-eeea`,
  `cursor/custom-pigment-entry-580b`,
  `cursor/custom-pigment-review-fixes-580b`,
  `cursor/phase4-solver-swatch-tests-580b`, `cursor/session-handover-580b`,
  `cursor/sourcery-custom-pigment-hygiene-eeea`,
  `agents/caveman-conversation-feature`, `ripkdr-stunning-spork`,
  `ripkdr-execute-task-e9f5f2e3` (identical SHA to `main`).

## ⚠️ Unresolved security note carried over from 2026-09-01

A classic GitHub PAT with broad scopes was pasted into chat that day. As of
this handover there is no evidence it was revoked. **If you are the repo
owner and have not already done so: revoke it now** at
<https://github.com/settings/tokens> and use a repo-scoped fine-grained
token or Actions secret instead. Do not assume old credentials are dead —
verify with `gh auth status` / the tokens page directly.

## What shipped since the last handover (2026-09-01 → 2026-09-02)

- **PR #5/#6** — the Sourcery trio from PR #2's review: mix session no
  longer resets on custom-pigment refresh; failed extras load keeps last
  good state instead of `[]`; `reflectanceJson` validated to exactly 41
  finite `[0,1]` samples, decode/cast failures wrapped as
  `FormatException` (not `Error`s) so corrupt rows are skipped without
  swallowing real bugs.
- **PR #7** — optional Appwrite (Flutter client SDK) recipe cloud sync:
  email/password auth in Settings, explicit Push/Pull, Drift stays the
  offline source of truth, schema bumped to **v4** (`MixRecipes.cloudId`).
- **PR #8** — fixed `rust_parity_test.dart`: `testEngineWithAllPigments()`
  now calls `TestWidgetsFlutterBinding.ensureInitialized()` before
  `rootBundle.loadString`.
- Android native build validated on-device (Pixel 9 / API 35); Gradle
  8.14.3 / AGP 8.13.2 / Kotlin 2.2.21 / NDK 28.2.13676358; CI bumped to
  Flutter **3.47.0** (`DropdownButtonFormField.initialValue` needs 3.33+).
- Precision-mode phone-width layout overflow fixed.
- `build_runner`/drift toolchain upgraded (freezed/json_serializable
  removed — were unused and freezed 2.5.8 hung under Dart 3.13's analyzer
  pin); drift 2.34.3, drift_dev 2.34.5, build_runner 2.16.0.

## Authoritative docs

- `CLAUDE.md` — agent operating manual (Flutter path, dual-engine, CI
  constraints).
- `docs/DESIGN.md` — architecture.
- `docs/FEATURES.md` — feature → file map.
- `docs/ROADMAP.md` — phase status; still dated 2026-09-01 in its header
  but content is current through the Android build/layout work — bump the
  header date whenever you touch it next.
- `docs/ENGINE.md` — KM / colorimetry notes.

## Environment

- CI pins Flutter **3.47.0** (matches local dev).
- Rust stable 1.83.
- Dual-engine rule unchanged: Dart `chroma_engine.dart` is the reference;
  Rust mirrors it except for Dart-only paths (solver, photo CAT,
  spectrum-from-Lab, overlay/custom pigments).

## Do not

- Commit machine-local tool output (`.codacy/`, `*_output.txt`,
  `agent-tools/*` scrape dumps) — this handover exists because that
  happened twice.
- Commit `apps/mobile/pubspec.lock` (already `.gitignore`d — CI/local
  Flutter versions can drift).
- Use `initialValue:` on `DropdownButtonFormField` unless you also bump
  CI's Flutter pin.
- Require the native `.so` in Flutter tests (CI has no native lib).
- Recreate `MixSessionNotifier` when refreshing custom pigments.
- Swallow custom-pigment load failures into `[]`.
- Accept `reflectanceJson` that is not exactly 41 finite in-range samples.

## Verification

```bash
cd packages/chroma_engine && cargo test --release && cargo build --release
cd apps/mobile && /agent/flutter/bin/flutter analyze
cd apps/mobile && /agent/flutter/bin/flutter test
```

Any widget test that builds a mix session (`engineBackendProvider` /
`_sessionDepsProvider`) **must** include `emptyCustomPigmentsOverride()`
from `test/support/engine_fixtures.dart`, or `pumpAndSettle` hangs (CI has
no `libsqlite3.so`).
