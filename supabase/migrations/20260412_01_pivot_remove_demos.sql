-- LeadForge Pivot: Remove demos, add reports
-- Run this in Supabase Dashboard > SQL Editor

-- 1. Update existing demo_created businesses to audited
UPDATE businesses SET status = 'audited' WHERE status = 'demo_created';

-- 2. Update status constraint: replace demo_created with report_sent
ALTER TABLE businesses DROP CONSTRAINT IF EXISTS businesses_status_check;
ALTER TABLE businesses ADD CONSTRAINT businesses_status_check
  CHECK (status IN ('found', 'audited', 'report_sent', 'contacted', 'interested', 'closed', 'lost'));

-- 3. Drop demos table and related storage
DROP TABLE IF EXISTS demos CASCADE;
DELETE FROM storage.objects WHERE bucket_id = 'demos';
DELETE FROM storage.buckets WHERE id = 'demos';

-- 4. Add reports_this_month to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS reports_this_month INTEGER NOT NULL DEFAULT 0;

-- 5. Update increment_counter function
CREATE OR REPLACE FUNCTION public.increment_counter(p_user_id UUID, p_column TEXT)
RETURNS void AS $$
BEGIN
  IF p_column = 'searches_this_month' THEN
    UPDATE profiles SET searches_this_month = searches_this_month + 1 WHERE id = p_user_id;
  ELSIF p_column = 'audits_this_month' THEN
    UPDATE profiles SET audits_this_month = audits_this_month + 1 WHERE id = p_user_id;
  ELSIF p_column = 'reports_this_month' THEN
    UPDATE profiles SET reports_this_month = reports_this_month + 1 WHERE id = p_user_id;
  ELSE
    RAISE EXCEPTION 'Invalid column: %', p_column;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Update monthly reset
CREATE OR REPLACE FUNCTION public.reset_monthly_limits()
RETURNS void AS $$
BEGIN
  UPDATE profiles SET
    searches_this_month = 0,
    audits_this_month = 0,
    reports_this_month = 0,
    month_reset_at = date_trunc('month', now()) + interval '1 month'
  WHERE month_reset_at <= now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Create reports table
CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  breakdown JSONB NOT NULL,
  diagnosis TEXT NOT NULL,
  recommendations JSONB NOT NULL DEFAULT '[]',
  pdf_storage_path TEXT,
  shared_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own reports" ON reports FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own reports" ON reports FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own reports" ON reports FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_reports_business_id ON reports(business_id);
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON reports(user_id);

-- 8. Create reports storage bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('reports', 'reports', false) ON CONFLICT DO NOTHING;

CREATE POLICY "Users can upload reports" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'reports' AND auth.uid()::text = (storage.foldername(name))[2]);
CREATE POLICY "Users can read own reports" ON storage.objects FOR SELECT
  USING (bucket_id = 'reports' AND auth.uid()::text = (storage.foldername(name))[2]);
CREATE POLICY "Users can delete own reports" ON storage.objects FOR DELETE
  USING (bucket_id = 'reports' AND auth.uid()::text = (storage.foldername(name))[2]);
