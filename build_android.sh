#!/usr/bin/env bash
# Build RustDesk for Android using cargo-ndk directly

set -e

# Set environment variables
export ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-D:\Android\sdk\ndk\28.2.13676358}"
export VCPKG_ROOT="${VCPKG_ROOT:-D:\vcpkg}"

# Disable OpenSSL vendoring
export OPENSSL_NO_VENDOR=1

# For Android, we need to set OPENSSL environment to skip linking
export OPENSSL_LIB_DIR=""
export OPENSSL_INCLUDE_DIR=""

# Build for all architectures
TARGETS=(
    "aarch64-linux-android"
    "armv7-linux-androideabi"
    "x86_64-linux-android"
    "i686-linux-android"
)

for TARGET in "${TARGETS[@]}"; do
    echo "Building for $TARGET..."
    cargo ndk --target "$TARGET" --platform 21 -- build --release
done

echo "Build complete!"
