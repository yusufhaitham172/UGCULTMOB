# UGCULT — Mobile Product Requirements Document (PRD)

**Status:** Approved v3.1 (Creator-Owned Google Drive Media Architecture Revision)  
**Target Platforms:** iOS (Primary Target) & Android (Flutter Cross-Platform)  
**Development Host:** Windows 10/11 (PowerShell) with Cloud CI/CD iOS Compilation (`macos-14`)  
**Target Market:** Egypt (B2C Creator ↔ B2B Brand Discovery & Campaign Operations)  
**Backend:** Supabase (PostgreSQL 16, Auth, RLS, Edge Functions) + Firebase (FCM / APNs) + Google Drive API v3 (Creator-Owned Video Storage)  
**Storage Model:** Decoupled Hybrid — Supabase Storage (Avatars, Campaign Covers, Lightweight Portfolios) & Creator-Owned Google Drive (Original High-Bitrate UGC Video Deliverables)  
**Language:** English only for MVP. RTL-ready layout infrastructure preserved for Phase 2 Arabic.  
**Monetization Strategy:** 100% Free for MVP (Liquidity phase); Phase 2 Subscriptions & Posting Fees architected as dormant feature flags.

---

## 1. Product Overview & Vision

**UGCULT Mobile** is a production-grade mobile platform connecting Egyptian UGC (User-Generated Content) creators with emerging and enterprise brands. It transforms the chaotic, informal workflow currently happening over Instagram DMs, WhatsApp, and Facebook groups into a structured, accountable, and transparent mobile experience.

UGCULT is **not** an escrow or direct payment gateway. It is a **directory, campaign management, and reputation engine**. All creator↔brand financial transactions happen off-platform (Instapay, Bank Transfer, Cash), while UGCULT handles:
- Creator discovery & rich video+photo portfolio showcasing
- Mobile-first campaign creation, discovery, and 1-tap applications
- End-to-end content submission (video & photo), review, and unlimited revision workflows
- Double-blind mutual rating (7-day reveal) and off-platform payment dispute auditing
- **Creator-Owned Media Storage:** Creators connect their personal Google Drive accounts to host high-bitrate UGC video deliverables. Our platform stores relationships, metadata, and handles authorization, keeping the platform ultra-lean without warehousing petabytes of raw video.

### 1.1 What UGCULT Does NOT Do (Explicit Exclusions)
- **No payment processing.** UGCULT never touches money. Payments happen off-platform via Instapay, bank transfer, or cash.
- **No campaign pre-approval.** Brands publish campaigns directly. Admin only moderates content violations post-publication.
- **No deadlines.** No application or submission deadlines. A campaign lives until all slots are filled and all creators are paid.
- **No revision limits.** Brands can request unlimited revisions. Creators can withdraw from a campaign if they feel it's abusive.
- **No escrow or payment guarantees.** UGCULT provides a mutual confirmation system and dispute flagging, not financial protection.
- **No centralized raw video warehousing.** UGCULT does NOT accumulate primary multi-terabyte raw video binary storage. High-bitrate campaign deliverables reside inside the creator's connected Google Drive account. From the brand's perspective, this storage architecture is completely invisible.

---

## 2. Target Personas & Tenancy Model

### 2.1 User Roles

| Role | Experience & Scope |
|---|---|
| **Creator** (Mobile App) | Content creator in Egypt. Maintains a public profile showcasing portfolio (video/photo), niche, avatar, social media links, and self-reported follower counts. Browses campaigns freely, applies with pure 1 tap (no pitch note or portfolio selection required), connects personal Google Drive account to host video deliverables, uploads video/photo deliverables, confirms payment receipt, rates brands. |
| **Brand** (Mobile App) | Business owner, marketing manager, or agency. Creates campaigns (published directly, no approval queue), reviews applicants with video/photo previews, approves/rejects, reviews submitted content via native in-app video player (with zero Google Drive UI exposure), downloads original uncompressed videos, confirms payment sent, rates creators. |
| **Admin** (Separate Web Portal) | Platform operator. Views all uploaded media and deletes violations, sees disputes and contacts parties via phone number, suspends user accounts. **Does NOT approve/reject campaigns.** |

### 2.2 Tenancy & Authorization
- Multi-tenant architecture where **Tenant = Individual User**.
- Strict Single Role per registered account (`creator` or `brand`).
- Zero-trust Row-Level Security (RLS) guarantees that sensitive creator contact information (Phone, Instapay Handle, Shipping Address) is completely hidden until a brand explicitly approves that creator's application.

---

## 3. Functional Requirements

### 3.1 Authentication & Onboarding

| FR | Requirement | Details |
|---|---|---|
| **FR-001** | **Role Selection** | Onboarding screen: "I'm a Creator" or "I'm a Brand". Role is immutable upon registration. |
| **FR-002** | **Phone SMS OTP Login** | Phone verification via Supabase Auth built-in SMS OTP (Twilio provider). Egyptian phone validation (`+20` prefix, regex `^01[0125][0-9]{8}$`). This is the **sole login method**. |
| **FR-003** | **Email Collection** | Email collected during profile setup as optional field. Used for account recovery and admin contact only. **Not a login method.** |
| **FR-004** | **Age Attestation** | 18+ Terms of Service checkbox & acknowledgment during registration. |
| **FR-005** | **Push Permission** | Contextual push notification permission prompt after onboarding (not during splash). |
| **FR-006** | **Session Persistence** | Supabase handles automatic JWT token refresh. User stays logged in until explicit logout. No biometric login in MVP. |

### 3.2 Creator Profile & Portfolio

| FR | Requirement | Details |
|---|---|---|
| **FR-007** | **Profile Schema** | Display name, bio, avatar, niche categories (Beauty, Tech, Food, Fashion, Fitness, Lifestyle, Other + freetext), Egyptian governorate, social handles (TikTok, Instagram, YouTube), self-reported follower count & engagement rate, profile completion indicator. |
| **FR-008** | **Portfolio (Video + Photo)** | Native picker from gallery or camera. Client-side video compression (H.264, 720p/1080p, <30MB). On-device thumbnail generation. Photos accepted as-is (JPEG/PNG/WebP). Grid view + fullscreen reel player with caching. **Portfolio accepts both video and photo.** |
| **FR-009** | **PII Privacy Firewall** | Creator contact details (Phone, Instapay handle, Shipping address) are RLS-protected and **never visible** to brands until the brand approves that creator's application. |

### 3.3 Campaign Management (Brand)

| FR | Requirement | Details |
|---|---|---|
| **FR-010** | **Campaign Creation Wizard** | Multi-step mobile wizard with draft auto-save. Fields: Title, category (6 fixed + "Other" with freetext search), description/guidelines, cover image, reference URLs, creator slots needed, physical shipping toggle, compensation model (`gift`/`cash`/`both` with EGP amounts), accepted deliverable types (`video`/`photo`/`both`). |
| **FR-011** | **Direct Publishing** | Brand submits draft → campaign moves directly to `published`. **No admin approval queue.** An immutability confirmation screen warns: "You can't edit this campaign after publishing." Immutability enforced by database trigger on `title`, `description`, `guidelines`, `compensation_type`, `compensation_description`, `cash_amount_egp`, `gift_estimated_value_egp`. |
| **FR-012** | **Campaign Discovery Feed** | Pull-to-refresh, infinite-scroll, filterable feed. Filters: Category, Compensation Type (Cash/Gift/Both), Governorate. Text search across title and brand name. **No deadline filters** (deadlines removed). |

### 3.4 Application & Delivery Workflow

| FR | Requirement | Details |
|---|---|---|
| **FR-013** | **1-Tap Application** | Pure 1-tap application. Creator taps "Apply" on campaign detail and confirms with 1 tap. No pitch note and no portfolio selection attached to the application. Server enforces unique constraint per (campaign, creator). |
| **FR-014** | **Applicant Review & Public Profile** | Brand reviews applicants in list view with: avatar, name, niche, governorate, average rating, and a **"View Creator Profile"** action. Tapping opens the creator's public profile showcasing their full portfolio (video/photo), niche, social media links (TikTok, Instagram, YouTube), self-reported follower count/engagement, and bio. Actions: **Select** or **Reject**. |
| **FR-015** | **Approval & Data Reveal** | Approving a creator moves their status to `approved` and automatically unlocks their shipping/contact data (Phone, Instapay, Shipping Address) to the brand via RLS. |
| **FR-016** | **Simplified Shipping** | If campaign requires physical product: Brand marks **"Product sent"**. Creator marks **"Product received."** No carrier name, no tracking number. Just a 2-step handshake. |
| **FR-017** | **Content Submission** | Creator uploads video/photo deliverables (matching campaign's accepted types) with caption copy and notes for brand. For video deliverables, upload streams directly to creator's connected Google Drive using Google Drive v3 Resumable Upload protocol. System captures Google Drive file ID, checksum, dimensions, duration, and submission timestamp. Photos upload directly to Supabase Storage. **No submission deadline.** |
| **FR-018** | **Review & Revisions** | Brand watches/views submitted content in-app via native Flutter video player (Option B streaming proxy) with zero Google Drive UI exposure. Brand can **Approve** (moves to `content_approved`), **Request Revision** with timestamped feedback notes and optional timecode markers on video, or tap **Download Original** to fetch the lossless master video. **No revision cap.** Unlimited revisions. Creator can **Withdraw** from the campaign at any point. |
| **FR-024** | **Google Drive Account Connection** | Creator connects personal Google Drive via Google OAuth 2.0. App requests strictly non-restricted scope `https://www.googleapis.com/auth/drive.file` (no CASA Tier 2 audit needed). OAuth tokens are exchanged and stored server-side with encryption in Supabase Vault; client never handles refresh tokens. Creator can view connection status, reconnect, or disconnect. |
| **FR-025** | **In-App Brand Video Playback (Option B)** | Video deliverables play directly inside the Flutter app with native controls (play, pause, seek, scrub, fullscreen) backed by a Supabase Edge Function media streaming proxy with Range header support and on-device disk caching (`cached_video_player_plus`). Google Drive branding, web previews, and folder structures are completely hidden. Option D (Cloudflare CDN streaming proxy) is pre-designed as scale fallback. |
| **FR-026** | **Lossless Original Deliverable Download** | Brand can download the original master video file exactly as uploaded by creator (original codec, bitrate, resolution, container) without platform compression or re-encoding. Request is authorized against brand campaign ownership. System prompts brand to archive locally; platform maintains zero raw video storage permanently. |
| **FR-027** | **Pre-Completion Pause & Prompt Auditing** | If a creator deletes a file or disconnects Drive while campaign review is active, system freezes the submission in `submission_unavailable` / `access_revoked`, blocks payment confirmation, and alerts the creator via push notification to restore or reconnect. |

### 3.5 Payment Confirmation & Disputes

| FR | Requirement | Details |
|---|---|---|
| **FR-019** | **Dual Payment Confirmation** | Payment requires BOTH sides to confirm. Brand marks **"I paid"** (selects method: Instapay/Bank Transfer/Cash). Creator marks **"I received payment."** Application reaches `completed` only when BOTH confirm. |
| **FR-020** | **Auto-Dispute Flag** | If brand marks "paid" but creator has NOT confirmed receipt after 72 hours, the application is auto-flagged as `disputed`. Enters admin moderation queue. |
| **FR-021** | **Creator Dispute** | Creator can manually flag "I didn't receive payment" at any time after brand marks paid. Creates a dispute record with reason text. |

### 3.6 Double-Blind Ratings

| FR | Requirement | Details |
|---|---|---|
| **FR-022** | **Mutual Rating Prompt** | Once both sides confirm payment (application reaches `completed`), both receive push notifications to rate each other. 1–5 stars + structured badges (Punctuality, Communication, Content Quality, Payment Reliability) + optional text comment. |
| **FR-023** | **Double-Blind Reveal** | Ratings are **hidden** until BOTH parties submit their review, OR after a **7-day timeout** from completion. Prevents retaliation bias. After reveal, ratings are permanently public on profiles. |

### 3.7 Campaign Lifecycle & Auto-Transitions

| State | Trigger | Description |
|---|---|---|
| `draft` | Brand creates campaign | Campaign is being composed. Editable. Not visible to creators. |
| `published` | Brand confirms publish | Visible on discovery feed. Core fields become immutable (DB trigger). |
| `in_progress` | **Auto:** First creator application is approved | Campaign has active work happening. Still visible on feed if slots remain. |
| `completed` | **Manual:** Brand marks campaign complete | All work is done. Triggers rating prompts for any un-rated completed applications. |
| `archived` | **Auto:** 30 days after `completed` with no activity | Historical record. Hidden from feeds. |
| `cancelled` | **Manual:** Brand cancels at any time | Campaign removed from feed. Active applications notified. |

---

### 3.8 Media Storage Architecture & Product Principles

#### 3.8.1 Locked Product Principles
1. **Creator Drive Custody Forever:** Creators connect their own Google Drive accounts. Raw UGC video deliverables reside in the creator's Google Drive as the permanent source of truth. UGCULT never stores raw video binaries on platform storage under any circumstance—neither during active review nor post-completion.
2. **Invisible Infrastructure to Brands:** Google Drive is an implementation and storage detail. From the brand's perspective, the video behaves as though uploaded directly to UGCULT. Brands review videos in-app via a native video player and never see Google Drive branding, web links, or folder directories.
3. **Lossless Original Downloads & Post-Completion Responsibility:** Brands can download the uncompressed original video as exported by the creator with 100% byte fidelity. Upon deliverable approval and payment confirmation, brands are explicitly prompted: *"Download original deliverable to your local or company storage. UGCULT does not warehouse raw media."* If a creator deletes or moves the file post-completion, the submission is marked `submission_unavailable`.
4. **Pre-Completion Pause & Prompt Policy:** If a creator disconnects Google Drive or deletes the deliverable file while the campaign is actively under review (pre-completion), the workflow is immediately frozen in `submission_unavailable` or `access_revoked`. Payment confirmation is blocked, and high-priority push notifications alert the creator to reconnect or restore the file.
5. **Metadata & Relationship Custody:** Supabase remains the authoritative source for user identity, campaign tenancy, application status, review cycles, and file metadata linkages.

#### 3.8.2 Creator Submission UX State Matrix

```
[Campaign Accepted / Approved]
         │
         ▼
[Initiate Video Submission]
         │
         ├── Google Drive Not Connected? ──► [Prompt Connect Google Drive Modal]
         │                                               │
         │                                               ▼
         │                                     [OAuth 2.0 Web/App Sheet]
         │                                               │
         │                                               ▼
         │                                     [Drive Connected Banner]
         ▼                                               │
[Select Video from Gallery] ◄────────────────────────────┘
         │
         ▼
[Initiate Resumable Session]
         │
         ▼
[Uploading State (Active Chunk Transfer)]
   ├── Progress Indicator (0 - 100%, Transfer Speed, MB remaining)
   ├── Pause / Cancel Action ──► [Upload Cancelled / Resumable Token Preserved]
   ├── Network Drop / Error ──► [Upload Failed State] ──► [Upload Retry Action (Resume Chunk)]
   └── Upload Complete (100% Chunks Stored in Creator's Drive)
         │
         ▼
[Link Submission Record] ──► [Extract File Metadata (ID, size, duration, resolution)]
         │
         ▼
[Submission Created & Linked] ──► [Brand Notification Dispatched]
         │
         ▼ (Post-Submission Health States)
   ├── [Normal / Available]: Video healthy in creator Drive
   ├── [Submission Unavailable]: File deleted or moved by creator in Drive
   └── [Access Revoked]: Creator disconnected Drive or revoked OAuth grant
```

| State | Trigger | UI Presentation | Allowed Actions |
|---|---|---|---|
| `drive_not_connected` | Creator attempts video submission without connected Drive | Warning banner + "Connect Google Drive" button | Launch Google OAuth flow |
| `connecting_drive` | Creator initiates Google OAuth | Full-screen glass modal with spinner + Google authorization sheet | Cancel OAuth |
| `upload_pending` | File selected, initiating resumable session with Drive API | Pulsing glass card: "Preparing secure upload..." | Cancel |
| `uploading` | Active chunked byte transfer directly to Google Drive | Dynamic progress capsule: % complete, transferred MB / total MB | Pause, Cancel |
| `upload_paused` | User paused or low network detected | "Upload paused" badge + progress bar preserved | Resume, Cancel |
| `upload_failed` | Network timeout, socket error, or token failure | Red alert glass badge: "Upload interrupted. Your progress is saved." | Retry (resumes from chunk), Cancel |
| `upload_cancelled` | User voluntarily aborted upload | Clears local session cache; returns to deliverable picker | Re-select file |
| `upload_completed` | All bytes acknowledged by Google Drive API | Green checkmark animation + "Verifying upload..." | Automatic transition |
| `submission_linked` | Metadata written to Supabase `campaign_submissions` | Success card: "Deliverable submitted for brand review" | View submission, Withdraw |
| `submission_unavailable` | File deleted or inaccessible in creator Drive | Amber alert badge: "Video deliverable missing from Drive" | Re-upload deliverable, Contact support |
| `access_revoked` | Creator revoked Google OAuth token | Red alert badge: "Google Drive connection severed" | Reconnect Google Drive |

#### 3.8.3 Brand Native Review & Download Experience
- **Navigation Path:** Campaign Detail → Applicants Hub → Submission Card → In-App Video Player.
- **Player Interface:** Native Flutter video player embedded directly in the submission detail view. Supports play, pause, seek bar with scrub preview, full-screen toggle, and timecode indicator.
- **Revision Markers:** Interactive timecode chips below player (e.g., `00:03 - Blurry label`, `00:15 - Audio clipping`). Tapping a chip seeks video directly to that timecode.
- **Lossless Download Action:** Prominent primary action button: **"Download Original ({file_size} MB)"**.
  - Authorizes brand access via Supabase RLS.
  - Streams or transfers the master uncompressed file with proper MIME headers (`video/mp4`, `video/quicktime`) and sanitized filename (`{campaign_title}_{creator_name}_original.mp4`).
  - Native download progress bar in mobile notification tray / in-app snackbar.

#### 3.8.4 Quality Preservation Guarantee
- **Original Asset Integrity:** The file stored in the creator's Google Drive is the exact, unaltered binary exported by the creator's editing tool/camera.
- **No Platform Re-encoding for Downloads:** The system MUST NOT compress, transcode, downsample, or re-encode the video for the brand's original download.
- **Derivatives Separation:** If lightweight proxies or preview renditions are generated in the future for fast streaming, they must be treated strictly as ephemeral streaming derivatives and must never overwrite or substitute the master download asset.

---

## 4. Non-Functional Requirements

| ID | Category | Requirement |
|---|---|---|
| **NFR-001** | **Performance** | Cold start to interactive < 1.5s. Feed pagination < 250ms. 60fps scroll on mid-range devices. |
| **NFR-002** | **Video Uploads** | Resumable chunked video uploads directly to creator's Google Drive via Google Drive v3 Resumable Upload protocol. Survives 3G/4G network drops with chunk-level resume capability. |
| **NFR-003** | **Push Notifications** | 99.5% delivery SLA via FCM/APNs for critical campaign state changes. |
| **NFR-004** | **Offline** | Basic read cache (last-loaded feed, profile, active jobs) via Riverpod `keepAlive`. "You're offline" banner. No local database. |
| **NFR-005** | **Security** | TLS 1.3, `flutter_secure_storage` for JWT tokens, zero plaintext credentials. OAuth refresh tokens encrypted server-side in Supabase Vault. |
| **NFR-006** | **Authorization** | 100% via PostgreSQL RLS. Application layer is untrusted. Zero-trust access on creator contacts and Drive deliverable metadata. |
| **NFR-007** | **Scalability** | 100,000+ creators, 10,000+ concurrent campaigns. Decoupled media storage avoids accumulating ~5 TB/month of primary raw video binaries on platform storage. |
| **NFR-008** | **Phase 2 Readiness** | Monetization as dormant feature flags. Arabic/RTL as layout-ready infrastructure. |
| **NFR-009** | **Google Drive API Quota Resilience** | Architecture must adhere to Google Drive API project rate limits (12,000 requests/minute) and per-user limits. Resumable uploads bypass application backend bandwidth. Exponential backoff on 429/403 rate-limit responses. |
| **NFR-010** | **Lossless Deliverable Preservation** | Original video deliverable downloaded by brand must have 100% byte fidelity to the creator's uploaded master file (matching checksum, resolution, bitrate, container). |
| **NFR-011** | **Multi-Tenant Deliverable Isolation** | Brand A can ONLY access submissions for Brand A's campaigns. Knowledge of a creator's `google_drive_file_id` by an unauthorized brand or user must result in strict 403 Forbidden access denial. |

---

## 5. Navigation Architecture

```
UGCULT Mobile App
├── Auth & Onboarding
│   ├── Splash Screen
│   ├── Role Selection (Creator / Brand)
│   ├── Phone OTP Verification
│   └── Profile Setup Wizard (includes optional email)
│
├── Creator Experience (3 tabs + bell icon)
│   ├── Tab 1: Discover Campaigns (Search, Filter, Detail, 1-Tap Apply)
│   ├── Tab 2: My Jobs (Applied, Selected, Shipping, Submitted, Completed)
│   ├── Tab 3: Profile (Portfolio Manager, Bio, Ratings, Settings)
│   └── 🔔 Bell icon (top bar): Notification Center
│
├── Brand Experience (3 tabs + bell icon + FAB)
│   ├── Tab 1: My Campaigns (Drafts, Published, In Progress, Completed)
│   ├── Tab 2: Applicants Hub (Review applicants, Review submissions, Mark paid)
│   ├── Tab 3: Profile (Brand info, Ratings, Settings)
│   ├── 🔔 Bell icon (top bar): Notification Center
│   └── ➕ FAB on Tab 1: "New Campaign" → Creation Wizard
│
└── Shared Modals & Flows
    ├── Media Viewer (Video Player + Photo Gallery)
    ├── Application Detail & Timeline Stepper
    ├── Payment Confirmation Sheet
    ├── Dispute Report Sheet
    └── 5-Star Rating & Review Modal
```

---

## 6. Admin Web Portal (Separate Project)

A minimal standalone web application (Next.js or Vite + React) with 3 screens:

| Screen | Purpose | Actions |
|---|---|---|
| **Media Browser** | View all uploaded videos/photos across portfolios and submissions | Flag, delete violations |
| **Disputes List** | View disputed payment applications with both parties' contact info | View phone numbers, mark resolved |
| **User Management** | View all users, filter by role/status | Suspend/unsuspend accounts |

Admin authenticates via Supabase Auth with `admin` role. All admin actions are logged to `audit_logs` table.

---

## 7. Glossary

| Term | Meaning |
|---|---|
| **Creator** | A UGC content creator registered on UGCULT. Never "influencer" or "user" in UI. |
| **Brand** | A business or agency registered on UGCULT. Never "vendor" or "client" in UI. |
| **Campaign** | A project posted by a brand seeking creator-made content. |
| **Spot** | A creator slot in a campaign. Say "spots", never "slots" in UI copy. |
| **Application** | A creator's request to join a campaign. |
| **Deliverable** | Video or photo content submitted by a creator to fulfill a campaign. |
| **Match** | The moment a creator is selected for a campaign (or content is approved). Triggers the signature blend animation. |
