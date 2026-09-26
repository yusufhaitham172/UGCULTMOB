# UI Design & Fluid Animation Enhancement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Elevate UGCULT Mobile to Apple-grade Cupertino design fidelity and fluid spring motion across tokens, core widgets, and all primary screens (Splash, Auth/OTP, Onboarding, and Home feeds) following [DOCS/Design.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/Design.md).

**Architecture:** Custom physics-driven interactive pressables (`BouncyScale`), multi-layer liquid glass optical containers (`GlassContainer`), and choreographed staggered entrances (`StaggeredSlideFade`) using standard Flutter animation controllers and Cupertino/Material primitives with zero unnecessary external dependencies.

**Tech Stack:** Flutter 3.x, Dart 3.x, Flutter Riverpod, GoRouter, HapticFeedback.

## Global Constraints

- Strict adherence to [DOCS/Design.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/Design.md) and Apple Human Interface Guidelines.
- All interactive touch items must provide immediate zero-latency feedback (`HapticFeedback.selectionClick()`) and dampening spring rebound.
- Glass containers must respect performance blur budgets ($\le 24\sigma$).
- All test suites must pass (`flutter test`).

---

### Task 1: Motion Tokens & Universal Touch Spring Primitive (`BouncyScale`)

**Files:**
- Modify: `lib/app/theme/tokens.dart`
- Create: `lib/core/widgets/bouncy_scale.dart`
- Modify: `lib/core/widgets/widgets.dart`
- Test: `test/core/widgets/bouncy_scale_test.dart`

**Interfaces:**
- Produces: `BouncyScale(onTap: VoidCallback?, child: Widget, scaleDownFactor: double = 0.96, enableHaptic: bool = true)`
- Consumes: `AppTokens.curveSpring`, `AppTokens.durationFast`

- [ ] **Step 1: Write the failing widget test for `BouncyScale`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/core/widgets/bouncy_scale.dart';

void main() {
  testWidgets('BouncyScale scales down on tap down and rebounds on tap up', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BouncyScale(
              onTap: () => tapped = true,
              child: const SizedBox(width: 100, height: 100, key: Key('target')),
            ),
          ),
        ),
      ),
    );

    final finder = find.byKey(const Key('target'));
    expect(finder, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump(const Duration(milliseconds: 50));

    // Should be transformed/scaled
    final transformFinder = find.byType(Transform);
    expect(transformFinder, findsWidgets);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/bouncy_scale_test.dart`
Expected: FAIL (file or class not found)

- [ ] **Step 3: Implement `AppMotion` / `AppTokens` spring curves and `BouncyScale` widget**

Implement `BouncyScale` with `GestureDetector` / `Listener`, `AnimationController`, `CurvedAnimation`, and `HapticFeedback.selectionClick()`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/bouncy_scale_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/theme/tokens.dart lib/core/widgets/bouncy_scale.dart lib/core/widgets/widgets.dart test/core/widgets/bouncy_scale_test.dart
git commit -m "feat(ui): add BouncyScale fluid gesture spring primitive and motion tokens"
```

---

### Task 2: Multi-Layer Liquid Glass & Shimmer Enhancement (`GlassContainer`, `AppShimmer`)

**Files:**
- Modify: `lib/core/widgets/glass_container.dart`
- Modify: `lib/core/widgets/shimmer_loader.dart`
- Test: `test/core/widgets/glass_container_test.dart`

**Interfaces:**
- Consumes: `AppColors.canvasGradient`, `AppTokens.radiusMd`
- Produces: `GlassContainer(blurSigma: double, tintColor: Color?, borderGradient: Gradient?, child: Widget)`

- [ ] **Step 1: Write test for `GlassContainer` specular border and tint options**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ugcult/core/widgets/glass_container.dart';

void main() {
  testWidgets('GlassContainer renders BackdropFilter and specular border', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            blurSigma: 16.0,
            child: Text('Glass Content'),
          ),
        ),
      ),
    );

    expect(find.text('Glass Content'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails or needs update**

Run: `flutter test test/core/widgets/glass_container_test.dart`

- [ ] **Step 3: Enhance `GlassContainer` & `ShimmerLoader`**

Add refractive 1px gradient border simulating directional light, concentric geometry clipping, and dual-tone smooth shimmer animation.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/glass_container_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/glass_container.dart lib/core/widgets/shimmer_loader.dart test/core/widgets/glass_container_test.dart
git commit -m "feat(ui): enhance GlassContainer optical refraction and ShimmerLoader"
```

---

### Task 3: Interactive Component Polish (`AppButton`, `AppTextInput`, `StatusPill`)

**Files:**
- Modify: `lib/core/widgets/app_button.dart`
- Modify: `lib/core/widgets/app_text_input.dart`
- Modify: `lib/core/widgets/status_pill.dart`
- Test: `test/core/widgets/app_button_test.dart`

**Interfaces:**
- Consumes: `BouncyScale`, `AppColors`, `AppTokens`
- Produces: Enhanced button with match glow gradient, animated input focus ring and shake physics, and frosted status pills with pulsing dot.

- [ ] **Step 1: Write widget tests for animated focus & button match blend**

- [ ] **Step 2: Run tests to verify failure/baseline**

Run: `flutter test test/core/widgets/app_button_test.dart`

- [ ] **Step 3: Implement component upgrades**

- [ ] **Step 4: Run tests to verify pass**

Run: `flutter test test/core/widgets/app_button_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/app_button.dart lib/core/widgets/app_text_input.dart lib/core/widgets/status_pill.dart test/core/widgets/app_button_test.dart
git commit -m "feat(ui): add BouncyScale and Cupertino polish to AppButton, AppTextInput, StatusPill"
```

---

### Task 4: Splash Screen Dual-Disc Entrance & Micro-Haptics (`SplashScreen`)

**Files:**
- Modify: `lib/features/auth/presentation/screens/splash_screen.dart`
- Test: `test/features/auth/splash_screen_test.dart`

**Interfaces:**
- Consumes: `AppColors.babyBlueSolid`, `AppColors.babyPinkSolid`, `AppTokens`
- Produces: Choreographed disc convergence animation with radial bloom and staggered tagline.

- [ ] **Step 1: Update/write tests for splash animation lifecycle**

- [ ] **Step 2: Implement choreographed disc convergence, blooming mesh, and tagline slide-fade**

- [ ] **Step 3: Verify tests and screen flow**

Run: `flutter test test/features/auth/splash_screen_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/presentation/screens/splash_screen.dart test/features/auth/splash_screen_test.dart
git commit -m "feat(ui): choreographed dual-disc bloom and fluid tagline on SplashScreen"
```

---

### Task 5: Auth & OTP Screen Interactive Polish (`PhoneOtpScreen`)

**Files:**
- Modify: `lib/features/auth/presentation/screens/phone_otp_screen.dart`
- Test: `test/features/auth/phone_otp_screen_test.dart`

**Interfaces:**
- Consumes: `BouncyScale`, `AppTextInput`, `EgyptianPhoneFormatter`
- Produces: Animated OTP boxes with elastic pop, error shake controller, and circular countdown timer.

- [ ] **Step 1: Write tests for OTP input interactions and countdown**

- [ ] **Step 2: Implement animated OTP digit cells, error shake animation, and circular resend progress**

- [ ] **Step 3: Run test suite to verify**

Run: `flutter test test/features/auth/phone_otp_screen_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/presentation/screens/phone_otp_screen.dart test/features/auth/phone_otp_screen_test.dart
git commit -m "feat(ui): add elastic OTP boxes, error shake, and timer animation to PhoneOtpScreen"
```

---

### Task 6: Onboarding Screens Motion Polish (`RoleSelectionScreen`, Profile Setup)

**Files:**
- Modify: `lib/features/onboarding/presentation/screens/role_selection_screen.dart`
- Modify: `lib/features/onboarding/presentation/screens/creator_profile_setup_screen.dart`
- Modify: `lib/features/onboarding/presentation/screens/brand_profile_setup_screen.dart`
- Test: `test/features/onboarding/onboarding_screens_test.dart`

**Interfaces:**
- Consumes: `BouncyScale`, `GlassContainer`, `AppButton`
- Produces: Ambient glowing role cards with spring checkmark pop, interactive multi-select chips, and floating glass bottom action bar.

- [ ] **Step 1: Run existing onboarding tests as baseline**

Run: `flutter test test/features/onboarding/onboarding_screens_test.dart`

- [ ] **Step 2: Implement role card spring animations, chip pop physics, and floating glass bar**

- [ ] **Step 3: Run onboarding tests to verify pass**

Run: `flutter test test/features/onboarding/onboarding_screens_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/onboarding/presentation/screens/ test/features/onboarding/onboarding_screens_test.dart
git commit -m "feat(ui): elevate Onboarding screens with ambient orbs, spring chips, and glass bottom bar"
```

---

### Task 7: Home Feeds & Navigation Polish (`CreatorHomeScreen`, `BrandHomeScreen`)

**Files:**
- Modify: `lib/features/home/presentation/screens/creator_home_screen.dart`
- Modify: `lib/features/home/presentation/screens/brand_home_screen.dart`
- Create: `lib/core/widgets/staggered_slide_fade.dart`
- Test: `test/features/home/home_screens_test.dart`

**Interfaces:**
- Consumes: `GlassContainer`, `BouncyScale`, `StatusPill`
- Produces: Floating glass segmented tab bar, staggered campaign card entrance, and glass price badges.

- [ ] **Step 1: Write test for `StaggeredSlideFade` and home screen rendering**

- [ ] **Step 2: Implement `StaggeredSlideFade` and polish `CreatorHomeScreen` & `BrandHomeScreen`**

- [ ] **Step 3: Run home screen tests to verify**

Run: `flutter test test/features/home/home_screens_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/presentation/screens/ lib/core/widgets/staggered_slide_fade.dart test/features/home/home_screens_test.dart
git commit -m "feat(ui): add floating glass navigation and staggered cards to Home screens"
```

---

### Task 8: Full Verification & Code Health Check

**Files:**
- Verification across entire codebase

- [ ] **Step 1: Run `flutter analyze`**

Run: `flutter analyze`
Expected: No errors / clean linter output.

- [ ] **Step 2: Run complete test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 3: Final Commit & Summary**

```bash
git commit -m "chore(ui): complete UI design and fluid animations enhancement pass"
```
