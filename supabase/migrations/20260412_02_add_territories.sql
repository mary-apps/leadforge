-- Add territories for batch scanning
CREATE TABLE IF NOT EXISTS territories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  query TEXT NOT NULL,
  latitude DECIMAL(10,8) NOT NULL,
  longitude DECIMAL(11,8) NOT NULL,
  radius_km DECIMAL(5,2) NOT NULL DEFAULT 2.0,
  business_count INTEGER NOT NULL DEFAULT 0,
  audited_count INTEGER NOT NULL DEFAULT 0,
  last_scanned_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE territories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own territories" ON territories FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own territories" ON territories FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own territories" ON territories FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own territories" ON territories FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_territories_user_id ON territories(user_id);

-- Add territory_id to businesses (nullable FK)
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS territory_id UUID REFERENCES territories(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_businesses_territory_id ON businesses(territory_id);
