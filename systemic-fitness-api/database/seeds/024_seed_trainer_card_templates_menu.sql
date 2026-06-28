-- ════════════════════════════════════════════════════════════════════
--  Seed: Training Card Templates menu.
--    - Parent: Master Libraries (a0000000-0000-0000-0000-000000000010)
--    - Target: /training-card-templates
--    - Authorized Roles: owner, admin, trainer
-- ════════════════════════════════════════════════════════════════════

-- Insert menu item
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-00000000001c',
   'a0000000-0000-0000-0000-000000000010',  -- parent: master-libraries
   'training-card-templates',
   'Card Templates',
   'Layers',
   '/training-card-templates',
   12)
ON CONFLICT (code) DO NOTHING;

-- Privileges: owner
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true
FROM menus
WHERE code = 'training-card-templates'
ON CONFLICT (menu_id, role) DO NOTHING;

-- Privileges: admin
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true
FROM menus
WHERE code = 'training-card-templates'
ON CONFLICT (menu_id, role) DO NOTHING;

-- Privileges: trainer
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'trainer'::user_role, true
FROM menus
WHERE code = 'training-card-templates'
ON CONFLICT (menu_id, role) DO NOTHING;
