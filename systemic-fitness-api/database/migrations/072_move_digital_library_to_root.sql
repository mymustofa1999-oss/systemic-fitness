-- +migrate Up

-- Move Digital Library and Modul Card to root level so they appear directly in the sidebar
UPDATE menus SET parent_id = NULL, sort_order = 8, is_active = false WHERE code = 'digital-library';
UPDATE menus SET parent_id = NULL, sort_order = 9, is_active = true WHERE code = 'modul-card';

-- +migrate Down

-- Move them back under Master Libraries
UPDATE menus SET parent_id = 'a0000000-0000-0000-0000-000000000010', sort_order = 1 WHERE code = 'digital-library';
UPDATE menus SET parent_id = 'a0000000-0000-0000-0000-000000000010', sort_order = 2 WHERE code = 'modul-card';
