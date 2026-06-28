-- ════════════════════════════════════════════════════════════════════
--  Seed: Payment Sub-menus
--  Convert "Payments" from a single link to a parent group with children
-- ════════════════════════════════════════════════════════════════════

-- Step 1: Remove href from payments parent so it becomes a group menu
UPDATE menus SET href = NULL WHERE code = 'payments';

-- Step 2: Add children under payments parent
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000071',
   'a0000000-0000-0000-0000-000000000007',
   'payments-overview',       'Overview',              'CreditCard',    '/payments',                1),

  ('a0000000-0000-0000-0000-000000000072',
   'a0000000-0000-0000-0000-000000000007',
   'client-subscriptions',    'Client Subscriptions',  'Star',          '/payments/subscriptions',  2),

  ('a0000000-0000-0000-0000-000000000073',
   'a0000000-0000-0000-0000-000000000007',
   'manage-plans',            'Manage Plans',          'Layers',        '/payments/plans',          3),

  ('a0000000-0000-0000-0000-000000000074',
   'a0000000-0000-0000-0000-000000000007',
   'payment-reports',         'Reports',               'TrendingUp',    '/payments/reports',        4)
ON CONFLICT (code) DO NOTHING;

-- Step 3: Grant access to new sub-menus

-- Owner: full access
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true FROM menus
WHERE code IN ('payments-overview', 'client-subscriptions', 'manage-plans', 'payment-reports')
ON CONFLICT (menu_id, role) DO NOTHING;

-- Admin: full access
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true FROM menus
WHERE code IN ('payments-overview', 'client-subscriptions', 'manage-plans', 'payment-reports')
ON CONFLICT (menu_id, role) DO NOTHING;

-- Finance: full access
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'finance'::user_role, true FROM menus
WHERE code IN ('payments-overview', 'client-subscriptions', 'manage-plans', 'payment-reports')
ON CONFLICT (menu_id, role) DO NOTHING;
