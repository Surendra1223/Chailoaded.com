/*
# Fix RLS policies on enquiry tables

1. Security Changes
- franchise_enquiries:
  - INSERT: replaced WITH CHECK (true) with required-field validation
    (name, email, phone, city must be non-empty)
  - UPDATE: dropped always-true policy
  - DELETE: dropped always-true policy
- contact_messages:
  - INSERT: replaced WITH CHECK (true) with required-field validation
    (name, email, message must be non-empty)
  - UPDATE: dropped always-true policy
  - DELETE: dropped always-true policy

2. Why UPDATE/DELETE policies were dropped instead of tightened
- These are single-tenant form-submission tables with NO user_id column,
  so there is no per-row ownership predicate to write.
- The site owner manages submissions through Supabase Studio, which uses
  the service_role that BYPASSES RLS entirely — the owner retains full
  read/update/delete access regardless of any policy.
- Dropping the policies means no authenticated user can modify or delete
  rows through the anon-key client, closing the "always true" bypass.
- Public visitors only INSERT (submit forms); they never read or manage
  submissions, so no anon SELECT/UPDATE/DELETE access is needed.

3. INSERT validation
- The WITH CHECK now rejects rows missing required fields, preventing
  junk/empty submissions even if a request is crafted outside the form.
*/

-- franchise_enquiries: tighten INSERT with required-field validation
DROP POLICY IF EXISTS "anon_insert_franchise_enquiries" ON franchise_enquiries;
CREATE POLICY "anon_insert_franchise_enquiries"
ON franchise_enquiries FOR INSERT
TO anon, authenticated
WITH CHECK (
  name IS NOT NULL AND btrim(name) <> ''
  AND email IS NOT NULL AND btrim(email) <> ''
  AND phone IS NOT NULL AND btrim(phone) <> ''
  AND city IS NOT NULL AND btrim(city) <> ''
);

-- franchise_enquiries: remove always-true UPDATE/DELETE policies
DROP POLICY IF EXISTS "owner_update_franchise_enquiries" ON franchise_enquiries;
DROP POLICY IF EXISTS "owner_delete_franchise_enquiries" ON franchise_enquiries;

-- contact_messages: tighten INSERT with required-field validation
DROP POLICY IF EXISTS "anon_insert_contact_messages" ON contact_messages;
CREATE POLICY "anon_insert_contact_messages"
ON contact_messages FOR INSERT
TO anon, authenticated
WITH CHECK (
  name IS NOT NULL AND btrim(name) <> ''
  AND email IS NOT NULL AND btrim(email) <> ''
  AND message IS NOT NULL AND btrim(message) <> ''
);

-- contact_messages: remove always-true UPDATE/DELETE policies
DROP POLICY IF EXISTS "owner_update_contact_messages" ON contact_messages;
DROP POLICY IF EXISTS "owner_delete_contact_messages" ON contact_messages;