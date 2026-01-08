#!/bin/bash
# Fix CodeSign for iOS Simulator
set -e

echo "🔧 Fixing CodeSign for iOS Simulator..."

# Find Flutter framework and remove extended attributes
find build/ios -name "Flutter.framework" -type d 2>/dev/null | while read framework; do
    echo "Cleaning: $framework"
    xattr -cr "$framework" 2>/dev/null || true
    find "$framework" -type f -exec xattr -cr {} \; 2>/dev/null || true
done

# Sign Flutter framework with ad-hoc signature for simulator
find build/ios -name "Flutter" -path "*/Flutter.framework/Flutter" 2>/dev/null | while read binary; do
    echo "Signing: $binary"
    codesign --force --sign - "$binary" 2>&1 || echo "Warning: Could not sign $binary"
done

echo "✅ CodeSign fix completed"
