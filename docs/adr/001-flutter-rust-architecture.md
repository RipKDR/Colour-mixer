# ADR 001: Flutter + Rust Monorepo Architecture

## Status
Accepted

## Context
ChromaStudio requires spectral Kubelka-Munk mixing, 60fps UI, and cross-platform iOS/Android delivery.

## Decision
- **Flutter** for UI, navigation, canvas, and local SQLite (Drift)
- **Rust** (`chroma_engine`) for spectral mixing, CIEDE2000, and pigment database
- **Dart engine mirror** in `lib/engine/` for development/CI without native linking; Rust validated via `cargo test`
- **C FFI** exports in Rust for mobile native linking (Phase 2+)
- **`chroma_engine_ffi`** package provides cross-platform `DynamicLibrary` resolution; mobile builds use `tools/build_mobile.sh`

## Consequences
- Color truth lives in Rust; Dart engine must stay in sync
- Mobile production builds link Rust cdylib via `chroma_engine_ffi` + jniLibs / Xcode static lib
- Linux desktop can load `libchroma_engine.so` when built; otherwise Dart engine is used
