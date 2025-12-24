# Building Complete Rust Library for Android

## Overview
This guide will help you build the complete RustDesk Rust library for Android cross-compilation.

## Prerequisites

### 1. Install Required Tools

#### Rust and Toolchain
```bash
# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add Android targets to Rust
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android

# Install cargo-ndk for Android builds
cargo install cargo-ndk
```

#### Android NDK
- Download: Android NDK r27.0.12077973 or newer
- Set environment variable: `ANDROID_NDK_HOME`

#### vcpkg for Dependencies
- Install vcpkg if not already done
- Set environment variable: `VCPKG_ROOT`

### 2. Environment Variables Setup

```bash
# Windows PowerShell
$env:ANDROID_NDK_HOME = "C:\Android\sdk\ndk\28.2.13676358"  # or your NDK path
$env:VCPKG_ROOT = "C:\vcpkg"  # or your vcpkg path
$env:OPENSSL_NO_VENDOR = "1"
```

### 3. Install vcpkg Dependencies for Android

```bash
# For Android ARM64 (aarch64)
./vcpkg install --triplet=arm64-android
./vcpkg install openssl:arm64-android
./vcpkg install libsodium:arm64-android

# For Android ARM (armv7)
./vcpkg install --triplet=arm-android
./vcpkg install openssl:arm-android
./vcpkg install libsodium:arm-android

# For Android x86_64
./vcpkg install --triplet=x64-android
./vcpkg install openssl:x64-android
./vcpkg install libsodium:x64-android

# For Android x86
./vcpkg install --triplet=x86-android
./vcpkg install openssl:x86-android
./vcpkg install libsodium:x86-android
```

## Building the Rust Library

### Option 1: Build Using cargo-ndk (Recommended)

```bash
cd /path/to/rustdesk
cargo ndk --target aarch64-linux-android --platform 21 -- build --release
cargo ndk --target armv7-linux-androideabi --platform 21 -- build --release
cargo ndk --target x86_64-linux-android --platform 21 -- build --release
cargo ndk --target i686-linux-android --platform 21 -- build --release
```

### Option 2: Build Using PowerShell Script (Windows)

Create `build_rust_android.ps1`:

```powershell
# Set environment variables
$env:ANDROID_NDK_HOME = "C:\Android\sdk\ndk\28.2.13676358"
$env:VCPKG_ROOT = "C:\vcpkg"
$env:OPENSSL_NO_VENDOR = "1"

# Verify environment
Write-Host "ANDROID_NDK_HOME: $($env:ANDROID_NDK_HOME)"
Write-Host "VCPKG_ROOT: $($env:VCPKG_ROOT)"

# Build targets
$targets = @(
    "aarch64-linux-android",
    "armv7-linux-androideabi",
    "x86_64-linux-android",
    "i686-linux-android"
)

foreach ($target in $targets) {
    Write-Host "Building for $target..."
    cargo ndk --target $target --platform 21 -- build --release
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed for $target"
        exit 1
    }
}

Write-Host "Build complete!"
```

## Copying Libraries to Flutter

After successful builds, copy the libraries to the Flutter project:

```bash
# Create library directories
mkdir -p flutter/android/app/src/main/jniLibs/arm64-v8a
mkdir -p flutter/android/app/src/main/jniLibs/armeabi-v7a
mkdir -p flutter/android/app/src/main/jniLibs/x86_64
mkdir -p flutter/android/app/src/main/jniLibs/x86

# Copy libraries from target/release
cp target/aarch64-linux-android/release/liblibrustdesk.so flutter/android/app/src/main/jniLibs/arm64-v8a/
cp target/armv7-linux-androideabi/release/liblibrustdesk.so flutter/android/app/src/main/jniLibs/armeabi-v7a/
cp target/x86_64-linux-android/release/liblibrustdesk.so flutter/android/app/src/main/jniLibs/x86_64/
cp target/i686-linux-android/release/liblibrustdesk.so flutter/android/app/src/main/jniLibs/x86/
```

## Troubleshooting

### 1. "cargo-ndk not found"
```bash
cargo install cargo-ndk
```

### 2. "Android NDK not found"
```bash
# Set the environment variable correctly
export ANDROID_NDK_HOME=/path/to/android-ndk-r27.0.12077973
```

### 3. Linking Errors
- Ensure VCPKG_ROOT is set correctly
- Verify vcpkg dependencies are installed for the correct triplets

### 4. Build Fails with OpenSSL Errors
```bash
# Make sure OpenSSL vendoring is disabled
export OPENSSL_NO_VENDOR=1
```

## Using Digital Ocean (Self-Hosted)

If building on Digital Ocean Droplet:

1. **Create Droplet**
   - Ubuntu 22.04 LTS
   - Minimum 4GB RAM
   - 50GB SSD recommended

2. **Setup Environment**
   ```bash
   sudo apt update
   sudo apt install -y build-essential git curl pkg-config
   
   # Install Rust
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source $HOME/.cargo/env
   
   # Install Android NDK
   cd /opt
   sudo wget https://dl.google.com/android/repository/android-ndk-r27.0.12077973-linux.zip
   sudo unzip android-ndk-r27.0.12077973-linux.zip
   
   # Setup environment
   export ANDROID_NDK_HOME=/opt/android-ndk-r27.0.12077973
   export VCPKG_ROOT=/opt/vcpkg
   
   # Add targets
   rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android
   cargo install cargo-ndk
   ```

3. **Clone and Build**
   ```bash
   git clone https://github.com/rustdesk/rustdesk.git
   cd rustdesk
   cargo ndk --target aarch64-linux-android --platform 21 -- build --release
   ```

4. **Transfer Built Libraries**
   ```bash
   # SCP from Digital Ocean to local machine
   scp -r root@your-droplet:/path/to/rustdesk/target/aarch64-linux-android/release/liblibrustdesk.so .
   ```

## Verification

After building, verify the library:

```bash
# Check library size
ls -lh flutter/android/app/src/main/jniLibs/*/liblibrustdesk.so

# Verify with file command
file flutter/android/app/src/main/jniLibs/arm64-v8a/liblibrustdesk.so
# Should show: ELF 64-bit LSB shared object, ARM aarch64
```

## Next Steps

1. Delete stub libraries or let Flutter prioritize real libraries
2. Rebuild Flutter APK: `flutter build apk --release`
3. Test the app - all remote functionality should now work

## Support

If you encounter issues:
1. Check environment variables are set correctly
2. Verify Android NDK and vcpkg are installed
3. Review build logs for specific error messages
4. Ensure you have enough disk space (at least 20GB recommended)
