# UGCULT — Database Design & Security Specification (PostgreSQL 16)

**Document:** Database Schema & RLS Architecture  
**Database:** PostgreSQL 16 (Supabase Managed)  
**Status:** Approved v3.1 (Creator-Owned Google Drive Media Architecture Revision)  
**Changes from v3.0:** Added `creator_google_drive_accounts` table for encrypted OAuth token custody; updated `campaign_submissions` with Google Drive file metadata fields (file_id, original filename, checksum, dimensions, duration, upload status); added `drive_account_status` and `drive_upload_status` enums; added strict zero-trust RLS policies isolating Google Drive credentials from brands and isolating submission access across tenants.

---

## 1. Schema Overview & Entity Relationship Diagram

```
                   ┌────────────────────────┐
                   │    auth.users (Auth)   │
                   └───────────┬────────────┘
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
┌───────────────────────┐             ┌───────────────────────┐
│     public.users      │             │    user_fcm_tokens    │
│  (id, role, status)   │             │ (user_id, token, os)  │
└───────────┬───────────┘             └───────────────────────┘
            │
            ├─────────────────────────────────────────┐
            ▼                                         ▼
┌───────────────────────┐                 ┌───────────────────────┐
│   creator_profiles    │                 │    brand_profiles     │
│ (user_id, bio, rating)│                 │(user_id, company_name)│
└───────────┬───────────┘                 └───────────┬───────────┘
            │                                         │
            ├───────────────────┬───────────────────┐ │
            ▼                   ▼                   ▼ │
┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────────────┐
│creator_private_contact│ │  creator_portfolios   │ │creator_google_drive_  │
│(phone, instapay, addr)│ │ (media_url, thumbnail)│ │  accounts             │
└───────────────────────┘ └───────────────────────┘ │(user_id, tokens, stat)│
                                                    └───────────────────────┘
                                                              │
                                                              ▼
                                                  ┌───────────────────────┐
                                                  │      campaigns        │
                                                  │(brand_id, title, stat)│
                                                  └───────────┬───────────┘
                                                              │
                                          ┌───────────────────┴───────────────────┐
                                          ▼                                       ▼
                              ┌───────────────────────┐               ┌───────────────────────┐
                              │ campaign_applications │               │    campaign_reviews   │
                              │(campaign_id,creator_id│               │(campaign_id, rater_id)│
                              └───────────┬───────────┘               └───────────────────────┘
                                          │
                                          ▼
                              ┌───────────────────────┐
                              │ campaign_submissions  │
                              │(application_id,       │
                              │ google_drive_file_id, │
                              │ checksum, dimensions, │
                              │ upload_status)        │
                              └───────────┬───────────┘
                                          │
                                          ▼
                              ┌───────────────────────┐
                              │ submission_revisions  │
                              │(submission_id, notes) │
                              └───────────────────────┘
```

---

## 2. PostgreSQL Types & Enums

```sql
-- User Roles
CREATE TYPE user_role AS ENUM ('creator', 'brand', 'admin');

-- User Account Status
CREATE TYPE user_status AS ENUM ('active', 'suspended', 'pending_verification');

-- Compensation Models
CREATE TYPE compensation_type AS ENUM ('gift', 'cash', 'both');

-- Accepted Deliverable Types
CREATE TYPE deliverable_type AS ENUM ('video', 'photo', 'both');

-- Campaign Lifecycle States (SIMPLIFIED: no pending_review, no rejected)
CREATE TYPE campaign_status AS ENUM (
    'draft',         -- Brand is composing the campaign
    'published',     -- Live on discovery feed, immutable core fields
    'in_progress',   -- Auto: first creator approved
    'completed',     -- Manual: brand marks done
    'cancelled',     -- Manual: brand cancels
    'archived'       -- Auto: 30 days after completed
);

-- Application Sub-Workflow Statuses
CREATE TYPE application_status AS ENUM (
    'applied',              -- Creator submitted application
    'rejected',             -- Brand rejected application
    'approved',             -- Brand approved; PII unlocked
    'product_sent',         -- Brand marked product shipped (shipping campaigns only)
    'product_received',     -- Creator confirmed receipt (shipping campaigns only)
    'content_submitted',    -- Creator uploaded deliverable
    'revision_requested',   -- Brand requested changes (no cap)
    'content_approved',     -- Brand approved deliverable
    'completed',            -- Both sides confirmed payment
    'withdrawn',            -- Creator withdrew voluntarily
    'disputed'              -- Payment dispute flagged
);

-- Submission Review Actions
CREATE TYPE submission_review_status AS ENUM (
    'pending_review',
    'revision_requested',
    'approved'
);

-- Payment Status (Dual Confirmation)
CREATE TYPE payment_status AS ENUM (
    'unpaid',                    -- No payment action taken
    'paid_by_brand',             -- Brand claims they paid
    'confirmed_by_creator',      -- Creator confirms receipt → application completed
    'disputed_by_creator',       -- Creator says they didn't receive
    'resolved_by_admin'          -- Admin resolved the dispute
);

-- Google Drive Account Connection Status
CREATE TYPE drive_account_status AS ENUM (
    'connected',                 -- Active connection, valid tokens
    'disconnected',              -- Voluntarily disconnected by creator
    'token_expired',             -- Refresh token expired or invalid
    'revoked'                    -- Creator revoked permissions via Google Account settings
);

-- Google Drive Video Deliverable Upload & Verification Status
CREATE TYPE drive_upload_status AS ENUM (
    'pending_upload',            -- Resumable session initiated, bytes in transfer
    'uploading',                 -- Chunk transfer in progress
    'linked',                    -- Verified in Drive, metadata recorded, ready for review
    'missing',                   -- File deleted or moved in creator's Drive
    'access_revoked',            -- Creator revoked OAuth or disconnected Drive
    'failed'                     -- Upload timed out or checksum verification failed
);
```

---

## 3. Table Definitions (DDL)

### 3.1 Base Users & Auth Extension
```sql
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    email TEXT UNIQUE,                          -- Optional, for recovery/admin contact only
    phone TEXT UNIQUE NOT NULL,                 -- Primary login identifier (SMS OTP)
    phone_verified BOOLEAN DEFAULT FALSE NOT NULL,
    status user_status DEFAULT 'active' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);
```

### 3.2 Creator Profiles & Private Contact Isolation
```sql
CREATE TABLE public.creator_profiles (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    niche_categories TEXT[] NOT NULL DEFAULT '{}',  -- Fixed: Beauty, Tech, Food, Fashion, Fitness, Lifestyle, Other
    custom_niche TEXT,                               -- Freetext when "Other" is selected
    governorate TEXT NOT NULL,
    tiktok_handle TEXT,
    instagram_handle TEXT,
    youtube_handle TEXT,
    follower_count INT DEFAULT 0,
    engagement_rate NUMERIC(5,2) DEFAULT 0.00,
    profile_completion_pct INT DEFAULT 0,
    average_rating NUMERIC(3,2) DEFAULT 5.00,
    ratings_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Highly Sensitive PII Data (Locked via Strict RLS)
CREATE TABLE public.creator_private_contacts (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    full_legal_name TEXT NOT NULL,
    contact_phone TEXT NOT NULL,
    instapay_handle TEXT,
    shipping_governorate TEXT,
    shipping_city TEXT,
    shipping_street_address TEXT,
    shipping_building_details TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Creator Portfolio Items (Video + Photo)
CREATE TABLE public.creator_portfolios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    media_type TEXT NOT NULL CHECK (media_type IN ('video', 'photo')),  -- NEW: supports both
    media_url TEXT NOT NULL,
    thumbnail_url TEXT NOT NULL,
    duration_seconds INT,                  -- NULL for photos
    file_size_bytes BIGINT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

-- Creator Connected Google Drive Accounts (OAuth Token Vault)
CREATE TABLE public.creator_google_drive_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.users(id) ON DELETE CASCADE,
    google_user_id TEXT NOT NULL,
    google_email TEXT NOT NULL,
    google_display_name TEXT,
    vault_secret_id UUID,                     -- Reference to Supabase Vault secret holding the refresh token
    encrypted_refresh_token TEXT,             -- AES-256 encrypted fallback if Vault not directly mounted
    token_scope TEXT NOT NULL DEFAULT 'https://www.googleapis.com/auth/drive.file',
    account_status drive_account_status DEFAULT 'connected' NOT NULL,
    connected_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);
```

### 3.3 Brand Profiles
```sql
CREATE TABLE public.brand_profiles (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    company_name TEXT NOT NULL,
    industry_category TEXT NOT NULL,
    description TEXT,
    logo_url TEXT,
    website_url TEXT,
    governorate TEXT,
    average_rating NUMERIC(3,2) DEFAULT 5.00,
    ratings_count INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);
```

### 3.4 Campaigns
```sql
CREATE TABLE public.campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    guidelines TEXT NOT NULL,
    category TEXT NOT NULL,
    cover_image_url TEXT,
    reference_urls TEXT[] DEFAULT '{}',
    
    -- Capacity (NO DEADLINES)
    creator_slots_needed INT NOT NULL CHECK (creator_slots_needed > 0),
    approved_creators_count INT NOT NULL DEFAULT 0,
    
    -- Deliverable Requirements
    requires_shipping BOOLEAN DEFAULT FALSE NOT NULL,
    accepted_deliverable_types deliverable_type NOT NULL DEFAULT 'video',  -- NEW: video, photo, or both
    
    -- Compensation
    compensation_type compensation_type NOT NULL,
    compensation_description TEXT NOT NULL,
    cash_amount_egp NUMERIC(10,2) DEFAULT 0.00,
    gift_estimated_value_egp NUMERIC(10,2) DEFAULT 0.00,
    
    -- Lifecycle State (SIMPLIFIED)
    status campaign_status DEFAULT 'draft' NOT NULL,
    
    -- Phase 2 Monetization Placeholders (Dormant in MVP)
    posting_fee_paid BOOLEAN DEFAULT FALSE NOT NULL,
    posting_fee_transaction_id TEXT,
    
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);
```

### 3.5 Applications & Sub-Workflow
```sql
CREATE TABLE public.campaign_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
    creator_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    -- 1-Tap Application: No pitch_note or selected_portfolio_ids (Brand views creator's public profile)
    status application_status DEFAULT 'applied' NOT NULL,
    
    -- Simplified Shipping (no carrier/tracking)
    product_sent_at TIMESTAMPTZ,       -- When brand marked "sent"
    product_received_at TIMESTAMPTZ,   -- When creator confirmed receipt
    
    -- Dual Payment Confirmation
    payment_status payment_status DEFAULT 'unpaid' NOT NULL,
    brand_payment_method TEXT,              -- 'Instapay' | 'Bank Transfer' | 'Cash'
    brand_marked_paid_at TIMESTAMPTZ,      -- When brand confirmed payment
    creator_confirmed_paid_at TIMESTAMPTZ, -- When creator confirmed receipt of payment
    dispute_reason TEXT,
    disputed_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    UNIQUE(campaign_id, creator_id)
);
```

### 3.6 Content Submissions & Revisions
```sql
CREATE TABLE public.campaign_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES public.campaign_applications(id) ON DELETE CASCADE,
    submission_number INT NOT NULL DEFAULT 1,
    media_type deliverable_type NOT NULL CHECK (media_type IN ('video', 'photo')),
    
    -- Platform Storage URLs (Photos or Thumbnails)
    media_url TEXT,                                     -- Supabase Storage URL for photos; NULL for video deliverables
    thumbnail_url TEXT NOT NULL,                        -- Supabase Storage URL for preview thumbnail (both photo & video)
    
    -- Creator Google Drive Fields (for media_type = 'video')
    google_drive_file_id TEXT,                         -- Google Drive v3 file ID in creator's account
    original_filename TEXT,                            -- Master export filename (e.g. 'unboxing_v1.mp4')
    mime_type TEXT,                                    -- 'video/mp4' | 'video/quicktime'
    file_size_bytes BIGINT,                            -- Exact byte size of creator's uncompressed upload
    video_duration_seconds INT,                        -- Extracted duration in seconds
    video_width INT,                                   -- Video frame pixel width (e.g. 1080)
    video_height INT,                                  -- Video frame pixel height (e.g. 1920)
    drive_file_checksum TEXT,                          -- MD5 or SHA-256 checksum from Drive API for integrity verification
    drive_upload_status drive_upload_status DEFAULT 'pending_upload',
    drive_file_created_at TIMESTAMPTZ,
    
    caption_copy TEXT,
    notes_for_brand TEXT,
    review_status submission_review_status DEFAULT 'pending_review' NOT NULL,
    brand_feedback TEXT,
    submitted_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    reviewed_at TIMESTAMPTZ
);

CREATE TABLE public.submission_revision_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id UUID NOT NULL REFERENCES public.campaign_submissions(id) ON DELETE CASCADE,
    feedback_notes TEXT NOT NULL,
    timestamp_markers JSONB DEFAULT '[]'::JSONB,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);
```

### 3.7 Mutual Ratings & Platform Audit Log
```sql
CREATE TABLE public.campaign_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
    application_id UUID NOT NULL REFERENCES public.campaign_applications(id) ON DELETE CASCADE,
    rater_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    ratee_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    communication_score INT CHECK (communication_score BETWEEN 1 AND 5),
    quality_score INT CHECK (quality_score BETWEEN 1 AND 5),
    punctuality_score INT CHECK (punctuality_score BETWEEN 1 AND 5),
    payment_score INT CHECK (payment_score BETWEEN 1 AND 5),
    is_revealed BOOLEAN DEFAULT FALSE NOT NULL,  -- NEW: double-blind reveal flag
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL,
    UNIQUE(campaign_id, rater_id, ratee_id)
);

CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.users(id),
    action TEXT NOT NULL,
    target_entity TEXT NOT NULL,
    target_id UUID NOT NULL,
    payload JSONB DEFAULT '{}'::JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);

CREATE TABLE public.user_fcm_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL UNIQUE,
    platform TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
    last_active_at TIMESTAMPTZ DEFAULT TIMEZONE('utc', NOW()) NOT NULL
);
```

---

## 4. PostgreSQL Triggers & Functions

### 4.1 Campaign Immutability Trigger
Once a campaign is `published`, core fields cannot be modified.

```sql
CREATE OR REPLACE FUNCTION enforce_campaign_immutability()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IN ('published', 'in_progress') AND (
        OLD.title <> NEW.title OR
        OLD.description <> NEW.description OR
        OLD.guidelines <> NEW.guidelines OR
        OLD.compensation_type <> NEW.compensation_type OR
        OLD.compensation_description <> NEW.compensation_description OR
        OLD.cash_amount_egp <> NEW.cash_amount_egp OR
        OLD.gift_estimated_value_egp <> NEW.gift_estimated_value_egp OR
        OLD.accepted_deliverable_types <> NEW.accepted_deliverable_types
    ) THEN
        RAISE EXCEPTION 'Campaign details cannot be modified once published.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_campaign_immutability
BEFORE UPDATE ON public.campaigns
FOR EACH ROW
EXECUTE FUNCTION enforce_campaign_immutability();
```

### 4.2 Auto-Transition: Published → In Progress
Fires when the first creator is approved for a published campaign.

```sql
CREATE OR REPLACE FUNCTION auto_transition_campaign_in_progress()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'approved' AND OLD.status = 'applied' THEN
        UPDATE public.campaigns
        SET status = 'in_progress',
            approved_creators_count = approved_creators_count + 1,
            updated_at = NOW()
        WHERE id = NEW.campaign_id
        AND status = 'published';
        
        -- If already in_progress, just increment the count
        UPDATE public.campaigns
        SET approved_creators_count = approved_creators_count + 1,
            updated_at = NOW()
        WHERE id = NEW.campaign_id
        AND status = 'in_progress';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_campaign_in_progress
AFTER UPDATE ON public.campaign_applications
FOR EACH ROW
EXECUTE FUNCTION auto_transition_campaign_in_progress();
```

### 4.3 Auto-Dispute Flag (72-Hour Payment Timeout)
This would be implemented as a scheduled Supabase Edge Function (cron) that checks for applications where `brand_marked_paid_at` is >72 hours ago and `creator_confirmed_paid_at` is NULL.

```sql
-- Run as a scheduled Edge Function, not a trigger
-- SELECT * FROM campaign_applications
-- WHERE payment_status = 'paid_by_brand'
-- AND brand_marked_paid_at < NOW() - INTERVAL '72 hours'
-- AND creator_confirmed_paid_at IS NULL;
-- → Update payment_status to 'disputed_by_creator'
```

---

## 5. Row-Level Security (RLS) Policies

```sql
-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_private_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_google_drive_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brand_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_reviews ENABLE ROW LEVEL SECURITY;

-- 0. Creator Google Drive Accounts: STRICT CREATOR ONLY (ZERO BRAND ACCESS)
CREATE POLICY "Creators can view and manage own Google Drive account"
ON public.creator_google_drive_accounts FOR ALL
USING (auth.uid() = user_id);
-- Note: Brands have NO policy on creator_google_drive_accounts. Even approved brands cannot view or query Drive tokens.

-- 1. Campaigns: Anyone can view published/in_progress; Brand manages own
CREATE POLICY "Anyone can view active campaigns"
ON public.campaigns FOR SELECT
USING (status IN ('published', 'in_progress'));

CREATE POLICY "Brands can manage own campaigns"
ON public.campaigns FOR ALL
USING (auth.uid() = brand_id);

-- 2. Creator Profiles: Self-manage + brands see applicants
CREATE POLICY "Creators can manage own profile"
ON public.creator_profiles FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Brands can view profiles of applicants"
ON public.creator_profiles FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.campaign_applications a
        JOIN public.campaigns c ON c.id = a.campaign_id
        WHERE a.creator_id = public.creator_profiles.user_id
        AND c.brand_id = auth.uid()
    )
);

-- 3. ZERO-TRUST: Creator Private Contacts
-- Only accessible if Brand has APPROVED the application
CREATE POLICY "Creators can view and update own private contacts"
ON public.creator_private_contacts FOR ALL
USING (auth.uid() = user_id);

CREATE POLICY "Approved Brands can view creator private contacts"
ON public.creator_private_contacts FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.campaign_applications a
        JOIN public.campaigns c ON c.id = a.campaign_id
        WHERE a.creator_id = public.creator_private_contacts.user_id
        AND c.brand_id = auth.uid()
        AND a.status NOT IN ('applied', 'rejected', 'withdrawn')
    )
);

-- 4. Applications: Creator views own; Brand views for their campaign
CREATE POLICY "Creators can manage own applications"
ON public.campaign_applications FOR ALL
USING (auth.uid() = creator_id);

CREATE POLICY "Brands can view and update applications for own campaigns"
ON public.campaign_applications FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.campaigns c
        WHERE c.id = public.campaign_applications.campaign_id
        AND c.brand_id = auth.uid()
    )
);

-- 4.1 Submissions: Creator manages own; Brand views ONLY for own campaign
CREATE POLICY "Creators can manage own submissions"
ON public.campaign_submissions FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.campaign_applications a
        WHERE a.id = public.campaign_submissions.application_id
        AND a.creator_id = auth.uid()
    )
);

CREATE POLICY "Brands can view submissions for own campaigns"
ON public.campaign_submissions FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.campaign_applications a
        JOIN public.campaigns c ON c.id = a.campaign_id
        WHERE a.id = public.campaign_submissions.application_id
        AND c.brand_id = auth.uid()
    )
);

-- 5. Portfolios: Creator manages own; anyone can view
CREATE POLICY "Creators can manage own portfolios"
ON public.creator_portfolios FOR ALL
USING (auth.uid() = creator_id);

CREATE POLICY "Anyone can view portfolios"
ON public.creator_portfolios FOR SELECT
USING (true);

-- 6. Reviews: Double-blind visibility
CREATE POLICY "Users can create own reviews"
ON public.campaign_reviews FOR INSERT
WITH CHECK (auth.uid() = rater_id);

CREATE POLICY "Users can view revealed reviews"
ON public.campaign_reviews FOR SELECT
USING (
    is_revealed = true
    OR rater_id = auth.uid()  -- You can always see your own rating
);

-- 7. Admin policies (for admin web portal)
CREATE POLICY "Admins can view all data"
ON public.users FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        WHERE u.id = auth.uid() AND u.role = 'admin'
    )
);
```

---

## 6. Indexes

```sql
-- Campaign discovery (most critical query)
CREATE INDEX idx_campaigns_status ON public.campaigns(status);
CREATE INDEX idx_campaigns_category ON public.campaigns(category);
CREATE INDEX idx_campaigns_brand_id ON public.campaigns(brand_id);
CREATE INDEX idx_campaigns_compensation ON public.campaigns(compensation_type);

-- Application lookups
CREATE INDEX idx_applications_campaign ON public.campaign_applications(campaign_id);
CREATE INDEX idx_applications_creator ON public.campaign_applications(creator_id);
CREATE INDEX idx_applications_status ON public.campaign_applications(status);
CREATE INDEX idx_applications_payment ON public.campaign_applications(payment_status);

-- Portfolio browsing
CREATE INDEX idx_portfolios_creator ON public.creator_portfolios(creator_id);

-- Submission lookups
CREATE INDEX idx_submissions_application ON public.campaign_submissions(application_id);
CREATE INDEX idx_submissions_drive_file ON public.campaign_submissions(google_drive_file_id) WHERE google_drive_file_id IS NOT NULL;
CREATE INDEX idx_submissions_upload_status ON public.campaign_submissions(drive_upload_status);

-- Google Drive Account lookups
CREATE INDEX idx_drive_accounts_user ON public.creator_google_drive_accounts(user_id);
CREATE INDEX idx_drive_accounts_status ON public.creator_google_drive_accounts(account_status);

-- Review lookups & double-blind
CREATE INDEX idx_reviews_application ON public.campaign_reviews(application_id);
CREATE INDEX idx_reviews_ratee ON public.campaign_reviews(ratee_id);

-- FCM token lookups
CREATE INDEX idx_fcm_user ON public.user_fcm_tokens(user_id);
```
