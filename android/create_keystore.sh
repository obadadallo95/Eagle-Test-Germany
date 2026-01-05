#!/bin/bash
# Script to create upload-keystore.jks for Android app signing

# Find Java from Android Studio or Flutter
JAVA_BIN=""
if [ -f "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java" ]; then
    JAVA_BIN="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin"
elif [ -f "$HOME/Library/Android/sdk/jbr/bin/java" ]; then
    JAVA_BIN="$HOME/Library/Android/sdk/jbr/bin"
elif [ -f "$HOME/Library/Android/sdk/jre/bin/java" ]; then
    JAVA_BIN="$HOME/Library/Android/sdk/jre/bin"
else
    # Try to use system java
    JAVA_BIN=$(dirname $(which java) 2>/dev/null || echo "")
fi

if [ -z "$JAVA_BIN" ] || [ ! -f "$JAVA_BIN/keytool" ]; then
    echo "=========================================="
    echo "❌ Error: Java keytool not found"
    echo "=========================================="
    echo ""
    echo "Please install Java JDK or ensure Android Studio is installed."
    echo "You can install Java using Homebrew:"
    echo "  brew install openjdk@17"
    echo ""
    exit 1
fi

echo "=========================================="
echo "Creating upload-keystore.jks"
echo "Using Java from: $JAVA_BIN"
echo "=========================================="
echo ""
echo "You will be prompted to enter:"
echo "1. Keystore password (use: MESSI@1912 or your own)"
echo "2. Re-enter password"
echo "3. Your name"
echo "4. Organizational unit (optional)"
echo "5. Organization name (e.g., Eagle Test)"
echo "6. City or locality"
echo "7. State or province"
echo "8. Two-letter country code (e.g., DE, US)"
echo "9. Confirm (type: yes)"
echo "10. Key password (press Enter to use same as keystore)"
echo ""
echo "Starting keytool command..."
echo ""

"$JAVA_BIN/keytool" -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ Keystore created successfully!"
    echo "File location: $(pwd)/upload-keystore.jks"
    echo "=========================================="
    echo ""
    echo "⚠️  IMPORTANT:"
    echo "1. Keep this file safe - you'll need it for all future releases"
    echo "2. Keep your password safe - you'll need it every time you build"
    echo "3. The file is already in .gitignore - it won't be committed to Git"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ Error creating keystore"
    echo "=========================================="
    exit 1
fi
