-- Migration: 007_complete_user_onboarding_rpc.sql

-- Helper function: calculate creator profile completion percentage
CREATE OR REPLACE FUNCTION public.calculate_creator_profile_completion(
    p_display_name TEXT,
    p_bio TEXT,
    p_avatar_url TEXT,
    p_niche_categories TEXT[],
    p_governorate TEXT,
    p_tiktok_handle TEXT,
    p_instagram_handle TEXT,
    p_youtube_handle TEXT,
    p_instapay_handle TEXT,
    p_shipping_street_address TEXT
)
RETURNS INT
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_score INT := 0;
BEGIN
    IF p_display_name IS NOT NULL AND length(trim(p_display_name)) > 0 THEN v_score := v_score + 15; END IF;
    IF p_bio IS NOT NULL AND length(trim(p_bio)) > 0 THEN v_score := v_score + 10; END IF;
    IF p_avatar_url IS NOT NULL AND length(trim(p_avatar_url)) > 0 THEN v_score := v_score + 15; END IF;
    IF p_niche_categories IS NOT NULL AND array_length(p_niche_categories, 1) > 0 THEN v_score := v_score + 15; END IF;
    IF p_governorate IS NOT NULL AND length(trim(p_governorate)) > 0 THEN v_score := v_score + 10; END IF;
    IF (p_tiktok_handle IS NOT NULL AND length(trim(p_tiktok_handle)) > 0) OR
       (p_instagram_handle IS NOT NULL AND length(trim(p_instagram_handle)) > 0) OR
       (p_youtube_handle IS NOT NULL AND length(trim(p_youtube_handle)) > 0) THEN v_score := v_score + 15; END IF;
    IF p_instapay_handle IS NOT NULL AND length(trim(p_instapay_handle)) > 0 THEN v_score := v_score + 10; END IF;
    IF p_shipping_street_address IS NOT NULL AND length(trim(p_shipping_street_address)) > 0 THEN v_score := v_score + 10; END IF;
    
    RETURN LEAST(v_score, 100);
END;
$$;

-- Atomic Onboarding Function
CREATE OR REPLACE FUNCTION public.complete_user_onboarding(
    p_role user_role,
    p_display_name TEXT DEFAULT NULL,
    p_company_name TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_governorate TEXT DEFAULT NULL,
    p_bio TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL,
    p_niche_categories TEXT[] DEFAULT '{}',
    p_custom_niche TEXT DEFAULT NULL,
    p_tiktok_handle TEXT DEFAULT NULL,
    p_instagram_handle TEXT DEFAULT NULL,
    p_youtube_handle TEXT DEFAULT NULL,
    p_full_legal_name TEXT DEFAULT NULL,
    p_contact_phone TEXT DEFAULT NULL,
    p_instapay_handle TEXT DEFAULT NULL,
    p_shipping_governorate TEXT DEFAULT NULL,
    p_shipping_city TEXT DEFAULT NULL,
    p_shipping_street_address TEXT DEFAULT NULL,
    p_shipping_building_details TEXT DEFAULT NULL,
    p_industry_category TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_website_url TEXT DEFAULT NULL,
    p_logo_url TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_user_id UUID;
    v_auth_phone TEXT;
    v_auth_email TEXT;
    v_effective_phone TEXT;
    v_effective_email TEXT;
    v_existing_role user_role;
    v_completion_pct INT := 0;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '42501';
    END IF;

    -- Fetch credentials from auth.users
    SELECT phone, email INTO v_auth_phone, v_auth_email
    FROM auth.users
    WHERE id = v_user_id;

    v_effective_phone := COALESCE(v_auth_phone, p_contact_phone);
    IF v_effective_phone IS NULL THEN
        RAISE EXCEPTION 'Phone number is required for user account creation.' USING ERRCODE = '23502';
    END IF;

    v_effective_email := COALESCE(p_email, v_auth_email);

    -- Check if user already exists in public.users
    SELECT role INTO v_existing_role
    FROM public.users
    WHERE id = v_user_id;

    IF v_existing_role IS NOT NULL AND v_existing_role <> p_role THEN
        RAISE EXCEPTION 'User role is immutable once assigned (existing: %, requested: %).', v_existing_role, p_role USING ERRCODE = '23514';
    END IF;

    -- Insert or update public.users
    INSERT INTO public.users (
        id,
        role,
        email,
        phone,
        phone_verified,
        status,
        updated_at
    ) VALUES (
        v_user_id,
        p_role,
        v_effective_email,
        v_effective_phone,
        (v_auth_phone IS NOT NULL),
        'active',
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        role = EXCLUDED.role,
        email = COALESCE(EXCLUDED.email, public.users.email),
        phone = COALESCE(EXCLUDED.phone, public.users.phone),
        phone_verified = (v_auth_phone IS NOT NULL),
        updated_at = NOW();

    -- Role-specific branch
    IF p_role = 'creator' THEN
        IF p_display_name IS NULL OR length(trim(p_display_name)) = 0 THEN
            RAISE EXCEPTION 'Display name is required for creators.' USING ERRCODE = '23502';
        END IF;

        IF p_governorate IS NULL OR length(trim(p_governorate)) = 0 THEN
            RAISE EXCEPTION 'Governorate is required for creators.' USING ERRCODE = '23502';
        END IF;

        v_completion_pct := calculate_creator_profile_completion(
            p_display_name,
            p_bio,
            p_avatar_url,
            p_niche_categories,
            p_governorate,
            p_tiktok_handle,
            p_instagram_handle,
            p_youtube_handle,
            p_instapay_handle,
            p_shipping_street_address
        );

        INSERT INTO public.creator_profiles (
            user_id,
            display_name,
            bio,
            avatar_url,
            niche_categories,
            custom_niche,
            governorate,
            tiktok_handle,
            instagram_handle,
            youtube_handle,
            profile_completion_pct,
            updated_at
        ) VALUES (
            v_user_id,
            p_display_name,
            p_bio,
            p_avatar_url,
            COALESCE(p_niche_categories, '{}'),
            p_custom_niche,
            p_governorate,
            p_tiktok_handle,
            p_instagram_handle,
            p_youtube_handle,
            v_completion_pct,
            NOW()
        )
        ON CONFLICT (user_id) DO UPDATE SET
            display_name = EXCLUDED.display_name,
            bio = EXCLUDED.bio,
            avatar_url = EXCLUDED.avatar_url,
            niche_categories = EXCLUDED.niche_categories,
            custom_niche = EXCLUDED.custom_niche,
            governorate = EXCLUDED.governorate,
            tiktok_handle = EXCLUDED.tiktok_handle,
            instagram_handle = EXCLUDED.instagram_handle,
            youtube_handle = EXCLUDED.youtube_handle,
            profile_completion_pct = EXCLUDED.profile_completion_pct,
            updated_at = NOW();

        -- Insert or update private contacts (PII)
        INSERT INTO public.creator_private_contacts (
            user_id,
            full_legal_name,
            contact_phone,
            instapay_handle,
            shipping_governorate,
            shipping_city,
            shipping_street_address,
            shipping_building_details,
            updated_at
        ) VALUES (
            v_user_id,
            COALESCE(p_full_legal_name, p_display_name),
            v_effective_phone,
            p_instapay_handle,
            COALESCE(p_shipping_governorate, p_governorate),
            p_shipping_city,
            p_shipping_street_address,
            p_shipping_building_details,
            NOW()
        )
        ON CONFLICT (user_id) DO UPDATE SET
            full_legal_name = EXCLUDED.full_legal_name,
            contact_phone = EXCLUDED.contact_phone,
            instapay_handle = EXCLUDED.instapay_handle,
            shipping_governorate = EXCLUDED.shipping_governorate,
            shipping_city = EXCLUDED.shipping_city,
            shipping_street_address = EXCLUDED.shipping_street_address,
            shipping_building_details = EXCLUDED.shipping_building_details,
            updated_at = NOW();

    ELSIF p_role = 'brand' THEN
        IF p_company_name IS NULL OR length(trim(p_company_name)) = 0 THEN
            RAISE EXCEPTION 'Company name is required for brands.' USING ERRCODE = '23502';
        END IF;

        IF p_industry_category IS NULL OR length(trim(p_industry_category)) = 0 THEN
            RAISE EXCEPTION 'Industry category is required for brands.' USING ERRCODE = '23502';
        END IF;

        INSERT INTO public.brand_profiles (
            user_id,
            company_name,
            industry_category,
            description,
            logo_url,
            website_url,
            governorate,
            updated_at
        ) VALUES (
            v_user_id,
            p_company_name,
            p_industry_category,
            p_description,
            p_logo_url,
            p_website_url,
            p_governorate,
            NOW()
        )
        ON CONFLICT (user_id) DO UPDATE SET
            company_name = EXCLUDED.company_name,
            industry_category = EXCLUDED.industry_category,
            description = EXCLUDED.description,
            logo_url = EXCLUDED.logo_url,
            website_url = EXCLUDED.website_url,
            governorate = EXCLUDED.governorate,
            updated_at = NOW();
    END IF;

    RETURN jsonb_build_object(
        'success', true,
        'profile_id', v_user_id,
        'role', p_role
    );
END;
$$;

-- Current user profile status RPC
CREATE OR REPLACE FUNCTION public.get_current_user_profile()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_user_id UUID;
    v_user RECORD;
    v_creator RECORD;
    v_brand RECORD;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object('authenticated', false);
    END IF;

    SELECT id, role, email, phone, phone_verified, status, created_at
    INTO v_user
    FROM public.users
    WHERE id = v_user_id;

    IF v_user.id IS NULL THEN
        RETURN jsonb_build_object(
            'authenticated', true,
            'onboarded', false,
            'user_id', v_user_id
        );
    END IF;

    IF v_user.role = 'creator' THEN
        SELECT user_id, display_name, bio, avatar_url, niche_categories, custom_niche,
               governorate, tiktok_handle, instagram_handle, youtube_handle,
               follower_count, engagement_rate, profile_completion_pct,
               average_rating, ratings_count
        INTO v_creator
        FROM public.creator_profiles
        WHERE user_id = v_user_id;

        RETURN jsonb_build_object(
            'authenticated', true,
            'onboarded', true,
            'user', to_jsonb(v_user),
            'creator_profile', to_jsonb(v_creator)
        );
    ELSIF v_user.role = 'brand' THEN
        SELECT user_id, company_name, industry_category, description,
               logo_url, website_url, governorate, average_rating,
               ratings_count, is_verified
        INTO v_brand
        FROM public.brand_profiles
        WHERE user_id = v_user_id;

        RETURN jsonb_build_object(
            'authenticated', true,
            'onboarded', true,
            'user', to_jsonb(v_user),
            'brand_profile', to_jsonb(v_brand)
        );
    ELSE
        RETURN jsonb_build_object(
            'authenticated', true,
            'onboarded', true,
            'user', to_jsonb(v_user)
        );
    END IF;
END;
$$;
