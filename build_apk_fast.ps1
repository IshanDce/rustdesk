# Fast APK Build Script
# Downloads pre-built native library and builds APK with Flutter

Write-Host "=== RustDesk APK Builder ===" -ForegroundColor Cyan

# Step 1: Download latest APK
Write-Host "`n[1/5] Downloading pre-built RustDesk APK..." -ForegroundColor Yellow
$downloadDir = "D:\Downloads"
$url = "https://github.com/rustdesk/rustdesk/releases/download/1.4.4/rustdesk-1.4.4.apk"
$apkPath = "$downloadDir\rustdesk.apk"

# Create downloads folder if needed
New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null

# Download
if (!(Test-Path $apkPath)) {
    Write-Host "Downloading from: $url"
    Invoke-WebRequest -Uri $url -OutFile $apkPath
    Write-Host "Downloaded to: $apkPath" -ForegroundColor Green
} else {
    Write-Host "APK already exists at: $apkPath" -ForegroundColor Green
}

# Step 2: Extract native library
Write-Host "`n[2/5] Extracting native library..." -ForegroundColor Yellow
$extractDir = "$downloadDir\rustdesk_extracted"
if (Test-Path $extractDir) { Remove-Item -Path $extractDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

Expand-Archive -Path $apkPath -DestinationPath $extractDir
Write-Host "Extracted to: $extractDir" -ForegroundColor Green

# Step 3: Copy library to Flutter project
Write-Host "`n[3/5] Copying library to Flutter project..." -ForegroundColor Yellow
$jniLibPath = "d:\smart-biz\rustdesk\flutter\android\app\src\main\jniLibs\arm64-v8a"
New-Item -ItemType Directory -Force -Path $jniLibPath | Out-Null

$soFile = "$extractDir\lib\arm64-v8a\librustdesk.so"
if (Test-Path $soFile) {
    Copy-Item -Path $soFile -Destination $jniLibPath\ -Force
    Write-Host "Copied librustdesk.so to: $jniLibPath" -ForegroundColor Green
} else {
    Write-Host "ERROR: librustdesk.so not found!" -ForegroundColor Red
    exit 1
}

# Step 4: Build APK
Write-Host "`n[4/5] Building APK with Flutter..." -ForegroundColor Yellow
cd d:\smart-biz\rustdesk\flutter

Write-Host "Running: flutter build apk --release --target-platform android-arm64 --split-per-abi" -ForegroundColor Cyan
flutter build apk --release --target-platform android-arm64 --split-per-abi

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Step 5: Copy APK to output location
Write-Host "`n[5/5] Finalizing APK..." -ForegroundColor Yellow
$outputApk = "d:\smart-biz\rustdesk\flutter\build\app\outputs\apk\release\app-arm64-v8a-release.apk"
$finalApk = "D:\smart-biz\rustdesk\rustdesk-custom.apk"

if (Test-Path $outputApk) {
    Copy-Item -Path $outputApk -Destination $finalApk -Force
    Write-Host "`n" -NoNewline
    Write-Host "APK Ready!" -ForegroundColor Green
    Write-Host "Location: $finalApk" -ForegroundColor Green
    $size = (Get-Item $finalApk).Length / 1MB
    Write-Host "File size: $size MB" -ForegroundColor Green
    Write-Host "To install on Android device:" -ForegroundColor Cyan
    Write-Host "  adb install $finalApk" -ForegroundColor Gray
} else {
    Write-Host "ERROR: APK not found at: $outputApk" -ForegroundColor Red
    exit 1
}

Write-Host "`nDone!" -ForegroundColor Green
