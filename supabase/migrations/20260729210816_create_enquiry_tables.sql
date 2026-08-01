/*
# Create enquiry tables for Chai Loaded (single-tenant, no auth)

1. New Tables
- `franchise_enquiries`
  - id (uuid, primary key)
  - name (text, not null) — applicant's full name
  - email (text, not null) — applicant's email
  - phone (text, not null) — contact number
  - city (text, not null) — proposed franchise city
  - investment_range (text) — selected investment bracket
  - message (text) — optional details
  - status (text, default 'new') — enquiry lifecycle state
  - created_at (timestamptz)
- `contact_messages`
  - id (uuid, primary key)
  - name (text, not null)
  - email (text, not null)
  - subject (text)
  - message (text, not null)
  - status (text, default 'new')
  - created_at (timestamptz)
2. Security
- RLS enabled on both tables.
- No sign-in screen exists on this site, so all policies use `TO anon, authenticated`
  so the anon-key frontend can submit (INSERT) and the public site never needs to read back.
- SELECT/UPDATE/DELETE are intentionally restricted to authenticated (site owner) only;
  public visitors only INSERT (they never read or manage submissions).
- Notes:
  - Visitors only write enquiries; they do not read them back, so no anon SELECT policy.
  - The authenticated owner (signed in via Supabase dashboard/Studio) can read/manage.
*/

CREATE TABLE IF NOT EXISTS franchise_enquiries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  city text NOT NULL,
  investment_range text,
  message text,
  status text NOT NULL DEFAULT 'new',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS contact_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  subject text,
  message text NOT NULL,
  status text NOT NULL DEFAULT 'new',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE franchise_enquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;

-- franchise_enquiries: public can INSERT, only authenticated (owner) can read/update/delete
DROP POLICY IF EXISTS "anon_insert_franchise_enquiries" ON franchise_enquiries;
CREATE POLICY "anon_insert_franchise_enquiries"
ON franchise_enquiries FOR INSERT
TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "owner_select_franchise_enquiries" ON franchise_enquiries;
CREATE POLICY "owner_select_franchise_enquiries"
ON franchise_enquiries FOR SELECT
TO authenticated USING (true);

DROP POLICY IF EXISTS "owner_update_franchise_enquiries" ON franchise_enquiries;
CREATE POLICY "owner_update_franchise_enquiries"
ON franchise_enquiries FOR UPDATE
TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "owner_delete_franchise_enquiries" ON franchise_enquiries;
CREATE POLICY "owner_delete_franchise_enquiries"
ON franchise_enquiries FOR DELETE
TO authenticated USING (true);

-- contact_messages: public can INSERT, only authenticated (owner) can read/update/delete
DROP POLICY IF EXISTS "anon_insert_contact_messages" ON contact_messages;
CREATE POLICY "anon_insert_contact_messages"
ON contact_messages FOR INSERT
TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "owner_select_contact_messages" ON contact_messages;
CREATE POLICY "owner_select_contact_messages"
ON contact_messages FOR SELECT
TO authenticated USING (true);

DROP POLICY IF EXISTS "owner_update_contact_messages" ON contact_messages;
CREATE POLICY "owner_update_contact_messages"
ON contact_messages FOR UPDATE
TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "owner_delete_contact_messages" ON contact_messages;
CREATE POLICY "owner_delete_contact_messages"
ON contact_messages FOR DELETE
TO authenticated USING (true);