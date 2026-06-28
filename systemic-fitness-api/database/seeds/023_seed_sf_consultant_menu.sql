-- ════════════════════════════════════════════════════════════════════
--  Seed: SF Phase 7c — Consultant Dashboard menu entries.
--
--  Why:
--    Phase 7b sudah expose endpoint /api/v2/consultant/* + clinical notes
--    + lab assign. Phase 7c memberi entry point UI di sidebar untuk role
--    'consultant'. Owner & admin juga ikut diberi akses (mereka oversee
--    workflow consultant).
--
--    Sekaligus: grant role 'consultant' akses ke menu Lab Consultations
--    yang sudah ada (Phase 6 hanya grant ke owner+admin) — supaya
--    consultant bisa lihat antrian booking yang ditujukan ke mereka.
-- ════════════════════════════════════════════════════════════════════

-- Parent group "Consultant"
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-0000000000c1',
   NULL,
   'sf_consultant',
   'Consultant',
   'Stethoscope',
   NULL,
   19)
ON CONFLICT (code) DO NOTHING;

-- Children
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-0000000000c2',
   'a0000000-0000-0000-0000-0000000000c1',
   'sf_consultant_queue',
   'Antrian Review',
   'ClipboardCheck',
   '/consultant/queue',
   1),
  ('a0000000-0000-0000-0000-0000000000c3',
   'a0000000-0000-0000-0000-0000000000c1',
   'sf_consultant_clients',
   'Klien Saya',
   'UsersRound',
   '/consultant/clients',
   2)
ON CONFLICT (code) DO NOTHING;

-- ─── Privileges: consultant + admin + owner ─────────────────────────

-- Consultant
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'consultant'::user_role, true
FROM menus
WHERE code IN (
  'sf_consultant',
  'sf_consultant_queue',
  'sf_consultant_clients',
  'sf_lab_consultations'   -- existing Phase 6 menu, grant juga ke consultant
)
ON CONFLICT (menu_id, role) DO NOTHING;

-- Admin (overseer)
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true
FROM menus
WHERE code IN ('sf_consultant', 'sf_consultant_queue', 'sf_consultant_clients')
ON CONFLICT (menu_id, role) DO NOTHING;

-- Owner (overseer)
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true
FROM menus
WHERE code IN ('sf_consultant', 'sf_consultant_queue', 'sf_consultant_clients')
ON CONFLICT (menu_id, role) DO NOTHING;
