# UGCULT Mobile — UI Design & Fluid Animation Enhancement Spec

**Date:** 2026-09-26  
**Status:** Approved  
**Author:** Pair Programming Agent  
**References:** [DOCS/Design.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/Design.md) · [DOCS/PRD.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/PRD.md) · [DOCS/ARCHITECTURE.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/ARCHITECTURE.md)

---

## 1. Overview & Objectives
This specification details the comprehensive UI design and animation enhancement across UGCULT Mobile (Flutter 3.x / Dart). The goal is to bring the application to full Apple-grade Cupertino fidelity, tactile fluidity, and visual excellence as mandated by Apple Human Interface Guidelines and UGCULT's dual-tint brand system ("Two Tints, One Lens").

---

## 2. Design Tokens & Motion Physics Engine

### 2.1 Motion Constants (`AppMotion` / `AppTokens`)
- **Zero-Latency Touch Springs:**
  - Standard Press Scale: `0.96` (small buttons / cards) / `0.98` (full-width cards)
  - Press-in Duration: `120ms`
  - Rebound Curve: Custom damped spring physics (`mass: 1.0, stiffness: 260.0, damping: 20.0`)
  - Haptic Pairing: Instant `HapticFeedback.selectionClick()` on touch contact
- **Page & Stagger Transitions:**
  - Item Stagger Offset: `40ms` per item
  - Slide Offset: `18pt` vertical delta
  - Entrance Curve: `Curves.easeOutCubic` (350ms total duration)
  - Error Shake: 3 cycles of sine oscillation (`8pt` amplitude, `300ms` total duration)

### 2.2 Color & Gradient Refinement (`AppColors`)
- **Brand Dual Tints:**
  - Baby Blue Tint: `#89CFF0` (500) / `#5DB4E8` (600) / `#2A73A6` (800)
  - Baby Pink Tint: `#F09BBB` (500) / `#E5729D` (600) / `#A23A64` (800)
  - The Match Blend: `LinearGradient(135deg, #A9D4F7, #F8C0D6)`
- **Specular Refraction Gradients:**
  - Light Rim: `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0x73FFFFFF), Color(0x14FFFFFF)])`

---

## 3. Core Component Architecture

### 3.1 `BouncyScale` / `InteractivePressable`
Universal gesture container providing:
1. Immediate scale-down feedback on `onTapDown`.
2. Haptic tick feedback.
3. Natural spring velocity rebound on `onTapUp` / `onTapCancel`.
4. Scroll gesture pass-through (canceling scale cleanly when drag motion exceeds threshold).

### 3.2 Enhanced `GlassContainer`
1. **Backdrop Filter:** Dual-sigma configuration (`12.0` standard, `20.0` floating navigation bar and modals).
2. **Specular Border:** 1px directional border gradient simulating overhead ambient lighting.
3. **Concentric Inner Padding:** Mathematical inner corner alignment ($R_{\text{inner}} = R_{\text{outer}} - \text{padding}$).
4. **Tint Overlays:** Dynamic tint support for Creator Pink, Brand Blue, Neutral Frosted, and Match Blend.

### 3.3 Enhanced `AppButton` & `StatusPill`
- **`AppButton`:** Wrapped in `BouncyScale`, supporting solid tint variants, outlined glass variants, and the signature glowing Match Gradient CTA with subtle radial underglow.
- **`StatusPill`:** Frosted glass capsule with saturated 1px border ring and pulsing in-progress state dot.

### 3.4 Enhanced `AppTextInput`
- Cupertino-styled text input with animated focus glow border transition.
- Error state horizontal shake animation triggered on validation error.
- Spring-popping clear button.

### 3.5 Shimmer System (`AppShimmer`)
- Continuous 1.4s sweep dual-tone gradient shimmer (`#E8EDF5` $\to$ `#F3F7FC` $\to$ `#E8EDF5`) for image and card placeholders.

---

## 4. Screen-by-Screen Polish

### 4.1 Splash Screen (`SplashScreen`)
- Animated dual-disc entrance (Baby Blue disc from left, Baby Pink disc from right) merging into the 135° Match Blend.
- Soft haptic tick on disc convergence.
- Pulsing ambient background radial mesh.
- Staggered tagline entrance: "Egypt's Premier UGC Marketplace".

### 4.2 Auth & OTP Flow (`PhoneOtpScreen`)
- Responsive phone input with Egyptian flag badge and instant phone formatting.
- Dynamic 6-digit OTP boxes with spring pop on entry, focused pastel glow, and error shake.
- Circular countdown progress timer for OTP resend action.

### 4.3 Onboarding & Role Selection (`RoleSelectionScreen`, `Creator/BrandProfileSetup`)
- **Role Cards:** Floating paper/glass cards with ambient glowing orbs (Creator Pink vs Brand Blue), animated border transitions, and spring checkmark draw.
- **Category & Governorate Selectors:** Multi-select chips with spring scale pops on toggle.
- **Sticky Floating Action Bar:** Glass-morphic bottom bar preserving background blur while scrolling long forms.

### 4.4 Home Feeds (`CreatorHomeScreen`, `BrandHomeScreen`)
- Floating frosted segmented navigation tab bar with animated sliding pill indicator.
- Staggered feed entrance animation for campaign cards.
- Campaign cards with pure white paper material, subtle blue-tinted drop shadows, glass price badges, and category tags.

---

## 5. Verification & Testing Strategy
- Unit & Widget Tests for `BouncyScale`, `GlassContainer`, and animated components.
- Run `flutter analyze` and `flutter test` across all test suites to guarantee zero regressions.
- Validate iOS 120Hz frame rendering and haptic feedback behavior.
