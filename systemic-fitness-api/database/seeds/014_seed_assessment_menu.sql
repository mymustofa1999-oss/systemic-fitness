-- ════════════════════════════════════════════════════════════════════
--  Seed: Assessments menu (web admin sidebar)
--  Visible to owner, admin, and trainer roles.
-- ════════════════════════════════════════════════════════════════════

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000040', NULL, 'assessments', 'Assessments', 'ClipboardCheck', '/assessments', 8)
ON CONFLICT (code) DO NOTHING;

-- ── Owner ─────────────────────────────────────────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true FROM menus WHERE code = 'assessments'
ON CONFLICT (menu_id, role) DO NOTHING;

-- ── Admin ─────────────────────────────────────────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true FROM menus WHERE code = 'assessments'
ON CONFLICT (menu_id, role) DO NOTHING;

-- ── Trainer ───────────────────────────────────────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'trainer'::user_role, true FROM menus WHERE code = 'assessments'
ON CONFLICT (menu_id, role) DO NOTHING;
