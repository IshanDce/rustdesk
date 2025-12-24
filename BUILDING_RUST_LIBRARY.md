# RustDesk Android Build - Complete Solution Package

## 📋 Overview

This package contains everything you need to build the complete RustDesk Rust native library for Android, replacing the stub libraries with fully functional remote desktop capabilities.

## 📦 Contents

### Documentation Files

1. **[QUICKSTART.md](./QUICKSTART.md)** ⭐ START HERE
   - Quick verification checklist
   - Step-by-step build instructions
   - Expected outputs at each step

2. **[BUILD_RUST_ANDROID.md](./BUILD_RUST_ANDROID.md)**
   - Detailed prerequisites
   - Build options and alternatives
   - vcpkg dependency setup
   - Digital Ocean self-hosted setup
   - Verification steps

3. **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**
   - Common issues and solutions
   - Environment variable troubleshooting
   - Build optimization tips
   - Getting help resources

### Build Scripts

1. **[build_rust_android.ps1](./build_rust_android.ps1)**
   - PowerShell script to build Rust libraries
   - Automatic target detection
   - Colored output for better UX
   - Build result summary

2. **[copy_libs_to_flutter.ps1](./copy_libs_to_flutter.ps1)**
   - Copy built libraries to Flutter project
   - Automatic directory creation
   - Library verification
   - Size reporting

3. **[setup_digital_ocean.sh](./setup_digital_ocean.sh)**
   - Complete environment setup for Digital Ocean Ubuntu 22.04
   - Installs all prerequisites
   - Creates environment scripts
   - Ready to build after script runs

## 🚀 Quick Start (3 Steps)

### Step 1: Verify Prerequisites
```powershell
# Check environment in PowerShell
rustc --version                    # Should show Rust version
cargo-ndk --version                # Should be installed
$env:ANDROID_NDK_HOME              # Should point to NDK
$env:VCPKG_ROOT                    # Should point to vcpkg
```

### Step 2: Build Rust Library
```powershell
cd D:\smart-biz\rustdesk
.\build_rust_android.ps1           # Build for all architectures
# Or: .\build_rust_android.ps1 -Targets aarch64  # Single target
```

### Step 3: Copy to Flutter & Build APK
```powershell
.\copy_libs_to_flutter.ps1         # Copy libraries
cd flutter
flutter build apk --release        # Build APK with native libraries
```

## 💻 System Requirements

### Minimum
- 4GB RAM
- 4 CPU cores
- 50GB disk space
- Windows 10/11, Linux, or macOS

### Recommended
- 8GB RAM
- 8+ CPU cores
- 100GB disk space
- SSD for faster builds

## ⏱️ Build Times

| Setup | Single Target | All Targets |
|-------|--------------|------------|
| Local (4 cores) | 20-30 min | 60-90 min |
| Local (8 cores) | 10-15 min | 30-45 min |
| Digital Ocean $24/mo | 25-35 min | 90-120 min |
| Digital Ocean $48/mo | 15-25 min | 45-75 min |

## 🔧 Prerequisites Installation

### Windows
```powershell
# Install Rust
irm https://rustup.rs | iex

# Install cargo-ndk
cargo install cargo-ndk

# Add Android targets
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android
```

### Linux (Ubuntu/Debian)
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Install build tools
sudo apt install build-essential clang

# Install cargo-ndk and targets
cargo install cargo-ndk
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android
```

### macOS
```bash
# Install Xcode
xcode-select --install

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install cargo-ndk and targets
cargo install cargo-ndk
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android
```

## 🌐 Digital Ocean Option

For those without powerful local machines:

1. **Create Droplet**
   - Ubuntu 22.04 LTS
   - 4GB RAM ($24/month) or 8GB RAM ($48/month)
   - 50GB SSD

2. **Setup**
   ```bash
   ssh root@your-droplet-ip
   curl -O https://raw.githubusercontent.com/rustdesk/rustdesk/.../setup_digital_ocean.sh
   chmod +x setup_digital_ocean.sh
   ./setup_digital_ocean.sh
   ```

3. **Build**
   ```bash
   git clone https://github.com/rustdesk/rustdesk.git
   cd rustdesk
   cargo ndk --target aarch64-linux-android --platform 21 -- build --release
   ```

4. **Transfer**
   ```bash
   # On local machine
   scp root@droplet-ip:/root/rustdesk/target/aarch64-linux-android/release/librustdesk.so .
   ```

## 📋 What Gets Built

Each target produces:
- **arm64-v8a** (aarch64) - 26 MB - Primary for modern Android phones
- **armeabi-v7a** (armv7) - 22 MB - Support for older devices
- **x86_64** - 27 MB - For Android emulators
- **x86** - 21 MB - For older Android emulators

**Total APK size: ~30-35 MB** (compressed from ~96 MB of native libraries)

## ✅ Verification

After copying libraries, verify they exist:

```powershell
ls flutter\android\app\src\main\jniLibs\*\librustdesk.so

# Expected output:
# arm64-v8a\librustdesk.so      26 MB
# armeabi-v7a\librustdesk.so    22 MB
# x86_64\librustdesk.so         27 MB
# x86\librustdesk.so            21 MB
```

## 🎯 Build Targets Explained

### aarch64-linux-android
- **Rust target:** `aarch64-linux-android`
- **JNI architecture:** `arm64-v8a`
- **Use:** Modern Android phones (ARM64)
- **Coverage:** ~95% of current Android devices

### armv7-linux-androideabi
- **Rust target:** `armv7-linux-androideabi`
- **JNI architecture:** `armeabi-v7a`
- **Use:** Older Android phones (ARM)
- **Coverage:** Legacy device support

### x86_64-linux-android
- **Rust target:** `x86_64-linux-android`
- **JNI architecture:** `x86_64`
- **Use:** Android emulators, x86 tablets
- **Coverage:** Development and testing

### i686-linux-android
- **Rust target:** `i686-linux-android`
- **JNI architecture:** `x86`
- **Use:** Older emulators, x86 devices
- **Coverage:** Legacy support

## 🔍 Debugging Tips

### Monitor build progress
```powershell
# Watch in real-time (Windows)
.\build_rust_android.ps1 -Verbose

# Or on Linux/Mac
cargo ndk --target aarch64-linux-android --platform 21 -- build --release 2>&1 | tee build.log
```

### Check intermediate outputs
```bash
# List compiled object files
find target -name "*.o" | head -20

# Check library exists
file flutter/android/app/src/main/jniLibs/arm64-v8a/librustdesk.so
```

### Verify library functionality
```bash
# Extract symbols from library
nm -D flutter/android/app/src/main/jniLibs/arm64-v8a/librustdesk.so | grep "rust"
```

## 📞 Support Resources

### Official Resources
- [RustDesk GitHub](https://github.com/rustdesk/rustdesk)
- [Rust Android Guide](https://rust-lang.github.io/rustup/cross-compilation.html)
- [Android NDK Documentation](https://developer.android.com/ndk)

### Troubleshooting
1. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
2. Review build logs for specific error messages
3. Search [RustDesk Issues](https://github.com/rustdesk/rustdesk/issues)
4. Post on Stack Overflow with tags: `rust`, `android`, `android-ndk`

## 📝 Build Log Example

Successful build output:
```
Building for: aarch64-linux-android
========== Compiling rustdesk v1.4.4 ==========
    Compiling hbb_common v0.1.0
    Compiling scrap v0.5.0
    Compiling rustdesk v1.4.4
   Finished release [optimized] target(s) in 2m 30s
✓ Build successful for aarch64-linux-android
```

## 🎓 Learning Resources

- [Rust Book](https://doc.rust-lang.org/book/)
- [Rustlings](https://github.com/rust-lang/rustlings)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Android NDK Samples](https://github.com/android/ndk-samples)

## ⚖️ License

RustDesk is licensed under the GNU General Public License v3.0

## 🎉 Next Steps After Successful Build

1. ✅ Built complete Rust native library
2. ✅ Copied to Flutter project
3. ✅ Built APK with full functionality
4. 📱 Install on Android device
5. 🔌 Connect to RustDesk peers
6. ✨ Enjoy full remote desktop functionality!

---

**Ready to build?** Start with [QUICKSTART.md](./QUICKSTART.md) or run the build scripts above!
