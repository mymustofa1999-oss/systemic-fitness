-- +migrate Up
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'consultant'::user_role, true
FROM menus
WHERE code = 'clients'
ON CONFLICT (menu_id, role) DO UPDATE SET can_access = true;

-- +migrate Down
DELETE FROM menu_role_privileges 
WHERE role = 'consultant'::user_role 
AND menu_id IN (SELECT id FROM menus WHERE code = 'clients');
