-- ════════════════════════════════════════════════════════════════════
--  Seed: Training Schedule menu + privileges (owner only)
-- ════════════════════════════════════════════════════════════════════

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000035', NULL, 'training-schedules', 'Training Schedules', 'CalendarClock', '/training-schedules', 8)
ON CONFLICT (code) DO NOTHING;

-- Only owner can access
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true FROM menus WHERE code = 'training-schedules'
ON CONFLICT (menu_id, role) DO NOTHING;
