-- ============================================================================
-- Brijstar CRM — demo seed data (STAGING ONLY)
-- ============================================================================
-- Inserts a small, coherent demo dataset: billing entity, referrers, clients,
-- sites across pipeline stages, leads, quotes, jobs, payments, invoices and
-- tickets. Fixed UUIDs + ON CONFLICT DO NOTHING make it safe to re-run.
--
-- HOW TO RUN (pick one), against your STAGING project only:
--   • Supabase Dashboard -> SQL Editor -> paste this file -> Run
--   • psql "<staging service-role connection string>" -f seed/seed.sql
--
-- Run with a role that bypasses RLS (service_role / the SQL editor). The anon
-- key cannot and should not be able to insert this.
--
-- !! DO NOT run against production. !!
--
-- NOTE ON ROLES: this DB's `roles` / `permissions` tables are empty, and
-- users.role is a FK to roles.key. The role keys below ('admin','office',
-- 'technician','sales') are demo placeholders — change them to match your
-- app's real role keys before running if they differ.
-- ============================================================================

BEGIN;

-- --- roles (needed before users) -------------------------------------------
INSERT INTO roles (key, label, app, is_system) VALUES
  ('admin',      'Administrator', 'management', true),
  ('office',     'Office Staff',  'management', false),
  ('sales',      'Sales',         'management', false),
  ('technician', 'Technician',    'field',      false)
ON CONFLICT (key) DO NOTHING;

-- --- users ------------------------------------------------------------------
INSERT INTO users (id, name, phone, email, role) VALUES
  ('d0000000-0000-4000-8000-000000000001', 'Asha Admin',      '+919800000001', 'asha@brijstar.example',  'admin'),
  ('d0000000-0000-4000-8000-000000000002', 'Omkar Office',    '+919800000002', 'omkar@brijstar.example', 'office'),
  ('d0000000-0000-4000-8000-000000000003', 'Sanjay Sales',    '+919800000003', 'sanjay@brijstar.example','sales'),
  ('d0000000-0000-4000-8000-000000000004', 'Tarun Technician','+919800000004', 'tarun@brijstar.example', 'technician')
ON CONFLICT (id) DO NOTHING;

-- --- billing entity ---------------------------------------------------------
INSERT INTO billing_entities (id, name, gstin, address, phone, email, invoice_prefix) VALUES
  ('b0000000-0000-4000-8000-000000000001', 'Brijstar Energy Pvt Ltd', '27AAACB1234C1ZV',
   '12 Solar Park Rd, Pune, Maharashtra 411001', '+912000000000', 'billing@brijstar.example', 'BE')
ON CONFLICT (id) DO NOTHING;

-- --- referrers --------------------------------------------------------------
INSERT INTO referrers (id, type, name, phone) VALUES
  ('a0000000-0000-4000-8000-000000000001', 'client', 'Rakesh Patil',  '+919811111111'),
  ('a0000000-0000-4000-8000-000000000002', 'agent',  'GreenLead Agency','+919822222222')
ON CONFLICT (id) DO NOTHING;

-- --- clients ----------------------------------------------------------------
INSERT INTO clients (id, client_code, name, type, phone, email, billing_address, gstin) VALUES
  ('c0000000-0000-4000-8000-000000000001', 'CL-0001', 'Meera Joshi',           'individual', '+919830000001', 'meera@example.com',  '7 Lane 3, Kothrud, Pune 411038', NULL),
  ('c0000000-0000-4000-8000-000000000002', 'CL-0002', 'Vivek Deshmukh',        'individual', '+919830000002', 'vivek@example.com',  '22 Baner Rd, Pune 411045',       NULL),
  ('c0000000-0000-4000-8000-000000000003', 'CL-0003', 'Sunrise Textiles Pvt Ltd','company',  '+919830000003', 'accounts@sunrise.example', 'Plot 14 MIDC, Pune 411019', '27AAACS9876F1Z2'),
  ('c0000000-0000-4000-8000-000000000004', 'CL-0004', 'Harmony Hospital',      'company',    '+919830000004', 'admin@harmony.example','45 Ring Rd, Pune 411014',   '27AAACH5432K1Z8')
ON CONFLICT (id) DO NOTHING;

-- --- sites (spread across pipeline stages) ----------------------------------
INSERT INTO sites (id, site_code, client_id, name, pipeline, domestic_stage, ci_stage, owner_id,
                   address, system_kwp, order_value, referrer_id) VALUES
  ('50000000-0000-4000-8000-000000000001', 'CL-0001-S1', 'c0000000-0000-4000-8000-000000000001',
     'Joshi Residence',    'domestic', 'survey_done',        NULL, 'd0000000-0000-4000-8000-000000000003',
     '7 Lane 3, Kothrud, Pune', 3.0, 180000, 'a0000000-0000-4000-8000-000000000001'),
  ('50000000-0000-4000-8000-000000000002', 'CL-0002-S1', 'c0000000-0000-4000-8000-000000000002',
     'Deshmukh Villa',     'domestic', 'quote_sent',         NULL, 'd0000000-0000-4000-8000-000000000003',
     '22 Baner Rd, Pune', 5.0, 310000, NULL),
  ('50000000-0000-4000-8000-000000000003', 'CL-0001-S2', 'c0000000-0000-4000-8000-000000000001',
     'Joshi Farmhouse',    'domestic', 'installation_done',  NULL, 'd0000000-0000-4000-8000-000000000003',
     'Mulshi Rd, Pune', 6.5, 400000, NULL),
  ('50000000-0000-4000-8000-000000000004', 'CL-0003-S1', 'c0000000-0000-4000-8000-000000000003',
     'Sunrise Factory Roof','ci',       NULL, 'proposal_sent',       'd0000000-0000-4000-8000-000000000003',
     'Plot 14 MIDC, Pune', 120.0, 5400000, 'a0000000-0000-4000-8000-000000000002'),
  ('50000000-0000-4000-8000-000000000005', 'CL-0004-S1', 'c0000000-0000-4000-8000-000000000004',
     'Harmony Hospital Block A','ci',    NULL, 'handover_complete',   'd0000000-0000-4000-8000-000000000003',
     '45 Ring Rd, Pune', 75.0, 3600000, NULL)
ON CONFLICT (id) DO NOTHING;

-- --- leads (various statuses) -----------------------------------------------
INSERT INTO leads (id, name, phone, location, category, monthly_bill, source, status, owner_id) VALUES
  ('60000000-0000-4000-8000-000000000001', 'Priya Kulkarni', '+919840000001', 'Pune',      'domestic',   2500,  'meta_ads',       'new',              'd0000000-0000-4000-8000-000000000003'),
  ('60000000-0000-4000-8000-000000000002', 'Anil Shah',      '+919840000002', 'Pune',      'domestic',   3200,  'website',        'contacted',        'd0000000-0000-4000-8000-000000000003'),
  ('60000000-0000-4000-8000-000000000003', 'Nitin Rao',      '+919840000003', 'Pimpri',    'domestic',   4100,  'referral',       'follow_up',        'd0000000-0000-4000-8000-000000000003'),
  ('60000000-0000-4000-8000-000000000004', 'Zenith Foods',   '+919840000004', 'Chakan',    'commercial', 85000, 'field_sales',    'qualified',        'd0000000-0000-4000-8000-000000000003'),
  ('60000000-0000-4000-8000-000000000005', 'Deepa Menon',    '+919840000005', 'Hinjewadi', 'domestic',   1900,  'justdial',       'not_interested',   'd0000000-0000-4000-8000-000000000003'),
  ('60000000-0000-4000-8000-000000000006', 'Orbit Logistics','+919840000006', 'Wagholi',   'industrial', 210000,'google_business','survey_requested', 'd0000000-0000-4000-8000-000000000003')
ON CONFLICT (id) DO NOTHING;

-- --- quotes -----------------------------------------------------------------
INSERT INTO quotes (id, site_id, status, template, input, meta, result, price_status,
                    system_kwp, total, brand, created_by) VALUES
  ('e0000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000002', 'sent',
     'domestic_subsidy', '{"units_per_month":450}'::jsonb, '{"notes":"demo quote"}'::jsonb,
     '{"system_kwp":5.0,"total":310000}'::jsonb, 'priced', 5.0, 310000, 'tata',
     'd0000000-0000-4000-8000-000000000003'),
  ('e0000000-0000-4000-8000-000000000002', '50000000-0000-4000-8000-000000000003', 'accepted',
     'domestic_subsidy', '{"units_per_month":600}'::jsonb, '{"notes":"demo quote"}'::jsonb,
     '{"system_kwp":6.5,"total":400000}'::jsonb, 'priced', 6.5, 400000, 'tata',
     'd0000000-0000-4000-8000-000000000003'),
  ('e0000000-0000-4000-8000-000000000003', '50000000-0000-4000-8000-000000000004', 'sent',
     'ci_capex', '{"contract_demand_kva":150}'::jsonb, '{"notes":"demo quote"}'::jsonb,
     '{"system_kwp":120.0,"total":5400000}'::jsonb, 'priced', 120.0, 5400000, 'tata',
     'd0000000-0000-4000-8000-000000000003')
ON CONFLICT (id) DO NOTHING;

-- --- jobs -------------------------------------------------------------------
INSERT INTO jobs (id, site_id, type, technician_id, scheduled_at, status, helpers, created_by) VALUES
  ('f0000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001', 'survey',
     'd0000000-0000-4000-8000-000000000004', now() - interval '10 days', 'approved',    '{}', 'd0000000-0000-4000-8000-000000000002'),
  ('f0000000-0000-4000-8000-000000000002', '50000000-0000-4000-8000-000000000003', 'installation',
     'd0000000-0000-4000-8000-000000000004', now() - interval '3 days',  'submitted',   '{}', 'd0000000-0000-4000-8000-000000000002'),
  ('f0000000-0000-4000-8000-000000000003', '50000000-0000-4000-8000-000000000005', 'amc_visit',
     'd0000000-0000-4000-8000-000000000004', now() + interval '5 days',  'scheduled',   '{}', 'd0000000-0000-4000-8000-000000000002')
ON CONFLICT (id) DO NOTHING;

-- --- payments ---------------------------------------------------------------
INSERT INTO payments (id, site_id, amount, paid_on, mode, reference, source, status, milestone, created_by) VALUES
  ('70000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000003', 120000, CURRENT_DATE - 20, 'upi',  'UPI-REF-1001', 'manual', 'verified', 'advance',  'd0000000-0000-4000-8000-000000000002'),
  ('70000000-0000-4000-8000-000000000002', '50000000-0000-4000-8000-000000000003', 280000, CURRENT_DATE - 4,  'neft', 'NEFT-REF-1002','manual', 'verified', 'balance',  'd0000000-0000-4000-8000-000000000002'),
  ('70000000-0000-4000-8000-000000000003', '50000000-0000-4000-8000-000000000005', 1800000,CURRENT_DATE - 45, 'neft', 'NEFT-REF-2001','manual', 'verified', 'advance',  'd0000000-0000-4000-8000-000000000002'),
  ('70000000-0000-4000-8000-000000000004', '50000000-0000-4000-8000-000000000002', 50000,  CURRENT_DATE - 1,  'upi',  'UPI-REF-3001', 'manual', 'pending',  'token',    'd0000000-0000-4000-8000-000000000002')
ON CONFLICT (id) DO NOTHING;

-- --- invoices ---------------------------------------------------------------
INSERT INTO invoices (id, site_id, entity_id, kind, number, fy, seq, taxable, cgst, sgst, igst, total,
                      place_of_supply, bill_to, lines, status) VALUES
  ('90000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000003',
     'b0000000-0000-4000-8000-000000000001', 'tax_invoice', 'BE/2025-26/0001', '2025-26', 1,
     380952.38, 9523.81, 9523.81, 0, 400000, 'Maharashtra',
     '{"name":"Meera Joshi","gstin":null,"address":"Mulshi Rd, Pune"}'::jsonb,
     '[{"item":"6.5 kWp Rooftop Solar System","qty":1,"rate":380952.38,"amount":380952.38}]'::jsonb,
     'issued'),
  ('90000000-0000-4000-8000-000000000002', '50000000-0000-4000-8000-000000000005',
     'b0000000-0000-4000-8000-000000000001', 'tax_invoice', 'BE/2025-26/0002', '2025-26', 2,
     3050847.46, 0, 0, 549152.54, 3600000, 'Maharashtra',
     '{"name":"Harmony Hospital","gstin":"27AAACH5432K1Z8","address":"45 Ring Rd, Pune"}'::jsonb,
     '[{"item":"75 kWp Rooftop Solar System","qty":1,"rate":3050847.46,"amount":3050847.46}]'::jsonb,
     'issued')
ON CONFLICT (id) DO NOTHING;

-- --- tickets ----------------------------------------------------------------
INSERT INTO tickets (id, site_id, source, category, description, priority, status, assigned_to, chargeable, created_by) VALUES
  ('80000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000005', 'call', 'generation_low',
     'Customer reports ~15% lower generation this week.', 'high', 'open',
     'd0000000-0000-4000-8000-000000000004', false, 'd0000000-0000-4000-8000-000000000002'),
  ('80000000-0000-4000-8000-000000000002', '50000000-0000-4000-8000-000000000003', 'whatsapp', 'inverter_fault',
     'Inverter showing error E04 intermittently.', 'normal', 'resolved',
     'd0000000-0000-4000-8000-000000000004', false, 'd0000000-0000-4000-8000-000000000002')
ON CONFLICT (id) DO NOTHING;

COMMIT;

-- Quick verification (optional):
-- SELECT 'clients' t, count(*) FROM clients
-- UNION ALL SELECT 'sites', count(*) FROM sites
-- UNION ALL SELECT 'leads', count(*) FROM leads
-- UNION ALL SELECT 'quotes', count(*) FROM quotes
-- UNION ALL SELECT 'jobs', count(*) FROM jobs
-- UNION ALL SELECT 'payments', count(*) FROM payments
-- UNION ALL SELECT 'invoices', count(*) FROM invoices
-- UNION ALL SELECT 'tickets', count(*) FROM tickets;
