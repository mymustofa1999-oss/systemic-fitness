-- ════════════════════════════════════════════════════════════════════
--  Seed: Menus & Role Privileges
--  Mirrors the hardcoded sidebar navigation from systemic-fitness-web
-- ════════════════════════════════════════════════════════════════════

-- ── Top-level menus ────────────────────────────────────────────────

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000001', NULL, 'dashboard',       'Dashboard',       'LayoutDashboard', '/',              1),
  ('a0000000-0000-0000-0000-000000000002', NULL, 'messages',        'Messages',        'MessageSquare',   '/messages',      2),
  ('a0000000-0000-0000-0000-000000000003', NULL, 'groups',          'Groups',          'UsersRound',      '/groups',        3),
  ('a0000000-0000-0000-0000-000000000004', NULL, 'challenges',      'Challenges',      'Trophy',          '/challenges',    4),
  ('a0000000-0000-0000-0000-000000000005', NULL, 'clients',         'Clients',         'UserCheck',       '/clients',       5),
  ('a0000000-0000-0000-0000-000000000006', NULL, 'team',            'Team',            'Users',           '/team',          6),
  ('a0000000-0000-0000-0000-000000000007', NULL, 'payments',        'Payments',        'CreditCard',      '/payments',      7),
  -- Parent groups (no href)
  ('a0000000-0000-0000-0000-000000000010', NULL, 'master-libraries','Master Libraries','Library',          NULL,             10),
  ('a0000000-0000-0000-0000-000000000020', NULL, 'scheduling',      'Scheduling',      'CalendarDays',     NULL,             20),
  -- More top-level
  ('a0000000-0000-0000-0000-000000000030', NULL, 'announcements',   'Announcements',   'Megaphone',       '/announcements', 30),
  ('a0000000-0000-0000-0000-000000000031', NULL, 'progress',        'Progress',        'TrendingUp',      '/progress',      31),
  ('a0000000-0000-0000-0000-000000000032', NULL, 'automations',     'Automations',     'Zap',             '/automations',   32),
  ('a0000000-0000-0000-0000-000000000033', NULL, 'settings',        'Settings',        'Settings',        '/settings',      99),
  -- Menu Management (owner only)
  ('a0000000-0000-0000-0000-000000000034', NULL, 'menu-management', 'Menu Management', 'Shield',          '/menu-management', 98)
ON CONFLICT (code) DO NOTHING;

-- ── Master Libraries children ──────────────────────────────────────

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000011', 'a0000000-0000-0000-0000-000000000010', 'digital-library',     'Digital Library',     'BookOpen',        '/digital-library',     1),
  ('a0000000-0000-0000-0000-000000000099', 'a0000000-0000-0000-0000-000000000010', 'modul-card',          'Modul Card',          'Layers',          '/modul-card',          2),
  ('a0000000-0000-0000-0000-000000000012', 'a0000000-0000-0000-0000-000000000010', 'programs',            'Programs',            'CalendarRange',   '/programs',            3),
  ('a0000000-0000-0000-0000-000000000013', 'a0000000-0000-0000-0000-000000000010', 'workouts',            'Workouts',            'ClipboardList',   '/workouts',            4),
  ('a0000000-0000-0000-0000-000000000014', 'a0000000-0000-0000-0000-000000000010', 'exercises',           'Exercises',           'Dumbbell',        '/exercises',           5),
  ('a0000000-0000-0000-0000-000000000015', 'a0000000-0000-0000-0000-000000000010', 'meals',               'Meals',               'UtensilsCrossed', '/nutrition',           6),
  ('a0000000-0000-0000-0000-000000000016', 'a0000000-0000-0000-0000-000000000010', 'foods',               'Foods',               'Cookie',          '/foods',               7),
  ('a0000000-0000-0000-0000-000000000017', 'a0000000-0000-0000-0000-000000000010', 'habits',              'Habits',              'Repeat',          '/habits',              8),
  ('a0000000-0000-0000-0000-000000000018', 'a0000000-0000-0000-0000-000000000010', 'medicines',           'Daftar Obat',         'Pill',            '/medicines',           9),
  ('a0000000-0000-0000-0000-000000000019', 'a0000000-0000-0000-0000-000000000010', 'program-categories',  'Program Categories',  'Layers',          '/program-categories',  10),
  ('a0000000-0000-0000-0000-00000000001a', 'a0000000-0000-0000-0000-000000000010', 'trainer-card-types',  'Training Card Types',  'ClipboardCheck',  '/training-card-types', 11),
  ('a0000000-0000-0000-0000-00000000001b', 'a0000000-0000-0000-0000-000000000010', 'forms',               'Forms',               'FileText',        '/forms',              12)
ON CONFLICT (code) DO NOTHING;

-- ── Scheduling children ────────────────────────────────────────────

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000021', 'a0000000-0000-0000-0000-000000000020', 'scheduling-calendar',     'Calendar',     'CalendarDays',  '/scheduling/calendar',     1),
  ('a0000000-0000-0000-0000-000000000022', 'a0000000-0000-0000-0000-000000000020', 'scheduling-availability', 'Availability', 'CalendarRange', '/scheduling/availability', 2),
  ('a0000000-0000-0000-0000-000000000023', 'a0000000-0000-0000-0000-000000000020', 'scheduling-event-types',  'Event Types',  'CalendarDays',  '/scheduling/event-types',  3)
ON CONFLICT (code) DO NOTHING;

-- ════════════════════════════════════════════════════════════════════
--  Role Privileges
--  owner  = full access (all menus)
--  admin  = most menus (same as owner minus menu-management)
--  finance = dashboard, payments, messages, settings
--  trainer = dashboard, messages, groups, challenges, clients, master libs, scheduling, progress, automations, settings
--  client  = dashboard, messages, settings
-- ════════════════════════════════════════════════════════════════════

-- Helper: Insert privilege for a menu + role
-- We'll bulk-insert all privileges

-- ── Owner: Full access to ALL menus ────────────────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true FROM menus
ON CONFLICT (menu_id, role) DO NOTHING;

-- ── Admin: All menus except menu-management ────────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true FROM menus WHERE code != 'menu-management'
ON CONFLICT (menu_id, role) DO NOTHING;

-- ── Finance: limited access ────────────────────────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'finance'::user_role, true FROM menus
WHERE code IN ('dashboard', 'messages', 'payments', 'settings')
ON CONFLICT (menu_id, role) DO NOTHING;

-- ── Trainer: broad access minus admin-specific ─────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'trainer'::user_role, true FROM menus
WHERE code IN (
  'dashboard', 'messages', 'groups', 'challenges', 'clients',
  'master-libraries', 'digital-library', 'programs', 'workouts', 'exercises',
  'meals', 'foods', 'habits', 'medicines', 'program-categories',
  'trainer-card-types', 'forms',
  'scheduling', 'scheduling-calendar', 'scheduling-availability', 'scheduling-event-types',
  'progress', 'automations', 'settings'
)
ON CONFLICT (menu_id, role) DO NOTHING;

-- ── Client: minimal access ─────────────────────────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'client'::user_role, true FROM menus
WHERE code IN ('dashboard', 'messages', 'settings')
ON CONFLICT (menu_id, role) DO NOTHING;
