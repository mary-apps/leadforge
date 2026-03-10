-- ============================================
-- LeadForge - Supabase Schema
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. PROFILES TABLE
-- Auto-created on user signup via trigger
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  business_name TEXT,
  preferred_language TEXT NOT NULL DEFAULT 'en',
  subscription_tier TEXT NOT NULL DEFAULT 'free' CHECK (subscription_tier IN ('free', 'pro')),
  searches_this_month INTEGER NOT NULL DEFAULT 0,
  audits_this_month INTEGER NOT NULL DEFAULT 0,
  demos_this_month INTEGER NOT NULL DEFAULT 0,
  month_reset_at TIMESTAMPTZ NOT NULL DEFAULT (date_trunc('month', now()) + interval '1 month'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. BUSINESSES TABLE
CREATE TABLE IF NOT EXISTS businesses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  search_id TEXT,
  place_id TEXT NOT NULL,
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  website TEXT,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  rating DECIMAL(3,2),
  reviews_count INTEGER NOT NULL DEFAULT 0,
  photos JSONB NOT NULL DEFAULT '[]'::jsonb,
  categories JSONB NOT NULL DEFAULT '[]'::jsonb,
  opening_hours JSONB,
  web_presence TEXT NOT NULL DEFAULT 'none' CHECK (web_presence IN ('none', 'poor', 'decent')),
  audit_score INTEGER CHECK (audit_score >= 0 AND audit_score <= 100),
  audit_breakdown JSONB,
  audit_diagnosis TEXT,
  audited_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'found' CHECK (status IN ('found', 'audited', 'demo_created', 'contacted', 'interested', 'closed', 'lost')),
  notes TEXT,
  deal_value DECIMAL(12,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- 3. DEMOS TABLE
CREATE TABLE IF NOT EXISTS demos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  template TEXT NOT NULL CHECK (template IN ('restaurant', 'professional', 'health_beauty')),
  storage_path TEXT NOT NULL,
  public_slug TEXT NOT NULL UNIQUE,
  business_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  views INTEGER NOT NULL DEFAULT 0,
  last_viewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. MESSAGES TABLE
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  channel TEXT NOT NULL CHECK (channel IN ('email', 'whatsapp', 'instagram', 'phone', 'other')),
  tone TEXT NOT NULL DEFAULT 'professional',
  language TEXT NOT NULL DEFAULT 'en',
  content TEXT NOT NULL,
  copied_at TIMESTAMPTZ,
  marked_sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- INDEXES
-- ============================================

-- Unique constraint for upsert (prevents duplicate place per user)
ALTER TABLE businesses ADD CONSTRAINT uq_businesses_user_place UNIQUE (user_id, place_id);

CREATE INDEX IF NOT EXISTS idx_businesses_user_id ON businesses(user_id);
CREATE INDEX IF NOT EXISTS idx_businesses_user_status ON businesses(user_id, status);
CREATE INDEX IF NOT EXISTS idx_businesses_created_at ON businesses(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_demos_business_id ON demos(business_id);
CREATE INDEX IF NOT EXISTS idx_demos_user_id ON demos(user_id);
CREATE INDEX IF NOT EXISTS idx_demos_public_slug ON demos(public_slug);
CREATE INDEX IF NOT EXISTS idx_messages_business_id ON messages(business_id);
CREATE INDEX IF NOT EXISTS idx_messages_user_id ON messages(user_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE demos ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- PROFILES: Users can only read/update their own profile
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- BUSINESSES: Users can CRUD their own businesses
CREATE POLICY "Users can read own businesses"
  ON businesses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own businesses"
  ON businesses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own businesses"
  ON businesses FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own businesses"
  ON businesses FOR DELETE
  USING (auth.uid() = user_id);

-- DEMOS: Users can CRUD their own demos
CREATE POLICY "Users can read own demos"
  ON demos FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own demos"
  ON demos FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own demos"
  ON demos FOR DELETE
  USING (auth.uid() = user_id);

-- MESSAGES: Users can CRUD their own messages
CREATE POLICY "Users can read own messages"
  ON messages FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own messages"
  ON messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own messages"
  ON messages FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- TRIGGER: Auto-create profile on signup
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, created_at, month_reset_at)
  VALUES (
    new.id,
    now(),
    date_trunc('month', now()) + interval '1 month'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists, then create
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- FUNCTION: Reset monthly limits
-- Run this as a cron job (1st of each month)
-- ============================================

CREATE OR REPLACE FUNCTION public.reset_monthly_limits()
RETURNS void AS $$
BEGIN
  UPDATE profiles
  SET
    searches_this_month = 0,
    audits_this_month = 0,
    demos_this_month = 0,
    month_reset_at = date_trunc('month', now()) + interval '1 month'
  WHERE month_reset_at <= now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STORAGE: Create demos bucket
-- Run this in SQL Editor after schema setup
-- ============================================

-- Create storage bucket for demo HTML files
INSERT INTO storage.buckets (id, name, public)
VALUES ('demos', 'demos', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload demos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'demos' AND
    auth.uid()::text = (storage.foldername(name))[2]
  );

-- Allow public read access for demo serving
CREATE POLICY "Public can read demos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'demos');

-- Allow users to delete their own demos
CREATE POLICY "Users can delete own demos storage"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'demos' AND
    auth.uid()::text = (storage.foldername(name))[2]
  );
