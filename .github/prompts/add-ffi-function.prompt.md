---
mode: agent
description: 'Add a new FFI-exported function to the Rust chroma_engine and wire it through to Dart, following the full checklist.'
---

# Add an FFI Function

Follow `docs/ENGINE.md`'s "Adding an FFI function" checklist exactly:

1. Implement and export the function in `packages/chroma_engine/src/api.rs`
   using `#[no_mangle] pub extern "C" fn ...`. Keep `unsafe` blocks minimal and
   comment the invariants the caller must uphold.
2. Build and test:
   ```bash
   cd packages/chroma_engine
   cargo test --release
   cargo build --release
   ```
3. Add the corresponding Dart binding in
   `apps/mobile/lib/engine/native_engine.dart`.
4. If the function is load-bearing (the app should not silently run without
   it), add it to the `_hasRequiredSymbols` check in
   `packages/chroma_engine_ffi/lib/chroma_engine_ffi.dart` so a stale/missing
   `.so` triggers a clean fallback instead of a crash or wrong behaviour.
5. If the function's behaviour has a Dart-side equivalent (i.e. it's not one
   of the Dart-only exceptions — solver, photo CAT, spectrum-from-Lab,
   custom-pigments overlay), mirror it in
   `apps/mobile/lib/engine/chroma_engine.dart` and add a Dart test.
6. Run the full Flutter suite — it must pass on the Dart fallback engine
   (CI's flutter job has no compiled `.so`):
   ```bash
   cd apps/mobile
   flutter analyze
   flutter test
   ```
7. Update `docs/ENGINE.md`'s FFI ABI table with the new function.

Report exactly which files were touched and confirm all tests pass before
finishing.
