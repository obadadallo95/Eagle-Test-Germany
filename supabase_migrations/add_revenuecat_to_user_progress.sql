-- ============================================
-- Add revenuecat_customer_id to user_progress table
-- ============================================
-- This migration adds revenuecat_customer_id to enable shared progress
-- across multiple devices (up to 3 devices) for Pro subscribers

-- Add revenuecat_customer_id column (if it doesn't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_progress' 
                   AND column_name = 'revenuecat_customer_id') THEN
        ALTER TABLE public.user_progress 
        ADD COLUMN revenuecat_customer_id TEXT;
    END IF;
END $$;

-- Create index for faster lookups by revenuecat_customer_id
CREATE INDEX IF NOT EXISTS idx_user_progress_revenuecat_customer_id 
ON public.user_progress(revenuecat_customer_id) 
WHERE revenuecat_customer_id IS NOT NULL;

-- Add comment
COMMENT ON COLUMN public.user_progress.revenuecat_customer_id IS 'RevenueCat Customer ID for shared progress across devices (Pro feature)';

