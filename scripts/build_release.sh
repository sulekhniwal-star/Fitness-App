#!/bin/bash
# scripts/build_release.sh

# Navigate to flutter project
cd fitkarma || exit

echo "🚀 Starting optimized build for FitKarma..."

# Build split APKs with obfuscation and debug symbols stripping
flutter build apk --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols

echo "✅ Build complete! Check build/app/outputs/flutter-apk/ for the split APKs."
echo "📏 APK sizes:"
ls -lh build/app/outputs/flutter-apk/*.apk
