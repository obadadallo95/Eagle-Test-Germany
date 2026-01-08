#!/bin/bash
# Script to try different iOS solutions for the com.apple.provenance issue

set -e

echo "═══════════════════════════════════════════════════════════════════"
echo "🔧 iOS Simulator Crash - Solution Helper Script"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Check available devices
echo "📱 Available iOS Simulators:"
echo "───────────────────────────────────────────────────────────────────"
xcrun simctl list devices available | grep -E "iPhone|iPad" | head -10
echo ""

# Check available iOS runtimes
echo "📦 Available iOS Runtimes:"
echo "───────────────────────────────────────────────────────────────────"
xcrun simctl list runtimes | grep -E "iOS|com.apple.CoreSimulator.SimRuntime.iOS"
echo ""

# Check physical devices
echo "📱 Physical iOS Devices:"
echo "───────────────────────────────────────────────────────────────────"
flutter devices | grep -E "iPhone|iPad" || echo "No physical devices connected"
echo ""

echo "═══════════════════════════════════════════════════════════════════"
echo "💡 Recommended Solutions:"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "1️⃣  Use Physical iPhone (BEST):"
echo "   - Enable Developer Mode: Settings → Privacy & Security → Developer Mode"
echo "   - Run: flutter run -d iPhone"
echo ""
echo "2️⃣  Use Older iOS Simulator:"
echo "   - Download iOS 17/18 from Xcode: Settings > Components"
echo "   - Create simulator: xcrun simctl create \"iPhone 15 Pro\" \"iPhone 15 Pro\" \"iOS17.5\""
echo "   - Run: flutter run -d \"iPhone 15 Pro\""
echo ""
echo "3️⃣  Run from Xcode:"
echo "   - open ios/Runner.xcworkspace"
echo "   - Press ⌘+R in Xcode"
echo ""
echo "═══════════════════════════════════════════════════════════════════"

