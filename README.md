# UGCULT Mobile 🎬📱

[![iOS Cloud Build](https://github.com/ugcult/ugcult-mobile/actions/workflows/ios-build.yml/badge.svg)](https://github.com/ugcult/ugcult-mobile/actions/workflows/ios-build.yml)
[![Android Cloud Build](https://github.com/ugcult/ugcult-mobile/actions/workflows/android-build.yml/badge.svg)](https://github.com/ugcult/ugcult-mobile/actions/workflows/android-build.yml)
[![Test & Lint](https://github.com/ugcult/ugcult-mobile/actions/workflows/test-and-lint.yml/badge.svg)](https://github.com/ugcult/ugcult-mobile/actions/workflows/test-and-lint.yml)

> **Production-grade mobile platform connecting Egyptian UGC creators with emerging and enterprise brands.**

---

## 🌟 Overview

UGCULT Mobile transforms the chaotic, informal creator-brand collaboration in Egypt into a structured, accountable, and transparent mobile experience:
- **Creators:** Showcase video & photo reel portfolios, apply to campaigns with 1 tap, submit deliverables with structured feedback markers, and get protected by double-blind ratings and dual payment audit confirmations.
- **Brands:** Create campaigns with clear briefs and accepted deliverable types (video/photo), review applicants with rich previews, approve or request revisions directly on deliverables, and confirm off-platform payments (Instapay, Bank Transfer).
- **Security:** Zero-trust architecture powered by PostgreSQL Row-Level Security (RLS) ensuring creator private contacts (Phone, Instapay, Shipping) are strictly locked until a brand approves their application.

---

## 🛠️ Tech Stack & Architecture

- **Frontend:** Flutter 3.x (Dart 3.x) targeting **iOS** (and Android cross-platform)
- **Host Development OS:** Windows 10 / 11 (PowerShell)
- **State Management:** Riverpod 2.x with code generation (`flutter_riverpod`, `riverpod_annotation`)
- **Routing:** `go_router` with declarative route guards and deep linking
- **Backend:** Supabase (PostgreSQL 16, Supabase Auth, Storage, Edge Functions)
- **Push Notifications:** Firebase Cloud Messaging (FCM) & Apple Push Notification service (APNs)
- **CI/CD Build Pipeline:** GitHub Actions (`macos-14` cloud runners for iOS compilation & packaging; `ubuntu-latest` for Android & automated tests)

---

## 💻 Developing for iOS on Windows

This project is configured for seamless **iOS development from a Windows workstation**:

1. **Local Iteration on Windows:**
   - Develop UI, business logic, and Riverpod state locally with instant hot-reload.
   - Run and test using `flutter run -d chrome`, `flutter run -d windows`, or Android emulator with iOS/Cupertino styling and physics.
2. **Automated Cloud iOS Builds:**
   - Pushing commits triggers GitHub Actions on a hosted `macos-14` runner to run tests and compile the native iOS `.ipa` / `.app` bundle.
3. **Physical iOS Testing:**
   - Download cloud build artifacts or distribute directly to physical iPhones via Apple TestFlight.

👉 **See [DOCS/IOS-WINDOWS-DEV-GUIDE.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/IOS-WINDOWS-DEV-GUIDE.md) for full instructions.**

---

## 🚀 Quick Start (Windows PowerShell)

```powershell
# 1. Clone the repository
git clone https://github.com/ugcult/ugcult-mobile.git
cd UGCULTMOB

# 2. Install Flutter dependencies
flutter pub get

# 3. Generate code (Riverpod & Freezed models)
dart run build_runner build --delete-conflicting-outputs

# 4. Run tests and static analysis
flutter analyze
flutter test

# 5. Launch local development server
flutter run -d chrome
```

---

## 📚 Documentation Index

| Document | Purpose |
|---|---|
| [**iOS on Windows Guide**](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/IOS-WINDOWS-DEV-GUIDE.md) | Step-by-step iOS development, testing & cloud build workflow on Windows |
| [**Product Requirements Document (PRD)**](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/PRD.md) | Feature specifications, user roles, tenancy model, and workflows |
| [**System Architecture**](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/ARCHITECTURE.md) | Clean architecture layers, Riverpod flow, media pipeline & security |
| [**Implementation Plan**](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/IMPLEMENTATION-PLAN.md) | Phased roadmap, milestones, and task checklists |
| [**Design System Specification**](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/Design.md) | Dual-tint color tokens, Cupertino glassmorphism, typography & motion |
| [**API & Edge Functions Spec**](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/API-SPEC.md) | REST endpoints, RPC calls, Edge functions, and payload schemas |
| [**Database Schema & RLS**](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/DB-DESIGN.md) | PostgreSQL 16 DDL, enum types, triggers, and Zero-Trust RLS policies |
