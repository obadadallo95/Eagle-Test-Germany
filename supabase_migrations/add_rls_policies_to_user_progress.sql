-- ============================================
-- Add Row Level Security (RLS) Policies to user_progress table
-- ============================================
-- This migration adds RLS policies to allow users to:
-- 1. Insert their own progress records
-- 2. Update their own progress records
-- 3. Read their own progress records
-- 4. Read shared progress (for Pro users with same revenuecat_customer_id)
--
-- IMPORTANT: This must be run AFTER the user_progress table is created
-- ============================================

-- Enable Row Level Security (RLS) on user_progress table
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can read own progress" ON public.user_progress;
DROP POLICY IF EXISTS "Users can update own progress" ON public.user_progress;
DROP POLICY IF EXISTS "Users can insert own progress" ON public.user_progress;
DROP POLICY IF EXISTS "Users can read shared progress" ON public.user_progress;

-- Policy 1: Users can read their own progress
-- Allows users to SELECT rows where user_id matches their auth.uid()
CREATE POLICY "Users can read own progress"
    ON public.user_progress
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy 2: Users can update their own progress
-- Allows users to UPDATE rows where user_id matches their auth.uid()
CREATE POLICY "Users can update own progress"
    ON public.user_progress
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy 3: Users can insert their own progress
-- Allows users to INSERT rows where user_id matches their auth.uid()
CREATE POLICY "Users can insert own progress"
    ON public.user_progress
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy 4: Users can read shared progress (for Pro users)
-- Allows users to read progress from other devices if they share the same revenuecat_customer_id
-- This enables cross-device sync for Pro subscribers
CREATE POLICY "Users can read shared progress"
    ON public.user_progress
    FOR SELECT
    USING (
        -- User can read if:
        -- 1. It's their own progress (already covered by Policy 1, but included for clarity)
        auth.uid() = user_id
        OR
        -- 2. They share the same revenuecat_customer_id (Pro feature - shared progress)
        (
            revenuecat_customer_id IS NOT NULL
            AND revenuecat_customer_id IN (
                SELECT revenuecat_customer_id 
                FROM public.user_profiles 
                WHERE user_id = auth.uid()
                AND revenuecat_customer_id IS NOT NULL
            )
        )
    );

-- Add comments for documentation
COMMENT ON POLICY "Users can read own progress" ON public.user_progress 
IS 'Allows users to read their own progress records';

COMMENT ON POLICY "Users can update own progress" ON public.user_progress 
IS 'Allows users to update their own progress records';

COMMENT ON POLICY "Users can insert own progress" ON public.user_progress 
IS 'Allows users to insert their own progress records';

COMMENT ON POLICY "Users can read shared progress" ON public.user_progress 
IS 'Allows Pro users to read progress from other devices sharing the same revenuecat_customer_id (cross-device sync)';

