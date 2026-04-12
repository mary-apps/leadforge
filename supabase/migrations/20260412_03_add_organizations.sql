-- Organizations for team collaboration
CREATE TABLE IF NOT EXISTS organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS org_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(org_id, user_id)
);

ALTER TABLE org_members ENABLE ROW LEVEL SECURITY;

-- Add org_id to shared tables
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS org_id UUID REFERENCES organizations(id) ON DELETE SET NULL;
ALTER TABLE territories ADD COLUMN IF NOT EXISTS org_id UUID REFERENCES organizations(id) ON DELETE SET NULL;
ALTER TABLE reports ADD COLUMN IF NOT EXISTS org_id UUID REFERENCES organizations(id) ON DELETE SET NULL;

-- Add org_id to profiles for quick lookup
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS org_id UUID REFERENCES organizations(id) ON DELETE SET NULL;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_org_members_org_id ON org_members(org_id);
CREATE INDEX IF NOT EXISTS idx_org_members_user_id ON org_members(user_id);
CREATE INDEX IF NOT EXISTS idx_businesses_org_id ON businesses(org_id);
CREATE INDEX IF NOT EXISTS idx_territories_org_id ON territories(org_id);

-- RLS: Organization members can read their org
CREATE POLICY "Members can read own org" ON organizations FOR SELECT
  USING (id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()));

CREATE POLICY "Owner can update org" ON organizations FOR UPDATE
  USING (owner_id = auth.uid());

CREATE POLICY "Users can create orgs" ON organizations FOR INSERT
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Owner can delete org" ON organizations FOR DELETE
  USING (owner_id = auth.uid());

-- RLS: Members can read their org's members
CREATE POLICY "Members can read org members" ON org_members FOR SELECT
  USING (org_id IN (SELECT org_id FROM org_members AS om WHERE om.user_id = auth.uid()));

CREATE POLICY "Admins can manage members" ON org_members FOR INSERT
  WITH CHECK (org_id IN (SELECT org_id FROM org_members AS om WHERE om.user_id = auth.uid() AND om.role IN ('owner', 'admin')));

CREATE POLICY "Admins can remove members" ON org_members FOR DELETE
  USING (org_id IN (SELECT org_id FROM org_members AS om WHERE om.user_id = auth.uid() AND om.role IN ('owner', 'admin')));

-- Function to create org + add owner as member in one transaction
CREATE OR REPLACE FUNCTION public.create_organization(p_name TEXT)
RETURNS UUID AS $$
DECLARE
  v_org_id UUID;
BEGIN
  INSERT INTO organizations (name, owner_id) VALUES (p_name, auth.uid()) RETURNING id INTO v_org_id;
  INSERT INTO org_members (org_id, user_id, role) VALUES (v_org_id, auth.uid(), 'owner');
  UPDATE profiles SET org_id = v_org_id WHERE id = auth.uid();
  RETURN v_org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to invite a member by user_id
CREATE OR REPLACE FUNCTION public.invite_org_member(p_org_id UUID, p_user_id UUID, p_role TEXT DEFAULT 'member')
RETURNS void AS $$
BEGIN
  -- Verify caller is owner or admin
  IF NOT EXISTS (SELECT 1 FROM org_members WHERE org_id = p_org_id AND user_id = auth.uid() AND role IN ('owner', 'admin')) THEN
    RAISE EXCEPTION 'Not authorized to invite members';
  END IF;
  INSERT INTO org_members (org_id, user_id, role) VALUES (p_org_id, p_user_id, p_role)
    ON CONFLICT (org_id, user_id) DO UPDATE SET role = p_role;
  UPDATE profiles SET org_id = p_org_id WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
