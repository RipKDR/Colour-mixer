#!/usr/bin/env bash
# Build chroma_engine for mobile targets (requires rustup + cargo-ndk for Android).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE="$ROOT/packages/chroma_engine"
OUT="$ROOT/packages/chroma_engine_ffi/prebuilt"

TARGET="${1:-}"

mkdir -p "$OUT"

build_android() {
  if ! command -v cargo-ndk >/dev/null 2>&1; then
    echo "Install cargo-ndk: cargo install cargo-ndk"
    exit 1
  fi
  for abi in arm64-v8a armeabi-v7a x86_64; do
    echo "Building Android $abi..."
    cargo ndk -t "$abi" -o "$OUT/android/jniLibs" build --release
  done
  echo "Android libs in $OUT/android/jniLibs"
}

build_ios() {
  echo "Building iOS device (aarch64-apple-ios)..."
  rustup target add aarch64-apple-ios x86_64-apple-ios 2>/dev/null || true
  cargo build --release --target aarch64-apple-ios
  cargo build --release --target x86_64-apple-ios
  echo "iOS libs in $ENGINE/target/aarch64-apple-ios/release/"
  echo "Link libchroma_engine.a in Xcode for device/simulator."
}

build_linux() {
  "$ROOT/tools/build_engine.sh"
}

case "$TARGET" in
  android) build_android ;;
  ios) build_ios ;;
  linux) build_linux ;;
  *)
    echo "Usage: $0 {android|ios|linux}"
    exit 1
    ;;
esac
