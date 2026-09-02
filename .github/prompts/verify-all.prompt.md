---
mode: agent
description: 'Run the full ChromaStudio verification suite (Rust + Flutter) and report a clear pass/fail summary.'
---

# Full Verification Suite

Run every check required before considering ChromaStudio work "done", in this
order, and report a concise pass/fail summary at the end (do not just paste
raw output).

1. Rust engine:
   ```bash
   cd packages/chroma_engine
   cargo test --release
   cargo build --release
   ```
2. Flutter app:
   ```bash
   cd apps/mobile
   flutter analyze
   flutter test
   ```

If any step fails:

- Show the actual failing test name(s)/error, not just "tests failed".
- Do not attempt to silence the failure by weakening a test or adding
  `continue-on-error` — fix the root cause (see the relevant
  `.github/agents/*.agent.md` specialist if the failure is engine or FFI
  related).
- Re-run the failed suite after the fix to confirm green before reporting
  done.

If the FFI surface changed (functions added/removed in
`packages/chroma_engine/src/api.rs`), also confirm
`packages/chroma_engine_ffi/lib/chroma_engine_ffi.dart`'s required-symbols
check was updated to match — a stale check means the app silently falls back
to the Dart engine without warning.

End with a short report: what was run, what passed, what (if anything) still
needs attention.
