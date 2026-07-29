-- ════════════════════════════════════════════════════════════════════
--  Seed: Consultant nested menus (My Clients & My Schedule)
-- ════════════════════════════════════════════════════════════════════

-- Parent group "Consultant" id = 'a0000000-0000-0000-0000-0000000000c1'

-- 1. "My Clients" (Level 2)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000100', 'a0000000-0000-0000-0000-0000000000c1', 'sf_consultant_my_clients', 'My Clients', 'UsersRound', NULL, 3)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label;

-- 1.1 "Digital" (Level 3)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000101', 'a0000000-0000-0000-0000-000000000100', 'sf_consultant_clients_digital', 'Digital', 'Smartphone', NULL, 1)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label;

-- 1.1.1 "Personal Training" (Level 4)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000102', 'a0000000-0000-0000-0000-000000000101', 'sf_consultant_clients_digital_pt', 'Personal Training', 'Dumbbell', '/consultant/clients/digital/pt', 1)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, href = EXCLUDED.href;

-- 1.1.2 "Group Training" (Level 4)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000103', 'a0000000-0000-0000-0000-000000000101', 'sf_consultant_clients_digital_gt', 'Group Training', 'Users', '/consultant/clients/digital/gt', 2)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, href = EXCLUDED.href;

-- 1.2 "On-site" (Level 3)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000104', 'a0000000-0000-0000-0000-000000000100', 'sf_consultant_clients_onsite', 'On-site', 'MapPin', NULL, 2)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label;

-- 1.2.1 "Personal Training" (Level 4)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000105', 'a0000000-0000-0000-0000-000000000104', 'sf_consultant_clients_onsite_pt', 'Personal Training', 'Dumbbell', '/consultant/clients/on-site/pt', 1)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, href = EXCLUDED.href;

-- 1.2.2 "Group Training" (Level 4)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000106', 'a0000000-0000-0000-0000-000000000104', 'sf_consultant_clients_onsite_gt', 'Group Training', 'Users', '/consultant/clients/on-site/gt', 2)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, href = EXCLUDED.href;


-- 2. "My Schedule" (Level 2)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000110', 'a0000000-0000-0000-0000-0000000000c1', 'sf_consultant_my_schedule', 'My Schedule', 'Calendar', NULL, 4)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label;

-- 2.1 "Private Consultation" (Level 3)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000111', 'a0000000-0000-0000-0000-000000000110', 'sf_consultant_schedule_private', 'Private Consultation', 'User', '/consultant/schedule/private', 1)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, href = EXCLUDED.href;

-- 2.2 "Initial Assessment" (Level 3)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000112', 'a0000000-0000-0000-0000-000000000110', 'sf_consultant_schedule_initial', 'Initial Assessment', 'ClipboardList', '/consultant/schedule/initial-assessment', 2)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, href = EXCLUDED.href;

-- 2.3 "Re-Assessment" (Level 3)
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000113', 'a0000000-0000-0000-0000-000000000110', 'sf_consultant_schedule_reassessment', 'Re-Assessment', 'ClipboardCheck', '/consultant/schedule/re-assessment', 3)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, href = EXCLUDED.href;


-- ─── Privileges: grant to consultant, admin, owner ──────────────────────

INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT m.id, r.role::user_role, true
FROM menus m
CROSS JOIN (VALUES ('consultant'), ('admin'), ('owner')) AS r(role)
WHERE m.code IN (
  'sf_consultant_my_clients',
  'sf_consultant_clients_digital',
  'sf_consultant_clients_digital_pt',
  'sf_consultant_clients_digital_gt',
  'sf_consultant_clients_onsite',
  'sf_consultant_clients_onsite_pt',
  'sf_consultant_clients_onsite_gt',
  'sf_consultant_my_schedule',
  'sf_consultant_schedule_private',
  'sf_consultant_schedule_initial',
  'sf_consultant_schedule_reassessment'
)
ON CONFLICT (menu_id, role) DO NOTHING;
