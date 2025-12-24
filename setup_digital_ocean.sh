#!/bin/bash
# Setup RustDesk build environment on Digital Ocean Ubuntu 22.04

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

function print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

function print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

function print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info "RustDesk Build Environment Setup for Digital Ocean"
print_info "===================================================="
print_info ""

# Update system
print_info "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install build tools
print_info "Installing build tools..."
sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    pkg-config \
    libssl-dev \
    clang \
    cmake \
    ninja-build

print_success "Build tools installed"

# Install Rust
print_info "Installing Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    print_success "Rust installed"
else
    print_info "Rust already installed: $(rustc --version)"
fi

# Add Android targets
print_info "Adding Android targets to Rust..."
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
rustup target add i686-linux-android
print_success "Android targets added"

# Install cargo-ndk
print_info "Installing cargo-ndk..."
if ! command -v cargo-ndk &> /dev/null; then
    cargo install cargo-ndk
    print_success "cargo-ndk installed"
else
    print_info "cargo-ndk already installed"
fi

# Download and setup Android NDK
print_info "Downloading Android NDK r27.0.12077973..."
NDK_VERSION="r27.0.12077973"
NDK_DIR="/opt/android-ndk-${NDK_VERSION}"

if [ ! -d "$NDK_DIR" ]; then
    cd /tmp
    NDK_FILE="android-ndk-${NDK_VERSION}-linux.zip"
    wget -q "https://dl.google.com/android/repository/${NDK_FILE}"
    
    print_info "Extracting NDK..."
    unzip -q "$NDK_FILE"
    sudo mv "android-ndk-${NDK_VERSION}" "$NDK_DIR"
    rm "$NDK_FILE"
    
    print_success "Android NDK installed to $NDK_DIR"
else
    print_info "Android NDK already installed at $NDK_DIR"
fi

# Setup vcpkg
print_info "Setting up vcpkg..."
VCPKG_DIR="/opt/vcpkg"

if [ ! -d "$VCPKG_DIR" ]; then
    sudo git clone https://github.com/Microsoft/vcpkg.git "$VCPKG_DIR"
    sudo "$VCPKG_DIR/bootstrap-vcpkg.sh" -useSystemBinaries
    
    print_success "vcpkg installed to $VCPKG_DIR"
else
    print_info "vcpkg already installed at $VCPKG_DIR"
fi

# Create environment setup script
print_info "Creating environment setup script..."
ENV_SCRIPT="$HOME/setup_rustdesk_env.sh"
cat > "$ENV_SCRIPT" << 'EOF'
#!/bin/bash
# RustDesk build environment setup

export ANDROID_NDK_HOME="/opt/android-ndk-r27.0.12077973"
export VCPKG_ROOT="/opt/vcpkg"
export OPENSSL_NO_VENDOR="1"
export OPENSSL_LIB_DIR=""
export OPENSSL_INCLUDE_DIR=""
export PATH="$HOME/.cargo/bin:$PATH"

echo "RustDesk build environment ready"
echo "ANDROID_NDK_HOME: $ANDROID_NDK_HOME"
echo "VCPKG_ROOT: $VCPKG_ROOT"
EOF

chmod +x "$ENV_SCRIPT"
print_success "Environment setup script created at $ENV_SCRIPT"

# Add to bashrc
if ! grep -q "setup_rustdesk_env" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# RustDesk build environment" >> ~/.bashrc
    echo "source $ENV_SCRIPT" >> ~/.bashrc
    print_info "Added to ~/.bashrc"
fi

# Source the environment
source "$ENV_SCRIPT"

# Verify installation
print_info ""
print_info "Verifying installation..."
print_info "========================="

print_info "Rust version: $(rustc --version)"
print_info "Cargo version: $(cargo --version)"
print_info "Android NDK: $ANDROID_NDK_HOME"
print_info "vcpkg location: $VCPKG_ROOT"

if command -v cargo-ndk &> /dev/null; then
    print_success "cargo-ndk installed"
else
    print_error "cargo-ndk not found"
fi

print_info ""
print_success "RustDesk build environment setup complete!"
print_info ""
print_info "Next steps:"
print_info "1. Clone RustDesk repository:"
print_info "   git clone https://github.com/rustdesk/rustdesk.git"
print_info "   cd rustdesk"
print_info ""
print_info "2. Setup vcpkg dependencies:"
print_info "   \$VCPKG_ROOT/vcpkg install --triplet=arm64-android openssl libsodium"
print_info ""
print_info "3. Build for Android:"
print_info "   cargo ndk --target aarch64-linux-android --platform 21 -- build --release"
print_info ""
print_info "4. Transfer built libraries to your local machine:"
print_info "   scp -r root@your-droplet-ip:/root/rustdesk/target/aarch64-linux-android/release/liblibrustdesk.so ."
print_info ""
