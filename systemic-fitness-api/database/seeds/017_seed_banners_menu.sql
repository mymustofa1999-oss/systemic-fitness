-- ════════════════════════════════════════════════════════════════════
--  Seed: Banners menu (web admin sidebar)
--  Manages promotional banners displayed on mobile app carousel.
--  Visible to owner and admin roles.
-- ════════════════════════════════════════════════════════════════════

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000042', NULL, 'banners', 'Banners', 'Image', '/banners', 33)
ON CONFLICT (code) DO NOTHING;

-- ── Owner ─────────────────────────────────────────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true FROM menus WHERE code = 'banners'
ON CONFLICT (menu_id, role) DO NOTHING;

-- ── Admin ─────────────────────────────────────────────────────────
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true FROM menus WHERE code = 'banners'
ON CONFLICT (menu_id, role) DO NOTHING;
