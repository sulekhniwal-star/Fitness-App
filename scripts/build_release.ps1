# scripts/build_release.ps1

# Navigate to flutter project
Set-Location fitkarma

Write-Host "🚀 Starting optimized build for FitKarma..." -ForegroundColor Cyan

# Build split APKs with obfuscation and debug symbols stripping
flutter build apk --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols

Write-Host "✅ Build complete! Check build/app/outputs/flutter-apk/ for the split APKs." -ForegroundColor Green
Write-Host "📏 APK sizes:"
Get-ChildItem build/app/outputs/flutter-apk/*.apk | Select-Object Name, @{Name="Size(MB)";Expression={"{0:N2}" -f ($_.Length / 1MB)}}
