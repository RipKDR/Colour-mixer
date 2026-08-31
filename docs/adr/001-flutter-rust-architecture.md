# ADR 001: Flutter + Rust Monorepo Architecture

## Status
Accepted

## Context
ChromaStudio requires spectral Kubelka-Munk mixing, 60fps UI, and cross-platform iOS/Android delivery.

## Decision
- **Flutter** for UI, navigation, canvas, and local SQLite (Drift)
- **Rust** (`chroma_engine`) for spectral mixing, CIEDE2000, and pigment database
- **Dart engine mirror** in `lib/engine/` for development/CI without native linking; Rust validated via `cargo test`
- **C FFI** exports in Rust for future mobile native linking (Phase 2)

## Consequences
- Color truth lives in Rust; Dart engine must stay in sync
- Mobile production builds should link Rust cdylib via FFI plugin
- Linux desktop uses Dart engine for development
