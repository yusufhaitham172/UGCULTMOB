# UGCULT — iOS Development on Windows Guide

**Target Application:** UGCULT Mobile (iOS Native Experience & Android Cross-Platform)  
**Host Development OS:** Windows 10 / 11 (PowerShell)  
**Framework:** Flutter 3.x (Dart 3.x)  
**Backend:** Supabase (PostgreSQL 16) + Firebase (FCM / APNs)  
**Status:** Approved v3.0 (Post-Grill Revision)  

---

## 1. Overview & Development Strategy

Developing a world-class iOS mobile app on a Windows workstation is a well-established and highly productive workflow using Flutter. 

Since Flutter compiles directly to ARM64 iOS binaries while offering hot-reload and desktop rendering engines locally on Windows, our development lifecycle separates **rapid local UI/logic iteration** from **cloud-based iOS native compilation**.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                           Windows Development Host                               │
│  - Code Editing & Refactoring (Dart / Flutter)                                   │
│  - Instant UI Iteration via Chrome / Windows Desktop / Android                   │
│  - iOS Cupertino Theme & Layout Simulation (Notch, Safe Area, Dynamic Island)    │
│  - Static Analysis (`flutter analyze`) & Unit/Widget Testing (`flutter test`)    │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         │ (Git Push / GitHub Actions Dispatch)
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                   Automated Cloud macOS Runner (macos-14)                        │
│  - Xcode SDK 15/16 + CocoaPods / Swift Package Manager                           │
│  - Native iOS Compilation (`flutter build ios` / `flutter build ipa`)            │
│  - Code Signing & Provisioning Profiles                                          │
│  - Artifact Upload & Fastlane Deploy to Apple TestFlight / App Store Connect     │
└────────────────────────┬─────────────────────────────────────────────────────────┘
                         │
                         │ (TestFlight Distribution)
                         ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                           Physical iPhone Devices                                │
│  - Real-world iOS Testing, Camera, APNs Push Notifications                       │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Daily Local Iteration on Windows

### 2.1 Running Locally on Windows
During active feature development, test UI layouts, state management (Riverpod), and database integrations (Supabase) locally:

```powershell
# 1. Check connected devices and Flutter status
flutter devices
flutter doctor

# 2. Run in Web / Chrome with mobile viewport simulation
flutter run -d chrome

# 3. Run on Windows Desktop (fastest compile time for UI layout)
flutter run -d windows

# 4. Run on connected Android device / emulator (tests mobile touch physics)
flutter run -d android
```

### 2.2 Enforcing iOS-Native UI/UX & Cupertino Fidelity
To ensure the app feels 100% native to iOS users while building on Windows:
1. **Target Platform Override for Testing:**
   In development mode or test wrappers, force iOS platform behavior:
   ```dart
   MaterialApp(
     theme: ThemeData(
       platform: TargetPlatform.iOS, // Forces Cupertino scroll physics, swipe-to-back, and native transitions
     ),
   )
   ```
2. **Cupertino Navigation Transitions:**
   Use `CupertinoPageRoute` or `GoRouter` with iOS slide transitions to enable the native swipe-back gesture.
3. **Safe Area & Dynamic Island Accommodations:**
   Always wrap top-level scaffolds in `SafeArea` or query `MediaQuery.of(context).padding` to ensure UI respects the notch, Dynamic Island, and iOS Home Indicator bar.
4. **Haptics:**
   Call `HapticFeedback.lightImpact()` or `HapticFeedback.selectionClick()` on button presses and pull-to-refresh.

---

## 3. iOS Cloud Build & Packaging Pipeline

Native iOS compilation requires Apple's Xcode toolchain (running on macOS). All iOS release binaries and TestFlight payloads are built automatically via GitHub Actions:

### 3.1 GitHub Actions Workflow (`.github/workflows/ios-build.yml`)
- Runs on GitHub's hosted `macos-14` Apple Silicon runners.
- Installs Flutter, dependencies (`flutter pub get`), runs tests (`flutter test`), and builds the iOS bundle.
- Produces a downloadable `.zip` / `.ipa` artifact on every push or manual dispatch.

### 3.2 Triggering an iOS Build from Windows
You can trigger an iOS cloud build directly from your Windows terminal:
```powershell
# Commit and push changes
git add .
git commit -m "feat: implement creator portfolio reels player"
git push origin main

# (Optional) Trigger manually via GitHub CLI
gh workflow run ios-build.yml
```

---

## 4. Testing on Physical iOS Devices

1. **Apple TestFlight (Recommended):**
   - Cloud CI/CD builds the `.ipa` with distribution certificates.
   - Pushes build directly to App Store Connect / TestFlight.
   - Testers and developers receive instant over-the-air updates on physical iPhones.
2. **Local Debugging against Supabase:**
   - Supabase backend is hosted in the cloud or accessible over the local network via HTTPS/WSS.
   - Physical iPhones running TestFlight builds interact with the real backend, storage buckets, and FCM push notifications.

---

## 5. Verification & Testing Commands on Windows

Run these commands locally on Windows before pushing code:

| Command | Purpose |
|---|---|
| `flutter pub get` | Resolve and download all project dependencies |
| `flutter analyze` | Run Dart analyzer to catch syntax, type, and lint issues |
| `flutter test` | Run complete unit and widget test suite |
| `flutter test --coverage` | Generate code coverage metrics |
| `dart run build_runner build --delete-conflicting-outputs` | Generate Riverpod & JSON serialization code |

---

## 6. Key iOS-Specific Libraries Configured in Project

| Feature | Flutter Package | iOS Native Capability |
|---|---|---|
| **Secure Token Storage** | `flutter_secure_storage` | iOS Keychain Enclave |
| **Biometric Auth** | `local_auth` | Face ID / Touch ID |
| **Push Notifications** | `firebase_messaging` | Apple Push Notification service (APNs) |
| **Media Selection** | `image_picker` | iOS Photo Library & Camera permissions |
| **Video Compression** | `video_compress` | Native AVFoundation H.264 hardware encoding |
| **Liquid Glass Styling** | `BackdropFilter` + Custom Shaders | Metal / Impeller hardware-accelerated blur |
| **Typography** | `google_fonts` (Readex Pro) | Scalable iOS Dynamic Type metrics |
