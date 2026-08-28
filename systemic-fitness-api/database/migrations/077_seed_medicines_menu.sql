-- ════════════════════════════════════════════════════════════════════
--  Seed: Medicines menu entry for admin/owner sidebar
-- ════════════════════════════════════════════════════════════════════
-- +migrate Up

INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order, is_active)
VALUES
  ('a0000000-0000-0000-0000-000000000077', NULL, 'medicines', 'Medicines', 'Pill', '/medicines', 36, true)
ON CONFLICT (code) DO UPDATE
  SET parent_id  = EXCLUDED.parent_id,
      label      = EXCLUDED.label,
      icon       = EXCLUDED.icon,
      href       = EXCLUDED.href,
      sort_order = EXCLUDED.sort_order,
      is_active  = EXCLUDED.is_active;

-- Grant sidebar access to owner, admin, consultant, trainer
-- (edit/delete enforcement is at API route + frontend level)
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT m.id, r.role::user_role, true
FROM   menus m
CROSS JOIN (VALUES ('owner'), ('admin'), ('consultant'), ('trainer')) AS r(role)
WHERE  m.code = 'medicines'
ON CONFLICT (menu_id, role) DO UPDATE
  SET can_access = EXCLUDED.can_access;


-- +migrate Down
DELETE FROM menu_role_privileges
WHERE menu_id = (SELECT id FROM menus WHERE code = 'medicines');

DELETE FROM menus WHERE code = 'medicines';
