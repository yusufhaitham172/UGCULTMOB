# UGCULT — Production Mobile System Architecture

**Document:** System Architecture Specification  
**Platform:** Flutter Mobile (iOS Primary Target & Android Cross-Platform)  
**Development Host:** Windows 10 / 11 (PowerShell)  
**CI/CD Compilation:** Automated Cloud macOS Runners (`macos-14`)  
**Backend:** Supabase Serverless (PostgreSQL 16) + Firebase (FCM / APNs) + Google Drive API v3 (Creator-Owned Storage)  
**Storage Architecture:** Decoupled Hybrid — Supabase Storage (Avatars, Covers, Portfolios) & Creator-Owned Google Drive (Original High-Bitrate UGC Video Deliverables)  
**Status:** Approved v3.1 (Creator-Owned Google Drive Media Architecture Revision)  
**Changes from v3.0:** Introduced decoupled media storage architecture; creator Google Drive integration for campaign video deliverables; in-app brand video playback broker; lossless original download pipeline; Google OAuth 2.0 server-side token security model; zero-trust multi-tenant media authorization; deep comparative playback options analysis.

---

## 1. High-Level Architecture Diagram

```
                             ┌────────────────────────────────────────────────────────┐
                             │                  UGCULT Flutter App                    │
                             │                (iOS & Android Client)                  │
                             └────────────┬──────────────┬──────────────┬─────────────┘
                                          │              │              │
                ┌─────────────────────────┘              │              └─────────────────────────┐
                │ (HTTPS / REST / WSS)                   │ (Direct Resumable Upload)              │ (FCM Push)
                ▼                                        ▼                                        ▼
   ┌─────────────────────────┐              ┌─────────────────────────┐              ┌─────────────────────────┐
   │  Supabase API Gateway   │              │   Google Drive API v3   │              │   Firebase Cloud Msg    │
   │   (PostgREST / Auth)    │              │  (Creator-Owned Account)│              │    (FCM / APNs Push)    │
   └────────────┬────────────┘              └────────────┬────────────┘              └────────────┬────────────┘
                │                                        │                                        │
                ▼                                        │                                        │
   ┌─────────────────────────┐                           │                                        │
   │   PostgreSQL 16 Engine  │                           │                                        │
   │   - Row-Level Security  │                           │                                        │
   │   - Database Triggers   │◄──────────────────────────┼──────────────────┐                     │
   │   - Custom RPC Functions│  (Metadata, File IDs,     │                  │                     │
   └────────────┬────────────┘   Checksums, Status)      │                  │                     │
                │ (Database Webhooks / pg_net)           │                  │                     │
                ▼                                        │                  │                     │
   ┌─────────────────────────┐                           │                  │                     │
   │ Supabase Edge Functions │                           │                  │                     │
   │ (Deno / TypeScript)     │                           │                  │                     │
   │ - media-broker/streamer │◄──────────────────────────┘                  │                     │
   │ - drive-oauth-handler   │  (Authorized Playback Stream & Downloads)    │                     │
   │ - submission-reviewer   │                                              │                     │
   │ - dispute-handler       │                                              │                     │
   │ - push-dispatcher       │──────────────────────────────────────────────┼─────────────────────┘
   │ - rating-revealer (cron)│                                              │
   │ - auto-archiver (cron)  │                                              │
   │ - payment-timeout (cron)│                                              │
   └────────────┬────────────┘                                              │
                │                                                           │
                ▼                                                           ▼
   ┌─────────────────────────┐                                 ┌─────────────────────────┐
   │   Google Cloud OAuth    │                                 │   Supabase Storage S3   │
   │  (drive.file Scope)     │                                 │  (Avatars, Covers,      │
   │  (Server Token Exchange)│                                 │   Portfolios, Photos)   │
   └─────────────────────────┘                                 └─────────────────────────┘

                             ┌───────────────────────────────────┐
                             │    Admin Web Portal (Separate)    │
                             │    Next.js or Vite + React        │
                             │    - Media Browser (flag/delete)  │
                             │    - Disputes List (contact info) │
                             │    - User Management (suspend)    │
                             └─────────────────┬─────────────────┘
                                               │
                                               ▼
                                  (Same Supabase Backend via RPC/REST)
```

---

## 2. Flutter Mobile Client Architecture

The mobile application follows **Clean Architecture** organized with a **Feature-First** structure.

### 2.1 Layer Breakdown

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp configuration & theme setup
│   ├── router/                    # GoRouter configuration & route guards
│   └── theme/                     # Brand typography, palette & component styling
├── core/
│   ├── constants/                 # App constants, Supabase keys, endpoints
│   ├── errors/                    # Failure & Exception classes
│   ├── network/                   # Connectivity monitor & Supabase client wrapper
│   ├── storage/                   # Secure storage (tokens) & local key-value store
│   ├── utils/                     # Formatters, media compressors, date helpers
│   └── widgets/                   # Design system atoms & molecules (Buttons, Inputs, Cards)
└── features/
    ├── auth/                      # Phone OTP login, Role onboarding
    ├── campaigns/                 # Feed, Detail, Creation Wizard, Filters
    ├── applications/              # Application submission, Status tracking, Applicant review
    ├── submissions/               # Resumable video/photo upload, Video player, Revision feedback
    ├── ratings/                   # 5-Star rating dialog, Badges, Double-blind reveal
    ├── payments/                  # Dual payment confirmation, Dispute flagging
    ├── profile/                   # Creator portfolio (video+photo), Brand profile, Media picker
    └── notifications/             # In-app notification center, FCM handlers
```

Inside each feature module, three distinct layers are enforced:
1. **Domain Layer (Pure Dart):**
   - **Entities:** Immutable business models (`Campaign`, `CreatorProfile`, `Submission`).
   - **Value Objects:** Strongly typed identifiers, status enums (`CampaignStatus`, `CompensationType`, `DeliverableType`).
   - **Repository Interfaces:** Abstract contracts defining required operations.
2. **Data Layer:**
   - **DTOs / Models:** JSON serialization with `freezed` and `json_annotation`.
   - **Data Sources:** Direct integration with `SupabaseClient` and Riverpod cache.
   - **Repository Implementations:** Map database rows to Domain Entities, manage in-memory caching.
3. **Presentation Layer:**
   - **Riverpod State Notifiers:** Manage UI state using `AsyncValue` (`AsyncLoading`, `AsyncData`, `AsyncError`).
   - **Screens & Widgets:** Declarative UI widgets subscribing to Riverpod providers.

---

## 3. State Management & Data Flow (Riverpod 2.x)

```
[UI Widget (ConsumerWidget)]
        │
        ▼ (Calls intent/method)
[Riverpod StateNotifier / AsyncNotifier]
        │
        ▼ (Executes Domain UseCase / Repo)
[Repository Implementation]
        │
        ├──► [Riverpod Cache (keepAlive)]  ──► (Returns cached data for offline display)
        │
        └──► [Supabase Client / PostgREST]  ──► (Network call with RLS token)
                    │
                    ▼ (Response)
[DTO to Domain Entity Mapper]
        │
        ▼ (Yields new State)
[StateNotifier updates AsyncValue]
        │
        ▼ (Re-renders UI)
[UI Widget reflects latest Data / Loading / Error state]
```

### 3.1 Caching Strategy (No Local Database)
- **Riverpod `keepAlive`:** Key providers (campaign feed, user profile, active jobs) use `keepAlive` to retain data in memory across navigations.
- **`cached_network_image`:** Images and thumbnails cached to disk automatically.
- **`cached_video_player_plus`:** Video content cached to disk on first play.
- **Offline behavior:** When offline, cached data is displayed as read-only. A connectivity banner shows "You're offline. Some features are unavailable." Interactive actions (apply, submit, approve) are disabled.

---

## 4. Media & Content Pipeline (Decoupled Video + Platform Assets)

UGCULT implements a **Decoupled Media Storage Model**:
- **Creator Portfolio Videos & Photos:** Lightly compressed and stored in Supabase Storage (`portfolios` bucket) with public CDN edge caching.
- **Campaign Photo Deliverables:** Uploaded directly to Supabase Storage (`submissions` bucket).
- **Campaign UGC Video Deliverables:** Stored directly inside the **creator's connected Google Drive account**. The raw, full-bitrate master files remain in creator custody, while UGCULT acts as the metadata index, authorization layer, in-app playback broker, and lossless download gateway.

---

### 4.1 Creator Portfolio Video Pipeline (Platform Managed)
```
[Camera / Gallery Selection]
        │
        ▼
[On-Device Video Compression (video_compress)]
  - Transcodes to H.264 / AAC 720p / 1080p
  - Targets bitrate ~2.5 Mbps (< 25MB typical file size)
        │
        ▼
[Local Video Thumbnail Generation]
  - Generates WEBP/JPEG preview thumbnail
        │
        ▼
[Direct Resumable Upload (Supabase Storage + Tus Protocol)]
  - Chunked uploads with resume token saved locally
  - Auto-resumes from last confirmed chunk on network drop
        │
        ▼
[Postgres Row Insert with Supabase Storage URL]
```

---

### 4.2 Photo Pipeline (Portfolios & Deliverables)
```
[Camera / Gallery Selection]
        │
        ▼
[Optional: Client-side resize if > 2048px]
  - Targets JPEG quality 85%
        │
        ▼
[Direct Upload (Supabase Storage)]
  - Single request upload (no Tus needed for photos)
        │
        ▼
[Postgres Row Insert with Storage URL]
```

---

### 4.3 Creator-Owned Google Drive Campaign Video Pipeline

#### 4.3.1 Conceptual Architecture & Responsibilities Breakdown

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                   UGCULT Flutter App                                   │
└──────────────────┬─────────────────────────────────────────────────┬───────────────────┘
                   │                                                 │
                   │ 1. Initiate Upload Session                      │ 3. Direct Binary Upload
                   │    (Authorized with Supabase JWT)               │    (Resumable Chunks)
                   ▼                                                 ▼
┌──────────────────────────────────────┐            ┌────────────────────────────────────┐
│       Supabase Backend Gateway       │            │        Google Drive API v3         │
│  (PostgREST, Auth, Edge Functions)   │            │   (Creator's Personal Account)     │
├──────────────────────────────────────┤            ├────────────────────────────────────┤
│ RESPONSIBILITIES:                    │            │ RESPONSIBILITIES:                  │
│ • User Identity & Role Auth          │            │ • Primary storage for raw video    │
│ • Campaign & Application Tenancy     │            │ • Chunked resumable byte storage   │
│ • Secure OAuth Token Vault (AES-256) │            │ • Zero platform storage cost       │
│ • Submission Metadata Custody        │            │ • Retains creator's original file  │
│   (file_id, size, duration, status)  │            │ • Source of truth for raw download │
│ • Multi-Tenant Access Authorization  │            │                                    │
│ • In-App Playback Broker / Streamer  │            │                                    │
│ • Lossless Download Authorization    │            │                                    │
└──────────────────┬───────────────────┘            └─────────────────┬──────────────────┘
                   │                                                  │
                   │ 2. Issues Upload Session URI                     │ 4. Verifies Checksum &
                   │    using Creator's Refresh Token                 │    File ID Linkage
                   └──────────────────────────────────────────────────┘
```

#### 4.3.2 Classification of Architectural Decisions

To prevent ambiguity, all technical facets of this integration are classified into four explicit categories:

| Category | Definition | Key Items |
|---|---|---|
| **LOCKED DECISIONS** | Product principles and architectural boundaries that are firmly decided and non-negotiable. | • **Creator Drive Custody Forever:** Creator's Google Drive is the permanent source of truth; zero raw video storage on platform ever (even post-completion).<br>• **Brand Storage Invisibility:** Google Drive is 100% invisible to brands; in-app native video player only.<br>• **Lossless Original Downloads:** Brands download the uncompressed master video with 100% byte fidelity.<br>• **Option B Playback for MVP:** Supabase Edge Function media proxy + on-device disk caching (`cached_video_player_plus`).<br>• **Option D Scale Fallback:** Cloudflare CDN streaming proxy pre-designed as scale fallback if egress exceeds budget.<br>• **Pre-Completion Pause & Prompt:** Disconnect/deletion during review pauses workflow, freezes payment, and prompts creator to reconnect/restore.<br>• **Post-Completion Responsibility:** If creator deletes file post-completion, asset is marked unavailable; brands are prompted to download locally upon approval.<br>• **OAuth Scope:** Strictly locked to `https://www.googleapis.com/auth/drive.file` (Non-sensitive/Sensitive tier; zero CASA Tier 2 assessment needed). |
| **PROPOSED DESIGN** | Concrete implementation mechanics supporting the locked decisions. | • Client-to-Drive direct chunked upload via Google Drive v3 Resumable Upload protocol.<br>• Server-side Google OAuth 2.0 exchange with refresh token encrypted in Supabase Vault.<br>• Background mobile download manager (`flutter_downloader`) with byte-range resumption.<br>• Periodic cron auditor (`submission-storage-auditor`) monitoring file accessibility. |
| **RESOLVED SPIKES** | Architectural unknowns definitively answered via API specifications and locked decisions. | • **SPK-001 (Resumable Upload):** Fully supported natively in Flutter via chunked `PUT` with `Content-Range`.<br>• **SPK-002 (Range Requests):** Drive API supports HTTP 206 `alt=media`; normalized via Edge Proxy.<br>• **SPK-003 (Virus Interstitial):** Programmatic API requests with OAuth Bearer bypass the HTML warning entirely.<br>• **SPK-005 (Google Verification):** `drive.file` is non-restricted; requires standard brand verification only.<br>• **Permanent Custody:** Locked as Creator Drive Forever (zero platform warehousing). |
| **TECHNICAL RISKS** | Active engineering vulnerabilities with locked mitigation strategies. | • **RSK-001 (File Deletion):** Mitigated by Pause & Prompt (pre-completion) and Brand Download Prompt (post-completion).<br>• **RSK-002 (OAuth Revocation):** Mitigated by `access_revoked` state and payment freeze.<br>• **RSK-003 (Quota Throttling):** Mitigated by exponential backoff, client disk caching, and Option D fallback.<br>• **RSK-004 (Edge Bandwidth):** Mitigated by disk caching and Option D threshold transition. |

---

#### 4.3.3 The In-App Video Playback Dilemma & Options Evaluation

##### The Core Technical Reality
A Google Drive file is fundamentally an object in a personal cloud drive, not a native CDN video asset.
We must distinguish between five technical concepts:
1. **Google Drive Web Viewer (`/file/d/{id}/preview`):** An HTML iframe that renders Google's web player, controls, pop-out links, and branding. **Strictly rejected by product requirements.**
2. **Google Drive API File Download (`alt=media`):** Binary download endpoint. Requires an `Authorization: Bearer {token}` header. Supports HTTP Range requests (`206 Partial Content`), but is throttled by Google API quotas.
3. **Direct Media Playback:** Flutter's video player making direct HTTP range requests to Google Drive's media endpoint using an ephemeral token.
4. **Application-Controlled Media Proxying:** Flutter streams from a Supabase Edge Function, which authenticates to Google Drive, fetches byte ranges, and pipes them to Flutter with proper `Content-Type: video/mp4` and `Accept-Ranges: bytes`.
5. **Derivative / Streaming CDN Layer:** A separate transcoding or CDN pipeline (e.g., Cloudflare Stream / Fastly) that generates a lightweight streaming proxy while leaving the original master in Google Drive.

##### Detailed Comparison of Architectural Options

| Evaluation Dimension | Option A: Direct Client-to-Drive (`Flutter → Drive`) | Option B: Backend Media Proxy (`Flutter → Edge → Drive`) [Recommended Base] | Option C: Temporary Google Media URL | Option D: Drive Source + Lightweight CDN Streaming Proxy | Option E: Drive Staging + Platform Storage for Approved |
|---|---|---|---|---|---|
| **Architecture** | Flutter passes OAuth Bearer token directly to `googleapis.com/drive/v3/files/{id}?alt=media`. | Flutter calls Supabase Edge Function with JWT; Edge Function streams from Drive with Creator token. | Backend calls Drive API to generate a public/presigned URL and sends it to Flutter. | Raw video in Drive; Edge Function creates lightweight HLS/720p derivative cached on Cloudflare CDN. | Creator uploads to Drive; once brand clicks "Approve", file is copied to Supabase Storage. |
| **User Experience (Brand)** | Native player, but initial buffer latency can reach 3–6s; seek stutter on 100MB+ files. | Native player, transparent to brand; low initial latency if Edge Function is region-proxied. | Native player, fast buffering if URL allows direct byte streaming without auth. | **Optimal**: Zero-latency HLS adaptive bitrate streaming, instant scrub/seek. | Fast playback post-approval; pre-approval playback relies on Option A or B. |
| **Cost Profile** | **Lowest**: Zero platform compute or egress bandwidth cost. | **High Risk**: Supabase Edge Function egress bandwidth charges for all playback (5 TB/mo = $450–$1,000/mo). | Low: Direct Google bandwidth, minimal backend cost. | **Moderate**: ~$5/TB CDN bandwidth + minimal one-time transcoding cost. | Moderate storage cost: Stores only approved files (~10–20% of total submissions). |
| **Scalability** | Poor: Hits Google Drive API per-user and per-IP rate limits rapidly under concurrent brand reviews. | Moderate: Edge Functions scale horizontally, but outbound bandwidth saturates cloud limits. | Poor: Google Drive API does not support S3-style presigned URLs without public sharing. | **High**: CDN caches segments globally; eliminates 95% of traffic to Google Drive API. | High: Approved assets served from scalable S3 CDN; eliminates Drive dependency post-review. |
| **Security & Isolation** | **Critical Vulnerability**: Exposes creator's Google OAuth access token to the Brand's mobile device! | **Strict Zero-Trust**: Brand only presents Supabase JWT. Google tokens stay in server Vault. | High Risk: Requires making Drive file public ("anyone with link") or sharing Google account access. | **Strict Zero-Trust**: Signed CDN tokens tied to Supabase JWT; zero Google token exposure. | **Strict Zero-Trust**: RLS enforced on both Drive staging and Supabase Storage S3. |
| **Google API Limitations** | Frequent 403 RateLimitExceeded on high-frequency seeking; files >100MB trigger virus warning. | Edge function can handle virus scan confirmation parameters (`confirm=xxx`) programmatically. | Google Drive API has no native presigned URL mechanism for unauthenticated direct media stream. | Isolates Drive API: Drive is read once to generate CDN stream, eliminating repeated API hits. | Isolates Drive API: One-time copy operation; zero ongoing API calls during brand playback. |
| **Implementation Complexity** | Low code, but high Flutter video_player configuration complexity (custom HTTP headers). | Moderate: Requires streaming Deno Edge Function with HTTP Range header forwarding. | High / Impractical: Works against Google Drive's security model. | Moderate-High: Requires integrating Cloudflare Stream or worker caching proxy. | Moderate: Requires background worker to transfer file from Drive to S3 on approval. |
| **Video Playback Reliability** | Low-Medium: Inconsistent range request support across different Android/iOS player engines. | High: Edge function normalizes byte ranges, handles chunk buffering, and injects clean headers. | Low: Prone to sudden URL expiration and Google cookie challenges. | **Highest**: Production-grade HLS streaming across all mobile devices and networks. | **Highest**: Standard S3 direct byte streaming with CDN edge caching. |
| **Original-Quality Downloads** | Works via direct download, but exposes creator token or requires public link. | **Clean**: Edge function streams original byte stream directly to brand with sanitized filename. | High risk of virus scan interstitial HTML page replacing video download. | **Preserved**: Download button fetches original from Google Drive; CDN handles playback only. | **Preserved**: Original copied losslessly to S3, or downloaded from Drive. |
| **Storage Implications** | Zero platform storage. | Zero platform storage. | Zero platform storage. | Zero raw platform storage (ephemeral CDN cache only). | Low platform storage (only approved final deliverables, ~0.5 TB/mo). |

##### Architectural Recommendation & Phased Fallback Strategy
1. **Primary Target for MVP Spike (Option B — Backend Media Proxy):**
   - Maintain zero platform storage.
   - Flutter calls `/functions/v1/submission-playback?submission_id={id}` with the Brand's Supabase JWT.
   - The Edge Function validates that the Brand owns the Campaign, retrieves the Creator's encrypted refresh token from PostgreSQL, obtains a short-lived Google access token, and proxies the stream from `https://www.googleapis.com/drive/v3/files/{id}?alt=media`.
   - The Edge Function handles `Range` request forwarding (`bytes=start-end`) and appends `confirm=t` to bypass the 100MB+ virus scan warning.
2. **Fallback / Scale Architecture (Option D — Drive Source + CDN Streaming Derivative):**
   - If Option B proves cost-prohibitive in egress bandwidth ($400+/month) or produces high seek latency on Egyptian 4G networks, implement Option D:
   - When a creator submits a video, a lightweight background Edge Function generates a low-bitrate 720p HLS proxy cached on Cloudflare Stream/R2.
   - The brand watches the ultra-fast HLS proxy in-app.
   - When the brand taps "Download Original", the master uncompressed 1080p/4K file is streamed directly from the creator's Google Drive.

---

#### 4.3.4 Lossless Original Video Download Pipeline

The product requires that the brand receives the exact master binary uploaded by the creator, without downscaling, bitrate reduction, or container conversion.

```
[Brand Taps "Download Original" Button]
                    │
                    ▼
[Flutter Client Issues Authenticated Request]
  GET /functions/v1/submission-download-original?submission_id={id}
  Headers: Authorization: Bearer {Brand_Supabase_JWT}
                    │
                    ▼
[Supabase Edge Function: download-broker]
  ├── Step 1: Validates Brand Tenancy (Brand ID owns Campaign associated with Submission)
  ├── Step 2: Checks Submission Status (must be in 'content_submitted', 'revision_requested', 'content_approved', 'completed')
  ├── Step 3: Retrieves Creator's Google Refresh Token from secure Vault
  ├── Step 4: Obtains Google Access Token (cached in memory if valid)
  ├── Step 5: Queries Drive API Metadata to verify file integrity & checksum
  └── Step 6: Initiates Media Fetch from Drive API:
              GET https://www.googleapis.com/drive/v3/files/{file_id}?alt=media&confirm=t
                    │
                    ▼
[Streaming Response Piped Directly to Client]
  Headers:
    Content-Type: video/mp4 (or original MIME)
    Content-Disposition: attachment; filename="{sanitized_campaign}_{creator}_original.mp4"
    Content-Length: {exact_file_size_bytes}
    Accept-Ranges: bytes
                    │
                    ▼
[Flutter Native Mobile Download Manager]
  - Streams directly to device file system (Downloads directory / Camera Roll)
  - Displays persistent notification progress bar
  - Validates downloaded file size against metadata
```

##### Handling Failure Scenarios & Edge Cases
1. **Large Files (100MB – 2GB+):**
   - Direct memory buffering in the Edge Function is prohibited; the response body must be piped as a `ReadableStream` directly from the Google Drive fetch response to the client response to maintain memory usage < 32MB.
   - Mobile client uses `flutter_downloader` or `dio` with chunk-to-disk streaming to prevent out-of-memory crashes on mid-range Android/iOS devices.
2. **Creator Revoked Access or Disconnected Drive:**
   - If Google Drive returns `401 Unauthorized` or `invalid_grant`, the Edge Function updates `campaign_submissions.drive_upload_status = 'access_revoked'`.
   - Returns HTTP `409 Conflict` with error code `CREATOR_STORAGE_DISCONNECTED`.
   - In-app UI prompts brand: "Creator storage connection temporarily interrupted. Creator has been notified to re-authorize."
   - Sends priority push notification to creator: "Please re-connect your Google Drive to finalize your deliverable submission."
3. **Creator Deleted File from Drive:**
   - If Google Drive returns `404 Not Found`, updates `campaign_submissions.drive_upload_status = 'missing'`.
   - Returns HTTP `410 Gone` with error code `DELIVERABLE_FILE_MISSING`.
   - Prompts creator to restore the file or re-upload.

---

#### 4.3.5 Google OAuth 2.0 Security Architecture & Token Governance

```
[Creator Mobile App]            [Supabase Backend]            [Google OAuth 2.0]
         │                               │                             │
         │ 1. Request Auth URL           │                             │
         ├──────────────────────────────►│                             │
         │                               │ 2. Generate State & PKCE    │
         │ 3. Return Google Auth URL     │                             │
         │◄──────────────────────────────┤                             │
         │                               │                             │
         │ 4. Open Google OAuth Sheet    │                             │
         ├───────────────────────────────┼────────────────────────────►│
         │                               │                             │
         │ 5. User Grants Permission (`drive.file`)                    │
         │◄──────────────────────────────┼─────────────────────────────┤
         │    (Returns Auth Code + State)│                             │
         │                               │                             │
         │ 6. Submit Auth Code           │                             │
         ├──────────────────────────────►│                             │
         │                               │ 7. Exchange Code for Tokens │
         │                               ├────────────────────────────►│
         │                               │                             │
         │                               │ 8. Returns Access + Refresh │
         │                               │◄────────────────────────────┤
         │                               │                             │
         │                               │ 9. Encrypt Refresh Token    │
         │                               │    Store in Vault / DB      │
         │ 10. Return Connection Success │                             │
         │     (email, connected_at)     │                             │
         │◄──────────────────────────────┤                             │
```

##### Critical Security Rules
1. **Least-Privilege OAuth Scope:**
   - We request **ONLY**: `https://www.googleapis.com/auth/drive.file`.
   - **Why this matters:** This scope grants read/write access **strictly to files and folders created by UGCULT**. It does **NOT** grant access to the creator's personal photos, documents, or other folders.
   - Protects creator privacy and significantly simplifies Google OAuth App Verification requirements.
2. **Client Token Isolation:**
   - **THE FLUTTER CLIENT NEVER RECEIVES REFRESH TOKENS OR CLIENT SECRETS.**
   - All token exchanges occur server-side inside Supabase Edge Functions.
   - The Flutter client only receives confirmation metadata: `{ connected: true, google_email: "creator@gmail.com", connected_at: "..." }`.
3. **Token Storage & Encryption:**
   - Refresh tokens are stored in the PostgreSQL database in an encrypted format using Supabase Vault (or `pgcrypto` with AES-256-GCM using an encryption key held in Supabase secrets).
4. **Token Revocation & Disconnect:**
   - Creator can disconnect at any time from Profile → Storage Settings.
   - The backend calls `https://oauth2.googleapis.com/revoke?token={refresh_token}` to revoke Google access and deletes the local token record.
   - If active campaign submissions rely on that Drive, a warning modal alerts the creator: "You have 2 active campaign submissions. Disconnecting Google Drive will pause your review process."

---

#### 4.3.6 Authorization & Zero-Trust Multi-Tenant Permission Model

We strictly reject making creator files publicly accessible with `"Anyone with the link can view"` permissions.

```
                    ┌───────────────────────────────────┐
                    │      Brand A (JWT in Request)     │
                    └─────────────────┬─────────────────┘
                                      │
                                      ▼
                    ┌───────────────────────────────────┐
                    │   Supabase Authorization Check    │
                    ├───────────────────────────────────┤
                    │ SELECT 1 FROM campaign_submissions s
                    │ JOIN campaign_applications a ON a.id = s.application_id
                    │ JOIN campaigns c ON c.id = a.campaign_id
                    │ WHERE s.id = :requested_submission_id
                    │   AND c.brand_id = auth.uid()     │
                    └─────────────────┬─────────────────┘
                                      │
                      ┌───────────────┴───────────────┐
                      │                               │
             MATCH FOUND (Authorized)         NO MATCH (Tenant Mismatch)
                      │                               │
                      ▼                               ▼
      ┌───────────────────────────────┐   ┌───────────────────────────────┐
      │ Fetch Creator Token & Stream  │   │  HTTP 403 FORBIDDEN           │
      │ Video from Google Drive API   │   │  (Log security violation)     │
      └───────────────────────────────┘   └───────────────────────────────┘
```

- **Cross-Brand Leak Prevention:** Even if Brand A discovers the `google_drive_file_id` belonging to Creator Submission B (for Brand B), Brand A cannot stream or download it through the platform because the authorization query checks database campaign ownership.
- **Direct Drive Link Obfuscation:** The raw Google Drive file ID and web links are never exposed in brand-facing API payloads. The brand client only receives internal UUIDs (`submission_id`).

---

#### 4.3.7 Scaling, Quota Economics & Cost Modeling

##### Scale Profile
- Target Creator Base: **~5,000 active creators**
- Monthly Submissions: **~10+ videos per creator per month**
- Monthly Video Volume: **~50,000+ new video submissions / month**
- Average File Size: **~100 MB**
- New Video Data: **~5 TB+ / month**

##### Storage Cost Avoidance
- Storing 5 TB of new video data per month on platform S3 storage accumulates to **60 TB/year**.
- At standard S3 storage pricing (~$0.023/GB/month), year 1 cumulative storage alone would cost **~$8,000 – $12,000/year**, scaling continuously.
- **The Creator-Owned Google Drive architecture reduces primary video storage costs to $0.**

##### Google Drive API Quota Engineering
- **Project-Level Quotas:** Google Drive API v3 provides a default quota of **12,000 requests per minute per project** and **20,000 requests per 100 seconds per user**.
- **Upload Quota Impact:** Since uploads occur directly from the mobile client to the Google Drive upload URI, uploads consume minimal platform API quota (1 call to initiate session + 1 call to verify metadata). 50,000 uploads/month = ~100,000 API calls/month, which is negligible (< 3 requests/minute).
- **Playback & Download Quota Impact:**
  - A brand reviewing a video generates 1–5 range requests per viewing session.
  - At 50,000 submissions reviewed 3 times each = 150,000 review sessions/month = ~450,000 API calls/month.
  - Peak rate: ~10 concurrent brands reviewing videos = ~50 requests/minute (well below the 12,000 req/min project ceiling).
- **Rate-Limit Resilience:** Edge Functions implement standard exponential backoff with jitter on HTTP `429 Too Many Requests` or `403 userRateLimitExceeded`.

##### Bandwidth Egress Risk Analysis
- **The Hidden Cost:** While storage is free, proxying 5 TB/month of video data through Supabase Edge Functions (Option B) will incur cloud egress bandwidth costs (typically $0.09/GB on AWS/Supabase = **~$450/month per 5 TB**).
- **Optimization Strategy:**
  - Leverage on-device caching via `cached_video_player_plus`: Brand only streams the video once; repeated reviews play from local device disk cache.
  - If egress bandwidth costs threaten operating margins at 5,000 users, execute the pre-designed transition to **Option D (Lightweight HLS Proxy on Cloudflare Stream/Workers)**, which reduces bandwidth costs by ~80%.

---

### 4.4 Media Playback & In-App Player UX
- **Video Playback Component:** High-performance via `cached_video_player_plus`. Local disk caching on device. Pre-buffering for zero-latency scrolling.
- **Photo Playback Component:** `cached_network_image` with disk caching and shimmer placeholder.
- **Timecode-Pinning:** Interactive revision feedback chips synchronized with video player controller. Tapping seeks directly to target timecode.

---

## 5. Push Notification & Event Dispatching Architecture

```
[Database Event (e.g. Application Status changed to 'approved')]
        │
        ▼
[Postgres Database Trigger / pg_net Webhook]
        │
        ▼
[Supabase Edge Function: 'push-dispatcher']
        │
        ├── Queries Creator/Brand FCM device tokens from `user_fcm_tokens` table
        ├── Constructs notification payload (English only)
        └── Dispatches to Firebase Cloud Messaging (FCM HTTP v1 API)
                    │
                    ▼
          ┌───────────────────┐
          │   FCM / APNs      │
          └─────────┬─────────┘
                    │
                    ▼
          [User Mobile Device]
                    │
                    ├── If Foreground: `flutter_local_notifications` heads-up banner
                    └── If Background / Terminated: System Tray Notification
                              │
                              ▼ (User Taps Notification)
                    [Deep Link Router (GoRouter)]
                    Navigates directly to relevant screen
```

### 5.1 Notification Events

| Event | Recipient | Notification |
|---|---|---|
| Creator applies to campaign | Brand | "New application from {creator_name} for {campaign_title}" |
| Brand approves creator | Creator | "You've been selected for {campaign_title}!" |
| Brand rejects creator | Creator | "Your application for {campaign_title} was not selected" |
| Brand marks product sent | Creator | "Product shipped for {campaign_title}" |
| Creator submits deliverable | Brand | "New submission from {creator_name} for {campaign_title}" |
| Brand requests revision | Creator | "Revision requested for {campaign_title}. See feedback." |
| Brand approves deliverable | Creator | "Your content for {campaign_title} has been approved!" |
| Brand marks payment sent | Creator | "Payment sent for {campaign_title}. Please confirm receipt." |
| Creator disputes payment | Brand + Admin | "Payment dispute filed for {campaign_title}" |
| Both ratings submitted | Both | "Your ratings for {campaign_title} are now visible" |

---

## 6. Security Architecture & Zero-Trust RLS

1. **Token Management:**
   - JWT tokens stored in `FlutterSecureStorage` (iOS Keychain, Android EncryptedSharedPreferences).
   - Supabase handles automatic token refresh. No biometric lock in MVP.
2. **Network Security:**
   - HTTPS with TLS 1.3 encryption.
   - Certificate pinning for Supabase API requests.
3. **Database-Level Zero-Trust Access Control:**
   - **Creator PII Isolation:** Phone, Instapay handles, shipping addresses in `creator_private_contacts`.
   - **RLS Rule:** Brand can ONLY access PII if they have an `approved` (or later) application with that creator.
4. **Campaign Immutability Trigger:**
   - PostgreSQL `BEFORE UPDATE` trigger prevents mutation of core campaign fields once `status IN ('published', 'in_progress')`.

---

## 7. CI/CD & Deployment Pipeline

```
[Windows Workstation (Dart / Flutter)]
  ├── Local Hot-Reload & Debugging (Chrome / Windows / Android)
  ├── Static Code Analysis (`flutter analyze`)
  └── Automated Local Tests (`flutter test`)
        │
        ▼ (Git Push / PR)
[GitHub Actions Workflow]
  ├── Step 1: Static Analysis (`flutter analyze` + `custom_lint`)
  ├── Step 2: Automated Unit & Widget Tests (`flutter test --coverage`)
  ├── Step 3: Supabase Schema & RLS Test Suite (`supabase test db`)
  ├── Step 4: Build Release Binaries
  │     ├── Android: `flutter build appbundle --release` (on ubuntu-latest)
  │     └── iOS: `flutter build ipa --release` (on macos-14 Apple Silicon runner)
  └── Step 5: Fastlane Distribution
        ├── Android: Google Play Console (Internal Testing / Production)
        └── iOS: Apple App Store Connect (TestFlight / App Store)
```

---

## 8. Scalability & Operational Architecture

| System Component | Strategy |
|---|---|
| **PostgreSQL Database** | Read replicas for discovery queries; connection pooling via Supavisor; B-tree and GIN indexes on search filters. |
| **Media & Assets** | Supabase Storage backed by S3/Cloudflare CDN edge caching. |
| **API Load** | PostgREST auto-scales with connection pooling; Edge Functions on Deno V8 isolate infrastructure. |
| **Mobile Error Monitoring** | Sentry Flutter for crash reporting, real-time error tracking, and performance tracing. |
| **Admin Portal** | Separate lightweight web app consuming the same Supabase backend. |


---

## 9. Locked Architectural Decisions, Spike Findings & Risk Mitigations

### 9.1 Technical Spike Findings & Locked Solutions

The technical spikes and open questions have been empirically analyzed and formally resolved as follows:

| Spike / Question | Technical Finding | Locked Resolution |
|---|---|---|
| **SPK-001: Flutter Direct Resumable Upload** | Google Drive API v3 provides standard RFC 7233 chunked resumable uploads via a session URI. If connection drops, querying the URI returns `HTTP 308 Resume Incomplete` with the exact confirmed byte range. | **LOCKED:** Client-to-Drive direct upload using Flutter `dio`/chunked HTTP client. 100% bypasses platform serverless bandwidth. |
| **SPK-002: Google Drive Media Range Requests** | Google Drive API v3 `alt=media` honors `Range: bytes=start-end` (`HTTP 206 Partial Content`). However, direct mobile video player requests introduce 1.5s–3s seek latency and risk user rate-limiting. | **LOCKED:** Option B (Supabase Edge Function streaming proxy) acts as the normalized range broker. Paired with `cached_video_player_plus` for local disk caching. |
| **SPK-003: 100MB+ Virus Scan Interstitial Bypass** | The HTML virus scan interstitial page is strictly an unauthenticated web browser behavior (`drive.google.com/uc?export=download`). Authorized API calls (`alt=media` + OAuth Bearer token + `confirm=t`) bypass this interstitial completely and stream raw MP4 binaries for files of any size. | **LOCKED:** Edge Function requests always inject `Authorization: Bearer <token>` and `confirm=t`. Virus warning interstitial is 100% eliminated. |
| **SPK-004: Edge Function Streaming Throughput** | Deno isolates support streaming `ReadableStream` directly from upstream fetch to client response with < 32MB RAM usage. | **LOCKED:** Streams are piped in 512KB chunks without buffering the full file in memory. |
| **SPK-005: Google OAuth App Verification Tier** | `https://www.googleapis.com/auth/drive.file` is classified by Google as a **Sensitive (non-restricted)** scope. It does **NOT** require a Restricted Scope CASA Tier 2 third-party audit ($15k–$75k fee). | **LOCKED:** Request ONLY `drive.file`. Google Cloud verification requires only brand verification, domain ownership, and privacy policy URLs for the Egyptian market. |
| **Permanent Source of Truth Policy** | Product trade-off between zero platform storage vs post-completion creator deletion risk. | **LOCKED: Creator Drive Custody Forever.** Platform stores 0 bytes of video binaries permanently. If creator deletes post-completion, deliverable is marked `submission_unavailable`. Brands are instructed to download originals upon approval. |
| **Playback Architecture Selection** | Trade-off between Edge proxy egress costs vs CDN complexity. | **LOCKED:** Option B (Supabase Edge Proxy) for MVP + on-device caching; Option D (Cloudflare CDN streaming proxy) pre-designed as scale fallback if egress exceeds budget. |
| **Pre-Completion Disconnection Policy** | Handling creator Drive disconnect or file deletion while review is active. | **LOCKED: Pause & Prompt.** Workflow freezes in `submission_unavailable` / `access_revoked`, payment actions are locked, and high-priority push notifications alert creator to restore/reconnect. |

---

### 9.2 Technical Risk Mitigations (Locked Specifications)

| Risk ID | Identified Risk | Impact | Locked Mitigation Specification |
|---|---|---|---|
| **RSK-001** | **Creator Deletes or Moves Video File in Google Drive** | Brand opens submission and video playback fails (HTTP 404). | 1. **Pre-Completion:** App locks submission in `submission_unavailable`, freezes payment confirmation, and alerts creator via FCM push to restore or re-upload.<br>2. **Post-Completion:** System marks asset `submission_unavailable`; brand was notified at completion to download to company storage. Platform never stores raw videos. |
| **RSK-002** | **Creator Disconnects Drive or Revokes OAuth Access** | Backend cannot refresh token; cannot stream or download video. | 1. Detection of `invalid_grant` transitions status to `access_revoked`.<br>2. Payment confirmation is blocked until re-authenticated.<br>3. In-app disconnect flow warns creator that active campaign deliverables will be paused. |
| **RSK-003** | **Google Drive API Quota Throttling (HTTP 429/403)** | Video playback buffers indefinitely or fails during concurrent brand review spikes. | 1. Exponential backoff with jitter on backend API calls.<br>2. Aggressive on-device disk caching via `cached_video_player_plus`: Brand only streams the video once; repeated reviews play from local device disk cache.<br>3. Pre-designed fallback to Option D (Cloudflare CDN streaming proxy) if quota limits are reached. |
| **RSK-004** | **Supabase Edge Function Egress Bandwidth Costs** | High cloud egress bandwidth bills if brands stream large videos repeatedly. | 1. On-device disk caching ensures each brand reviewer fetches bytes only once.<br>2. Streaming endpoints require valid brand session JWTs and enforce rate limits.<br>3. If monthly egress exceeds $200, trigger transition to Option D (transcoded 720p HLS proxy on Cloudflare Stream/Workers). |
| **RSK-005** | **Mobile Download Interruption on Large Files (100MB+)** | Brand download fails halfway due to mobile screen lock or network switch. | 1. Native background download manager (`flutter_downloader` with iOS background sessions and Android WorkManager).<br>2. Implements chunked resumable download verification via `Content-Range`. |

---

### 9.3 Decision Gates (Status: LOCKED & APPROVED)

1. **[X] Gate 1: Playback Architecture Sign-Off:**
   - **LOCKED:** Option B (Supabase Edge Proxy) approved for MVP with on-device disk caching; Option D pre-designed as scale fallback.
2. **[X] Gate 2: OAuth Scopes & Verification Strategy:**
   - **LOCKED:** Scope strictly restricted to `https://www.googleapis.com/auth/drive.file`. Standard App Verification path confirmed.
3. **[X] Gate 3: Long-Term Custody & Archival Policy:**
   - **LOCKED:** Creator Drive Custody Forever. 0 platform video storage. Brand download calls-to-action upon approval.
4. **[X] Gate 4: Pre-Completion Failure Handling Policy:**
   - **LOCKED:** Pause & Prompt workflow freeze with payment lock on pre-completion disconnects or deletions.
5. **[ ] Gate 5: Pre-Code Infrastructure & Credentials Provisioning (Next Step):**
   - Provision Google Cloud Console project, OAuth client IDs, and Supabase Vault secrets when code implementation is authorized.
