# UGCULT Mobile — Phased Implementation Plan

**Project:** UGCULT Production Mobile App (iOS Target & Android Cross-Platform)  
**Host Development OS:** Windows 10 / 11 (PowerShell)  
**CI/CD iOS Compilation:** GitHub Actions (`macos-14` Apple Silicon runner)  
**Framework:** Flutter (Dart) + Supabase (PostgreSQL 16) + Firebase (FCM / APNs) + Google Drive API v3  
**Target Quality:** Production-Ready, Secure, Low Latency  
**Document Status:** Approved v3.1 (Creator-Owned Google Drive Media Architecture Revision)  
**Changes from v3.0:** Added Creator-Owned Google Drive media storage architecture; pre-implementation technical spikes for resumable direct upload and range request playback; Google OAuth 2.0 integration tasks; in-app video player broker; lossless original deliverable download pipeline; updated cross-document reference map.

---

## 1. Implementation Roadmap & Timeline Overview

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ Phase 1: Project Scaffolding, Design System & Supabase Backend Setup     (Weeks 1 - 2) │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Phase 2: Auth, Phone OTP, Role Selection & Profile Setup                  (Weeks 3 - 4) │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Phase 3: Media Processing, Video/Photo Upload & Portfolio Engine          (Weeks 5 - 6) │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Phase 4: Campaign Creation, Discovery Feed & 1-Tap Apply                  (Weeks 7 - 8) │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Phase 5: Applicant Review, Shipping & Content Submission Workflow        (Weeks 9 - 10) │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Phase 6: Revisions, Dual Payment Confirmation, Ratings & Disputes       (Weeks 11 - 12) │
├────────────────────────────────────────────────────────────────────────────────────────┤
│ Phase 7: Push Notifications, Admin Portal, Caching, Polish & Launch     (Weeks 13 - 14) │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Phase-by-Phase Breakdown & Tasks

### Phase 1: Foundations, Design System & Supabase Backend Setup

#### Task 1.1: Flutter Project Initialization
- [ ] Initialize Flutter project with bundle IDs `com.ugcult.app`.
- [ ] Configure target SDKs (Android minSdk 24 / iOS 15.0+).
- [ ] Setup Riverpod 2.x code generator (`flutter_riverpod`, `riverpod_annotation`, `build_runner`).
- [ ] Configure `go_router` with declarative routing and route guards.
- [ ] Setup Sentry Flutter for crash reporting.

#### Task 1.2: Design System & Theming
- [ ] Implement Readex Pro typography scale (all Latin-only for MVP).
- [ ] Define custom color tokens from Design.md (Baby Blue, Baby Pink, Ink, Semantic States).
- [ ] Build Glass container primitive (`GlassContainer`) with 3-tier rendering (A/B/C).
- [ ] Build reusable UI primitives: `AppButton`, `AppTextInput`, `AppCard`, `AvatarBadge`, `ShimmerLoader`, `StatusPill`.
- [ ] Use logical layout properties (`start`/`end`) for RTL-readiness throughout.

#### Task 1.3: Supabase Backend Setup
- [ ] Create Supabase project (cloud).
- [ ] Write and apply migration 001: all ENUMs from DB-DESIGN.md (including `drive_account_status`, `drive_upload_status`).
- [ ] Write and apply migration 002: all tables (`users`, `creator_profiles`, `creator_private_contacts`, `creator_portfolios`, `creator_google_drive_accounts`, `brand_profiles`, `campaigns`, `campaign_applications`, `campaign_submissions`, `submission_revision_requests`, `campaign_reviews`, `audit_logs`, `user_fcm_tokens`).
- [ ] Write and apply migration 003: all triggers (`enforce_campaign_immutability`, `auto_transition_campaign_in_progress`).
- [ ] Write and apply migration 004: all RLS policies from DB-DESIGN.md (including zero-brand access to Drive accounts & multi-tenant submission isolation).
- [ ] Write and apply migration 005: all indexes from DB-DESIGN.md (including `idx_drive_accounts_user`, `idx_submissions_drive_file`).
- [ ] Configure Supabase Vault for OAuth refresh token encryption.
- [ ] Create Supabase Storage buckets: `portfolios`, `submissions` (photos only), `avatars`, `campaign-covers`.
- [ ] Configure Storage bucket RLS policies.
- [ ] Test RLS policies with `supabase test db` (pgTAP) for PII isolation and cross-tenant deliverable boundaries.

#### Phase 1: Definition of Done (DoD) Criteria
- [ ] Flutter app compiles and executes on Windows desktop, Chrome, Android emulator, and iOS simulator without compilation errors or critical warnings.
- [ ] `flutter analyze` and `dart run custom_lint` exit with 0 errors and 0 warnings.
- [ ] Sentry Flutter SDK is configured and captures unhandled exceptions with device telemetry.
- [ ] Supabase migrations (001–005) successfully applied to production/staging Supabase project.
- [ ] All PostgreSQL 16 ENUMs, 12 tables, triggers (`enforce_campaign_immutability`, `auto_transition_campaign_in_progress`), and RLS policies are active.
- [ ] Supabase Vault is configured with master encryption key for OAuth token custody.
- [ ] Supabase Storage buckets created with strict RLS policies: `portfolios` (public read, creator insert), `submissions` (photos only), `avatars` (public read), `campaign-covers` (public read).
- [ ] Automated database test suite (`supabase test db` via pgTAP) passes 100% of tests verifying PII isolation and multi-tenant security boundaries.

#### Phase 1: Manual Verification Checklist
- [ ] **UI Rendering:** Launch app on Android emulator and Chrome: verify `Readex Pro` typography, Baby Blue (`#89CFF0`), Baby Pink (`#F09BBB`), and Ink palette render without default fallback fonts.
- [ ] **Design System Gallery:** Open design system test screen: verify `GlassContainer` renders 3 visual tiers (A, B, C) with background backdrop blur and subtle borders.
- [ ] **Primitive Widgets:** Verify `AppButton`, `AppTextInput`, `AppCard`, `AvatarBadge`, `ShimmerLoader`, and `StatusPill` interact cleanly with micro-haptic feedback.
- [ ] **Sentry Telemetry:** Trigger test crash button: verify exception event appears in Sentry dashboard within 60 seconds with stack trace and device metadata.
- [ ] **Database Inspection:** Open Supabase Dashboard Table Editor: verify all 12 tables exist with correct relationships, foreign keys, and indexes.
- [ ] **RLS Verification:** Run pgTAP tests or execute test queries in Supabase SQL editor: verify anonymous and brand users cannot read `creator_private_contacts` or `creator_google_drive_accounts`.

#### Phase 1: Manual Actions You Need to Take
1. **Supabase Cloud Project:**
   - Create a new project on [supabase.com](https://supabase.com) (recommended region: Frankfurt `eu-central-1` for Egypt latency).
   - In Project Settings → API: copy `Project URL` and `anon public` key to `.env` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
   - In Database → Extensions: search for and enable `vault` (Supabase Vault) and `pgcrypto`.
2. **Sentry Error Tracking:**
   - Create an account on [sentry.io](https://sentry.io) and create a new project with platform "Flutter".
   - Copy Sentry DSN into `.env` (`SENTRY_DSN`).
3. **CI/CD Cloud Runners:**
   - In GitHub repository Settings → Secrets and variables → Actions: add `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY`.
   - Verify GitHub Actions runner quota supports `macos-14` Apple Silicon runners.

---

### Phase 2: Authentication, Phone OTP & Onboarding

#### Task 2.1: Supabase Auth & Session Layer
- [ ] Integrate `supabase_flutter` with `flutter_secure_storage` for JWT persistence.
- [ ] Configure Supabase SMS OTP (Twilio provider) in Supabase dashboard.
- [ ] Implement automatic token refresh via Supabase session manager.
- [ ] Implement GoRouter auth guard (redirect unauthenticated users to login).

#### Task 2.2: Onboarding UI
- [ ] Build splash screen with brand animation.
- [ ] Build role selection screen ("I'm a Creator" / "I'm a Brand") with Glass cards.
- [ ] Build Phone OTP login screen with Egyptian phone validation (`+20` prefix).
- [ ] Build OTP code entry screen with auto-submit on 6 digits.
- [ ] Build age attestation (18+) and ToS acceptance modal.

#### Task 2.3: Profile Setup Wizards
- [ ] **Creator:** Display name, bio, niche categories (6 fixed + "Other" with freetext), governorate, social handles (TikTok/Instagram/YouTube), follower count. Optional email field.
- [ ] **Brand:** Company name, industry category, description, website URL, logo upload, governorate. Optional email field.
- [ ] **Creator PII:** Contact phone, Instapay handle, shipping address (optional for digital-only creators). Saved to `creator_private_contacts`.
- [ ] Implement `complete_user_onboarding` RPC function.
- [ ] Profile completion percentage calculation.

#### Phase 2: Definition of Done (DoD) Criteria
- [ ] Phone SMS OTP authentication via Supabase Auth (Twilio SMS provider) functional for Egyptian mobile numbers (`+20` prefix, `^01[0125][0-9]{8}$`).
- [ ] Automatic OTP submission upon 6-digit entry with SMS Autofill support on Android and iOS.
- [ ] Immutable user role (`creator` or `brand`) persisted in `public.users` upon initial onboarding and cannot be mutated.
- [ ] `complete_user_onboarding` RPC function executes atomically: writes `public.users`, role-specific profile (`creator_profiles` or `brand_profiles`), and sensitive PII (`creator_private_contacts`).
- [ ] User JWT session token stored securely via `FlutterSecureStorage` (iOS Keychain / Android EncryptedSharedPreferences).
- [ ] GoRouter auth guards correctly redirect unauthenticated users to `/login` and un-onboarded users to `/onboarding`.
- [ ] Zero-trust RLS policies verify that unapproved brands cannot read creator contacts (phone, Instapay handle, shipping address).

#### Phase 2: Manual Verification Checklist
- [ ] **Role Selection:** Open app on fresh install: verify Splash screen transitions to Role Selection ("I'm a Creator" / "I'm a Brand") with responsive Glass cards.
- [ ] **Egyptian Phone Validation:** Enter invalid numbers (`01312345678`, `123456`): verify instant inline error. Enter valid Egyptian mobile `01012345678`: verify button enables.
- [ ] **OTP Delivery:** Tap "Send OTP": verify 6-digit SMS code arrives on mobile. Enter code: verify auto-submit without pressing an enter key.
- [ ] **Creator Profile Setup:** Fill display name, bio, niche category ("Beauty"), governorate ("Cairo"), Instagram handle. Fill private contacts (Instapay handle, shipping address). Tap "Finish Setup": verify profile persists and user lands on Creator 3-tab navigation.
- [ ] **Brand Profile Setup:** Register second test account as Brand. Fill company name ("Glow Skincare"), industry ("Beauty"), website, logo upload. Verify Brand lands on Brand 3-tab navigation.
- [ ] **Session Persistence:** Force-close app and re-launch: verify user stays logged in without seeing login screen.
- [ ] **Logout Flow:** Tap Logout in Profile Settings: verify secure storage cleared and app returns to Login screen.

#### Phase 2: Manual Actions You Need to Take
1. **Twilio Account Setup:**
   - Create an account on [twilio.com](https://twilio.com) and purchase an SMS-enabled Egyptian phone number or Alphanumeric Sender ID.
   - Retrieve Twilio Account SID, Auth Token, and Messaging Service SID.
2. **Configure Supabase Phone Auth:**
   - In Supabase Dashboard → Authentication → Providers → Phone:
     - Enable Phone Provider.
     - Select "Twilio" as SMS Provider.
     - Enter Account SID, Auth Token, and Message Service SID.
     - Set SMS OTP Message template: `"Your UGCULT verification code is {{ .Code }}."`
3. **Configure Auth Test Numbers (Crucial for Dev/Testing):**
   - In Supabase Dashboard → Authentication → Providers → Phone → Test Phone Numbers:
     - Add `+201000000001` with fixed code `123456` (Creator Test).
     - Add `+201000000002` with fixed code `123456` (Brand Test).
     - This allows development and automated testing without incurring Twilio SMS costs.

---

### Phase 3: Media Processing, Video/Photo Upload & Portfolio

#### Task 3.0: Technical Spikes & Locked Findings (Google Drive Integration)
- [x] **Spike 3.0A (Direct Resumable Upload):** Confirmed. RFC 7233 Google Drive v3 Resumable Upload protocol handles chunked streaming natively via `Content-Range: bytes x-y/total`. Querying the URI returns `HTTP 308 Resume Incomplete` for dropped connections. Zero backend serverless bandwidth consumed.
- [x] **Spike 3.0B (Range Request Video Playback):** Confirmed. Google Drive API v3 `alt=media` honors `Range: bytes=start-end` (`HTTP 206 Partial Content`). Locked on Option B (Supabase Edge Function streaming proxy) + `cached_video_player_plus` on-device disk caching, with Option D as scale fallback.
- [x] **Spike 3.0C (100MB+ Virus Scan Interstitial):** Confirmed. HTML virus warning is strictly an unauthenticated browser page (`/uc?export=download`). Programmatic calls with `Authorization: Bearer <token>` and `confirm=t` stream raw video binaries directly regardless of file size.
- [x] **Spike 3.0D (Google OAuth Scope Tier):** Confirmed. `https://www.googleapis.com/auth/drive.file` is officially categorized by Google as a Sensitive (non-restricted) scope. Eliminates third-party CASA Tier 2 security audit requirement ($15k–$75k fee). Standard Google brand verification applies.

#### Task 3.1: Media Picker & Video Compression
- [ ] Implement native camera and gallery picker using `image_picker`.
- [ ] Integrate `video_compress` for on-device video compression for **portfolio reels** (H.264, 720p/1080p, ~2.5 Mbps).
- [ ] Auto-extract video thumbnail on-device for all video selections.
- [ ] Photo support: accept JPEG/PNG/WebP, optional resize if > 2048px.

#### Task 3.2: Portfolio Upload Pipeline (Platform Managed)
- [ ] Configure Tus resumable video upload targeting Supabase Storage bucket `portfolios`.
- [ ] Implement upload progress indicator with pause/resume and network recovery.
- [ ] Photo direct upload (non-resumable, single request).
- [ ] Background upload support with local notification on completion.

#### Task 3.3: Google Drive OAuth Connection Flow (Creator)
- [ ] Deploy Edge Function `drive-auth-url` to generate secure OAuth authorization URL with PKCE challenge.
- [ ] Implement in-app Google OAuth consent sheet (in-app browser or native webview).
- [ ] Deploy Edge Function `drive-oauth-callback`: exchange code server-side, encrypt refresh token in Supabase Vault, insert `creator_google_drive_accounts` record.
- [ ] Build Creator Profile → Google Drive Connection status card (connect, view status, disconnect).
- [ ] Deploy Edge Function `drive-disconnect` with token revocation API call.

#### Task 3.4: Portfolio Showcase
- [ ] Build portfolio grid view (video + photo items).
- [ ] Build fullscreen video reel player using `cached_video_player_plus` with disk caching.
- [ ] Build fullscreen photo viewer with pinch-to-zoom.
- [ ] Portfolio item management (add, delete, reorder).
- [ ] Media type indicator badges on grid thumbnails (video/photo).

#### Phase 3: Definition of Done (DoD) Criteria
- [ ] All 4 pre-implementation technical spikes (SPK-001, SPK-002, SPK-003, SPK-005) verified with documented findings in `DOCS/ARCHITECTURE.md`.
- [ ] Native camera and gallery picker functional via `image_picker`.
- [ ] On-device video compression (`video_compress`) encodes portfolio reels to H.264 / AAC 720p/1080p at ~2.5 Mbps (< 30MB).
- [ ] On-device video thumbnail generation creates WebP/JPEG thumbnail preview for every selected video.
- [ ] Tus resumable upload protocol uploads portfolio reels to Supabase Storage `portfolios` bucket with chunk-level progress and network drop recovery.
- [ ] Google OAuth 2.0 integration functional:
  - Scopes strictly restricted to non-sensitive `https://www.googleapis.com/auth/drive.file`.
  - `drive-auth-url` Edge Function generates authorization URL with PKCE challenge and signed state.
  - `drive-oauth-callback` Edge Function exchanges code server-side and stores encrypted refresh token in Supabase Vault.
  - Zero Google access tokens, refresh tokens, or client secrets are exposed to the Flutter client.
  - `drive-disconnect` revokes Google OAuth token and updates account status.
- [ ] Fullscreen portfolio reel video player with `cached_video_player_plus` caches viewed videos to local device disk.

#### Phase 3: Manual Verification Checklist
- [ ] **Media Selection & Compression:** Open Creator Profile → Portfolio Manager. Tap "+ Add Media". Select a 100MB+ 4K camera video: verify on-device compression reduces file size to < 25MB and extracts clear thumbnail.
- [ ] **Resumable Portfolio Upload:** Upload portfolio video: verify progress bar (0–100%). Toggle airplane mode on at 50%: verify upload pauses. Toggle airplane mode off: verify upload resumes without starting from 0%.
- [ ] **Portfolio Reel Playback:** Tap uploaded portfolio card: verify fullscreen video player opens, plays audio, supports pause/seek, and caches to local disk.
- [ ] **Google OAuth Consent Flow:** In Creator Profile → Settings → Storage: tap "Connect Google Drive". Verify system browser opens Google consent screen requesting ONLY permission to "See, edit, create, and delete only the specific Google Drive files you use with this app".
- [ ] **OAuth Callback & Security Check:** Sign in with Google: verify consent completes, browser redirects back to app via deep link, and status updates to "Connected as creator@gmail.com".
- [ ] **Token Vault Inspection:** Inspect Supabase database `creator_google_drive_accounts` via SQL Editor: verify `encrypted_refresh_token` or `vault_secret_id` is populated; verify no plaintext credentials exist.
- [ ] **Disconnect Flow:** Tap "Disconnect Google Drive": verify confirmation modal warning of active submissions, tap confirm, verify account status transitions to `disconnected`.

#### Phase 3: Manual Actions You Need to Take
1. **Google Cloud Console Project:**
   - Go to [console.cloud.google.com](https://console.cloud.google.com) and create project `"UGCULT-Production"`.
   - Enable **Google Drive API** in APIs & Services → Library.
2. **OAuth Consent Screen Configuration:**
   - Set User Type to **External**.
   - App Name: `UGCULT`, User Support Email, Developer Contact Email.
   - App Domains: Add Privacy Policy URL and Terms of Service URL.
   - Scopes: Add `https://www.googleapis.com/auth/drive.file`.
3. **OAuth 2.0 Client IDs:**
   - Create **Web Application** Client ID (for Supabase Edge Function redirect):
     - Authorized redirect URI: `https://<supabase-project-ref>.supabase.co/functions/v1/drive-oauth-callback`.
   - Create **Android** Client ID:
     - Package name: `com.ugcult.app`.
     - SHA-1 fingerprint: Add debug and release keystore SHA-1.
   - Create **iOS** Client ID:
     - Bundle ID: `com.ugcult.app`.
4. **Deploy Edge Functions & Secrets:**
   - Deploy `drive-auth-url`, `drive-oauth-callback`, and `drive-disconnect`:
     ```powershell
     supabase functions deploy drive-auth-url
     supabase functions deploy drive-oauth-callback
     supabase functions deploy drive-disconnect
     supabase secrets set GOOGLE_CLIENT_ID="<id>.apps.googleusercontent.com" GOOGLE_CLIENT_SECRET="<secret>"
     ```

---

### Phase 4: Campaign Creation, Discovery Feed & Applications

#### Task 4.1: Campaign Creation Wizard (Brand)
- [ ] Multi-step wizard with draft auto-save.
- [ ] Step 1: Title, Category (6 fixed + "Other"), Description, Guidelines.
- [ ] Step 2: Creator spots needed, Compensation type (gift/cash/both) with EGP amounts.
- [ ] Step 3: Shipping toggle, Accepted deliverable types (video/photo/both).
- [ ] Step 4: Cover image upload, Reference URLs.
- [ ] Step 5: Review & Publish with immutability warning confirmation.
- [ ] Direct publish → `published` status (no admin approval).

#### Task 4.2: Campaign Discovery Feed (Creator)
- [ ] Infinite scroll paginated feed with pull-to-refresh.
- [ ] Campaign card: title, brand name + logo, category pill, compensation badge, spots remaining, accepted media types.
- [ ] Filter sheet: Category, Compensation Type (Cash/Gift/Both), Governorate.
- [ ] Text search across campaign title and brand name.
- [ ] Detailed campaign view with guidelines, brand profile card, and apply button.

#### Task 4.3: 1-Tap Application
- [ ] Pure 1-tap application bottom sheet: confirmation prompt with "Apply" button (no pitch note or portfolio item selection).
- [ ] Creator application links creator to campaign; Brand can inspect creator's public profile (portfolio, niche, avatar, social links, follower count).
- [ ] Server-side unique application constraint (`UNIQUE(campaign_id, creator_id)`).
- [ ] Success confirmation with Match Blend animation.

#### Phase 4: Definition of Done (DoD) Criteria
- [ ] Multi-step Campaign Creation Wizard allows Brand to draft, preview, and directly publish campaigns without admin approval queue.
- [ ] PostgreSQL trigger `enforce_campaign_immutability` blocks mutation of core campaign fields (`title`, `compensation_type`, `cash_amount_egp`, `guidelines`, `accepted_deliverable_types`) once status is `published` or `in_progress`.
- [ ] Creator Campaign Discovery Feed loads paginated results in < 250ms with pull-to-refresh and infinite scroll.
- [ ] Multi-faceted filtering functional: Category (Beauty, Tech, Food, etc.), Compensation Type (Cash, Gift, Both), and Governorate.
- [ ] Full-text search queries campaign titles and brand company names with indexing.
- [ ] 1-Tap Application bottom-sheet enforces prerequisite: creator must possess ≥ 1 portfolio item.
- [ ] Database constraint `UNIQUE(campaign_id, creator_id)` blocks duplicate applications.
- [ ] Successful application submission triggers signature Match Blend particle/gradient animation.

#### Phase 4: Manual Verification Checklist
- [ ] **Campaign Creation Wizard:** Log in as Brand: tap FAB "+" button. Step 1: Fill title ("Summer Skincare UGC Video"), category ("Beauty"), description, guidelines. Step 2: Spots needed (3), compensation ("Cash", 1000 EGP). Step 3: Shipping (Disabled), Deliverable ("Video"). Step 4: Upload cover image. Tap "Publish Campaign": confirm immutability modal.
- [ ] **Immutability Trigger Test:** In Supabase SQL Editor: attempt `UPDATE campaigns SET cash_amount_egp = 2000 WHERE id = '<id>';`: verify PostgreSQL trigger raises exception: `Campaign details cannot be modified once published.`
- [ ] **Discovery Feed Verification:** Log in as Creator: verify newly published campaign appears at top of feed with correct badge, compensation pill, and cover image.
- [ ] **Filter Verification:** Open filter sheet: select Category "Beauty": verify campaign matches. Select "Food": verify campaign disappears. Select "Cairo": verify governorate filter works.
- [ ] **1-Tap Application Flow:** Tap campaign card → tap "Apply". Tap confirmation button (no pitch note or portfolio selection needed). Verify Match Blend animation renders smoothly at 60fps.
- [ ] **Duplicate Application Guard:** Tap "Apply" on the same campaign again: verify button is disabled and backend rejects with `DUPLICATE_APPLICATION`.

#### Phase 4: Manual Actions You Need to Take
1. **Supabase Storage Bucket Configuration:**
   - In Supabase Dashboard → Storage → Buckets:
     - Verify `campaign-covers` bucket exists and is set to **Public**.
     - Verify RLS policy on `campaign-covers`: `INSERT` allowed only for authenticated users where `auth.uid() = brand_id`.
2. **Database Trigger Verification:**
   - Run SQL check in Supabase SQL Editor to verify trigger is enabled:
     ```sql
     SELECT trigger_name, event_manipulation, event_object_table, action_statement
     FROM information_schema.triggers WHERE trigger_name = 'trg_campaign_immutability';
     ```

---

### Phase 5: Applicant Review, Shipping & Content Submission

#### Task 5.1: Applicant Review Hub & Public Profile (Brand)
- [ ] Brand Applicants tab: list all applicants per campaign.
- [ ] Applicant card: avatar, name, niche, governorate, rating, and "View Creator Profile" button.
- [ ] Creator Public Profile screen: displays full portfolio grid (videos/photos), niche, avatar, social media links (TikTok, Instagram, YouTube), self-reported follower counts/engagement, and bio.
- [ ] "Select" / "Reject" action buttons.
- [ ] On approve: RLS auto-unlocks creator PII, push notification sent.
- [ ] Campaign auto-transitions `published → in_progress` on first approval.

#### Task 5.2: Simplified Shipping
- [ ] If campaign `requires_shipping`:
  - [ ] Brand marks "Product sent" → updates `product_sent_at`.
  - [ ] Creator sees "Product on the way" status.
  - [ ] Creator marks "Product received" → updates `product_received_at`.
- [ ] No carrier name or tracking number fields.

#### Task 5.3: Content Submission Flow (Creator)
- [ ] Upload deliverable matching campaign's `accepted_deliverable_types`.
- [ ] **Google Drive Video Submission:**
  - [ ] Check creator's Drive connection status; show "Connect Google Drive" modal if not connected.
  - [ ] Call `initiate-video-submission` Edge Function to obtain Drive v3 resumable upload session URI.
  - [ ] Stream original uncompressed master video directly from mobile to Google Drive with progress bar.
  - [ ] Handle pause, cancel, network drop retry, and chunk resumption.
  - [ ] Upload video thumbnail to Supabase Storage `submissions` bucket.
  - [ ] Call `complete-video-submission` Edge Function: validates file existence in Drive, extracts metadata (file_id, size, duration, resolution, checksum), writes `campaign_submissions` row.
- [ ] **Photo Submission:** Direct upload to Supabase Storage `submissions` bucket.
- [ ] Caption copy and notes-for-brand text fields.
- [ ] Application status → `content_submitted`.

#### Phase 5: Definition of Done (DoD) Criteria
- [ ] Brand Applicants Hub displays all creator applications per campaign with avatar, name, niche, governorate, rating, and 'View Creator Profile' action linking to public profile (full portfolio, social links, follower count).
- [ ] RPC function `decide_applicant` atomically updates application status to `approved` or `rejected`, increments `approved_creators_count`, and triggers auto-transition of campaign to `in_progress`.
- [ ] Zero-Trust RLS strictly unlocks creator private contacts (`creator_private_contacts`) ONLY to the brand that approved the application.
- [ ] Simplified 2-step shipping handshake ("Product sent" → "Product received") timestamps shipping events without tracking numbers.
- [ ] Creator Video Deliverable Submission via Google Drive:
  - If Google Drive is disconnected, prompts "Connect Google Drive" modal.
  - `initiate-video-submission` Edge Function creates resumable upload session on Google Drive v3 API.
  - Flutter client streams raw master video binary directly from device to Google Drive upload URI with real-time progress.
  - Video thumbnail extracted on-device and stored in Supabase Storage `submissions` bucket.
  - `complete-video-submission` Edge Function validates file existence in Drive, extracts metadata (file_id, size, duration, resolution, checksum), and records `campaign_submissions` row.
  - Application status transitions to `content_submitted`.
- [ ] Zero raw video binaries pass through or reside on Supabase platform storage.

#### Phase 5: Manual Verification Checklist
- [ ] **Applicant Review & Public Profile:** Log in as Brand: navigate to Applicants Hub. Open campaign: verify creator application appears with 'View Creator Profile' button. Tap button: verify public profile displays creator's full portfolio reels/photos, niche, avatar, social handles, and self-reported follower counts.
- [ ] **Pre-Approval PII Lock Test:** In Supabase SQL Editor: query `creator_private_contacts` as Brand user before approval: verify 0 rows returned.
- [ ] **Applicant Approval:** Tap "Select" (Approve): verify status transitions to `approved`. Verify campaign status auto-transitions from `published` to `in_progress`.
- [ ] **Post-Approval PII Unlock:** Verify Brand mobile screen now reveals creator's phone number, Instapay handle, and shipping address.
- [ ] **Simplified Shipping (if applicable):** Brand taps "Product sent" → Creator sees "Product on the way" banner → Creator taps "Product received" → Status transitions to `product_received`.
- [ ] **Google Drive Video Submission:** Log in as Creator: open accepted job. Tap "Submit Deliverable". Select uncompressed 100MB+ 1080p video.
- [ ] **Direct Stream Monitoring:** Observe upload progress bar (0–100%). Monitor network inspector: verify outbound bytes stream directly to `www.googleapis.com` (0 bytes to Supabase storage).
- [ ] **Submission Confirmation:** When upload finishes: verify submission card appears with thumbnail, exact file size, duration, and status `content_submitted`.
- [ ] **Drive Cloud Verification:** Log in to creator's personal Google Drive on web: verify video file exists in "UGCULT Submissions" folder.

#### Phase 5: Manual Actions You Need to Take
1. **Deploy Submission Edge Functions:**
   - Deploy `initiate-video-submission` and `complete-video-submission`:
     ```powershell
     supabase functions deploy initiate-video-submission
     supabase functions deploy complete-video-submission
     ```
2. **Verify Database Trigger:**
   - Verify `auto_transition_campaign_in_progress` trigger is active on `campaign_applications` table.

---

### Phase 6: Revisions, Dual Payment Confirmation, Ratings & Disputes

#### Task 6.1: Video/Photo Review, Native In-App Player & Lossless Download
- [ ] **Native In-App Video Player (Zero Google Drive UI):**
  - [ ] Deploy Edge Function `submission-playback`: verifies brand campaign ownership, proxies byte stream from creator's Google Drive with Range request support.
  - [ ] Flutter `cached_video_player_plus` streams directly from playback endpoint with custom headers.
  - [ ] Native controls: play, pause, seek, scrub preview, fullscreen.
  - [ ] Interactive timecode revision markers pinned below player.
- [ ] **Lossless Original Video Download:**
  - [ ] Deploy Edge Function `submission-download-original`: verifies brand authorization, pipes uncompressed master video stream with sanitized filename (`Content-Disposition: attachment`).
  - [ ] Flutter client triggers native background download manager with tray progress bar.
  - [ ] Verifies downloaded file size and checksum against stored metadata.
  - [ ] Zero quality reduction guarantee (preserves creator's exact 1080p/4K resolution and bitrate).
- [ ] **Deliverable Storage Health Auditing:**
  - [ ] Deploy `submission-storage-auditor` Edge Function (cron): checks Drive file availability.
  - [ ] Handle edge cases: deleted Drive file, revoked OAuth, disconnected account (`submission_unavailable` UI state).
- [ ] Brand photo viewer with annotated feedback.
- [ ] "Approve" button → application status `content_approved`.
- [ ] "Request Revision" button → creates `submission_revision_requests` record with feedback and timecodes.
- [ ] **No revision cap.** Unlimited revisions. Creator can "Withdraw" at any time.

#### Task 6.2: Dual Payment Confirmation
- [ ] Brand marks "I paid" with payment method selector (Instapay / Bank Transfer / Cash).
- [ ] Creator sees notification: "Payment sent. Please confirm receipt."
- [ ] Creator marks "I received payment."
- [ ] **Both confirm → application reaches `completed`.**
- [ ] If brand marks paid but creator doesn't confirm within 72 hours → auto-dispute flag.

#### Task 6.3: Double-Blind Mutual Ratings
- [ ] Post-completion rating prompt (push notification triggered).
- [ ] Rating modal: 1–5 stars overall + sub-scores (Communication, Quality, Punctuality, Payment) + optional text.
- [ ] **Double-blind:** Ratings hidden until BOTH submit OR 7-day timeout.
- [ ] `rating-revealer` Edge Function (cron, hourly) handles reveal logic.
- [ ] Profile average_rating updated after reveal.

#### Task 6.4: Dispute System
- [ ] Creator "I didn't receive payment" button → creates dispute.
- [ ] Dispute logged to `audit_logs`.
- [ ] Push notification to admin (via admin web portal).

#### Phase 6: Definition of Done (DoD) Criteria
- [ ] Native In-App Brand Video Player plays creator's Google Drive video via `submission-playback` Edge Function streaming broker with HTTP Range request support (`206 Partial Content`).
- [ ] Google Drive branding, web links, folder interfaces, and external pop-outs are 100% invisible to the Brand.
- [ ] On-device video disk caching (`cached_video_player_plus`) caches streamed video so repeated reviews make 0 network requests.
- [ ] Timecode-pinned revision notes: Brand can scrub to timecode, add feedback, and request unlimited revisions.
- [ ] Lossless Original Video Download: Brand taps "Download Original", `submission-download-original` Edge Function verifies tenancy, streams uncompressed master video with sanitized `Content-Disposition: attachment` filename; mobile background downloader saves file to device storage.
- [ ] Pre-Completion Failure Policy (Pause & Prompt): If creator deletes file or revokes Drive access while review is active, submission transitions to `submission_unavailable` / `access_revoked`, payment actions are locked, and creator is alerted via FCM push.
- [ ] Dual Payment Confirmation: Brand marks paid (Instapay / Bank Transfer / Cash) → Creator marks received → Application reaches `completed`.
- [ ] Payment Timeout Auto-Dispute: `payment-timeout-checker` cron flags applications as `disputed` if Brand marks paid but Creator does not confirm within 72 hours.
- [ ] Double-Blind Ratings: Reviews hidden until BOTH parties submit OR after 7-day timeout via `rating-revealer` cron function.

#### Phase 6: Manual Verification Checklist
- [ ] **Native In-App Playback:** Log in as Brand: open creator submission. Tap video thumbnail: verify native video player opens, plays audio, supports play/pause/scrubbing, and shows zero Google Drive UI.
- [ ] **Timecode Revision Flow:** Pause video at `00:05`. Tap "Request Revision": enter note "Show product label closer to camera", pin marker `00:05`. Submit.
- [ ] **Creator Revision Flow:** Log in as Creator: verify push notification received. Open job: tap `00:05` chip, verify player seeks directly to 5 seconds.
- [ ] **Content Approval:** Creator re-uploads updated video. Brand reviews and taps "Approve Deliverable": verify status moves to `content_approved`.
- [ ] **Lossless Download Test:** Brand taps "Download Original ({size} MB)": verify notification tray progress bar. Inspect downloaded file on device: verify exact file size, original bitrate, and 1080p/4K resolution match creator upload.
- [ ] **Pre-Completion Deletion Test:** Delete a video from creator's Google Drive web interface during review: Brand opens submission: verify UI shows `submission_unavailable` alert and payment confirmation is disabled.
- [ ] **Dual Payment Handshake:** Brand marks "I paid" (selects Instapay). Creator verifies "Payment sent" banner and taps "I received payment". Verify application status reaches `completed`.
- [ ] **Double-Blind Rating Verification:** Brand submits 5-star review: verify review does NOT appear on creator's profile (`is_revealed = false`). Creator submits review: verify instant reveal and profile score calculation.

#### Phase 6: Manual Actions You Need to Take
1. **Deploy Review & Streaming Edge Functions:**
   - Deploy playback and download brokers:
     ```powershell
     supabase functions deploy submission-playback
     supabase functions deploy submission-download-original
     supabase functions deploy submission-reviewer
     supabase functions deploy submission-storage-auditor
     supabase functions deploy rating-revealer
     supabase functions deploy payment-timeout-checker
     ```
2. **Configure Supabase Scheduled Cron Jobs (pg_cron):**
   - In Supabase SQL Editor, enable `pg_cron` and configure cron triggers:
     ```sql
     -- Hourly double-blind rating reveal
     SELECT cron.schedule('rating-revealer-cron', '0 * * * *', $$
       SELECT net.http_post(
         url := 'https://<project-ref>.supabase.co/functions/v1/rating-revealer',
         headers := '{"Authorization": "Bearer <SERVICE_ROLE_KEY>"}'::jsonb
       );
     $$);

     -- 6-hour payment timeout auto-dispute checker
     SELECT cron.schedule('payment-timeout-cron', '0 */6 * * *', $$
       SELECT net.http_post(
         url := 'https://<project-ref>.supabase.co/functions/v1/payment-timeout-checker',
         headers := '{"Authorization": "Bearer <SERVICE_ROLE_KEY>"}'::jsonb
       );
     $$);
     ```

---

### Phase 7: Push Notifications, Admin Portal, Caching, Polish & Launch

#### Task 7.1: FCM Push Notification Integration
- [ ] Configure `firebase_messaging` & APNs tokens stored in `user_fcm_tokens`.
- [ ] Deploy `push-dispatcher` Edge Function triggered by database webhooks (pg_net).
- [ ] Implement all notification events from Architecture doc (10 event types).
- [ ] Deep linking: tapping notification navigates to relevant screen via GoRouter.
- [ ] Foreground notifications via `flutter_local_notifications`.
- [ ] In-app notification center (bell icon in top bar).

#### Task 7.2: Admin Web Portal (Separate Project)
- [ ] Initialize separate web project (Next.js or Vite + React).
- [ ] Admin auth via Supabase Auth (`admin` role).
- [ ] **Screen 1: Media Browser** — paginated grid of all uploaded media (portfolios + submissions). Flag/delete violations.
- [ ] **Screen 2: Disputes List** — view disputed applications with both parties' phone numbers. Mark resolved.
- [ ] **Screen 3: User Management** — list users by role/status. Suspend/unsuspend accounts.
- [ ] All admin actions logged to `audit_logs`.

#### Task 7.3: Offline Caching & Connectivity
- [ ] Riverpod `keepAlive` for campaign feed, user profile, and active jobs.
- [ ] `cached_network_image` for all image thumbnails.
- [ ] `cached_video_player_plus` for viewed videos.
- [ ] Network connectivity listener with "You're offline" banner.
- [ ] Disable interactive actions when offline.

#### Task 7.4: Cron Edge Functions
- [ ] Deploy `rating-revealer` (hourly): reveal double-blind ratings.
- [ ] Deploy `auto-archiver` (daily): archive campaigns 30 days after completion.
- [ ] Deploy `payment-timeout-checker` (every 6 hours): auto-dispute unpaid after 72h.

#### Task 7.5: Quality Assurance & Testing
- [ ] Unit tests for all Riverpod StateNotifiers and Domain Repositories (target > 85% coverage).
- [ ] Golden widget tests for key screens (Campaign Feed, Application Flow, Rating Dialog).
- [ ] End-to-end integration tests using `integration_test` package.
- [ ] RLS security audit: zero exposed creator contacts to unapproved brands.

#### Task 7.6: Production Build & App Store Submissions
- [ ] GitHub Actions automated iOS compilation pipeline (`macos-14` runner).
- [ ] Fastlane pipeline for iOS (TestFlight / App Store Connect) and Android (Google Play Console).
- [ ] Sentry crash analytics and telemetry integration.
- [ ] App Store metadata, screenshots, and descriptions.

#### Phase 7: Definition of Done (DoD) Criteria
- [ ] Firebase Cloud Messaging (FCM HTTP v1 API) & Apple Push Notification service (APNs) operational with 99.5% delivery SLA for all 10 campaign lifecycle events.
- [ ] Deep linking functional: tapping any notification routes directly to the relevant screen via GoRouter (e.g. Campaign Details, Submission Review, Dispute Chat).
- [ ] Admin Web Portal deployed and operational (Next.js or React):
  - Screen 1: Media Browser (browse all uploaded media, flag violations, delete media).
  - Screen 2: Disputes List (inspect payment disputes, view both parties' phone numbers, mark resolved).
  - Screen 3: User Management (search users, suspend/unsuspend accounts).
  - All admin operations logged to `audit_logs` table.
- [ ] Offline read cache via Riverpod `keepAlive` displays last-loaded campaign feed, user profile, and active jobs with "You're offline" banner.
- [ ] Test coverage exceeds 85% on domain and data layers (`flutter test --coverage`).
- [ ] Release binaries built: Android AAB (`flutter build appbundle --release`) and iOS IPA (`flutter build ipa --release`).
- [ ] Fastlane pipelines configured for App Store Connect (TestFlight) and Google Play Console (Internal Testing).

#### Phase 7: Manual Verification Checklist
- [ ] **Background Push Notification:** Put app in background: trigger event (Brand approves creator) from web dashboard or second phone: verify heads-up banner arrives within 3 seconds.
- [ ] **Deep Linking:** Tap push notification: verify app launches and GoRouter navigates directly to the target application screen.
- [ ] **Offline Banner:** Turn on Airplane Mode: navigate between tabs: verify previously viewed campaigns and active jobs load from cache with "You're offline" banner.
- [ ] **Admin Media Browser:** Log in to Admin Web Portal: open Media Browser: verify portfolio reels and submission thumbnails render. Test flagging a violation.
- [ ] **Admin Dispute Resolution:** Trigger test payment dispute: open Admin Disputes List: verify Brand and Creator phone numbers are clearly displayed. Mark resolved.
- [ ] **Account Suspension:** From Admin Portal, suspend a test creator account: attempt to log in or make API calls on that account on mobile: verify instant 403 Forbidden suspension alert.
- [ ] **Automated Test Suite:** Run `flutter test --coverage`: verify all unit and widget tests pass with > 85% coverage.
- [ ] **Cloud CI/CD Build:** Push commit to GitHub `main` branch: verify GitHub Actions automated workflow completes, builds Android AAB on Ubuntu runner and iOS IPA on `macos-14` runner.

#### Phase 7: Manual Actions You Need to Take
1. **Firebase Console Configuration:**
   - Create project on [console.firebase.google.com](https://console.firebase.google.com).
   - Add Android App (`com.ugcult.app`): download `google-services.json` to `android/app/`.
   - Add iOS App (`com.ugcult.app`): download `GoogleService-Info.plist` to `ios/Runner/`.
   - In Project Settings → Service accounts: click "Generate new private key".
   - Save Firebase Admin SDK private key JSON into Supabase Secrets:
     ```powershell
     supabase secrets set FCM_SERVICE_ACCOUNT_KEY='{"type": "service_account", ...}'
     ```
2. **Apple Developer Portal & APNs:**
   - In [developer.apple.com](https://developer.apple.com):
     - Register App ID `com.ugcult.app` with Push Notifications enabled.
     - Generate APNs Authentication Key (`.p8`).
   - In Firebase Console → Project Settings → Cloud Messaging → Apple app configuration:
     - Upload APNs Key (`.p8`), Key ID, and Team ID.
3. **App Store Connect & Fastlane:**
   - Create App record on [appstoreconnect.apple.com](https://appstoreconnect.apple.com).
   - Generate App Store Connect API Key (`.p8`) for automated deployment.
   - Add GitHub Secrets:
     - `APP_STORE_CONNECT_KEY_ID`
     - `APP_STORE_CONNECT_ISSUER_ID`
     - `APP_STORE_CONNECT_PRIVATE_KEY`
     - `CERTIFICATES_P12` and `PROVISIONING_PROFILE` (base64 encoded).
4. **Google Play Console:**
   - In [play.google.com/console](https://play.google.com/console): create App `UGCULT`.
   - Create Google Cloud Service Account with Play Developer publishing permissions and download JSON key.
   - Add GitHub Secret: `PLAY_STORE_JSON_KEY`.
   - Upload initial signed AAB manually to Internal Testing track once to establish package namespace.
5. **Deploy Admin Web Portal:**
   - Deploy `admin-portal` frontend to Vercel or Cloudflare Pages.
   - Configure environment variables: `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`.

---

## 3. Verification & Quality Gates

| Gate | Requirement | Tool / Method |
|---|---|---|
| **Code Quality** | Zero analyzer warnings & zero custom lint errors | `flutter analyze && dart run custom_lint` |
| **Test Coverage** | > 85% domain & data layer test coverage | `flutter test --coverage` |
| **Security Audit** | Zero exposed creator contacts to unapproved brands | Automated RLS pgTAP tests (`supabase test db`) |
| **Performance** | App launch cold start < 1.5s, 60fps scrolling | Flutter DevTools Performance Overlay & Profile Mode |
| **Crash Free Rate** | > 99.8% crash-free user sessions | Sentry Crash Reporting |
| **Notification Delivery** | 99.5% delivery rate for critical notifications | FCM/APNs delivery logs |

---

## 4. Cross-Document Reference Map

| Decision | Source Doc | Implementing Phase |
|---|---|---|
| Campaign lifecycle: `draft → published → in_progress → completed → archived/cancelled` | PRD §3.7, DB-DESIGN §2 | Phase 1 (schema), Phase 4 (UI) |
| No admin campaign approval — brands publish directly | PRD §3.3 FR-011 | Phase 4 |
| No deadlines | PRD §1.1, DB-DESIGN §3.4 | All phases (removed) |
| No revision cap — unlimited revisions | PRD §3.4 FR-018, DB-DESIGN §2 | Phase 6 |
| Dual payment confirmation | PRD §3.5, API-SPEC §5 | Phase 6 |
| Simplified shipping (2-step handshake) | PRD §3.4 FR-016, DB-DESIGN §3.5 | Phase 5 |
| Photo + video deliverables | PRD §3.2 FR-008, DB-DESIGN §3.2 | Phase 3, Phase 5 |
| Double-blind ratings (7-day reveal) | PRD §3.6 FR-023, API-SPEC §6 | Phase 6 |
| 3-tier glass rendering (A/B/C) | Design.md §3 | Phase 1 |
| English only, RTL-ready infrastructure | PRD header, Design.md §6 | Phase 1 |
| Supabase SMS OTP via Twilio | PRD §3.1 FR-002, API-SPEC §1 | Phase 2 |
| Admin web portal (3 screens) | PRD §6, ARCHITECTURE §1 | Phase 7 |
| 3-tab navigation per role | PRD §5 | Phase 2+ |
| Creator-owned Google Drive video storage | PRD §1, §3.8, ARCHITECTURE §4.3 | Phase 1 (schema), Phase 3 (OAuth/spikes), Phase 5 (upload) |
| Native in-app brand video playback (zero Drive UI) | PRD §3.8.3, ARCHITECTURE §4.3.3, API-SPEC §4.5.3 | Phase 3 (spike), Phase 6 (player) |
| Lossless original video download (100% byte fidelity) | PRD §3.8.4, ARCHITECTURE §4.3.4, API-SPEC §4.5.4 | Phase 6 |
| Google OAuth server-side Vault token encryption | ARCHITECTURE §4.3.5, DB-DESIGN §3.2.1 | Phase 1 (Vault), Phase 3 (Edge Function) |
| Multi-tenant deliverable access isolation | PRD §4 NFR-011, ARCHITECTURE §4.3.6, DB-DESIGN §5 | Phase 1 (RLS), Phase 6 (API) |
