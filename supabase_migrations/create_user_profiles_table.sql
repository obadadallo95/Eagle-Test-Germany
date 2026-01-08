-- ============================================
-- Create user_profiles table
-- ============================================
-- This table stores user profile information (name, avatar, etc.)
-- It is linked to auth.users via user_id

-- Create the table
CREATE TABLE IF NOT EXISTS public.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    avatar_url TEXT,
    organization_id UUID,
    is_pro BOOLEAN DEFAULT FALSE,
    subscription_type TEXT, -- 'monthly', 'yearly', 'lifetime', 'trial', null
    subscription_expires_at TIMESTAMPTZ, -- تاريخ انتهاء الاشتراك (null للـ lifetime)
    trial_ends_at TIMESTAMPTZ, -- تاريخ انتهاء التجريبي
    revenuecat_customer_id TEXT, -- RevenueCat Customer ID (للاسترداد عند تغيير الجهاز)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_organization_id ON public.user_profiles(organization_id) WHERE organization_id IS NOT NULL;

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Users can read own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;

-- Policy: Users can read their own profile
CREATE POLICY "Users can read own profile"
    ON public.user_profiles
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile"
    ON public.user_profiles
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update updated_at on row update
-- Drop if exists to avoid conflicts
DROP TRIGGER IF EXISTS set_updated_at ON public.user_profiles;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create function to automatically create profile when user signs up
-- This is a trigger function that runs after a user is created in auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (user_id, created_at, updated_at)
    VALUES (NEW.id, NOW(), NOW())
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create profile when user is created
-- Drop if exists to avoid conflicts
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON public.user_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.user_profiles TO anon;

-- Add comments for documentation
COMMENT ON TABLE public.user_profiles IS 'Stores user profile information including name, avatar, and organization linkage';
COMMENT ON COLUMN public.user_profiles.user_id IS 'Foreign key to auth.users.id';
COMMENT ON COLUMN public.user_profiles.name IS 'User display name (optional)';
COMMENT ON COLUMN public.user_profiles.avatar_url IS 'URL to user avatar image (optional)';
COMMENT ON COLUMN public.user_profiles.organization_id IS 'Organization ID for B2B users (optional)';

