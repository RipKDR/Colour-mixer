---
name: dual-engine-parity-check
description: Verify that the Dart reference engine and the Rust native engine produce matching behaviour for a given mixing/colorimetry change, and identify whether a change is one of the sanctioned Dart-only exceptions. Use whenever you edit lib/engine/chroma_engine.dart, packages/chroma_engine/src/, or anything touching mixing math or colour conversion.
---

# Dual-Engine Parity Check

ChromaStudio implements its colour-science engine twice: a Dart reference
implementation and a Rust native implementation exposed over FFI. They must
stay in behavioural sync, with four sanctioned exceptions.

## Step 1 — Classify the change

Is the change to one of these Dart-only subsystems?

- The mix solver (`apps/mobile/lib/engine/mix_solver.dart`)
- Photo CAT / white-card adaptation (`apps/mobile/lib/engine/photo_adapt.dart`)
- Spectrum-from-Lab synthesis for custom pigments
  (`apps/mobile/lib/engine/spectrum_from_lab.dart`)
- The custom-pigments overlay engine (`apps/mobile/lib/engine/overlay_engine.dart`)

**If yes** — no Rust mirror is required. Stop here (but still test the Dart
side).

**If no** — continue to Step 2. This includes any change to: Kubelka–Munk
mixing math, reflectance→XYZ/Lab conversion, ΔE calculation, illuminant/CMF
tables, or the FFI ABI itself.

## Step 2 — Implement in Dart first (reference)

1. Write/adjust a failing test in `apps/mobile/test/` that pins the expected
   behaviour.
2. Implement the change in `apps/mobile/lib/engine/chroma_engine.dart` (or the
   relevant file).
3. `cd apps/mobile && flutter test` — must pass.

## Step 3 — Mirror in Rust

1. Apply the equivalent change in `packages/chroma_engine/src/` (usually
   `engine.rs`, `colorimetry.rs`, or `mixing.rs` — check
   `packages/chroma_engine/src/` for the actual module layout).
2. `cd packages/chroma_engine && cargo test --release && cargo build --release`
   — must pass.
3. If numeric outputs must match within a tolerance (they should, since both
   sides implement the same formulas), consider adding/asserting a
   cross-engine fixture: same input → same output within a small epsilon
   (e.g. 1e-4) in both suites.

## Step 4 — FFI surface (only if the ABI changed)

If you added/removed/changed the signature of an exported function in
`packages/chroma_engine/src/api.rs`:

1. Update the Dart binding in
   `apps/mobile/lib/engine/native_engine.dart`.
2. Update the required-symbols check in
   `packages/chroma_engine_ffi/lib/chroma_engine_ffi.dart` — this is what
   prevents a stale/incompatible `.so` from being silently accepted.
3. Update the FFI ABI table in `docs/ENGINE.md`.

## Step 5 — Final verification

```bash
cd packages/chroma_engine && cargo test --release && cargo build --release
cd apps/mobile && flutter analyze && flutter test
```

Both must be clean. Remember: CI's Flutter job has **no compiled native
library** — the Dart fallback engine must independently pass every test.

## Common failure modes to check for

- Weighting formula changed in one engine but not the other (e.g. tinting
  strength applied before vs. after the K/S weighted average).
- A pure single-pigment mix no longer reproduces that pigment's own masstone
  in one engine — a classic parity break.
- Reflectance spectrum length/step assumptions (41 samples, 380–780 nm,
  10 nm) hardcoded differently in Dart vs Rust.
- `ENGINE` state in Rust reverted to `static mut` instead of
  `OnceLock<EngineState>` — causes crashes under parallel `cargo test`.
