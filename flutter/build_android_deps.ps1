#!/usr/bin/env pwsh
# Build OpenSSL for Android using NDK

param(
    [string]$AndroidAbi = "arm64-v8a",
    [string]$NdkRoot = "D:\Android\sdk\ndk\28.2.13676358",
    [string]$VcpkgRoot = "D:\vcpkg"
)

# Map Android ABI to vcpkg triplet
$VcpkgTripletMap = @{
    "arm64-v8a"  = "arm64-android"
    "armeabi-v7a" = "arm-neon-android"
    "x86_64"      = "x64-android"
    "x86"         = "x86-android"
}

$VcpkgTriplet = $VcpkgTripletMap[$AndroidAbi]
if (-not $VcpkgTriplet) {
    Write-Error "Unknown Android ABI: $AndroidAbi"
    exit 1
}

Write-Host "Building dependencies for Android ABI: $AndroidAbi (vcpkg triplet: $VcpkgTriplet)" -ForegroundColor Cyan

# Set up environment
$env:ANDROID_NDK_HOME = $NdkRoot
$env:VCPKG_ROOT = $VcpkgRoot
$env:VCPKG_INSTALLED_ROOT = "$VcpkgRoot\installed"

# Create overlay ports if needed
$VcpkgDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$OverlayDir = Join-Path $VcpkgDir "res\vcpkg"

Write-Host "Project directory: $VcpkgDir" -ForegroundColor Yellow

# Install vcpkg dependencies for Android
Write-Host "Installing vcpkg dependencies for $VcpkgTriplet..." -ForegroundColor Cyan

Push-Location $VcpkgDir
& "$VcpkgRoot\vcpkg" install --triplet $VcpkgTriplet --x-install-root="$VcpkgRoot\installed" 2>&1
$ExitCode = $LASTEXITCODE
Pop-Location

if ($ExitCode -ne 0) {
    Write-Error "Failed to install vcpkg dependencies"
    exit $ExitCode
}

# Move arm-neon-android to arm-android if needed
if (Test-Path "$VcpkgRoot\installed\arm-neon-android") {
    Write-Host "Renaming arm-neon-android to arm-android..." -ForegroundColor Cyan
    Move-Item "$VcpkgRoot\installed\arm-neon-android" "$VcpkgRoot\installed\arm-android" -Force
}

Write-Host "Successfully built Android dependencies!" -ForegroundColor Green
