-- ============================================================================
-- Remove ALL demo seed data inserted by seed/seed.sql
-- ============================================================================
-- Deletes only rows with the fixed demo UUIDs / demo role keys from seed.sql.
-- Real data is not affected. Children are deleted before parents to respect
-- foreign keys.
--
-- Run against the SAME (staging) database you seeded, with a role that
-- bypasses RLS (service_role / SQL Editor).
-- ============================================================================

BEGIN;

DELETE FROM tickets  WHERE id LIKE '80000000-0000-4000-8000-%';
DELETE FROM invoices WHERE id LIKE '90000000-0000-4000-8000-%';
DELETE FROM payments WHERE id LIKE '70000000-0000-4000-8000-%';
DELETE FROM jobs     WHERE id LIKE 'f0000000-0000-4000-8000-%';
DELETE FROM quotes   WHERE id LIKE 'e0000000-0000-4000-8000-%';
DELETE FROM leads    WHERE id LIKE '60000000-0000-4000-8000-%';
DELETE FROM sites    WHERE id LIKE '50000000-0000-4000-8000-%';
DELETE FROM clients  WHERE id LIKE 'c0000000-0000-4000-8000-%';
DELETE FROM referrers WHERE id LIKE 'a0000000-0000-4000-8000-%';
DELETE FROM billing_entities WHERE id LIKE 'b0000000-0000-4000-8000-%';
DELETE FROM users    WHERE id LIKE 'd0000000-0000-4000-8000-%';

-- Demo roles seeded by seed.sql. This will error if any non-demo user still
-- references one of these keys (that is intentional — it protects real users).
DELETE FROM roles WHERE key IN ('admin','office','sales','technician');

COMMIT;
