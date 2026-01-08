#!/bin/bash
# Final CodeSign Fix - Remove ALL signatures and extended attributes AFTER build
# This runs as a final script phase in Xcode

set -e

echo "🔧 [FINAL FIX] Removing all code signatures and extended attributes..."

# Find the app bundle
APP_BUNDLE="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "⚠️  App bundle not found: $APP_BUNDLE"
    exit 0
fi

echo "📦 Processing app bundle: $APP_BUNDLE"

# Remove extended attributes from entire app bundle
echo "🧹 Removing extended attributes from app bundle..."
xattr -cr "$APP_BUNDLE" 2>/dev/null || true
find "$APP_BUNDLE" -type f -exec xattr -cr {} \; 2>/dev/null || true

# Remove signatures from all frameworks
if [ -d "$APP_BUNDLE/Frameworks" ]; then
    echo "🧹 Processing frameworks..."
    find "$APP_BUNDLE/Frameworks" -name "*.framework" -type d | while read framework; do
        echo "  Processing: $framework"
        # Remove extended attributes
        xattr -cr "$framework" 2>/dev/null || true
        find "$framework" -type f -exec xattr -cr {} \; 2>/dev/null || true
        
        # Find and remove signatures from binaries
        find "$framework" -type f -perm +111 | while read binary; do
            if file "$binary" | grep -q "Mach-O"; then
                echo "    Removing signature from: $binary"
                /usr/bin/codesign --remove-signature "$binary" 2>/dev/null || true
            fi
        done
    done
fi

# Remove signature from main app binary
if [ -f "$APP_BUNDLE/Runner" ]; then
    echo "🧹 Removing signature from main binary..."
    /usr/bin/codesign --remove-signature "$APP_BUNDLE/Runner" 2>/dev/null || true
fi

# Remove signature from dylibs
find "$APP_BUNDLE" -name "*.dylib" -type f | while read dylib; do
    echo "🧹 Removing signature from: $dylib"
    /usr/bin/codesign --remove-signature "$dylib" 2>/dev/null || true
    xattr -cr "$dylib" 2>/dev/null || true
done

echo "✅ [FINAL FIX] Completed - All signatures and extended attributes removed"


