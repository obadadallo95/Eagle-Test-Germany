#!/bin/bash
# 🛠️ iOS Build Nuclear Clean Script
# This script performs a complete clean of the iOS build environment
# to fix CodeSign issues caused by Extended Attributes

set -e  # Exit on error

echo "═══════════════════════════════════════════════════════════════════"
echo "🛠️  iOS BUILD NUCLEAR CLEAN"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Get project root (assuming script is in scripts/ directory)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "📁 Project root: $PROJECT_ROOT"
echo ""

# Step 1: Deep Clean
echo "🧹 Step 1: Deep Clean Flutter..."
flutter clean
echo "✅ Flutter clean completed"
echo ""

echo "🗑️  Removing Pods and CocoaPods files..."
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
echo "✅ Pods removed"
echo ""

# Step 2: Nuke Xcode Cache
echo "💣 Step 2: Removing Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "✅ Xcode DerivedData cleared"
echo ""

# Step 3: Remove Extended Attributes
echo "🧼 Step 3: Removing Extended Attributes from all files..."
xattr -cr . 2>/dev/null || true
echo "✅ Extended Attributes removed"
echo ""

# Step 4: Re-Install
echo "📦 Step 4: Re-installing dependencies..."
flutter pub get
echo "✅ Flutter dependencies installed"
echo ""

echo "📦 Installing CocoaPods..."
cd ios
pod install --repo-update
cd ..
echo "✅ CocoaPods installed"
echo ""

echo "═══════════════════════════════════════════════════════════════════"
echo "✅ NUCLEAR CLEAN COMPLETED SUCCESSFULLY!"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Next steps:"
echo "   1. Open Xcode: open ios/Runner.xcworkspace"
echo "   2. Set Code Signing Identity for 'Any iOS Simulator SDK' = 'Don't Code Sign'"
echo "   3. Clean Build Folder (Cmd + Shift + K)"
echo "   4. Run the app (Cmd + R)"
echo ""
