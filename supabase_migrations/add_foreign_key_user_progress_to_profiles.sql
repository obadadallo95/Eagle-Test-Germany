-- ============================================
-- Add Foreign Key: user_progress.user_id -> user_profiles.user_id
-- ============================================
-- This migration creates a foreign key relationship between 
-- user_progress and user_profiles tables for Supabase joins.

-- First, ensure both tables exist
DO $$ 
BEGIN
    -- Check if user_profiles table exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_profiles') THEN
        RAISE EXCEPTION 'Table user_profiles does not exist. Run create_user_profiles_table.sql first.';
    END IF;
    
    -- Check if user_progress table exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_progress') THEN
        RAISE EXCEPTION 'Table user_progress does not exist.';
    END IF;
END $$;

-- Add foreign key constraint (if it doesn't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'user_progress_user_id_fkey'
        AND table_name = 'user_progress'
    ) THEN
        ALTER TABLE public.user_progress
        ADD CONSTRAINT user_progress_user_id_fkey
        FOREIGN KEY (user_id) 
        REFERENCES public.user_profiles(user_id)
        ON DELETE CASCADE;
        
        RAISE NOTICE 'Foreign key user_progress_user_id_fkey created successfully.';
    ELSE
        RAISE NOTICE 'Foreign key user_progress_user_id_fkey already exists.';
    END IF;
END $$;

-- Create index on user_progress.user_id for better join performance
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id 
ON public.user_progress(user_id);

-- Add comment for documentation
COMMENT ON CONSTRAINT user_progress_user_id_fkey ON public.user_progress 
IS 'Links user_progress to user_profiles for leaderboard and profile joins';

