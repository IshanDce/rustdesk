# Quick Start Guide - Build Rust Library for Android

## Prerequisites Check

Run this script first to verify your environment is ready:

### Windows (PowerShell)

```powershell
# Run as Administrator or with your user permissions

Write-Host "Checking RustDesk build environment..." -ForegroundColor Cyan
Write-Host ""

# Check Rust
if (command -v rustc 2>$null) {
    $rustVersion = rustc --version
    Write-Host "✓ Rust: $rustVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Rust not found - Install from https://rustup.rs" -ForegroundColor Red
}

# Check cargo
if (command -v cargo 2>$null) {
    $cargoVersion = cargo --version
    Write-Host "✓ Cargo: $cargoVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Cargo not found" -ForegroundColor Red
}

# Check cargo-ndk
if (cargo install --list | Select-String "cargo-ndk") {
    Write-Host "✓ cargo-ndk installed" -ForegroundColor Green
} else {
    Write-Host "✗ cargo-ndk not found - Run: cargo install cargo-ndk" -ForegroundColor Red
}

# Check Android NDK
$ndkHome = $env:ANDROID_NDK_HOME
if ($ndkHome -and (Test-Path $ndkHome)) {
    Write-Host "✓ Android NDK: $ndkHome" -ForegroundColor Green
} else {
    Write-Host "✗ Android NDK not set - Set ANDROID_NDK_HOME environment variable" -ForegroundColor Red
}

# Check vcpkg
$vcpkgRoot = $env:VCPKG_ROOT
if ($vcpkgRoot -and (Test-Path $vcpkgRoot)) {
    Write-Host "✓ vcpkg: $vcpkgRoot" -ForegroundColor Green
} else {
    Write-Host "✗ vcpkg not set - Set VCPKG_ROOT environment variable" -ForegroundColor Red
}

# Check Android targets
$targets = @("aarch64-linux-android", "armv7-linux-androideabi", "x86_64-linux-android", "i686-linux-android")
$allInstalled = $true
foreach ($target in $targets) {
    if (rustup target list | Select-String "$target" | Select-String "installed") {
        Write-Host "✓ Target: $target" -ForegroundColor Green
    } else {
        Write-Host "✗ Target not installed: $target" -ForegroundColor Red
        $allInstalled = $false
    }
}

Write-Host ""
if ($allInstalled) {
    Write-Host "All prerequisites met! Ready to build." -ForegroundColor Green
} else {
    Write-Host "Some prerequisites are missing. Please install them first." -ForegroundColor Yellow
}
```

---

## Step-by-Step Build Instructions

### Step 1: Prepare Environment

```powershell
# Set environment variables
$env:ANDROID_NDK_HOME = "C:\Android\sdk\ndk\28.2.13676358"  # Adjust path as needed
$env:VCPKG_ROOT = "C:\vcpkg"  # Adjust path as needed
$env:OPENSSL_NO_VENDOR = "1"

# Navigate to project
cd "D:\smart-biz\rustdesk"
```

### Step 2: Install Missing Components (if needed)

```powershell
# Install cargo-ndk
cargo install cargo-ndk

# Add Android targets
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android
```

### Step 3: Build Rust Library

```powershell
# Build for ARM64 (most common)
cargo ndk --target aarch64-linux-android --platform 21 -- build --release

# OR build for all architectures
.\build_rust_android.ps1

# OR build for specific architecture
.\build_rust_android.ps1 -Targets aarch64
```

**Expected output:**
```
Finished release [optimized] target(s) in 2m 30s
✓ Build successful for aarch64-linux-android
```

### Step 4: Copy Libraries to Flutter

```powershell
# Copy the built libraries
.\copy_libs_to_flutter.ps1

# Verify libraries were copied
ls flutter\android\app\src\main\jniLibs\*\librustdesk.so
```

**Expected output:**
```
Directory: flutter\android\app\src\main\jniLibs\arm64-v8a

    Directory: flutter\android\app\src\main\jniLibs\arm64-v8a
    
    Mode                 LastWriteTime         Length Name
    ----                 -----------         ------ ----
    -a---           12/23/2025  1:23 PM       26MB librustdesk.so
```

### Step 5: Build Flutter APK

```bash
cd flutter
flutter build apk --release
```

**Expected output:**
```
✓ Built build\app\outputs\flutter-apk\app-release.apk (28.5 MB).
```

### Step 6: Install and Test

```bash
# Install on connected device
flutter install

# Run with logging
flutter run -v
```

---

## Alternative: Use Digital Ocean for Compilation

If your local machine is slow, use Digital Ocean:

### 1. Create Droplet

- **Image:** Ubuntu 22.04 LTS
- **Size:** 4GB RAM / 2 vCPU ($24/month)
- **Disk:** 50GB SSD
- **Region:** Choose closest to you

### 2. Setup Remote Build

```bash
# On your local machine
# 1. SSH into droplet
ssh root@your-droplet-ip

# 2. Run setup script
wget https://raw.githubusercontent.com/rustdesk/rustdesk/main/setup_digital_ocean.sh
chmod +x setup_digital_ocean.sh
./setup_digital_ocean.sh

# 3. Clone RustDesk
git clone https://github.com/rustdesk/rustdesk.git
cd rustdesk

# 4. Build
cargo ndk --target aarch64-linux-android --platform 21 -- build --release
```

### 3. Transfer Libraries

```bash
# On your local machine
scp root@your-droplet-ip:/root/rustdesk/target/aarch64-linux-android/release/librustdesk.so .

# Copy to Flutter
cp librustdesk.so flutter/android/app/src/main/jniLibs/arm64-v8a/
```

---

## Estimated Build Times

- **Local machine (4 cores):** 30-45 minutes for first build
- **Local machine (8+ cores):** 15-25 minutes
- **Digital Ocean 4GB ($24/month):** 40-50 minutes
- **Digital Ocean 8GB ($48/month):** 20-30 minutes

**Subsequent builds are faster (10-20 minutes) due to caching.**

---

## Troubleshooting Quick Links

If you encounter errors, check:

1. [BUILD_RUST_ANDROID.md](./BUILD_RUST_ANDROID.md) - Detailed build guide
2. [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues and solutions
3. [RustDesk Issues](https://github.com/rustdesk/rustdesk/issues)

---

## Expected Output Structure

After successful build and copy:

```
flutter/android/app/src/main/jniLibs/
├── arm64-v8a/
│   └── librustdesk.so (26 MB)
├── armeabi-v7a/
│   └── librustdesk.so (22 MB)
├── x86_64/
│   └── librustdesk.so (27 MB)
└── x86/
    └── librustdesk.so (21 MB)
```

---

## Success Verification

After building and installing the APK:

1. **App launches** - No crashes
2. **Remote connections work** - Can connect to other RustDesk instances
3. **Settings accessible** - Can change app settings
4. **Clipboard sync** - Can copy/paste between devices
5. **File transfer** - Can transfer files

---

## Next Steps

1. ✅ Build Rust library
2. ✅ Copy to Flutter
3. ✅ Build APK
4. ✅ Install on device
5. ✅ Test connectivity
6. 📦 Release/distribute APK

---

## Support

If stuck:
- Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- Review build logs carefully
- Ensure disk space and RAM are sufficient
- Verify all environment variables are set correctly

---
