#!/usr/bin/env bash
# Build chroma_engine for mobile targets (requires rustup + cargo-ndk for Android).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE="$ROOT/packages/chroma_engine"
PLUGIN="$ROOT/packages/chroma_engine_ffi"
OUT="$PLUGIN/prebuilt"

TARGET="${1:-}"

mkdir -p "$OUT"

build_android() {
  if ! command -v cargo-ndk >/dev/null 2>&1; then
    echo "Install cargo-ndk: cargo install cargo-ndk"
    exit 1
  fi
  if [ -z "${ANDROID_NDK_HOME:-}" ] && [ -z "${ANDROID_NDK_ROOT:-}" ]; then
    echo "Set ANDROID_NDK_HOME to your NDK directory (e.g. \$LOCALAPPDATA/Android/Sdk/ndk/<version>)"
    exit 1
  fi
  rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android 2>/dev/null || true
  # cargo-ndk expects native-style paths and runs `cargo metadata` in the CWD,
  # so build from inside the engine directory (works on Linux, macOS and Windows/MSYS).
  local out="$PLUGIN/android/src/main/jniLibs"
  case "$out" in
    /[a-z]/*) out="$(cygpath -m "$out" 2>/dev/null || echo "$out")" ;;
  esac
  (
    cd "$ENGINE"
    for abi in arm64-v8a armeabi-v7a x86_64; do
      echo "Building Android $abi..."
      cargo ndk -t "$abi" -o "$out" build --release
    done
  )
  echo "Android libs in $PLUGIN/android/src/main/jniLibs"
}

build_ios() {
  echo "Building iOS device (aarch64-apple-ios)..."
  rustup target add aarch64-apple-ios x86_64-apple-ios 2>/dev/null || true
  cargo build --release --target aarch64-apple-ios --manifest-path "$ENGINE/Cargo.toml"
  mkdir -p "$PLUGIN/ios/Frameworks"
  cp "$ENGINE/target/aarch64-apple-ios/release/libchroma_engine.a" \
    "$PLUGIN/ios/Frameworks/libchroma_engine.a"
  echo "iOS static lib: $PLUGIN/ios/Frameworks/libchroma_engine.a"
}

build_linux() {
  "$ROOT/tools/build_engine.sh"
  mkdir -p "$PLUGIN/linux"
  cp "$ENGINE/target/release/libchroma_engine.so" "$PLUGIN/linux/libchroma_engine.so" 2>/dev/null || true
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
