# ChromaStudio — Copilot Instructions

ChromaStudio is a spectral paint-mixing app for fine artists. It predicts real
pigment mixing with Kubelka–Munk theory over 41-sample reflectance spectra
(380–780 nm, 10 nm steps) — **never** naive RGB blending. Flutter UI (Dart) +
Rust engine (FFI), monorepo.

**Read `CLAUDE.md` first — it is the canonical agent operating manual** (repo
map, environment notes, commands, workflow conventions). Read `docs/DESIGN.md`,
`docs/ENGINE.md`, and `docs/HANDOVER.md` before touching architecture or the
colour engine. This file only adds Copilot-specific pointers; it does not
replace those docs.

## The five rules that matter most

1. **Dual-engine parity.** `apps/mobile/lib/engine/chroma_engine.dart` (Dart,
   reference implementation) and `packages/chroma_engine/src/` (Rust) must
   produce matching results. Any mixing/colorimetry change goes in **both**,
   unless it's one of the Dart-only features called out in
   `docs/HANDOVER.md` under "Dual-engine rule" (solver, photo CAT,
   spectrum-from-Lab, custom pigments overlay).
2. **Rebuild Rust before Flutter tests touch FFI.** If you change
   `packages/chroma_engine/src/api.rs`, rebuild
   (`cargo build --release`) and update the required-symbols check in
   `packages/chroma_engine_ffi/lib/chroma_engine_ffi.dart` before running
   Flutter tests, or you'll silently test against a stale `.so`/fallback.
3. **CI has no native library for the Flutter job.** Never write a Flutter
   test that requires the native backend to pass. Widget tests that build a
   mix session must use `emptyCustomPigmentsOverride()` from
   `apps/mobile/test/support/engine_fixtures.dart`, or Drift/SQLite hangs
   `pumpAndSettle` (no `libsqlite3.so` in CI).
4. **Drift schema changes need a migration.** Bump `schemaVersion` in
   `apps/mobile/lib/features/recipes/database.dart`, add an `onUpgrade` step,
   then regenerate: `dart run build_runner build --delete-conflicting-outputs`.
   `database.g.dart` is committed — never hand-edit it.
5. **Never block the UI isolate with the solver.** `MixSolver` must run via
   `compute(solveMixRequest, SolveRequest(...))`.

## Verify before claiming done

```bash
cd packages/chroma_engine && cargo test --release && cargo build --release
cd apps/mobile && flutter analyze
cd apps/mobile && flutter test
```

Do not commit `apps/mobile/pubspec.lock` if your local Flutter version differs
from the CI-pinned version in `.github/workflows/ci.yml`. Do not use
`DropdownButtonFormField.initialValue:` if CI is pinned below Flutter 3.33
(check `ci.yml` for the current pin — it has moved before).

## Style

- Imports at the top of the file only; no inline imports.
- Exhaustive `switch` over enums — keep the analyzer's missing-case checks
  satisfied, don't add a `default` just to silence it.
- TDD for engine/domain code: write the failing test first, watch it fail,
  implement minimally, watch it pass (see `apps/mobile/test/` for style).
- Commit messages: imperative summary line, no forced prefix.

## Path-scoped and workflow instructions

More specific rules live in `.github/instructions/*.instructions.md` (applied
automatically by file path) and reusable workflows in `.github/prompts/`.
Specialist agents live in `.github/agents/`. The Codacy MCP rule in
`.github/instructions/codacy.instructions.md` is mandatory and independent of
this file — keep following it after every edit.
