#!/bin/bash
# Clean Flutter.framework extended attributes before codesign
set -e

if [[ "${PLATFORM_NAME}" == *"simulator"* ]]; then
  echo "🧹 Cleaning Flutter.framework extended attributes for simulator..."
  
  # Find and clean all Flutter.framework instances
  find "${FLUTTER_BUILD_DIR}" -name "Flutter.framework" -type d 2>/dev/null | while read fw; do
    echo "Cleaning: $fw"
    xattr -cr "$fw" 2>/dev/null || true
    find "$fw" -type f -exec xattr -cr {} \; 2>/dev/null || true
    # Remove existing signature
    if [ -f "$fw/Flutter" ]; then
      codesign --remove-signature "$fw/Flutter" 2>/dev/null || true
    fi
  done
  
  find "${TARGET_BUILD_DIR}" -name "Flutter.framework" -type d 2>/dev/null | while read fw; do
    echo "Cleaning: $fw"
    xattr -cr "$fw" 2>/dev/null || true
    find "$fw" -type f -exec xattr -cr {} \; 2>/dev/null || true
    if [ -f "$fw/Flutter" ]; then
      codesign --remove-signature "$fw/Flutter" 2>/dev/null || true
    fi
  done
  
  echo "✅ Flutter.framework cleaned"
fi
