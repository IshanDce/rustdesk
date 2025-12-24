#!/usr/bin/env pwsh
# Copy built Rust libraries to Flutter Android project

param(
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

$scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$projectRoot = if ($scriptDir -eq ".") { Get-Location } else { $scriptDir }

Write-Info "RustDesk Library Copy Utility"
Write-Info "============================="
Write-Info "Project root: $projectRoot"
Write-Info ""

# Define architecture mapping
$archMapping = @{
    "aarch64" = @{
        rustTarget = "aarch64-linux-android"
        jniName = "arm64-v8a"
    }
    "armv7" = @{
        rustTarget = "armv7-linux-androideabi"
        jniName = "armeabi-v7a"
    }
    "x86_64" = @{
        rustTarget = "x86_64-linux-android"
        jniName = "x86_64"
    }
    "x86" = @{
        rustTarget = "i686-linux-android"
        jniName = "x86"
    }
}

if ($Targets -eq "all") {
    $targetsToCopy = $archMapping.Keys
} else {
    if ($archMapping.ContainsKey($Targets)) {
        $targetsToCopy = @($Targets)
    } else {
        Write-Error-Custom "Invalid target: $Targets"
        exit 1
    }
}

# Create JNI library directories
$jniLibsDir = Join-Path $projectRoot "flutter\android\app\src\main\jniLibs"
Write-Info "Creating JNI directories at: $jniLibsDir"
Write-Info ""

foreach ($arch in $targetsToCopy) {
    $mapping = $archMapping[$arch]
    $rustTarget = $mapping.rustTarget
    $jniArch = $mapping.jniName
    
    $jniArchDir = Join-Path $jniLibsDir $jniArch
    $sourceLib = Join-Path $projectRoot "target\$rustTarget\release\librustdesk.so"
    
    Write-Info "Processing: $arch ($jniArch)"
    Write-Info "  Source: $sourceLib"
    Write-Info "  Destination: $jniArchDir"
    
    # Check if library exists
    if (-not (Test-Path $sourceLib)) {
        Write-Error-Custom "  ✗ Library not found: $sourceLib"
        Write-Info "  Please build Rust library first: .\build_rust_android.ps1 -Targets $arch"
        continue
    }
    
    # Create directory
    if (-not (Test-Path $jniArchDir)) {
        New-Item -ItemType Directory -Path $jniArchDir -Force | Out-Null
        Write-Info "  Created directory: $jniArchDir"
    }
    
    # Copy library
    try {
        Copy-Item -Path $sourceLib -Destination $jniArchDir -Force
        $libSize = (Get-Item (Join-Path $jniArchDir "librustdesk.so")).Length / 1MB
        Write-Success "  ✓ Copied librustdesk.so ($([Math]::Round($libSize, 2)) MB)"
    } catch {
        Write-Error-Custom "  ✗ Failed to copy library: $_"
    }
    
    Write-Info ""
}

# Verify copied libraries
Write-Info "Verification:"
Write-Info "============="
$copiedLibs = Get-ChildItem -Path $jniLibsDir -Recurse -Filter "librustdesk.so" -ErrorAction SilentlyContinue

if ($copiedLibs) {
    foreach ($lib in $copiedLibs) {
        $size = $lib.Length / 1MB
        $arch = Split-Path -Parent $lib | Split-Path -Leaf
        Write-Success "✓ $arch: librustdesk.so ($([Math]::Round($size, 2)) MB)"
    }
} else {
    Write-Error-Custom "✗ No libraries found in $jniLibsDir"
    exit 1
}

Write-Info ""
Write-Success "All libraries copied successfully!"
Write-Info ""
Write-Info "Next steps:"
Write-Info "1. Remove old stub libraries (if any)"
Write-Info "2. Build Flutter APK: flutter build apk --release"
Write-Info "3. Install on device: flutter install"
Write-Info ""
Write-Info "The app should now have full RustDesk functionality!"
