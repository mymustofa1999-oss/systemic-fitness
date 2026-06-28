-- ════════════════════════════════════════════════════════════════════
--  Seed: SF Master Data menu group (Phase 1 — Klasifikasi & Kondisi).
--  Adds a parent group "SF Master" with 2 children:
--    - Klasifikasi Kondisi  → /master/condition-classifications
--    - Kondisi Spesifik     → /master/specific-conditions
--  Visible to owner & admin.
-- ════════════════════════════════════════════════════════════════════

-- Parent group
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-0000000000a1', NULL, 'sf_master', 'SF Master', 'Layers', NULL, 18)
ON CONFLICT (code) DO NOTHING;

-- Children
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-0000000000a2',
   'a0000000-0000-0000-0000-0000000000a1',
   'sf_condition_classifications',
   'Klasifikasi Kondisi',
   'HeartPulse',
   '/master/condition-classifications',
   1),
  ('a0000000-0000-0000-0000-0000000000a3',
   'a0000000-0000-0000-0000-0000000000a1',
   'sf_specific_conditions',
   'Kondisi Spesifik',
   'Stethoscope',
   '/master/specific-conditions',
   2)
ON CONFLICT (code) DO NOTHING;

-- Privileges: owner + admin can access all 3 menu rows.
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true
FROM menus
WHERE code IN ('sf_master', 'sf_condition_classifications', 'sf_specific_conditions')
ON CONFLICT (menu_id, role) DO NOTHING;

INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true
FROM menus
WHERE code IN ('sf_master', 'sf_condition_classifications', 'sf_specific_conditions')
ON CONFLICT (menu_id, role) DO NOTHING;
