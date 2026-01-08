-- ============================================
-- Add detailed progress fields to user_progress table
-- ============================================
-- This migration adds JSONB columns to store detailed progress data
-- for intelligent merging across devices

-- Add answered_questions column (JSONB array of question IDs)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_progress' 
                   AND column_name = 'answered_questions') THEN
        ALTER TABLE public.user_progress 
        ADD COLUMN answered_questions JSONB DEFAULT '[]'::jsonb;
    END IF;
END $$;

-- Add exams_passed_ids column (JSONB array of exam IDs)
-- Note: Renamed from exams_passed to avoid conflict with existing count column
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_progress' 
                   AND column_name = 'exams_passed_ids') THEN
        ALTER TABLE public.user_progress 
        ADD COLUMN exams_passed_ids JSONB DEFAULT '[]'::jsonb;
    END IF;
END $$;

-- Add last_reset_timestamp column (for conflict resolution)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' 
                   AND table_name = 'user_progress' 
                   AND column_name = 'last_reset_timestamp') THEN
        ALTER TABLE public.user_progress 
        ADD COLUMN last_reset_timestamp TIMESTAMPTZ;
    END IF;
END $$;

-- Create GIN indexes for JSONB columns (for efficient queries)
CREATE INDEX IF NOT EXISTS idx_user_progress_answered_questions 
ON public.user_progress USING GIN (answered_questions) 
WHERE answered_questions IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_user_progress_exams_passed_ids 
ON public.user_progress USING GIN (exams_passed_ids) 
WHERE exams_passed_ids IS NOT NULL;

-- Add comments
COMMENT ON COLUMN public.user_progress.answered_questions IS 'JSONB array of question IDs that have been answered (for intelligent merging)';
COMMENT ON COLUMN public.user_progress.exams_passed_ids IS 'JSONB array of exam IDs that have been passed (for intelligent merging)';
COMMENT ON COLUMN public.user_progress.last_reset_timestamp IS 'Timestamp of last progress reset (for conflict resolution)';

