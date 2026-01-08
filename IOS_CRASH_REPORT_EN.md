# iOS Simulator Crash Report: Flutter App Closes Immediately After Installation

## 📋 Project Information
- **App Name:** Eagle Test: Germany
- **Version:** 1.0.3 (Build 4)
- **OS:** macOS 26.2 (Sequoia)
- **Xcode:** 17.x
- **Flutter SDK:** 3.38.5
- **iOS Simulator:** iPhone 17 Pro Max (iOS 26.2)
- **Issue:** App installs successfully but crashes immediately on launch (black screen then exit)

---

## 🔴 Core Problem

### Symptoms:
1. ✅ App builds successfully (`flutter build ios --simulator`)
2. ✅ App installs on simulator successfully (`xcrun simctl install`)
3. ❌ On app launch: Black screen for 1 second then immediate crash
4. ❌ No error message shown to user

### Actual Error (from Crash Reports):
```
Termination Reason: DYLD, Code 1, Library missing
Library not loaded: @rpath/Flutter.framework/Flutter
Referenced from: Runner.debug.dylib
Reason: code signature in <...> '/Users/.../Runner.app/Frameworks/Flutter.framework/Flutter'
```

---

## 🔍 Technical Analysis

### 1. Code Signature Issue:
- `dyld` (dynamic linker) refuses to load `Flutter.framework` due to signature problem
- Error indicates: `code signature in <...>` meaning signature exists but is invalid

### 2. Extended Attributes Issue (com.apple.provenance):
- macOS 26.2 automatically adds Extended Attribute named `com.apple.provenance` to all files
- This attribute prevents `codesign` from signing files correctly
- When attempting to sign: `codesign: resource fork, Finder information, or similar detritus not allowed`

### 3. Attempts to Remove Extended Attributes:
- ✅ `xattr -cr` - Failed (attribute returns automatically)
- ✅ `xattr -d com.apple.provenance` - Failed (attribute returns automatically)
- ✅ Copying files to `/tmp` - Failed (macOS adds attribute automatically)
- ❌ **Result:** Cannot remove `com.apple.provenance` on macOS 26.2

---

## 🛠️ Applied Solutions

### Solution 1: Modify Xcode Build Settings
**Modified Files:**
- `ios/Flutter/Debug.xcconfig`
- `ios/Flutter/Release.xcconfig`
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Podfile`

**Changes:**
```xcconfig
// Disable code signing for simulator
CODE_SIGN_IDENTITY[sdk=iphonesimulator*]=
CODE_SIGNING_REQUIRED[sdk=iphonesimulator*]=NO
CODE_SIGNING_ALLOWED[sdk=iphonesimulator*]=NO
```

**Result:** ❌ Did not solve - `dyld` still refuses to load `Flutter.framework`

---

### Solution 2: Create Wrapper Script to Clean Extended Attributes
**File:** `ios/xcode_backend_wrapper.sh`

**Function:**
- Clean Extended Attributes from `Flutter.framework` before each build
- Disable Code Signing for simulator

**Result:** ❌ Did not solve - macOS adds attribute back automatically

---

### Solution 3: Modify Flutter SDK
**File:** `/opt/homebrew/share/flutter/packages/flutter_tools/bin/xcode_backend.sh`

**Modification:**
- Disable `_signFramework` for simulator

**Result:** ❌ Did not solve - Problem is in `dyld`, not signing process

---

### Solution 4: Manually Re-sign Frameworks
**Command:**
```bash
codesign --force --sign - --timestamp=none Flutter.framework/Flutter
```

**Result:** ❌ Failed - `codesign` refuses to sign due to `com.apple.provenance`

---

### Solution 5: Build via xcodebuild Directly
**Command:**
```bash
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build
```

**Result:** ✅ Build succeeded, but app still crashes on launch

---

### Solution 6: Re-sign App After Installation
**Command:**
```bash
# Sign all frameworks in installed app
codesign --force --sign - --timestamp=none \
  /path/to/Runner.app/Frameworks/*.framework/*

# Sign Runner.debug.dylib and Runner
codesign --force --sign - --timestamp=none \
  /path/to/Runner.app/Runner.debug.dylib \
  /path/to/Runner.app/Runner
```

**Result:** ✅ Signing succeeded, but app still crashes - `dyld` rejects signature due to Extended Attributes

---

## 📊 Complete Crash Report

### Latest Crash Report:
```json
{
  "termination": {
    "code": 1,
    "flags": 518,
    "namespace": "DYLD",
    "indicator": "Library missing",
    "reasons": [
      "Library not loaded: @rpath/Flutter.framework/Flutter",
      "Referenced from: Runner.debug.dylib",
      "Reason: tried: '/Library/.../Flutter.framework/Flutter' (no such file)",
      "'/Users/.../Runner.app/Frameworks/Flutter.framework/Flutter' (code signature in <...>)"
    ]
  }
}
```

### Additional Information:
- **Exception Type:** EXC_CRASH (SIGABRT)
- **Triggered by Thread:** 0 (Main Thread)
- **Crash Location:** `dyld4::prepareSim()` - before app loads

---

## 🔬 Additional Checks Performed

### 1. Flutter.framework Check:
```bash
✅ File exists at: Runner.app/Frameworks/Flutter.framework/Flutter
✅ Size: ~77MB
✅ Architecture: arm64
✅ Code Signature: Present but dyld rejects it
❌ Extended Attributes: com.apple.provenance (cannot be removed)
```

### 2. Build Settings Check:
```bash
✅ EXCLUDED_ARCHS: i386 only (arm64 not excluded)
✅ ONLY_ACTIVE_ARCH: YES for simulator
✅ CODE_SIGNING_REQUIRED: NO for simulator
✅ CODE_SIGNING_ALLOWED: NO for simulator
```

### 3. Pods Check:
```bash
✅ Podfile: platform :ios, '13.0'
✅ All Pods updated
✅ pod install succeeded without errors
```

---

## 💡 Proposed Solutions (Not Yet Applied)

### Proposed Solution 1: Use Physical iPhone ⭐ (Primary Recommendation)
**Reason:** Physical devices handle code signing and security attributes differently than the simulator. The strict checks causing the `dyld` crash due to `com.apple.provenance` are typically not an issue in the same way for development provisioning on real hardware.

**Steps:**
1. Enable Developer Mode on iPhone:
   - Settings → Privacy & Security → Developer Mode
2. Restart iPhone
3. Run: `flutter run -d iPhone` or `flutter run -d [Device ID]`

**Cost:** Free (if you have an iPhone)

**Note:** This is the most reliable workaround to continue development.

---

### Proposed Solution 2: Use Older iOS Simulator Runtime ⭐ (Highly Recommended)
**Reason:** The issue is exacerbated by the combination of the latest macOS and the latest iOS Simulator runtime. An older iOS version (e.g., iOS 17.x or 18.x) running on the simulator might have less stringent checks or interact differently with the host OS's file attributes.

**Steps:**
1. In Xcode: **Settings > Components** (or **Preferences > Components**)
2. Download iOS 17.x or 18.x Simulator Runtime
3. Create a new simulator instance with older version:
   ```bash
   xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" "iOS17.5"
   ```
4. Test app on older simulator:
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

**Cost:** Free

**Note:** This solution may completely resolve the issue as older iOS versions may not verify Extended Attributes in the same way.

---

### Proposed Solution 3: Build via Xcode Directly ⭐ (Recommended)
**Reason:** Sometimes, the build and run process within Xcode handles signing and embedding frameworks slightly differently than the `flutter run` command-line tool. This might allow Xcode's internal tools to manage the attributes or signing more effectively.

**Steps:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select a simulator from the device list at the top
3. Press **⌘+R** to build and run

**Cost:** Free

**Note:** Xcode may handle Extended Attributes differently than Flutter CLI.

---

### Proposed Solution 4: Wait for Tooling Updates
**Reason:** Since macOS 26.2 is a very new (likely beta or preview) OS version, this is almost certainly a bug or a new security feature that Flutter and Xcode tooling have not yet adapted to.

**Steps:**
- Monitor Flutter Stable Channel updates
- Monitor macOS updates
- Monitor related GitHub issues:
  - Flutter: https://github.com/flutter/flutter/issues
  - Search for: "com.apple.provenance", "macOS 26", "Sequoia", "code signing simulator"

**Cost:** Free (but may take time)

**Note:** It is highly probable that a fix will be released in a future version of the Flutter SDK or Xcode to handle this specific extended attribute correctly.

---

### Proposed Solution 5: Use Flutter Dev Channel
**Reason:** May contain fixes for recent issues

**Steps:**
```bash
flutter channel dev
flutter upgrade
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

**Cost:** Free (but may be unstable)

**Note:** May be unstable, but may contain early fixes.

---

## 🎯 Expert Recommendations

After expert consultation, it has been confirmed that the crash is caused by a conflict between macOS 26.2's security features (`com.apple.provenance`) and the code signing requirements of the iOS Simulator. Since you cannot forcibly remove this attribute, the most practical immediate steps to continue development are:

### Priority 1: Use Physical iPhone
- **Most reliable** to continue development
- Physical devices handle Code Signing differently
- Don't suffer from the same Extended Attributes issue

### Priority 2: Use Older iOS Simulator
- **Highly recommended** as an alternative solution
- Older iOS versions (17.x or 18.x) may not verify Extended Attributes in the same way
- Can be downloaded from Xcode Settings > Components

### Priority 3: Use Xcode Directly
- Xcode may handle Code Signing differently than Flutter CLI
- Try building and running from within Xcode (⌘+R)

### Priority 4: Wait for Updates
- macOS 26.2 is very new and there may be upcoming fixes
- Monitor Flutter and macOS updates

---

## 📝 Important Notes

### 1. macOS 26.2 (Sequoia) New Issue:
- `com.apple.provenance` is automatically added to all files
- Cannot be removed even with `sudo`
- This is a known issue in macOS Sequoia

### 2. Flutter.framework Code Signature:
- Signature exists but `dyld` rejects it
- Reason: Extended Attributes (`com.apple.provenance`)
- `codesign` refuses to sign due to: `resource fork, Finder information, or similar detritus not allowed`

### 3. iOS 26.2 Simulator:
- Very new version
- May have compatibility issues with Flutter
- Recommended to try older version

---

## 🔗 References and Sources

### Modified Project Files:
- `ios/Flutter/Debug.xcconfig`
- `ios/Flutter/Release.xcconfig`
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Podfile`
- `ios/xcode_backend_wrapper.sh`

### Crash Reports:
- `~/Library/Logs/DiagnosticReports/Runner-*.ips`

### Flutter SDK:
- `/opt/homebrew/share/flutter/packages/flutter_tools/bin/xcode_backend.sh`

---

## 📞 For Consultation

### Useful Information for Consultant:
1. **OS:** macOS 26.2 (Sequoia) - Very new version
2. **Core Issue:** `com.apple.provenance` Extended Attribute prevents Code Signing
3. **Error:** `dyld` refuses to load `Flutter.framework` due to Code Signature
4. **Applied Solutions:** All common solutions failed
5. **Result:** App crashes immediately on launch

### Questions for Consultant:
1. Is there a way to remove `com.apple.provenance` on macOS 26.2?
2. Is there a workaround for Code Signing with Extended Attributes?
3. Are there Xcode settings that can be changed?
4. Should we wait for Flutter/macOS updates?
5. Will using a physical iPhone solve the problem?

---

## ✅ Summary

**Problem:** macOS 26.2 automatically adds `com.apple.provenance` which prevents correct Code Signing of `Flutter.framework`, causing `dyld` to refuse loading it and the app to crash immediately.

**Applied Solutions:** All common solutions failed due to inability to remove Extended Attributes.

**Proposed Solutions:** Use physical iPhone, older iOS simulator, or wait for Flutter/macOS updates.

---

---

## 📊 Current System Status

### Installed iOS Runtimes:
- ✅ iOS 26.2 only (current version causing the issue)
- ❌ No older versions installed (iOS 17/18)

### Available Simulators:
- iPhone 17 Pro Max (iOS 26.2) - Current simulator
- iPhone 17 Pro (iOS 26.2)
- iPhone 17 (iOS 26.2)
- iPhone 16e (iOS 26.2)
- And others... (all iOS 26.2)

### Physical Devices:
- ⚠️ Physical iPhone detected ("iPhone Lobna") but not currently connected

**Summary:** You need to download iOS 17/18 runtime from Xcode to create an older version simulator.

---

## 🚀 Quick Implementation Steps

### To Check Available Simulators:
```bash
./scripts/try_ios_solutions.sh
# or
xcrun simctl list devices available
```

### To Create New Simulator with Older iOS Version:
1. Download iOS Runtime from Xcode: **Settings > Components**
2. Create simulator:
   ```bash
   xcrun simctl create "iPhone 15 Pro iOS 18" "iPhone 15 Pro" "iOS18.0"
   ```
3. Run app:
   ```bash
   flutter run -d "iPhone 15 Pro iOS 18"
   ```

### To Run App from Xcode:
```bash
open ios/Runner.xcworkspace
# Then press ⌘+R in Xcode
```

### To Run App on Physical iPhone:
```bash
# 1. Enable Developer Mode on iPhone
# 2. Connect iPhone to computer
# 3. Run:
flutter devices  # To check available devices
flutter run -d iPhone
```

---

**Report Date:** January 8, 2026  
**Version:** 2.0 (Updated with Expert Recommendations)


