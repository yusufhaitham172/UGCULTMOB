# UGCULT — Mobile API & Edge Functions Specification

**Document:** API Endpoint & Edge Function Contract  
**Protocol:** REST / JSON (HTTPS) + WebSocket (Realtime Postgres CDC) + Edge Functions (Deno)  
**Authentication:** Bearer JWT (Supabase Auth / GoTrue)  
**Status:** Approved v3.1 (Creator-Owned Google Drive Media Architecture Revision)  
**Changes from v3.0:** Added candidate Google Drive OAuth connection endpoints, direct resumable video submission endpoints, in-app native video playback streaming broker, lossless original video download broker, deliverable storage health checks, and new error codes.

---

## 1. Authentication & Onboarding Endpoints

### 1.1 Send Phone SMS OTP
- **Method:** `POST`
- **Route:** `/auth/v1/otp`
- **Provider:** Supabase Auth built-in SMS OTP (Twilio)
- **Description:** Sends a 6-digit verification code to the user's Egyptian mobile number.
- **Request Body:**
```json
{
  "phone": "+201012345678",
  "channel": "sms"
}
```
- **Validation:** Egyptian phone regex: `^(\+20)?(01[0125][0-9]{8})$`
- **Response (200 OK):**
```json
{
  "message": "OTP sent successfully",
  "expires_in": 300
}
```

### 1.2 Verify Phone OTP & Create Session
- **Method:** `POST`
- **Route:** `/auth/v1/verify`
- **Request Body:**
```json
{
  "phone": "+201012345678",
  "token": "492810",
  "type": "sms"
}
```
- **Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsIn...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "d8f4b1e...",
  "user": {
    "id": "a3b1c9e4-8b5e-4c7a-9012-3456789abcde",
    "phone": "+201012345678"
  }
}
```

### 1.3 Complete User Onboarding (RPC)
Creates the user record and role-specific profile in a single transaction.
- **Method:** `POST`
- **Route:** `/rest/v1/rpc/complete_user_onboarding`
- **Request Body (Creator example):**
```json
{
  "p_role": "creator",
  "p_display_name": "Salma Content",
  "p_email": "salma@gmail.com",
  "p_governorate": "Cairo",
  "p_niche_categories": ["Beauty", "Fashion"],
  "p_custom_niche": null,
  "p_tiktok_handle": "@salma_ugc",
  "p_instagram_handle": "@salmaugc_eg"
}
```
- **Request Body (Brand example):**
```json
{
  "p_role": "brand",
  "p_company_name": "Glow Cosmetics Egypt",
  "p_email": "info@glowcosmetics.eg",
  "p_industry_category": "Beauty",
  "p_description": "Organic skincare products for the Egyptian market.",
  "p_governorate": "Cairo"
}
```
- **Response (200 OK):**
```json
{
  "success": true,
  "profile_id": "a3b1c9e4-8b5e-4c7a-9012-3456789abcde",
  "role": "creator"
}
```

---

## 2. Campaign Lifecycle APIs

### 2.1 Discover Campaigns Feed
- **Method:** `GET`
- **Route:** `/rest/v1/campaigns?select=id,title,category,cover_image_url,compensation_type,accepted_deliverable_types,cash_amount_egp,gift_estimated_value_egp,creator_slots_needed,approved_creators_count,brand_profiles(company_name,logo_url,average_rating)&status=in.published,in_progress&order=created_at.desc&limit=20&offset=0`
- **Headers:** `Authorization: Bearer <JWT>`
- **Filters (query params):**
  - `category=eq.Beauty` — filter by category
  - `compensation_type=eq.cash` — filter by compensation
  - `title=ilike.*skincare*` — text search
- **Response (200 OK):**
```json
[
  {
    "id": "c1f8e240-5a3d-4b82-9e20-1a2b3c4d5e6f",
    "title": "Summer Skincare UGC Video Reel",
    "category": "Beauty",
    "cover_image_url": "https://storage.ugcult.com/campaigns/c1f8/cover.jpg",
    "compensation_type": "both",
    "accepted_deliverable_types": "video",
    "cash_amount_egp": 750.00,
    "gift_estimated_value_egp": 1200.00,
    "creator_slots_needed": 5,
    "approved_creators_count": 2,
    "brand_profiles": {
      "company_name": "Glow Cosmetics Egypt",
      "logo_url": "https://storage.ugcult.com/brands/glow_logo.png",
      "average_rating": 4.90
    }
  }
]
```

### 2.2 Create Campaign (Draft)
- **Method:** `POST`
- **Route:** `/rest/v1/campaigns`
- **Request Body:**
```json
{
  "title": "Organic Coffee Unboxing & Tasting",
  "description": "Looking for energetic creators to create a 30s TikTok-style review.",
  "guidelines": "Mention 100% Arabica beans. Show brewing process. Good natural lighting.",
  "category": "Food",
  "creator_slots_needed": 3,
  "requires_shipping": true,
  "accepted_deliverable_types": "video",
  "compensation_type": "gift",
  "compensation_description": "Full Coffee Box valued at 950 EGP",
  "gift_estimated_value_egp": 950.00,
  "status": "draft"
}
```

### 2.3 Publish Campaign (Direct — No Admin Approval)
Brand publishes their campaign directly. The app shows an immutability confirmation before calling this.
- **Method:** `PATCH`
- **Route:** `/rest/v1/campaigns?id=eq.<campaign_id>`
- **Request Body:**
```json
{
  "status": "published"
}
```
- **Response (200 OK):** Returns updated campaign with `status: "published"`.
- **Note:** The `enforce_campaign_immutability` trigger prevents further edits to core fields.

### 2.4 Cancel Campaign (Brand)
- **Method:** `PATCH`
- **Route:** `/rest/v1/campaigns?id=eq.<campaign_id>`
- **Request Body:**
```json
{
  "status": "cancelled"
}
```

### 2.5 Mark Campaign Completed (Brand)
- **Method:** `PATCH`
- **Route:** `/rest/v1/campaigns?id=eq.<campaign_id>`
- **Request Body:**
```json
{
  "status": "completed"
}
```

---

## 3. Applications & Delivery Workflow APIs

### 3.1 Apply to Campaign (Creator - 1-Tap Apply)
- **Method:** `POST`
- **Route:** `/rest/v1/campaign_applications`
- **Description:** Pure 1-tap application. Creator does not submit pitch notes or pick portfolio items; the brand inspects the creator's full public profile via "View Creator Profile".
- **Request Body:**
```json
{
  "campaign_id": "c1f8e240-5a3d-4b82-9e20-1a2b3c4d5e6f"
}
```
- **Error (409):** `DUPLICATE_APPLICATION` if creator already applied.

### 3.2 Brand Decision on Applicant (RPC)
- **Method:** `POST`
- **Route:** `/rest/v1/rpc/decide_applicant`
- **Request Body:**
```json
{
  "p_application_id": "e8d7c6b5-1234-5678-90ab-cdef12345678",
  "p_decision": "approved"
}
```
- **Response (200 OK):**
```json
{
  "success": true,
  "status": "approved",
  "creator_contact_unlocked": true,
  "campaign_transitioned_to": "in_progress"
}
```
- **Side effects:**
  - RLS unlocks creator's private contact data for this brand.
  - Campaign auto-transitions to `in_progress` if this is the first approval.
  - `approved_creators_count` increments.

### 3.3 Brand Marks Product Sent (Simplified Shipping)
- **Method:** `PATCH`
- **Route:** `/rest/v1/campaign_applications?id=eq.<application_id>`
- **Request Body:**
```json
{
  "status": "product_sent",
  "product_sent_at": "2026-08-10T14:30:00Z"
}
```

### 3.4 Creator Confirms Product Received
- **Method:** `PATCH`
- **Route:** `/rest/v1/campaign_applications?id=eq.<application_id>`
- **Request Body:**
```json
{
  "status": "product_received",
  "product_received_at": "2026-08-12T11:00:00Z"
}
```

### 3.5 Creator Withdraws from Campaign
- **Method:** `PATCH`
- **Route:** `/rest/v1/campaign_applications?id=eq.<application_id>`
- **Request Body:**
```json
{
  "status": "withdrawn"
}
```

---

## 4. Content Submissions & Revisions

UGCULT uses a hybrid media submission model:
- **Photo Deliverables:** Uploaded directly to Supabase Storage (`submissions` bucket).
- **Video Deliverables:** Hosted directly in the **Creator's connected Google Drive account**. High-bitrate master files bypass Supabase Storage, while metadata and linkages are managed by Supabase.

---

### 4.1 Upload Photo Deliverable (Supabase Storage)
- **Endpoint:** `POST /storage/v1/object/submissions/`
- **Headers:**
  - `Authorization: Bearer <JWT>`
  - `Content-Type: image/jpeg` or `image/png` or `image/webp`
  - `x-upsert: false`
- **Body:** Binary image stream.
- **Description:** Direct single-request photo upload for photo-only campaigns.

---

### 4.2 Submit Photo Deliverable Record (Supabase Database)
- **Method:** `POST`
- **Route:** `/rest/v1/campaign_submissions`
- **Headers:** `Authorization: Bearer <JWT>` (Creator role)
- **Request Body (Photo deliverable):**
```json
{
  "application_id": "e8d7c6b5-1234-5678-90ab-cdef12345678",
  "media_type": "photo",
  "media_url": "https://storage.ugcult.com/submissions/app_e8d7/deliverable_1.jpg",
  "thumbnail_url": "https://storage.ugcult.com/submissions/app_e8d7/deliverable_1_thumb.jpg",
  "caption_copy": "Glowing skin starts with clean ingredients ✨ #ugc #skincare",
  "notes_for_brand": "High-res photos shot in natural daylight."
}
```
- **Side effect:** Application status → `content_submitted`.

---

### 4.3 Brand Review Submission (Approve or Request Revision)
- **Method:** `POST`
- **Route:** `/functions/v1/submission-reviewer`
- **Headers:** `Authorization: Bearer <JWT>` (Brand role)
- **Request Body (Approve):**
```json
{
  "submission_id": "9a8b7c6d-5e4f-3a2b-1c0d-ef9876543210",
  "decision": "approved"
}
```
- **Request Body (Revision — no cap, unlimited):**
```json
{
  "submission_id": "9a8b7c6d-5e4f-3a2b-1c0d-ef9876543210",
  "decision": "revision_requested",
  "feedback_notes": "Great energy! Please re-record the hook with product closer to the camera.",
  "timestamp_markers": [
    { "time": "00:03", "note": "Blurry product label" },
    { "time": "00:15", "note": "Audio clipping slightly" }
  ]
}
```
- **Response (200 OK):**
```json
{
  "status": "revision_requested",
  "submission_number": 2
}
```

---

### 4.4 Google Drive OAuth & Account Connection Endpoints [PROPOSED]

#### 4.4.1 Get Google Drive Authorization URL [PROPOSED]
- **Method:** `POST`
- **Route:** `/functions/v1/drive-auth-url`
- **Purpose:** Generates a cryptographically signed Google OAuth 2.0 authorization URL containing state parameter and PKCE challenge.
- **Authentication:** Bearer JWT (Supabase Auth, Creator role only).
- **Authorization:** Only authenticated creators can initiate Drive connections.
- **Request Headers:**
  - `Authorization: Bearer <Creator_JWT>`
- **Request Body:**
```json
{
  "redirect_scheme": "ugcult://oauth-callback"
}
```
- **Response (200 OK):**
```json
{
  "auth_url": "https://accounts.google.com/o/oauth2/v2/auth?client_id=...&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive.file&access_type=offline&prompt=consent&state=sec_state_abc123&code_challenge=...&code_challenge_method=S256",
  "state": "sec_state_abc123"
}
```
- **Error Responses:**
  - `401 Unauthorized`: Invalid or expired JWT.
  - `403 Forbidden`: User role is not `creator`.
- **Security Considerations:**
  - `access_type=offline` and `prompt=consent` ensure a long-lived refresh token is returned.
  - Scope is strictly locked to `https://www.googleapis.com/auth/drive.file`.
  - State parameter contains HMAC signature to prevent CSRF.

#### 4.4.2 Handle Google OAuth Callback & Token Exchange [PROPOSED]
- **Method:** `POST`
- **Route:** `/functions/v1/drive-oauth-callback`
- **Purpose:** Exchanges the authorization code received from Google for OAuth access and refresh tokens server-side.
- **Authentication:** Bearer JWT (Supabase Auth, Creator role).
- **Authorization:** User ID extracted from JWT must match the session that initiated the state parameter.
- **Request Body:**
```json
{
  "code": "4/0AeanS0b...",
  "state": "sec_state_abc123"
}
```
- **Response (200 OK):**
```json
{
  "success": true,
  "google_email": "creator.studio@gmail.com",
  "google_display_name": "Salma Studios",
  "connected_at": "2026-09-25T14:30:00Z",
  "account_status": "connected"
}
```
- **Error Responses:**
  - `400 Bad Request`: `INVALID_STATE` or `INVALID_AUTH_CODE`.
  - `409 Conflict`: `ACCOUNT_ALREADY_CONNECTED` (if Google account is linked to another creator).
- **Security Considerations:**
  - **Zero client token leakage:** Refresh token and access token are NEVER returned in the response body.
  - Refresh token is encrypted with AES-256 and stored in `public.creator_google_drive_accounts` via Supabase Vault.

#### 4.4.3 Get Drive Connection Status [PROPOSED]
- **Method:** `GET`
- **Route:** `/rest/v1/creator_google_drive_accounts?select=google_email,google_display_name,account_status,connected_at,updated_at`
- **Purpose:** Retrieves the current Google Drive connection status for the logged-in creator.
- **Authentication:** Bearer JWT (Creator role).
- **Authorization:** Enforced by PostgreSQL RLS (`auth.uid() = user_id`).
- **Response (200 OK):**
```json
[
  {
    "google_email": "creator.studio@gmail.com",
    "google_display_name": "Salma Studios",
    "account_status": "connected",
    "connected_at": "2026-09-25T14:30:00Z",
    "updated_at": "2026-09-25T14:30:00Z"
  }
]
```
- **Error Responses:**
  - `401 Unauthorized`: Missing or invalid JWT.

#### 4.4.4 Disconnect Google Drive [PROPOSED]
- **Method:** `POST`
- **Route:** `/functions/v1/drive-disconnect`
- **Purpose:** Revokes Google OAuth token and removes Drive account linkage.
- **Authentication:** Bearer JWT (Creator role).
- **Authorization:** Creator can only disconnect their own account.
- **Request Body:**
```json
{
  "confirm_disconnect": true
}
```
- **Response (200 OK):**
```json
{
  "success": true,
  "disconnected_at": "2026-09-25T15:00:00Z",
  "active_submissions_affected": 2
}
```
- **Error Responses:**
  - `400 Bad Request`: Missing confirmation.
  - `409 Conflict`: `HAS_UNREVIEWED_SUBMISSIONS` (creator must acknowledge impact).
- **Security Considerations:**
  - Calls Google OAuth token revocation API endpoint (`https://oauth2.googleapis.com/revoke`).
  - Clears stored encrypted tokens from database.

---

### 4.5 Campaign Video Deliverables via Google Drive [PROPOSED]

#### 4.5.1 Initialize Resumable Video Submission [PROPOSED]
- **Method:** `POST`
- **Route:** `/functions/v1/initiate-video-submission`
- **Purpose:** Validates campaign application status and creates a direct resumable upload session on Google Drive v3 API inside the creator's account.
- **Authentication:** Bearer JWT (Creator role).
- **Authorization:** Creator must have an approved application for the target campaign.
- **Request Body:**
```json
{
  "application_id": "e8d7c6b5-1234-5678-90ab-cdef12345678",
  "filename": "summer_skincare_v1.mp4",
  "file_size_bytes": 104857600,
  "mime_type": "video/mp4"
}
```
- **Response (200 OK):**
```json
{
  "upload_session_id": "sess_918273645",
  "resumable_upload_url": "https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable&upload_id=ADPycd...",
  "destination_folder_name": "UGCULT Submissions",
  "expires_in_seconds": 86400
}
```
- **Error Responses:**
  - `400 Bad Request`: `DRIVE_NOT_CONNECTED` or `INVALID_FILE_SIZE`.
  - `403 Forbidden`: `APPLICATION_NOT_APPROVED` or `NOT_APPLICATION_OWNER`.
  - `409 Conflict`: `PREVIOUS_SUBMISSION_UNDER_REVIEW`.
- **Security Considerations:**
  - The binary video data will stream **directly from Flutter client to Google Drive** via `resumable_upload_url`. It does NOT pass through Supabase serverless bandwidth.
  - Short-lived upload session URI prevents arbitrary file uploads.

#### 4.5.2 Complete Video Submission Record [PROPOSED]
- **Method:** `POST`
- **Route:** `/functions/v1/complete-video-submission`
- **Purpose:** Verifies that the video was fully uploaded to creator's Google Drive, queries Google Drive API for checksum and dimensions, generates local thumbnail, and inserts `campaign_submissions` row.
- **Authentication:** Bearer JWT (Creator role).
- **Authorization:** Only the creator who initiated the upload can finalize it.
- **Request Body:**
```json
{
  "application_id": "e8d7c6b5-1234-5678-90ab-cdef12345678",
  "google_drive_file_id": "1A2B3C4D5E6F7G8H9I0J",
  "thumbnail_storage_url": "https://storage.ugcult.com/submissions/app_e8d7/thumb_1.jpg",
  "caption_copy": "Clean skincare routine unboxing ✨ #ugc #beauty",
  "notes_for_brand": "Shot in 4k 60fps with natural lighting.",
  "duration_seconds": 45,
  "width": 1080,
  "height": 1920
}
```
- **Response (201 Created):**
```json
{
  "submission_id": "9a8b7c6d-5e4f-3a2b-1c0d-ef9876543210",
  "submission_number": 1,
  "status": "content_submitted",
  "file_metadata": {
    "file_size_bytes": 104857600,
    "mime_type": "video/mp4",
    "md5_checksum": "5d41402abc4b2a76b9719d911017c592",
    "drive_upload_status": "linked"
  },
  "submitted_at": "2026-09-25T14:45:00Z"
}
```
- **Error Responses:**
  - `404 Not Found`: `DRIVE_FILE_NOT_FOUND` (file not found in creator's Drive).
  - `422 Unprocessable`: `CHECKSUM_MISMATCH` or `INVALID_VIDEO_FORMAT`.
- **Security Considerations:**
  - Backend verifies file ownership via creator's OAuth access token.
  - Ensures the file is non-empty and has proper `video/mp4` or `video/quicktime` MIME.

#### 4.5.3 In-App Video Playback Stream [PROPOSED]
- **Method:** `GET`
- **Route:** `/functions/v1/submission-playback?submission_id={submission_id}`
- **Purpose:** Acts as the authorized streaming media broker. Authenticates brand, fetches video bytes from Google Drive API with range request forwarding, and streams to Flutter's native player.
- **Authentication:** Bearer JWT (Brand or Creator role).
- **Authorization:**
  - If Brand: Brand must own the Campaign associated with this submission.
  - If Creator: Creator must own this application.
- **Request Headers:**
  - `Authorization: Bearer <Brand_JWT>`
  - `Range: bytes=0-1048575` (Standard HTTP Range request from video player)
- **Response (206 Partial Content or 200 OK):**
- **Response Headers:**
  - `Content-Type: video/mp4`
  - `Content-Range: bytes 0-1048575/104857600`
  - `Accept-Ranges: bytes`
  - `Content-Length: 1048576`
  - `Cache-Control: private, max-age=3600`
- **Response Body:** Binary byte chunk stream.
- **Error Responses:**
  - `401 Unauthorized`: Invalid Supabase JWT.
  - `403 Forbidden`: `TENANT_ACCESS_DENIED` (Brand does not own this campaign).
  - `404 Not Found`: `SUBMISSION_NOT_FOUND`.
  - `409 Conflict`: `CREATOR_STORAGE_DISCONNECTED` (Creator revoked OAuth).
  - `410 Gone`: `DELIVERABLE_FILE_MISSING` (File deleted from creator Drive).
  - `429 Too Many Requests`: `DRIVE_RATE_LIMIT_EXCEEDED`.
- **Security Considerations:**
  - **Zero Drive UI/Link Exposure:** Brand client never sees Google Drive URLs or file IDs.
  - Stream piped in chunks to keep Edge Function memory usage < 32MB.
  - Appends `confirm=t` to Google Drive upstream fetch to bypass 100MB+ virus scan warning.

#### 4.5.4 Lossless Original Video Download [PROPOSED]
- **Method:** `GET`
- **Route:** `/functions/v1/submission-download-original?submission_id={submission_id}`
- **Purpose:** Authorizes and pipes the uncompressed master video file directly to the brand for offline storage and marketing campaign execution.
- **Authentication:** Bearer JWT (Brand role).
- **Authorization:** Brand must own the Campaign associated with the submission.
- **Request Headers:**
  - `Authorization: Bearer <Brand_JWT>`
- **Response (200 OK):**
- **Response Headers:**
  - `Content-Type: video/mp4`
  - `Content-Disposition: attachment; filename="glow_skincare_salma_original.mp4"`
  - `Content-Length: 104857600`
  - `Accept-Ranges: bytes`
- **Response Body:** Full uncompressed binary stream.
- **Error Responses:**
  - `401 Unauthorized`: Missing or invalid JWT.
  - `403 Forbidden`: Brand does not own campaign.
  - `409 Conflict`: `CREATOR_STORAGE_DISCONNECTED`.
  - `410 Gone`: `DELIVERABLE_FILE_MISSING`.
- **Security Considerations:**
  - Filename is sanitized against path injection attacks.
  - Zero transcoding: Exact binary payload delivered.

#### 4.5.5 Check File Storage Health [PROPOSED]
- **Method:** `GET`
- **Route:** `/functions/v1/submission-storage-health?submission_id={submission_id}`
- **Purpose:** Audits whether a submission's Google Drive file is still accessible and healthy.
- **Authentication:** Bearer JWT (Brand or Creator role).
- **Authorization:** Must be participant in the campaign application.
- **Response (200 OK):**
```json
{
  "submission_id": "9a8b7c6d-5e4f-3a2b-1c0d-ef9876543210",
  "storage_status": "healthy",
  "file_exists": true,
  "drive_accessible": true,
  "last_verified_at": "2026-09-25T14:50:00Z"
}
```

---

## 5. Payment Confirmation & Disputes (Dual Confirmation)

### 5.1 Brand Confirms Payment Sent
- **Method:** `POST`
- **Route:** `/rest/v1/rpc/mark_payment_sent`
- **Request Body:**
```json
{
  "p_application_id": "e8d7c6b5-1234-5678-90ab-cdef12345678",
  "p_payment_method": "Instapay"
}
```
- **Response (200 OK):**
```json
{
  "payment_status": "paid_by_brand",
  "awaiting_creator_confirmation": true
}
```

### 5.2 Creator Confirms Payment Received
- **Method:** `POST`
- **Route:** `/rest/v1/rpc/confirm_payment_received`
- **Request Body:**
```json
{
  "p_application_id": "e8d7c6b5-1234-5678-90ab-cdef12345678"
}
```
- **Response (200 OK):**
```json
{
  "payment_status": "confirmed_by_creator",
  "application_status": "completed",
  "rating_prompt_triggered": true
}
```
- **Side effect:** Application → `completed`. Push notification triggers rating prompt for both parties.

### 5.3 Creator Flags Payment Dispute
- **Method:** `POST`
- **Route:** `/functions/v1/dispute-handler`
- **Request Body:**
```json
{
  "application_id": "e8d7c6b5-1234-5678-90ab-cdef12345678",
  "dispute_reason": "Brand marked paid on 2026-08-14, but no transfer was received to my Instapay account."
}
```
- **Response (200 OK):**
```json
{
  "dispute_id": "d1e2f3a4-b5c6-7d8e-9f0a-1b2c3d4e5f6a",
  "status": "disputed_by_creator",
  "audit_logged": true
}
```

---

## 6. Ratings (Double-Blind)

### 6.1 Submit Rating
- **Method:** `POST`
- **Route:** `/rest/v1/campaign_reviews`
- **Request Body:**
```json
{
  "campaign_id": "c1f8e240-5a3d-4b82-9e20-1a2b3c4d5e6f",
  "application_id": "e8d7c6b5-1234-5678-90ab-cdef12345678",
  "ratee_id": "b2c3d4e5-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
  "rating": 5,
  "communication_score": 5,
  "quality_score": 4,
  "punctuality_score": 5,
  "payment_score": 5,
  "comment": "Excellent collaboration, very professional!"
}
```
- **Side effect:** If both parties have now submitted reviews for this application, both reviews have `is_revealed` set to `true`.

### 6.2 Reveal Ratings (Scheduled Edge Function)
Runs on a cron schedule (every hour) to reveal ratings where:
- Both parties have submitted, OR
- 7 days have passed since the application reached `completed`

```
-- Pseudo-SQL executed by Edge Function
UPDATE campaign_reviews SET is_revealed = true
WHERE is_revealed = false
AND (
    -- Both submitted
    EXISTS (SELECT 1 FROM campaign_reviews cr2 
            WHERE cr2.application_id = campaign_reviews.application_id 
            AND cr2.rater_id = campaign_reviews.ratee_id)
    -- OR 7-day timeout
    OR (SELECT ca.creator_confirmed_paid_at FROM campaign_applications ca 
        WHERE ca.id = campaign_reviews.application_id) < NOW() - INTERVAL '7 days'
);
```

---

## 7. Edge Functions Summary

| Function | Trigger | Purpose |
|---|---|---|
| `drive-oauth-handler` | API call from creator | Exchange OAuth code for tokens, encrypt and persist refresh token in Vault [PROPOSED] |
| `initiate-video-submission` | API call from creator | Create Google Drive v3 resumable upload session directly for mobile client [PROPOSED] |
| `complete-video-submission` | API call from creator | Verify Drive upload completion, validate checksum, link submission metadata [PROPOSED] |
| `submission-playback` | API call from brand | Authorized media broker; streams video bytes from Drive with Range header support [PROPOSED] |
| `submission-download-original`| API call from brand | Authorized lossless download streaming broker with Content-Disposition headers [PROPOSED] |
| `submission-storage-auditor` | Cron (every 12 hours) | Audits active submissions for missing Drive files or revoked permissions [PROPOSED] |
| `submission-reviewer` | API call from brand | Approve/reject submission, create revision request, update application status |
| `dispute-handler` | API call from creator | Create dispute record, log to audit_logs, notify admin |
| `push-dispatcher` | Database webhook (pg_net) | Send FCM/APNs push notifications on state changes |
| `rating-revealer` | Cron (every hour) | Reveal double-blind ratings after both submit or 7-day timeout |
| `auto-archiver` | Cron (daily) | Archive completed campaigns after 30 days of inactivity |
| `payment-timeout-checker` | Cron (every 6 hours) | Auto-flag disputes for brand-marked payments not confirmed by creator after 72h |

---

## 8. Standard Error Codes & Envelope

All API errors return a standard JSON error payload:

```json
{
  "error": {
    "code": "DUPLICATE_APPLICATION",
    "message": "You have already applied to this campaign.",
    "details": null,
    "timestamp": "2026-08-15T18:22:01Z"
  }
}
```

| HTTP Status | Error Code | Description |
|---|---|---|
| `400` | `INVALID_TRANSITION` | Attempted invalid state transition |
| `400` | `PORTFOLIO_REQUIRED` | Creator must have ≥1 portfolio item to apply |
| `400` | `DRIVE_NOT_CONNECTED` | Creator has not connected a Google Drive account |
| `401` | `UNAUTHORIZED` | Invalid or expired Bearer JWT token |
| `403` | `RLS_FORBIDDEN` | Access denied by Postgres Row-Level Security |
| `403` | `TENANT_ACCESS_DENIED` | Brand does not own campaign associated with requested submission |
| `409` | `IMMUTABLE_RECORD` | Cannot modify published campaign fields |
| `409` | `DUPLICATE_APPLICATION` | Creator already applied to this campaign |
| `409` | `SLOTS_FULL` | Campaign has no remaining creator spots |
| `409` | `CREATOR_STORAGE_DISCONNECTED`| Creator has disconnected Google Drive or revoked OAuth access |
| `410` | `DELIVERABLE_FILE_MISSING` | Video file has been deleted or moved in creator's Google Drive |
| `422` | `INVALID_DELIVERABLE_TYPE` | Submitted media type doesn't match campaign's accepted types |
| `422` | `CHECKSUM_MISMATCH` | Uploaded video checksum does not match reported metadata |
| `429` | `RATE_LIMIT_EXCEEDED` | Exceeded endpoint rate limit |
| `429` | `DRIVE_RATE_LIMIT_EXCEEDED`| Google Drive API quota exceeded; retry with exponential backoff |
