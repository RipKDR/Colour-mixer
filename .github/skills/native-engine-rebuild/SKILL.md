---
name: native-engine-rebuild
description: Rebuild the Rust native engine and confirm Flutter picks it up (instead of silently falling back to the Dart engine) after any change to packages/chroma_engine or the FFI plugin. Use after any Rust-side change you expect to be exercised by native-backed Flutter tests or manual runs.
---

# Native Engine Rebuild & Verify

The Dart FFI loader (`packages/chroma_engine_ffi/lib/chroma_engine_ffi.dart`)
prefers the compiled native library and **silently falls back** to the pure
Dart engine if it's missing, stale, or missing a required symbol. A stale
`.so` after a Rust change is the single most common source of "why isn't my
fix showing up" confusion in this repo.

## Step 1 — Rebuild

```bash
cd packages/chroma_engine
cargo test --release
cargo build --release
```

Both must succeed. `cargo test` catches logic regressions; `cargo build
--release` produces the artifact Flutter will try to load.

## Step 2 — Desktop (Linux) convenience path

If you need the compiled library actually copied into place for a desktop
run/test (not just built):

```bash
./tools/build_engine.sh
```

Check the script for the exact destination path it copies to before assuming
it matches `chroma_engine_ffi.dart`'s expected location.

## Step 3 — Confirm the loader will accept it

Open `packages/chroma_engine_ffi/lib/chroma_engine_ffi.dart` and check the
required-symbols list. If you added a new FFI function that should be
load-bearing, it must appear here — otherwise a library missing that symbol
would be silently accepted and crash later, or (worse) an old cached library
would be silently rejected/accepted incorrectly.

## Step 4 — Mobile builds (only if targeting device/emulator)

```bash
./tools/build_mobile.sh android   # needs cargo-ndk + Android NDK
./tools/build_mobile.sh ios       # needs a Mac
```

## Step 5 — Verify Flutter still passes without the native lib too

CI's Flutter job has **no compiled `.so`** — never assume native-backed
behaviour is exercised there.

```bash
cd apps/mobile
flutter analyze
flutter test
```

Both must be green using the Dart fallback engine alone.

## Guardrails

- If you're debugging "my Rust fix doesn't seem to apply," the first thing
  to check is whether the app is actually loading the freshly built library
  or silently using the Dart fallback — check
  `apps/mobile/lib/engine/native_engine.dart`'s backend-selection logic and
  confirm the required-symbols check isn't rejecting your library.
- Never write a Flutter test that only passes when the native backend is
  loaded — it will be flaky/broken in CI.
