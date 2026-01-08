-- ============================================
-- Add subscription fields to user_profiles table
-- ============================================
-- This migration adds subscription-related columns to support
-- trial subscriptions and Supabase-based subscription verification

-- Add subscription columns (if they don't exist)
DO $$ 
BEGIN
    -- Add is_pro column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_profiles' 
                   AND column_name = 'is_pro') THEN
        ALTER TABLE public.user_profiles 
        ADD COLUMN is_pro BOOLEAN DEFAULT FALSE;
    END IF;

    -- Add subscription_type column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_profiles' 
                   AND column_name = 'subscription_type') THEN
        ALTER TABLE public.user_profiles 
        ADD COLUMN subscription_type TEXT;
    END IF;

    -- Add subscription_expires_at column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_profiles' 
                   AND column_name = 'subscription_expires_at') THEN
        ALTER TABLE public.user_profiles 
        ADD COLUMN subscription_expires_at TIMESTAMPTZ;
    END IF;

    -- Add trial_ends_at column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_profiles' 
                   AND column_name = 'trial_ends_at') THEN
        ALTER TABLE public.user_profiles 
        ADD COLUMN trial_ends_at TIMESTAMPTZ;
    END IF;

    -- Add revenuecat_customer_id column (for restore purchases)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_profiles' 
                   AND column_name = 'revenuecat_customer_id') THEN
        ALTER TABLE public.user_profiles 
        ADD COLUMN revenuecat_customer_id TEXT;
    END IF;
END $$;

-- Create index for faster subscription queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_is_pro ON public.user_profiles(is_pro) WHERE is_pro = TRUE;
CREATE INDEX IF NOT EXISTS idx_user_profiles_subscription_expires_at ON public.user_profiles(subscription_expires_at) WHERE subscription_expires_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_profiles_trial_ends_at ON public.user_profiles(trial_ends_at) WHERE trial_ends_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_profiles_revenuecat_customer_id ON public.user_profiles(revenuecat_customer_id) WHERE revenuecat_customer_id IS NOT NULL;

-- Add comments
COMMENT ON COLUMN public.user_profiles.is_pro IS 'Whether user has active Pro subscription';
COMMENT ON COLUMN public.user_profiles.subscription_type IS 'Type of subscription: monthly, yearly, lifetime, trial, revenuecat';
COMMENT ON COLUMN public.user_profiles.subscription_expires_at IS 'When subscription expires (null for lifetime)';
COMMENT ON COLUMN public.user_profiles.trial_ends_at IS 'When trial period ends';
COMMENT ON COLUMN public.user_profiles.revenuecat_customer_id IS 'RevenueCat Customer ID for restore purchases across devices';

