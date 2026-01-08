#!/bin/bash
# Wrapper for xcode_backend.sh - Complete codesign bypass for simulator

# If building for simulator, completely bypass codesigning
if [[ "${PLATFORM_NAME}" == *"simulator"* ]]; then
    echo "🚫 [WRAPPER] Simulator build detected - bypassing codesign"
    
    # Set environment to disable codesigning
    export CODE_SIGN_IDENTITY=""
    export CODE_SIGNING_REQUIRED=NO
    export CODE_SIGNING_ALLOWED=NO
    export EXPANDED_CODE_SIGN_IDENTITY=""
    export EXPANDED_CODE_SIGN_IDENTITY_NAME=""
    
    # Clean extended attributes and remove signatures from Flutter.framework
    # This must happen BEFORE xcode_backend.sh tries to sign it
    if [ -d "${FLUTTER_BUILD_DIR}" ]; then
        find "${FLUTTER_BUILD_DIR}" -name "Flutter.framework" -type d 2>/dev/null | while read fw; do
            echo "🧹 [WRAPPER] Cleaning Flutter.framework: $fw"
            # Remove extended attributes recursively
            xattr -cr "$fw" 2>/dev/null || true
            find "$fw" -type f -exec xattr -cr {} \; 2>/dev/null || true
            # Remove code signature
            if [ -f "$fw/Flutter" ]; then
                /usr/bin/codesign --remove-signature "$fw/Flutter" 2>/dev/null || true
            fi
        done
    fi
    
    if [ -d "${TARGET_BUILD_DIR}" ]; then
        find "${TARGET_BUILD_DIR}" -name "Flutter.framework" -type d 2>/dev/null | while read fw; do
            echo "🧹 [WRAPPER] Cleaning Flutter.framework: $fw"
            xattr -cr "$fw" 2>/dev/null || true
            find "$fw" -type f -exec xattr -cr {} \; 2>/dev/null || true
            if [ -f "$fw/Flutter" ]; then
                /usr/bin/codesign --remove-signature "$fw/Flutter" 2>/dev/null || true
            fi
        done
    fi
    
    # Also check in the final app bundle
    if [ -d "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" ]; then
        find "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" -name "Flutter.framework" -type d 2>/dev/null | while read fw; do
            echo "🧹 [WRAPPER] Cleaning Flutter.framework in app bundle: $fw"
            xattr -cr "$fw" 2>/dev/null || true
            find "$fw" -type f -exec xattr -cr {} \; 2>/dev/null || true
            if [ -f "$fw/Flutter" ]; then
                /usr/bin/codesign --remove-signature "$fw/Flutter" 2>/dev/null || true
            fi
        done
    fi
    
    echo "✅ [WRAPPER] Environment prepared for simulator build"
fi

# Call the original xcode_backend.sh
exec "/bin/sh" "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" "$@"
