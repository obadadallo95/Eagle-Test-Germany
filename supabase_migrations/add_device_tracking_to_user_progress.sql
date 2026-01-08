-- ============================================
-- Add device tracking fields to user_progress table
-- ============================================
-- This migration adds last_active_at to track device activity
-- for enforcing the 3-device limit for Pro subscribers

-- Add last_active_at column (if it doesn't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_progress' 
                   AND column_name = 'last_active_at') THEN
        ALTER TABLE public.user_progress 
        ADD COLUMN last_active_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- Create index for faster lookups by last_active_at (for device limit queries)
CREATE INDEX IF NOT EXISTS idx_user_progress_last_active_at 
ON public.user_progress(last_active_at) 
WHERE last_active_at IS NOT NULL;

-- Create composite index for device limit queries (revenuecat_customer_id + last_active_at)
CREATE INDEX IF NOT EXISTS idx_user_progress_revenuecat_last_active 
ON public.user_progress(revenuecat_customer_id, last_active_at) 
WHERE revenuecat_customer_id IS NOT NULL;

-- Add comment
COMMENT ON COLUMN public.user_progress.last_active_at IS 'Last time this device synced progress (for device limit enforcement)';

