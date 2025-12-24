# Rust Android Build - Troubleshooting Guide

## Common Issues and Solutions

### 1. **"cargo-ndk not found"**

**Error:**
```
error: 'cargo-ndk' not found in PATH
```

**Solution:**
```bash
# Install cargo-ndk
cargo install cargo-ndk

# Verify installation
cargo-ndk --version
```

---

### 2. **"Android NDK not found"**

**Error:**
```
error: Android NDK not found
```

**Solution:**

Set the environment variable correctly:

**Windows (PowerShell):**
```powershell
$env:ANDROID_NDK_HOME = "C:\Android\sdk\ndk\28.2.13676358"
# Verify
Write-Host $env:ANDROID_NDK_HOME
```

**Linux/Mac:**
```bash
export ANDROID_NDK_HOME=/path/to/android-ndk-r27.0.12077973
# Verify
echo $ANDROID_NDK_HOME
```

---

### 3. **"Rust target not installed"**

**Error:**
```
error[E0514]: found crate `X` compiled by an incompatible version
error: failed to run custom build command
```

**Solution:**
```bash
# List available targets
rustup target list

# Install missing target
rustup target add aarch64-linux-android

# For all Android targets
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android
```

---

### 4. **"OpenSSL linking errors"**

**Error:**
```
error: linking with 'clang-14' failed
note: ld.lld: error: unable to find -lssl
```

**Solution:**

Ensure OpenSSL vendoring is disabled:

**Windows (PowerShell):**
```powershell
$env:OPENSSL_NO_VENDOR = "1"
$env:OPENSSL_LIB_DIR = ""
$env:OPENSSL_INCLUDE_DIR = ""
```

**Linux/Mac:**
```bash
export OPENSSL_NO_VENDOR=1
export OPENSSL_LIB_DIR=""
export OPENSSL_INCLUDE_DIR=""
```

---

### 5. **"vcpkg dependencies not found"**

**Error:**
```
error: could not find vcpkg installed libraries
```

**Solution:**

Verify vcpkg root and install dependencies:

```bash
# Set VCPKG_ROOT
export VCPKG_ROOT=/path/to/vcpkg  # Linux/Mac
# or
$env:VCPKG_ROOT = "C:\vcpkg"  # Windows

# Install dependencies for all Android architectures
./vcpkg install --triplet=arm64-android openssl libsodium
./vcpkg install --triplet=arm-android openssl libsodium
./vcpkg install --triplet=x64-android openssl libsodium
./vcpkg install --triplet=x86-android openssl libsodium
```

---

### 6. **"Compiler not found (clang)"**

**Error:**
```
error: C/C++ compiler not available
```

**Solution:**

**Ubuntu/Debian:**
```bash
sudo apt install -y build-essential clang
```

**CentOS/RHEL:**
```bash
sudo yum install -y gcc g++ clang
```

**macOS:**
```bash
xcode-select --install
```

**Windows (PowerShell):**
```powershell
# Install Visual C++ Build Tools or MSVC from Visual Studio
# Or use rustup to install llvm
rustup component add llvm-tools
```

---

### 7. **"Disk space issues"**

**Error:**
```
error: failed to write to disk: No space left on device
```

**Solution:**

Ensure you have at least 50GB free space:

**Check disk space:**
```bash
# Linux/Mac
df -h

# Windows (PowerShell)
Get-Volume
```

**Cleanup:**
```bash
# Remove build artifacts
cargo clean

# Remove old Rust toolchains
rustup toolchain prune
```

---

### 8. **"Long build times"**

**Optimization tips:**

1. **Build in release mode (already done with `--release` flag)**

2. **Use parallel compilation:**
```bash
# Set CARGO_BUILD_JOBS to use all cores
export CARGO_BUILD_JOBS=$(nproc)  # Linux
# or
$env:CARGO_BUILD_JOBS = [int](Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors  # Windows
```

3. **Use incremental compilation:**
```bash
export CARGO_INCREMENTAL=1
```

4. **Consider building on a more powerful machine:**
   - Minimum: 4GB RAM, 4 CPU cores
   - Recommended: 8GB RAM, 8 CPU cores
   - For Digital Ocean: Droplet with 4GB RAM, $24/month

---

### 9. **"Library not found after build"**

**Error:**
```
error: could not find librustdesk.so
```

**Solution:**

Verify the build output:

```bash
# List target directory
ls -la target/aarch64-linux-android/release/

# Look for librustdesk.so (not with .a or .rlib extension)
find target -name "librustdesk.so"

# If found with different name, rename it:
mv target/aarch64-linux-android/release/liblibrustdesk.so target/aarch64-linux-android/release/librustdesk.so
```

---

### 10. **"Build fails on subsequent runs"**

**Solution:**

Clean and rebuild:

```bash
# Clean previous builds
cargo clean

# Remove target directory
rm -rf target

# Rebuild
cargo ndk --target aarch64-linux-android --platform 21 -- build --release
```

---

## Verification Checklist

Before starting the build, verify:

- [ ] Rust installed: `rustc --version`
- [ ] Cargo installed: `cargo --version`
- [ ] Android targets installed: `rustup target list | grep android`
- [ ] cargo-ndk installed: `cargo-ndk --version`
- [ ] Android NDK path set: Check `$ANDROID_NDK_HOME`
- [ ] vcpkg path set: Check `$VCPKG_ROOT`
- [ ] Disk space available: At least 50GB
- [ ] RAM available: At least 4GB free
- [ ] Internet connection: For downloading dependencies

---

## Getting Help

If you're still stuck:

1. **Check RustDesk GitHub Issues:** https://github.com/rustdesk/rustdesk/issues
2. **Rust Embedded Book:** https://rust-embedded.github.io/book/
3. **Android NDK Documentation:** https://developer.android.com/ndk
4. **Stack Overflow:** Tag with `rust` and `android-ndk`

---

## Build Output Reference

When the build succeeds, you should see:

```
Finished release [optimized] target(s) in XXsXXXms

ls -lh target/aarch64-linux-android/release/librustdesk.so
-rw-r--r-- 1 user group 25M Dec 23 12:34 librustdesk.so
```

The library size is typically 20-30MB per architecture.

---

## Next Steps After Build Success

1. **Copy libraries to Flutter:**
```bash
# Run the copy script
./copy_libs_to_flutter.ps1  # Windows
# or
cp target/aarch64-linux-android/release/librustdesk.so flutter/android/app/src/main/jniLibs/arm64-v8a/
```

2. **Build Flutter APK:**
```bash
cd flutter
flutter build apk --release
```

3. **Test the APK:**
```bash
flutter install  # On device
flutter run -v   # With verbose output
```

---
