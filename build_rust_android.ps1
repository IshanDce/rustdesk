#!/usr/bin/env pwsh
# Build RustDesk Rust Library for Android

param(
    [Parameter(Mandatory=$false)]
    [string]$AndroidNdkHome,
    [Parameter(Mandatory=$false)]
    [string]$VcpkgRoot,
    [Parameter(Mandatory=$false)]
    [ValidateSet("aarch64", "armv7", "x86_64", "x86", "all")]
    [string]$Targets = "all"
)

# Color output
function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

# Setup environment
Write-Info "Setting up build environment..."

# Set default paths if not provided
if (-not $AndroidNdkHome) {
    $AndroidNdkHome = $env:ANDROID_NDK_HOME
    if (-not $AndroidNdkHome) {
        $AndroidNdkHome = "C:\Android\sdk\ndk\28.2.13676358"
    }
}

if (-not $VcpkgRoot) {
    $VcpkgRoot = $env:VCPKG_ROOT
    if (-not $VcpkgRoot) {
        $VcpkgRoot = "C:\vcpkg"
    }
}

# Verify paths exist
if (-not (Test-Path $AndroidNdkHome)) {
    Write-Error-Custom "Android NDK not found at: $AndroidNdkHome"
    Write-Info "Please set ANDROID_NDK_HOME environment variable or use -AndroidNdkHome parameter"
    exit 1
}

if (-not (Test-Path $VcpkgRoot)) {
    Write-Error-Custom "vcpkg not found at: $VcpkgRoot"
    Write-Info "Please set VCPKG_ROOT environment variable or use -VcpkgRoot parameter"
    exit 1
}

# Set environment variables
$env:ANDROID_NDK_HOME = $AndroidNdkHome
$env:VCPKG_ROOT = $VcpkgRoot
$env:OPENSSL_NO_VENDOR = "1"
$env:OPENSSL_LIB_DIR = ""
$env:OPENSSL_INCLUDE_DIR = ""

Write-Info "Environment variables:"
Write-Info "  ANDROID_NDK_HOME: $($env:ANDROID_NDK_HOME)"
Write-Info "  VCPKG_ROOT: $($env:VCPKG_ROOT)"
Write-Info "  OPENSSL_NO_VENDOR: $($env:OPENSSL_NO_VENDOR)"

# Define targets
$targetMap = @{
    "aarch64" = "aarch64-linux-android"
    "armv7" = "armv7-linux-androideabi"
    "x86_64" = "x86_64-linux-android"
    "x86" = "i686-linux-android"
}

if ($Targets -eq "all") {
    $buildTargets = $targetMap.Values
} else {
    if ($targetMap.ContainsKey($Targets)) {
        $buildTargets = @($targetMap[$Targets])
    } else {
        Write-Error-Custom "Invalid target: $Targets"
        exit 1
    }
}

# Check if cargo-ndk is installed
Write-Info "Checking for cargo-ndk..."
$cargoNdk = cargo install --list | Select-String "cargo-ndk"
if (-not $cargoNdk) {
    Write-Info "cargo-ndk not found, installing..."
    cargo install cargo-ndk
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to install cargo-ndk"
        exit 1
    }
    Write-Success "cargo-ndk installed"
}

# Verify Rust targets are installed
Write-Info "Verifying Rust targets..."
foreach ($target in $buildTargets) {
    $installed = rustup target list | Select-String $target | Select-String "installed"
    if (-not $installed) {
        Write-Info "Installing $target..."
        rustup target add $target
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "Failed to install target: $target"
            exit 1
        }
    }
}

# Build for each target
$buildResults = @()

foreach ($target in $buildTargets) {
    Write-Info ""
    Write-Info "============================================"
    Write-Info "Building for: $target"
    Write-Info "============================================"
    
    # Run the build
    cargo ndk --target $target --platform 21 -- build --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Build successful for $target"
        $buildResults += @{
            target = $target
            success = $true
        }
    } else {
        Write-Error-Custom "✗ Build failed for $target"
        $buildResults += @{
            target = $target
            success = $false
        }
    }
}

# Summary
Write-Info ""
Write-Info "============================================"
Write-Info "Build Summary"
Write-Info "============================================"

$successCount = ($buildResults | Where-Object { $_.success }).Count
$failCount = ($buildResults | Where-Object { -not $_.success }).Count

foreach ($result in $buildResults) {
    if ($result.success) {
        Write-Success "✓ $($result.target)"
    } else {
        Write-Error-Custom "✗ $($result.target)"
    }
}

Write-Info ""
Write-Info "Total: $successCount success, $failCount failed"

if ($failCount -eq 0) {
    Write-Success ""
    Write-Success "All builds completed successfully!"
    Write-Info ""
    Write-Info "Next steps:"
    Write-Info "1. Copy libraries to Flutter: .\copy_libs_to_flutter.ps1"
    Write-Info "2. Build Flutter APK: flutter build apk --release"
    
    exit 0
} else {
    Write-Error-Custom "Some builds failed. Please check the logs above."
    exit 1
}
