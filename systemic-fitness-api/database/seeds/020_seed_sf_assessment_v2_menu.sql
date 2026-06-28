-- ════════════════════════════════════════════════════════════════════
--  Seed: SF Assessment v2 menu (Phase 3 web admin).
--    - Bobot System Score   (owner-only)         → /system-score
--    - Skema Asesmen v2     (admin+)             → /assessments/v2-schema
--  Viewer hasil v2 per klien dimount di
--    /clients/[userId]/assessment-v2 — diakses dari menu Klien
--    (existing) jadi tidak butuh entry tambahan.
-- ════════════════════════════════════════════════════════════════════

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-0000000000a4',
   'a0000000-0000-0000-0000-0000000000a1',  -- parent: sf_master (dari seed 019)
   'sf_system_score_weights',
   'Bobot System Score',
   'Activity',
   '/system-score',
   3),
  ('a0000000-0000-0000-0000-0000000000a5',
   'a0000000-0000-0000-0000-0000000000a1',
   'sf_assessment_v2_schema',
   'Skema Asesmen v2',
   'ClipboardCheck',
   '/assessments/v2-schema',
   4)
ON CONFLICT (code) DO NOTHING;

-- Privileges
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true
FROM menus
WHERE code IN ('sf_system_score_weights', 'sf_assessment_v2_schema')
ON CONFLICT (menu_id, role) DO NOTHING;

-- Skema reference visible juga ke admin (read-only, tidak menulis ke DB).
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true
FROM menus
WHERE code = 'sf_assessment_v2_schema'
ON CONFLICT (menu_id, role) DO NOTHING;
