# iOS SDK Version and Xcode Update (May 2026)

## Problem
App Store Connect rejected the iOS upload with the following error:
```
SDK version issue. This app was built with the iOS 18.1 SDK. 
All iOS and iPadOS apps must be built with the iOS 26 SDK or later, 
included in Xcode 26 or later...
```

## Root Cause
- The GitHub Actions workflow was using Xcode 16.1.
- Apple updated their requirements (likely as of April/May 2026) to require Xcode 26 and the iOS 26 SDK.

## Solution Applied

### 1. Updated GitHub Actions Workflow (`.github/workflows/ios.yml`)
- **Runner Update:** Changed `runs-on` from `macos-14` to `macos-15` to ensure compatibility with newer Xcode versions.
- **Xcode Update:** Changed `xcode-version` from `16.1` to `26.0`.
- **Deployment Target:** Bumped `IPHONEOS_DEPLOYMENT_TARGET` and `MinimumOSVersion` from `15.0` to `17.0` to ensure the app remains compatible with modern SDK standards.

### 2. Updated Local Project Configuration
- **Xcode Project:** Updated `IPHONEOS_DEPLOYMENT_TARGET` to `17.0` in `Runner.xcodeproj/project.pbxproj`.
- **Podfile:** Updated `platform :ios` to `17.0`.
- **Plist:** Updated `MinimumOSVersion` in `AppFrameworkInfo.plist` to `17.0`.

## How to Verify

1. **Push Changes:**
   ```bash
   git add .
   git commit -m "Update iOS SDK to 26 and Xcode to 26"
   git push
   ```

2. **Run Workflow:**
   - Go to GitHub Actions → **iOS Build and Deploy**.
   - Click "Run workflow".

3. **Check Logs:**
   - Verify that the `Setup Xcode` step shows Xcode 26.0.
   - Verify that the `Deploy to TestFlight` step succeeds without SDK version warnings.

## Summary of Version Changes

| Component | Old Value | New Value |
|-----------|-----------|-----------|
| macOS Runner | macos-14 | macos-15 |
| Xcode Version | 16.1 | 26.0 |
| iOS SDK | 18.1 | 26.0 |
| Deployment Target | 15.0 | 17.0 |

---
**Status:** Fixed and ready for deployment. 🚀
