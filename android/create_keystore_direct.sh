#!/bin/bash
# Direct command to create keystore using Android Studio's Java

cd /Users/obadadallo/Documents/politik_test/android

/Applications/Android\ Studio.app/Contents/jbr/Contents/Home/bin/keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore created successfully at: $(pwd)/upload-keystore.jks"
else
    echo ""
    echo "❌ Error creating keystore"
    exit 1
fi
