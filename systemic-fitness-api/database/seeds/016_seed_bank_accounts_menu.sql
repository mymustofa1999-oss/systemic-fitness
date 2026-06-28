-- ════════════════════════════════════════════════════════════════════
--  Seed: Bank Accounts sub-menu under Payments
--  Adds the Bank Accounts management page to the admin sidebar.
--  Belongs to migration 035 (payment gateway support).
-- ════════════════════════════════════════════════════════════════════

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000075',
   'a0000000-0000-0000-0000-000000000007',
   'bank-accounts',           'Bank Accounts',         'CreditCard',    '/payments/bank-accounts',  5)
ON CONFLICT (code) DO NOTHING;

-- Grant access: owner, admin, finance
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true FROM menus
WHERE code = 'bank-accounts'
ON CONFLICT (menu_id, role) DO NOTHING;

INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true FROM menus
WHERE code = 'bank-accounts'
ON CONFLICT (menu_id, role) DO NOTHING;

INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'finance'::user_role, true FROM menus
WHERE code = 'bank-accounts'
ON CONFLICT (menu_id, role) DO NOTHING;
