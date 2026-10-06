# Demo seed data

`seed.sql` loads a small, coherent demo dataset into the Brijstar CRM schema so
you can click through the app with realistic records.

## ⚠️ Staging only

Run this against a **staging / development** database only — never production.
It must be run with a role that bypasses RLS (Supabase `service_role`, or the
Dashboard SQL Editor). The public `anon` key cannot and should not be able to
insert these rows.

## How to run

**Option 1 — Supabase SQL Editor**
1. Open your *staging* project → SQL Editor.
2. Paste the contents of `seed.sql` and click **Run**.

**Option 2 — psql**
```bash
psql "<staging service-role connection string>" -f seed/seed.sql
```

Keep the connection string / service-role key out of source control and out of
chat — set it as an environment variable or paste it directly into the editor.

## What it inserts

| Table              | Rows | Notes                                             |
|--------------------|------|---------------------------------------------------|
| `roles`            | 4    | demo placeholders — see note below                |
| `users`            | 4    | admin, office, sales, technician                  |
| `billing_entities` | 1    | Brijstar Energy Pvt Ltd                           |
| `referrers`        | 2    | one client, one agent                             |
| `clients`          | 4    | 2 individuals, 2 companies                        |
| `sites`            | 5    | spread across domestic & C&I pipeline stages      |
| `leads`            | 6    | across lead statuses                              |
| `quotes`           | 3    | sent / accepted                                   |
| `jobs`             | 3    | survey, installation, AMC visit                   |
| `payments`         | 4    | verified + pending                                |
| `invoices`         | 2    | one intra-state (CGST/SGST), one IGST             |
| `tickets`          | 2    | open + resolved                                   |

## Notes

- **Role keys:** this database's `roles` and `permissions` tables were empty,
  and `users.role` is a foreign key to `roles.key`. The script seeds demo roles
  `admin`, `office`, `sales`, `technician`. If your app expects different role
  keys, edit the `roles` and `users` sections before running.
- **Re-runnable:** every row uses a fixed UUID with `ON CONFLICT DO NOTHING`, so
  running the script twice will not create duplicates.
- **Removing the data:** all demo UUIDs share recognizable prefixes
  (`c…` clients, `5…` sites, `6…` leads, `e…` quotes, `f…` jobs, `7…` payments,
  `9…` invoices, `8…` tickets, `d…` users, `a…` referrers, `b…` billing).
  Delete child rows before parents to respect foreign keys.
- `permissions` / `role_permissions` are **not** seeded — add those to match
  your app's real permission model if the UI needs them.
