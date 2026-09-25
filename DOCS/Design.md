# UGCULT — Mobile Design System & Brand Guidelines

**Status:** Approved v3.0 (Post-Grill Revision) · **Date:** 2026-09-24  
**Platform:** iOS (Primary Target, iOS 17/18 / Cupertino Fidelity) & Android Cross-Platform (Flutter 3.x / Dart on Windows Host)  
**Companions:** [PRD.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/PRD.md) · [ARCHITECTURE.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/ARCHITECTURE.md) · [API-SPEC.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/API-SPEC.md) · [DB-DESIGN.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/DB-DESIGN.md) · [IOS-WINDOWS-DEV-GUIDE.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/IOS-WINDOWS-DEV-GUIDE.md) · [IMPLEMENTATION-PLAN.md](file:///c:/Users/Youssef/Desktop/UGCULTMOB/DOCS/IMPLEMENTATION-PLAN.md)  
**Scope:** Complete Mobile Design System, Visual Identity & Brand Guidelines, Three-Layer Design Tokens (Primitive → Semantic → Component), Apple Human Interface & Fluid Motion Architecture, Materials/Liquid Glass Specs, Exhaustive Component State Matrices, Iconography System, Screen Wireframes, Accessibility, and Production Flutter Implementation.

---

## 1. Brand Identity & Strategy

### 1.1 Brand Narrative: "Two Tints, One Lens"
UGCULT is Egypt's premier mobile marketplace connecting vibrant UGC (User-Generated Content) creators with emerging DTC brands and enterprise businesses. In an Egyptian market historically hindered by chaotic Instagram DMs, fragmented WhatsApp voice notes, and unverified payment promises, UGCULT provides clarity, accountability, and seamless execution.

The visual and strategic language is anchored in a dual-tint optical metaphor:
- **Brands lean Baby Blue (`#89CFF0` / `#5DB4E8` / `#2A73A6`):** Trust, enterprise infrastructure, professional clarity, and business reliability.
- **Creators lean Baby Pink (`#F09BBB` / `#E5729D` / `#A23A64`):** Self-expression, creative energy, vitality, and mobile-native storytelling.
- **The Match Blend (`linear-gradient(135deg, #A9D4F7 0%, #F8C0D6 100%)`):** The point of mutual achievement — application approval, content acceptance, milestone completion, and double-blind ratings.
- **Glass is the Functional Lens:** UGC is visual media captured through a smartphone camera. Floating navigation bars, modal action sheets, and progress capsules behave as optical lenses refracting the vibrant media below.

```
       ┌──────────────────────┐              ┌──────────────────────┐
       │     BRAND REALM      │              │    CREATOR REALM     │
       │   Baby Blue Tint     │              │    Baby Pink Tint    │
       │   (#89CFF0 / 5DB4E8) │              │  (#F09BBB / E5729D)  │
       └──────────┬───────────┘              └───────────┬──────────┘
                  │                                      │
                  └───────────────────┬──────────────────┘
                                      ▼
                        ┌───────────────────────────┐
                        │     THE MATCH BLEND       │
                        │ Linear Gradient (135 deg) │
                        │  (#A9D4F7 ──► #F8C0D6)    │
                        │  Connection & Achievement │
                        └───────────────────────────┘
```

### 1.2 Brand Archetypes & Positioning

| Entity | Archetype | Emotional Role | Core Message |
|---|---|---|---|
| **Creators** | *The Creator & Magician* | Creative flair, authentic storytelling, self-empowerment | "Turn your authentic craft into a sustainable creative career." |
| **Brands** | *The Ruler & Caregiver* | Clarity, professional structure, business growth | "Scale your brand with authentic UGC campaigns executed without friction." |
| **UGCULT Platform** | *The Bridge & Enabler* | Neutral, accountable, crystal clear, protective | "The transparent bridge for creative commerce." |

### 1.3 Brand Pillars & Voice Guidelines

| Pillar | Voice Trait | What It Means in the App | What We Avoid |
|---|---|---|---|
| **Empowering & Direct** | Confident, active, transparent | Clear, concise calls-to-action ("Apply now", "Submit deliverable", "Confirm payment"). | Corporate jargon, passive voice, ambiguous steps. |
| **Calm & Restrained** | Quiet confidence, uncluttered | Generous white space, zero popups or banners shouting for attention, pastels used as structured functional accents. | Visual clutter, fluorescent neons, aggressive alert red. |
| **Accountable & Protective** | Factual, reassuring, objective | Explicit milestone tracking, zero-trust contact privacy badges, unbiased dispute status, neutral mediation tone. | Vague statuses, unilateral penalties, blame-oriented copy. |
| **Tactile & Fluid** | Physical, responsive, delightful | Micro-haptics synced precisely to touch release, spring physics that preserve velocity and momentum. | Rigid, robotic cuts, un-interruptible modal animations. |

### 1.4 Comprehensive Microcopy Framework

| User State | Tone | Microcopy Standard (English MVP) | Phase 2 Arabic Intent |
|---|---|---|---|
| **Onboarding Role Selection** | Welcoming, decisive | "Select your role to get started." | Clear role segmentation |
| **Phone OTP Verification** | Direct, functional | "We sent a 6-digit code to {phone}." | Reassuring security |
| **Empty Campaign Feed** | Encouraging, proactive | "No campaigns found. Try adjusting your category or governorate filters." | Action-oriented |
| **1-Tap Application** | Direct, transparent | "Apply with 1 tap. The brand can view your full creator profile." | Frictionless entry |
| **Application Approved** | Celebratory, clear | "You're selected! Contact details and shipping address are now unlocked." | Clear security transition |
| **Simplified Shipping (Sent)** | Factual, actionable | "Brand marked product as sent. Confirm receipt once package arrives." | 2-step handshake |
| **Simplified Shipping (Received)**| Confirmative | "Product marked as received. You can now start creating your content." | Milestone unlock |
| **Deliverable Submission** | Reassuring | "Deliverable submitted. The brand will review your content." | Clear expectation |
| **Revision Requested** | Constructive, specific | "Revision requested: '{feedback}'. Update and resubmit your content." | Transparent collaboration |
| **Dual Payment (Brand Paid)** | Factual, awaiting | "Brand marked payment as sent via {method}. Creator receipt pending." | Mutual accountability |
| **Dual Payment (Creator Confirmed)**| Celebratory | "Payment confirmed by both parties! Job completed." | Milestone completion |
| **Dispute Opened** | Neutral, reassuring | "Payment disputed. Our moderation team is auditing the transaction." | De-escalating |
| **Double-Blind Rating** | Prompting, private | "Rate your experience. Reviews stay private until both parties submit or after 7 days." | Bias-free honesty |

### 1.5 Logo System & Visual Assets Usage Rules

1. **The Primary Mark:** Two overlapping translucent discs — Baby Blue on the left (`#89CFF0`), Baby Pink on the right (`#F09BBB`) — with an optical blend in the lens intersection.
2. **App Icon (iOS & Android):** Layered asset featuring the primary mark centered on the ambient canvas gradient (`#F3F9FF` to `#FFF5F8`), with dynamic tint support for iOS dark/tinted home screen configurations. Master asset: 1024 × 1024 px PNG, zero baked-in corner radius.
3. **Monochrome / Glass Mark:** Single-color etched glass version for floating watermarks, subtle card stamps, and navigation headers.
4. **Clear Space:** Minimum clear space around the logo equals $0.5 \times D$ (where $D$ is the diameter of one disc).
5. **Minimum Sizes:**
   - Mobile Header: 32 pt height
   - App Icon: 60 × 60 pt (on-screen rendering)
   - Favicon / Small Badge: 16 × 16 px

#### Logo Usage Do's and Don'ts

```
  DO:
  ✓ Maintain the exact 135° angle for the lens blend.
  ✓ Use the monochrome white/glass mark over high-saturation video covers with scrim.
  ✓ Respect the 0.5D clear margin on all 4 sides.

  DON'T:
  ✗ Never skew, rotate, or stretch the logo discs.
  ✗ Never replace Baby Blue / Baby Pink with corporate primary colors.
  ✗ Never add drop shadows or harsh 3D bevels to the logo discs.
  ✗ Never place the colored logo directly over high-frequency video footage without a frosted glass plate.
```

---

## 2. Apple Design Foundations (WWDC Principles Adapted for Flutter)

The UGCULT mobile interface embodies Apple's core human interface design philosophy, serving four essential human needs: **Safety & Predictability, Understanding, Achievement, and Joy**.

```
                           ┌────────────────────────┐
                           │   HUMAN-CENTRIC GOAL   │
                           │ Safety · Joy · Agency  │
                           └───────────┬────────────┘
                                       │
        ┌───────────────────┬──────────┴────────┬───────────────────┐
        ▼                   ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   RESPONSE    │   │INTERRUPTIBILITY│  │  PHYSICALITY  │   │  FAMILIARITY  │
│ Zero Latency  │   │Spring Physics │   │Rubber-banding │   │ iOS Cupertino │
│ Touch-down fb │   │Velocity blend │   │Momentum proj. │   │ Direct labels │
└───────────────┘   └───────────────┘   └───────────────┘   └───────────────┘
```

### 2.1 The Eight Core Design Principles
1. **Purpose:** Every element on screen earns its presence. Non-essential indicators, redundant badges, and decorative noise are eliminated so creative content and campaign deliverables stand front and center.
2. **Agency:** The user remains in complete control. Swipes can be redirected or reversed mid-flight; bottom sheets can be dragged up or dismissed smoothly; destructive actions (e.g. rejecting an applicant, opening a dispute) provide clear, non-punitive confirmations.
3. **Responsibility:** User privacy is paramount. Zero-trust contact isolation is visually represented (lock icons on creator phone/Instapay/address until a brand confirms selection). Immutability locks prevent surprise scope-creep once campaigns are published.
4. **Familiarity:** Respect platform idioms. On iOS, adhere strictly to Cupertino navigation bars, swipe-back transitions, large title collapsing, and native modal sheets.
5. **Flexibility:** Fluid layout scaling with Dynamic Type (scaling gracefully up to 1.3× on floating chrome and uncapped on content bodies). English-first for MVP with RTL-ready layout infrastructure preserved for Phase 2 Arabic.
6. **Simplicity (Not Minimalism):** Clear hierarchy over hidden complexity. One primary action per screen. Progressive disclosure reveals advanced revision logs only when relevant.
7. **Craft:** Flawless visual alignment, mathematical corner concentricity ($R_{\text{inner}} = R_{\text{outer}} - \text{padding}$), custom-tuned spring curves, and high-DPI asset rendering.
8. **Delight:** Subtle, earned micro-interactions — such as the signature **Match Moment** bloom when a creator is selected.

---

## 3. Materials & Depth Architecture

### 3.1 Material Layering Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│ [Layer 3] FLOATING GLASS (Capsules, Tab Bar, Sheets, Primary CTA) │  ◄── Translucent Lens (sigma: 24)
├─────────────────────────────────────────────────────────────────┤
│ [Layer 2] PAPER CARDS (Campaigns, Submissions, Inputs, Lists)   │  ◄── Opaque Pure White + Tinted Shadow
├─────────────────────────────────────────────────────────────────┤
│ [Layer 1] AMBIENT CANVAS (Pre-baked WebP Pastel Mesh + Orbs)    │  ◄── Subtle Blue/Pink Gradient Base
└─────────────────────────────────────────────────────────────────┘
```

| Material | Physical Metaphor | Usage | Prohibited Usage |
|---|---|---|---|
| **Canvas** | Ambient background | Full-screen app background. Pre-baked 30KB WebP gradient with blue/pink ambient orbs. | Never place dense text directly on canvas without a Paper container. |
| **Paper** | Opaque content card | Feed cards, form fields, review lists, video/photo submission cards. Pure white (`#FFFFFF`) with 1px `ink-100` border and tinted blue shadow. | Floating navigation bars or floating action buttons. |
| **Glass · Regular** | Polished translucent lens | Floating bottom tab bar, top circular nav buttons, search capsule, segmented controls. | Main campaign feed card backgrounds (causes blur budget overflow). |
| **Glass · Tinted** | Optical filter with role hue | Single primary action button per screen (`blue-300` for Brand, `pink-300` for Creator, `Match Blend` for Selection). | Multiple competing buttons on the same screen. |
| **Glass · Clear** | Floating overlay with scrim | Video player controls, image cover back buttons, photo carousel tags. | Over raw white background (insufficient contrast). |
| **Glass · Thick** | Structural frosted sheet | Modal bottom sheets, full-height creation wizards, confirmation dialogs, system toasts. | Small inline list items or tags. |
| **Frost (Tier C)** | Opaque high-contrast fallback | Fallback container for low-RAM devices or *Reduce Transparency* mode. 94% opaque container with 1px border. | High-end devices with GPU acceleration active. |

### 3.2 Anatomy of a Liquid Glass Surface
1. **Backdrop Filter:** Hardware-accelerated `ImageFilter.blur(sigmaX: 24, sigmaY: 24)` on Impeller/Metal.
2. **Body Tint:** Layered gradient fill (`rgba(255, 255, 255, 0.55)` to `rgba(255, 255, 255, 0.38)`).
3. **Specular Rim (Light from Top-Left):** 1px stroke with directional gradient: `rgba(255,255,255,0.90)` top-left $\rightarrow$ `rgba(255,255,255,0.10)` center $\rightarrow$ `rgba(255,255,255,0.60)` bottom-right.
4. **Inner Glow:** 1px inset highlight at the top edge (`rgba(255,255,255,0.70)`).
5. **Outer Tinted Glow:** Soft blue-tinted shadow `0 8px 24px rgba(70, 110, 180, 0.14)` (never neutral grey).
6. **Foreground Content:** High-contrast `ink-900` text and icons.

### 3.3 Hardware-Aware Rendering Tiers

```
                          [Device Capabilities Check]
                                       │
            ┌──────────────────────────┼──────────────────────────┐
            ▼                          ▼                          ▼
   [Tier A: iOS Metal]         [Tier B: Standard]         [Tier C: Frost]
   - iOS 17/18 Impeller        - Android (RAM ≥ 4GB)      - RAM < 4GB
   - Native Cupertino Blur     - Flutter BackdropFilter   - Reduce Transparency = ON
   - Dynamic Specular Rim      - Tinted Box Shadow        - Simplified Visuals = ON
   - Max 3 blur surfaces       - Max 3 blur surfaces      - 94% Opaque container
```

---

## 4. Three-Layer Design Token Architecture

Following the design system standard, tokens are strictly architected into three distinct layers:
1. **Primitive Tokens:** Raw, invariant design values (colors, spacing, radii, elevations).
2. **Semantic Tokens:** Context- and role-aware aliases that assign purpose to primitives.
3. **Component Tokens:** Component-specific bindings that isolate UI widgets from raw values.

```
┌──────────────────────────────────────────────────────────┐
│  Layer 3: COMPONENT TOKENS                               │
│  btnPrimaryBg, cardBorder, inputFocusRing, tabLensFill   │
├──────────────────────────────────────────────────────────┤
│  Layer 2: SEMANTIC TOKENS                                │
│  role.accent, surface.paper, feedback.success, text.main │
├──────────────────────────────────────────────────────────┤
│  Layer 1: PRIMITIVE TOKENS                               │
│  blue-500, pink-300, ink-900, space-4, r-xl, blur-md     │
└──────────────────────────────────────────────────────────┘
```

### 4.1 Layer 1: Primitive Tokens

#### Color Primitives

```
// Baby Blue (Brand Realm & Trust Foundation)
blue-50   #F3F9FF  (Canvas top background)
blue-100  #E3F1FD  (Hover & pressed wash)
blue-200  #CBE5FB  (Subtle chip & pill fill)
blue-300  #A9D4F7  (Tinted glass surface & ambient orb)
blue-400  #89CFF0  (Canonical Baby Blue; Brand logo mark)
blue-500  #5DB4E8  (Brand solid accent, progress indicators, focus rings)
blue-600  #3A93CC  (Brand icons ≥ 24px)
blue-700  #2A73A6  (Brand text & interactive links - 5.1:1 AA on white)
blue-800  #1F5680  (Deep emphasis & dark mode header)
blue-900  #163B59  (Midnight Brand base)

// Baby Pink (Creator Realm & Creative Energy)
pink-50   #FFF5F8  (Canvas bottom background)
pink-100  #FEE9F0  (Creator pressed wash)
pink-200  #FCD7E4  (Creator chip fill)
pink-300  #F8C0D6  (Creator tinted glass & ambient orb)
pink-400  #F09BBB  (Canonical Baby Pink; Rating stars & Creator mark)
pink-500  #E5729D  (Creator solid accent & focus rings)
pink-600  #C9507F  (Creator icons ≥ 24px)
pink-700  #A23A64  (Creator text & interactive links - 6.3:1 AA on white)
pink-800  #7A2C4C  (Deep plum emphasis)
pink-900  #522034  (Midnight Creator base)

// Ink Neutrals (Blue-Slate Tints — Never Dead Grey or Harsh Black)
ink-900   #1A2138  (Primary typography, headings, glass labels - 16:1 AA)
ink-700   #3A4360  (Secondary typography, body text, default icons - 9.8:1 AA)
ink-500   #67708C  (Tertiary helper text ≥ 15pt, meta timestamps - 4.9:1 AA)
ink-300   #A4ABC0  (Disabled states, text field placeholders)
ink-100   #DDE1EC  (Card borders, dividers, frost outlines)
white     #FFFFFF  (Paper card base, pure specular highlights)
```

#### Spacing Primitives (4pt Base Grid)
```
space-1   4 pt   (Micro gaps between badge icon & text)
space-2   8 pt   (Pill internal padding, compact chip gap)
space-3  12 pt   (Gap between campaign cards in feed)
space-4  16 pt   (Standard card internal padding, input padding)
space-5  20 pt   (Screen horizontal side margins)
space-6  24 pt   (Header to content spacing)
space-8  32 pt   (Section-to-section vertical rhythm)
space-10 40 pt   (Major modal header spacing)
space-14 56 pt   (Hero section bottom spacing)
```

#### Corner Radius Primitives
```
r-xs     8 pt   (Nested thumbnail inside card, dense tag)
r-sm    12 pt   (16:9 media cover inside 16pt padded card: 28 - 16 = 12pt)
r-md    16 pt   (Text field containers, segmented control tracks)
r-lg    20 pt   (Compact sheet dialogs, alert boxes)
r-xl    28 pt   (Paper campaign cards, large content panels)
r-2xl   36 pt   (Modal bottom sheet top corners)
r-full 999 pt   (Buttons, filter chips, floating tab bar capsule, search bar, avatars)
```

#### Elevation & Shadow Primitives
```
shadow-tinted-sm:  0 2px 8px   rgba(70, 110, 180, 0.08)
shadow-tinted-md:  0 8px 24px  rgba(70, 110, 180, 0.12)
shadow-tinted-lg:  0 16px 40px rgba(70, 110, 180, 0.18)
shadow-glow-blue:  0 0 20px    rgba(93, 180, 232, 0.35)
shadow-glow-pink:  0 0 20px    rgba(240, 155, 187, 0.35)
```

---

### 4.2 Layer 2: Semantic Tokens

#### Role & Brand Semantics

| Semantic Token | Creator Realm | Brand Realm | Neutral / Guest |
|---|---|---|---|
| `role.accentTint` | `pink-300` (`#F8C0D6`) | `blue-300` (`#A9D4F7`) | `blue-300` (`#A9D4F7`) |
| `role.accentSolid` | `pink-500` (`#E5729D`) | `blue-500` (`#5DB4E8`) | `blue-500` (`#5DB4E8`) |
| `role.accentText` | `pink-700` (`#A23A64`) | `blue-700` (`#2A73A6`) | `blue-700` (`#2A73A6`) |
| `role.accentWash` | `pink-100` (`#FEE9F0`) | `blue-100` (`#E3F1FD`) | `blue-100` (`#E3F1FD`) |
| `role.glow` | `shadow-glow-pink` | `shadow-glow-blue` | `shadow-glow-blue` |
| `match.blend` | `linear-gradient(135deg, #A9D4F7 0%, #F8C0D6 100%)` |

#### Feedback Semantics (WCAG AA Compliant)

| Feedback State | Surface Color | Text / Icon Color | WCAG Contrast | Meaning in App |
|---|---|---|---|---|
| `feedback.success` | `#D6F3E7` | `#1F7A5A` | 5.3:1 AA | Application approved, payment confirmed, deliverable accepted |
| `feedback.warning` | `#FDEBCB` | `#8A5A12` | 5.9:1 AA | Revision requested, action required, spots filling fast |
| `feedback.danger` | `#FFDCE1` | `#B3263F` | 6.4:1 AA | Payment disputed, unconfirmed, rejected, destructive action |
| `feedback.info` | `#E3F1FD` | `#2A73A6` | 5.1:1 AA | System tips, privacy notices, guidelines |

> **Accessibility Rule on Pink vs. Danger:** Creator Pink (`#F09BBB`) and Danger Red (`#FFDCE1` / `#B3263F`) are strictly disambiguated. Destructive actions use neutral glass with `feedback.danger` text and explicit warning icons (e.g. `Ph.warning_circle`). Creator pink is never used for error/destructive signals.

---

### 4.3 Layer 3: Component Tokens

Component tokens bind semantic tokens directly to component properties:

```dart
// Button Tokens
--btn-primary-bg:        role.accentTint
--btn-primary-text:      ink-900
--btn-primary-rim:       white @ 85%
--btn-primary-glow:      role.glow

--btn-secondary-bg:      white @ 48% (Glass Regular)
--btn-secondary-text:    ink-900
--btn-secondary-rim:     white @ 65%

--btn-destructive-bg:    white @ 48%
--btn-destructive-text:  feedback.danger.fg
--btn-destructive-rim:   feedback.danger.bg

// Card Tokens
--card-paper-bg:         white
--card-paper-border:     ink-100 (1px solid)
--card-paper-shadow:     shadow-tinted-md
--card-paper-radius:     r-xl (28pt)

// Floating Tab Bar Tokens
--tab-bar-bg:            white @ 48% (Glass Regular)
--tab-bar-rim:           white @ 75%
--tab-bar-shadow:        shadow-tinted-lg
--tab-lens-fill:         role.accentTint @ 60%
--tab-lens-radius:       r-full

// Input Field Tokens
--input-field-bg:        white
--input-field-border:    ink-100
--input-focus-ring:      role.accentSolid (2px)
--input-error-ring:      feedback.danger.fg (2px)
--input-placeholder:     ink-300
```

---

## 5. Typography & Layout Architecture (English MVP, Phase 2 Arabic Ready)

### 5.1 Typeface Selection: Readex Pro
**Readex Pro** is the universal design system typeface for UGCULT. Specifically engineered as an optical contemporary geometric typeface with simultaneous, native Latin and Arabic glyph harmonization, it guarantees identical visual rhythm when Arabic localization launches in Phase 2.

- **Static Weights:** `400` (Regular), `500` (Medium), `600` (SemiBold).
- **Flutter Implementation:** `GoogleFonts.readexPro()`.
- **Secondary Fallback:** `IBM Plex Sans Arabic` (`GoogleFonts.ibmPlexSansArabic()`) for enterprise financial exports.

### 5.2 Type Scale (Mirrors iOS Dynamic Type Specifications)

| Token | Size / Line (Latin) | Line (Arabic Phase 2) | Weight | Tracking (Tracking Rule) | Usage |
|---|---|---|---|---|---|
| **Large Title** | 34 pt / 41 pt | 47 pt | 600 | `-0.02em` (Negative display) | Screen large headers (collapses on scroll) |
| **Title 1** | 28 pt / 34 pt | 39 pt | 600 | `-0.015em` (Negative display) | Empty states, success modals |
| **Title 2** | 22 pt / 28 pt | 32 pt | 600 | `-0.01em` | Bottom sheet titles |
| **Title 3** | 20 pt / 25 pt | 29 pt | 500 | `0.0em` | Section headers, card group titles |
| **Headline** | 17 pt / 22 pt | 25 pt | 600 | `-0.005em` | Card titles, primary button text |
| **Body** | 17 pt / 24 pt | 28 pt | 400 | `0.0em` (Neutral) | Main description copy, guidelines |
| **Callout** | 16 pt / 22 pt | 25 pt | 400 | `0.0em` | Text field inputs, dropdown values |
| **Subhead** | 15 pt / 20 pt | 23 pt | 400 | `+0.005em` | Brand names, creator bio, meta rows |
| **Footnote** | 13 pt / 18 pt | 21 pt | 400 | `+0.01em` (Positive small) | Timestamps, helper notes, sub-labels |
| **Caption** | 12 pt / 16 pt | 18 pt | 500 | `+0.015em` (Positive small) | Status pills, badge counters, tab labels |

### 5.3 Typography & Future RTL Preservation Rules
1. **Vertical Leading Multiplier ($1.15\times$ for Arabic):** Architecture reserves 15% line-height headroom so future Arabic diacritics never clip.
2. **Directional Padding:** Always use `EdgeInsetsDirectional` (`start`/`end`) instead of absolute `left`/`right` in layout code to ensure automatic mirrorability.
3. **No Faux Italic or Faux Bold:** Use native font weights 400, 500, and 600.
4. **Western Numerals (0–9):** Retain standard digits (`0, 1, 2, 3...`) across Egypt for monetary amounts (`750 EGP`) and phone numbers (`+20...`).
5. **Tabular Numbers (`fontFeatures: [FontFeature.tabularFigures()]`):** Enforced on money figures, star counts, and spot counters to prevent numeric jitter during state changes.

---

## 6. Fluid Motion, Springs & Spatial Physics

### 6.1 Apple Fluid Physics Model
Motion in UGCULT stops feeling like a scripted animation and starts feeling like a physical conversation. Animations always begin at the element's current presentation value, inherit the pointer's release velocity, project momentum forward, and remain **100% interruptible at any millisecond**.

```
                [User Touch / Flick Gesture]
                             │
                             ▼
              [Read Position & Release Velocity]
                             │
                             ▼
            ┌────────────────────────────────┐
            │ Apple Momentum Projection      │
            │ d = 0.998 (exponential decay)  │
            │ Target = Current + Project(v)  │
            └────────────────┬───────────────┘
                             │
                             ▼
           [Spring Simulation Hand-off (Damping + Response)]
           - Damping 1.0 (Critical / UI default)
           - Damping 0.8 (Momentum / Flick bounce)
                             │
                             ▼
    [Interruptible Target Update on Mid-flight Grab]
```

### 6.2 Motion & Spring Configuration Tokens

| Interaction | Damping ($\zeta$) | Response ($\omega$) | Flutter `SpringDescription` | Behavior |
|---|---|---|---|---|
| **Default UI Transition** | `1.0` (Critically damped) | `0.35s` | `mass: 1.0, stiffness: 320, damping: 35.7` | Smooth settle, zero overshoot |
| **Flick / Momentum Throw** | `0.8` (Slight bounce) | `0.38s` | `mass: 1.0, stiffness: 270, damping: 26.3` | Organic physical settle on gesture release |
| **Button / Card Press** | `1.0` | `0.18s` | `mass: 0.8, stiffness: 400, damping: 35.8` | Instant scale down to 0.97 on touch-down |
| **Modal Sheet Drag** | `0.85` | `0.32s` | `mass: 1.0, stiffness: 380, damping: 33.1` | Snaps cleanly to 50% / 92% detents |
| **Tab Lens Slide** | `1.0` | `0.28s` | `mass: 1.0, stiffness: 340, damping: 36.9` | Seamless liquid glide between tab items |

### 6.3 Mathematical Formulas for Fluid Gestures

#### Momentum Projection Formula (Exponential Decay)
Calculates where a flicked card or sheet will naturally come to rest:
$$\text{Projected Distance} = \left(\frac{v_{\text{release}}}{1000}\right) \times \frac{d}{1 - d} \quad \text{where } d = 0.998$$

#### Rubber-Banding Resistance Formula
Calculates progressive drag resistance when pulling past scroll boundaries or sheet limits:
$$x_{\text{rubberband}} = \frac{x \times \text{dimension} \times 0.55}{\text{dimension} + 0.55 \times |x|}$$

### 6.4 Spatial Consistency & Origin Anchoring
- **Symmetric Trajectories:** Modals and drawers exit along the exact physical vector they entered.
- **Origin Anchoring:** Popovers, action sheets, and menus scale outwards from the `Rect` of the triggering button (`transform-origin: buttonCenter`), never from arbitrary screen coordinates.
- **Hero Transitions:** Campaign card cover images transition seamlessly into campaign detail headers using Flutter `Hero` with shared-element spring curves.

### 6.5 The Signature "Match Moment" Sequence
When a creator's application is **Approved** or content is **Accepted**:
1. **Frame 0ms:** Light impact haptic (`HapticFeedback.lightImpact()`). Card border transitions to the 135° Match Blend gradient.
2. **Frame 100ms:** Soft radial glow blooms outwards from the status icon (40% opacity, 24px radius).
3. **Frame 200–800ms:** A subtle specular shimmer line sweeps across the card surface (`CurvedAnimation(curve: Curves.decelerate)`).
4. **Frame 800ms:** Success notification haptic (`HapticFeedback.mediumImpact()`). The card settles with a permanent, static blend rim for continued state legibility.
5. **Reduced Motion Mode:** Skips bloom/shimmer; immediately displays static blend rim with single light haptic.

---

## 7. Multimodal Feedback (Haptics & Audio Synchronization)

Feedback adheres to three rules: **Causality** (triggered directly by the action), **Harmony** (visual transform and haptic fire on the exact same frame), and **Utility** (reserved for meaningful moments).

```
┌──────────────────────────────┬──────────────────────────────┬──────────────────────────────┐
│       MOMENT / ACTION        │        HAPTIC FEEDBACK       │      VISUAL REINFORCEMENT    │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│ Primary Button Press         │ HapticFeedback.lightImpact() │ Scale 0.97 + brightness lift │
│ Tab Bar / Segmented Switch   │ HapticFeedback.selection()   │ Lens fluid slide (0.28s)     │
│ Match / Application Selected │ HapticFeedback.mediumImpact()│ Blend bloom & shimmer sweep  │
│ Deliverable Submitted        │ HapticFeedback.heavyImpact() │ Upload ring morphs to check  │
│ Pull-to-Refresh Threshold    │ HapticFeedback.selection()   │ Glass bead snaps & releases  │
│ Dispute Opened / Error       │ HapticFeedback.vibrate()     │ Danger toast slide & red rim │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
```

---

## 8. Exhaustive Component Specifications & State Matrices

Following the design system component specification pattern, every core UI element defines explicit states across all visual dimensions.

### 8.1 Primary Tinted Glass Button

#### Anatomy
```
┌────────────────────────────────────────────────────────┐
│  [Leading Icon]      Button Action Label     [Spinner] │  ◄── Height 52pt / 44pt
└────────────────────────────────────────────────────────┘
```

#### State Matrix

| State | Background Fill | Specular Rim | Text Color | Scale | Shadow Glow | Haptic Trigger |
|---|---|---|---|---|---|---|
| **Default** | `role.accentTint` @ 62% | 1px white @ 85% | `ink-900` | 1.00 | `role.glow` | None |
| **Pressed / Touch-down**| `role.accentTint` @ 80% | 1px white @ 100% | `ink-900` | 0.97 | Lifted glow | `lightImpact()` |
| **Loading** | `role.accentTint` @ 50% | 1px white @ 40% | Transparent | 1.00 | None | None |
| **Disabled** | `ink-100` @ 50% | 1px `ink-100` | `ink-300` | 1.00 | None | None |

---

### 8.2 Form Inputs: Egyptian Phone & OTP Matrix

#### Egyptian Phone Input Anatomy
```
┌────────────┬───────────────────────────────────────────┐
│ (🇪🇬 +20)   │  010 1234 5678                            │
└────────────┴───────────────────────────────────────────┘
   Prefix                     Phone Number Field
```

| Property | Default State | Focused State | Error State | Disabled State |
|---|---|---|---|---|
| **Prefix Container** | Glass Regular (`white @ 48%`) | Glass Regular (`white @ 70%`) | Glass Regular | Opaque `ink-100` |
| **Number Container** | Paper (`#FFFFFF`) | Paper (`#FFFFFF`) | Paper (`#FFFFFF`) | Paper (`#F3F9FF`) |
| **Border / Ring** | 1px `ink-100` | 2px `role.accentSolid` | 2px `feedback.danger.fg` | 1px `ink-100` |
| **Text Color** | `ink-900` (Callout 400) | `ink-900` | `ink-900` | `ink-300` |
| **Helper / Error** | None | "Enter 10-digit number" | "Invalid Egyptian phone number" | None |

#### OTP 6-Cell Matrix
- **Dimensions:** 6 individual cells, each 48 × 56 pt, `r-md` (16pt radius).
- **Active Cell:** 2px `role.accentSolid` focus ring, pulsing cursor.
- **Completed Cell:** 1px `ink-100` border, 24pt bold `ink-900` number.
- **Error State:** All 6 cells flash `feedback.danger.bg` fill with `feedback.danger.fg` borders + horizontal shake animation (`HapticFeedback.vibrate()`).

---

### 8.3 Campaign Discovery Card (Paper, `r-xl`, 16pt Padding)

#### Anatomy
```
┌─────────────────────────────────────────────────────────┐
│ [Brand Avatar 40pt]  Brand Name Egypt        ★ 4.9 (24) │
│                                                         │
│ Campaign Title (Headline 600)                           │
│ Brief description copy... (Body 400, max 2 lines)       │
│                                                         │
│ [ 💵 750 EGP Cash ]  [ 🎁 Product ]  [ ✨ Beauty ]      │
│ ─────────────────────────────────────────────────────── │
│ ●●●○○ 2 of 5 spots filled · Open for applications       │
└─────────────────────────────────────────────────────────┘
```

#### State & Interaction Behavior
- **Default:** Pure white Paper surface, 1px `ink-100` border, `shadow-tinted-sm`.
- **Touch Down:** Scales smoothly to 0.985 (`damping: 1.0, stiffness: 400`), shadow reduces.
- **Hero Image Transition:** Tapping card springs the cover image seamlessly into the Campaign Detail screen header via Flutter `Hero`.
- **All Spots Filled:** Card renders a subtle "Closed" frost badge, opacity transitions to 75%.

---

### 8.4 Application Handshake Stepper (Creator View)

Reflecting post-grill simplified 2-step shipping and dual payment handshake:

```
┌─────────────────────────────────────────────────────────┐
│ ┌─ Match Blend Rim ───────────────────────────────────┐ │
│ │ ✨ Selected for Campaign · Contact Details Unlocked  │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│  ✓ 1. Application Approved ····················· 10 Aug │
│  ✓ 2. Product Sent (Brand confirmed) ··········· 12 Aug │
│  ● 3. Confirm Product Received                          │
│  ○ 4. Submit Deliverable (Video/Photo)                  │
│  ○ 5. Brand Review & Dual Payment Confirmation          │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │         (  Confirm Product Received  )            │  ◄── Primary CTA
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

| Step Index | Milestone Title | Milestone State | Visual Indicator |
|---|---|---|---|
| **Step 1** | Application Approved | Complete | Solid Green Circle (`#1F7A5A`) with Checkmark |
| **Step 2** | Product Sent (if physical) | Complete | Solid Green Circle with Checkmark |
| **Step 3** | Confirm Product Received | Active | Pulsing Blue/Pink Ring + Action CTA |
| **Step 4** | Submit Deliverable | Upcoming / Pending | Open Circle (`ink-300`), Upload Trigger |
| **Step 5** | Dual Payment Confirmation | Final Handshake | Split Circle (Blue half = Brand paid, Pink half = Creator received) |

---

### 8.5 Resumable Upload Tile (Deliverable Submission)

#### State Matrix

| Upload State | Visual Style | Primary Indicator | Action Control |
|---|---|---|---|
| **Idle** | Dashed 1px `ink-300` border, Paper base | Cloud upload icon + "Select Video or Photos" | Gallery / Camera Picker |
| **Compressing** | Solid 1px `blue-200` border | Thumbnail with circular shimmer spinner | "Compressing media..." |
| **Uploading** | Solid 1px `blue-500` border | Horizontal progress bar + percentage (`72%`) | Pause / Resume Button |
| **Paused** | Solid 1px `warning-fg` border | Paused indicator + "Network drop detected" | "Retry Upload" Pill |
| **Uploaded** | 1px `success-fg` border | Media preview with green checkmark badge | "Replace" / "Submit" CTA |

---

## 9. Iconography & Visual Asset System

Following the built-in icon specifications, all icons adhere strictly to a standardized optical design grid:

```
┌─────────────────────────┐
│  24 × 24 pt Grid        │  - Stroke: 2.0 pt uniform
│    ┌───────────────┐    │  - Caps & Joins: Round
│    │ 20 × 20 pt    │    │  - Bounding Box: 24 × 24 pt
│    │ Optical Live  │    │  - Minimum Tap Hit Area: 44 × 44 pt
│    │ Area          │    │  - Icon Set: Phosphor Icons (Regular / Duotone)
│    └───────────────┘    │
└─────────────────────────┘
```

### 9.1 Phosphor Icon Token Mappings

| Feature / Domain | Phosphor Icon Token | Style / Weight | Flutter Mapping |
|---|---|---|---|
| **Discover Feed** | `Ph.compass` / `Ph.magnifying_glass` | Regular (2.0pt) | `PhosphorIcons.compass()` |
| **My Jobs / Activity** | `Ph.briefcase` / `Ph.stack` | Regular (2.0pt) | `PhosphorIcons.briefcase()` |
| **Notifications** | `Ph.bell` / `Ph.bell_simple` | Regular (2.0pt) | `PhosphorIcons.bell()` |
| **Profile** | `Ph.user` / `Ph.user_circle` | Regular (2.0pt) | `PhosphorIcons.user()` |
| **Video Deliverable** | `Ph.video_camera` | Duotone | `PhosphorIcons.videoCamera()` |
| **Photo Deliverable** | `Ph.image` | Duotone | `PhosphorIcons.image()` |
| **Shipping Product** | `Ph.package` | Regular | `PhosphorIcons.package()` |
| **Payment Confirmation**| `Ph.handshake` / `Ph.money` | Duotone | `PhosphorIcons.handshake()` |
| **Verified Badge** | `Ph.seal_check` | Solid Fill | `PhosphorIcons.sealCheck()` |
| **Dispute Flag** | `Ph.warning_circle` | Regular | `PhosphorIcons.warningCircle()` |
| **Match Moment** | `Ph.sparkle` | Duotone | `PhosphorIcons.sparkle()` |

### 9.2 Project Asset Directory Structure
```
assets/
├── icons/
│   ├── app_mark_blue.svg
│   ├── app_mark_pink.svg
│   └── app_mark_blend.svg
├── images/
│   ├── ambient_canvas_mesh.webp      (30 KB pre-baked background)
│   ├── onboarding_creator_hero.webp
│   └── onboarding_brand_hero.webp
└── placeholders/
    ├── avatar_creator_placeholder.png
    └── cover_campaign_placeholder.png
```

---

## 10. Complete Screen Wireframes & Layout Templates

### 10.1 Creator Discover Screen (Tab 1)
```
┌────────────────────────────────────────────────────────┐
│ 09:41                                           5G █   │
│                                                        │
│ Discover Campaigns                              ( 🔔 ) │  ◄── Large Title + Glass Circle
│                                                        │
│ ( 🔍 Search niche, brand, or location...             ) │  ◄── Glass Capsule Search
│                                                        │
│ ( All ) ( 🎁 Gift ) ( 💵 Cash ) ( ✨ Beauty ) ( 👗 )    │  ◄── Horizontally Scrolling Chips
│                                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ [Cover 16:9 - Skincare Model Unboxing]             │ │  ◄── Paper Card (r-xl)
│ │ Glow Cosmetics · Cairo                    ★ 4.9    │ │
│ │ Summer Skincare UGC Video & Photo Campaign         │ │
│ │ [ 💵 750 EGP Cash ]  [ 🎁 1,200 EGP Product ]       │ │
│ │ ●●●○○ 2 of 5 spots filled · Open                   │ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│  (   🔍 Discover   │   📋 Jobs   │   👤 Profile   )   │  ◄── Floating Glass Tab Bar
└────────────────────────────────────────────────────────┘
```

### 10.2 Campaign Detail & 1-Tap Application Sheet
```
┌────────────────────────────────────────────────────────┐
│ (<) Back                                       ( 📤 ) │  ◄── Floating Glass Circles over Cover
│ ┌────────────────────────────────────────────────────┐ │
│ │ [ High-Res 16:9 Cover Image with Bottom Scrim ]   │ │
│ └────────────────────────────────────────────────────┘ │
│ Summer Skincare UGC Video Reel                         │  ◄── Title 1 (28pt)
│ Glow Cosmetics Egypt · ★ 4.9 (24 completed campaigns)  │
│                                                        │
│ ┌ Requirements ──────────────────────────────────────┐ │  ◄── Paper Container
│ │ • 30-45s vertical TikTok/Reel or high-res photo    │ │
│ │ • Natural morning lighting; mention SPF 50 benefits│ │
│ │ • Free-form revision notes directly on timeline    │ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│  (  1-Tap Apply — Verified Creators  )                 │  ◄── Sticky Tint Glass Pill
└────────────────────────────────────────────────────────┘
```

### 10.3 Brand Applicants Review & Media Player Sheet
```
┌────────────────────────────────────────────────────────┐
│ Applicants Review (14 applicants · 3 spots)     ( ✕ ) │  ◄── Sheet Header
│ ┌────────────────────────────────────────────────────┐ │
│ │ [Avatar 44]  Nourhan M.  ★ 4.9 (18 completed)      │ │  ◄── Applicant Paper Tile
│ │ Cairo · Fashion & Lifestyle                        │ │
│ │ [View Creator Profile] (Portfolio, Socials, Stats) │ │
│ │                                                    │ │
│ │ [ Reel Thumbnail 1 ]  [ Reel Thumbnail 2 ]         │ │  ◄── Horizontal Video Preview Strip
│ │                                                    │ │
│ │ (  Reject  )           (  Select Creator  )        │ │  ◄── Glass Buttons
│ └────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

---

## 11. Complete Flutter Implementation Code

### 11.1 Design System Tokens (`lib/core/theme/app_theme_tokens.dart`)

```dart
import 'package:flutter/material.dart';

/// Layer 1: Primitive Color Tokens
class AppPrimitives {
  AppPrimitives._();

  // Baby Blue (Brand Realm & Trust Foundation)
  static const blue50  = Color(0xFFF3F9FF);
  static const blue100 = Color(0xFFE3F1FD);
  static const blue200 = Color(0xFFCBE5FB);
  static const blue300 = Color(0xFFA9D4F7);
  static const blue400 = Color(0xFF89CFF0);
  static const blue500 = Color(0xFF5DB4E8);
  static const blue600 = Color(0xFF3A93CC);
  static const blue700 = Color(0xFF2A73A6);
  static const blue800 = Color(0xFF1F5680);
  static const blue900 = Color(0xFF163B59);

  // Baby Pink (Creator Realm & Creative Energy)
  static const pink50  = Color(0xFFFFF5F8);
  static const pink100 = Color(0xFFFEE9F0);
  static const pink200 = Color(0xFFFCD7E4);
  static const pink300 = Color(0xFFF8C0D6);
  static const pink400 = Color(0xFFF09BBB);
  static const pink500 = Color(0xFFE5729D);
  static const pink600 = Color(0xFFC9507F);
  static const pink700 = Color(0xFFA23A64);
  static const pink800 = Color(0xFF7A2C4C);
  static const pink900 = Color(0xFF522034);

  // Ink Neutrals (Blue-Slate)
  static const ink900  = Color(0xFF1A2138);
  static const ink700  = Color(0xFF3A4360);
  static const ink500  = Color(0xFF67708C);
  static const ink300  = Color(0xFFA4ABC0);
  static const ink100  = Color(0xFFDDE1EC);
  static const white   = Color(0xFFFFFFFF);

  // Spatial Dimensions
  static const double space4  = 4.0;
  static const double space8  = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space56 = 56.0;

  // Corner Radii
  static const double rXs   = 8.0;
  static const double rSm   = 12.0;
  static const double rMd   = 16.0;
  static const double rLg   = 20.0;
  static const double rXl   = 28.0;
  static const double r2Xl  = 36.0;
  static const double rFull = 999.0;
}

/// Layer 2: Semantic Color Tokens
class AppSemanticColors {
  AppSemanticColors._();

  // Feedback States (Paired for WCAG AA)
  static const successBg = Color(0xFFD6F3E7);
  static const successFg = Color(0xFF1F7A5A);
  static const warningBg = Color(0xFFFDEBCB);
  static const warningFg = Color(0xFF8A5A12);
  static const dangerBg  = Color(0xFFFFDCE1);
  static const dangerFg  = Color(0xFFB3263F);
  static const infoBg    = Color(0xFFE3F1FD);
  static const infoFg    = Color(0xFF2A73A6);

  // The Match Blend Gradient
  static const matchGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPrimitives.blue300, AppPrimitives.pink300],
  );
}

/// Layer 3: Component Design Tokens
class AppComponentTokens {
  AppComponentTokens._();

  // Button Specs
  static const double buttonHeightLarge = 52.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonRadius = AppPrimitives.rFull;

  // Card Specs
  static const double cardRadius = AppPrimitives.rXl;
  static const EdgeInsets cardPadding = EdgeInsets.all(AppPrimitives.space16);

  // Floating Tab Bar
  static const double tabBarHeight = 64.0;
  static const double tabBarMargin = 20.0;
}
```

---

### 11.2 Fluid Glass Container (`lib/core/widgets/app_glass_container.dart`)

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme_tokens.dart';

enum GlassTier { nativeCupertino, standardBlur, frost }
enum GlassVariant { regular, clear, thick, tinted, match }

class AppGlassContainer extends StatefulWidget {
  final Widget child;
  final GlassVariant variant;
  final Color? tintColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool enablePressSpring;

  const AppGlassContainer({
    super.key,
    required this.child,
    this.variant = GlassVariant.regular,
    this.tintColor,
    this.borderRadius = AppPrimitives.rFull,
    this.padding,
    this.onTap,
    this.enablePressSpring = false,
  });

  @override
  State<AppGlassContainer> createState() => _AppGlassContainerState();
}

class _AppGlassContainerState extends State<AppGlassContainer> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.onTap != null && widget.enablePressSpring) {
      HapticFeedback.lightImpact();
      _pressController.forward();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (widget.onTap != null && widget.enablePressSpring) {
      _pressController.reverse();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (widget.onTap != null && widget.enablePressSpring) {
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sigma = switch (widget.variant) {
      GlassVariant.clear => 12.0,
      GlassVariant.thick => 40.0,
      _ => 24.0,
    };

    final bgFill = switch (widget.variant) {
      GlassVariant.clear => AppPrimitives.white.withOpacity(0.14),
      GlassVariant.thick => AppPrimitives.white.withOpacity(0.72),
      GlassVariant.tinted => (widget.tintColor ?? AppPrimitives.blue300).withOpacity(0.62),
      GlassVariant.match => null,
      GlassVariant.regular => AppPrimitives.white.withOpacity(0.48),
    };

    Widget container = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgFill,
            gradient: widget.variant == GlassVariant.match ? AppSemanticColors.matchGradient : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: AppPrimitives.white.withOpacity(widget.variant == GlassVariant.clear ? 0.40 : 0.75),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF466EB4).withOpacity(0.12),
                blurRadius: 24.0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null) {
      return Listener(
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: GestureDetector(
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: container,
          ),
        ),
      );
    }

    return container;
  }
}
```

---

### 11.3 Primary Glass Button (`lib/core/widgets/app_glass_button.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme_tokens.dart';
import 'app_glass_container.dart';

class AppGlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final bool isLoading;
  final bool isDestructive;
  final Color? tintColor;
  final double height;

  const AppGlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.isLoading = false,
    this.isDestructive = false,
    this.tintColor,
    this.height = AppComponentTokens.buttonHeightLarge,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDestructive 
        ? AppSemanticColors.dangerFg 
        : AppPrimitives.ink900;

    final variant = isDestructive 
        ? GlassVariant.regular 
        : GlassVariant.tinted;

    return AppGlassContainer(
      variant: variant,
      tintColor: tintColor,
      enablePressSpring: onPressed != null && !isLoading,
      onTap: isLoading ? null : onPressed,
      borderRadius: AppComponentTokens.buttonRadius,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: height - 24, // accounted for padding
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(leadingIcon, size: 20, color: textColor),
                      const SizedBox(width: AppPrimitives.space8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.readexPro(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: -0.005,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
```

---

## 12. Accessibility (WCAG 2.1 AA Compliance)

1. **Strict Text Legibility on Glass:** All text on glass surfaces uses high-contrast `AppPrimitives.ink900` ($\approx 16:1$) or `AppPrimitives.ink700` ($\approx 9.8:1$). Never use pastel or white text on glass controls.
2. **Platform Dynamic Type Scaling:** All headings, descriptions, and list cards scale dynamically without clipping. Interactive floating chrome is capped at $1.3\times$ font scaling to maintain touch target ergonomics.
3. **Screen Reader Semantic Roles:** All glass icon buttons contain explicit `Semantics(label: "...", button: true)` tags. The timeline stepper announces status as an ordered progress list with active milestones.
4. **Color-Blind Safe Badges:** Danger states are strictly distinguished from Creator Pink by pairing with dedicated icons (`Ph.warning_circle`, `Ph.x_circle`) and high-contrast dark text tones.
5. **Touch Target Boundaries:** Minimum interactive control footprint is $\ge 44 \times 44\text{ pt}$ on all touch surfaces.

---

## 13. Quality Assurance & Device Test Matrix

| QA Gate | Verification Standard | Target Threshold |
|---|---|---|
| **Impeller / Metal 60 FPS** | Profiling with Flutter DevTools Performance Overlay on iOS & Android | 0 dropped frames during feed scroll |
| **Blur Surface Budget** | Inspection of active rendering tree on Tier B devices | $\le 3$ simultaneous `BackdropFilter` widgets |
| **RTL Layout Audit** | Phase 2 preparation: verify directional layout mirroring and font rendering readiness | Zero horizontal overflow; proper bidirectional text isolates |
| **Accessibility Contrast** | Automated audit with axe/WCAG compliance checkers | 100% of text elements meet $\ge 4.5:1$ (Normal) or $\ge 3:1$ (Large) |
| **Low-End Tier Fallback** | Automated test on simulated Android device with $< 4\text{GB}$ RAM | Gracefully falls back to Tier C Frost containers |
| **Touch Target Area** | Automated widget test asserting minimum hit boundaries | All interactive controls $\ge 44 \times 44\text{ pt}$ |