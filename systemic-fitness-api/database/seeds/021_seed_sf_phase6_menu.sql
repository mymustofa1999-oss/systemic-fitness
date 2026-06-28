-- ════════════════════════════════════════════════════════════════════
--  Seed: SF Phase 6 menu — Lab Consultations + Tier 4 Waitlist.
--  Owner & admin can access. Parent group: SF Master (existing).
-- ════════════════════════════════════════════════════════════════════

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-0000000000a6',
   'a0000000-0000-0000-0000-0000000000a1',  -- parent: sf_master
   'sf_lab_consultations',
   'Lab Consultations',
   'ClipboardCheck',
   '/lab-consultations',
   5),
  ('a0000000-0000-0000-0000-0000000000a7',
   'a0000000-0000-0000-0000-0000000000a1',
   'sf_tier4_waitlist',
   'Tier 4 Waitlist',
   'Star',
   '/tier4-waitlist',
   6)
ON CONFLICT (code) DO NOTHING;

-- Privileges: owner + admin
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true
FROM menus
WHERE code IN ('sf_lab_consultations', 'sf_tier4_waitlist')
ON CONFLICT (menu_id, role) DO NOTHING;

INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true
FROM menus
WHERE code IN ('sf_lab_consultations', 'sf_tier4_waitlist')
ON CONFLICT (menu_id, role) DO NOTHING;
