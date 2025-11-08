# Flutter APK Build Script
# This script helps build a release APK for the Student Task Manager app

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Building Release APK" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Developer Mode is enabled (required for symlinks on Windows)
Write-Host "Checking Developer Mode status..." -ForegroundColor Yellow
$devMode = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue

if ($devMode.AllowDevelopmentWithoutDevLicense -eq 1) {
    Write-Host "✓ Developer Mode is enabled" -ForegroundColor Green
} else {
    Write-Host "⚠ Developer Mode is NOT enabled" -ForegroundColor Red
    Write-Host ""
    Write-Host "To enable Developer Mode:" -ForegroundColor Yellow
    Write-Host "1. Press Windows key + I to open Settings" -ForegroundColor White
    Write-Host "2. Go to Privacy & Security > For developers" -ForegroundColor White
    Write-Host "3. Enable 'Developer Mode'" -ForegroundColor White
    Write-Host "4. Restart your computer if prompted" -ForegroundColor White
    Write-Host ""
    Write-Host "Opening Developer Settings..." -ForegroundColor Yellow
    Start-Process "ms-settings:developers"
    Write-Host ""
    Write-Host "Please enable Developer Mode and run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Building release APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "✓ APK built successfully!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "APK location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if APK exists
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-Host "APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
        
        Write-Host ""
        Write-Host "To install on your device:" -ForegroundColor Yellow
        Write-Host "1. Transfer the APK to your Android device" -ForegroundColor White
        Write-Host "2. Enable 'Install from Unknown Sources' in device settings" -ForegroundColor White
        Write-Host "3. Open the APK file and install" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host "✗ Build failed!" -ForegroundColor Red
    Write-Host "=========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check the error messages above." -ForegroundColor Yellow
}

