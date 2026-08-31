#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Building chroma_engine (release)..."
cargo build --release --manifest-path "$ROOT/packages/chroma_engine/Cargo.toml"
echo "Done: $ROOT/packages/chroma_engine/target/release/libchroma_engine.so"
