-- +migrate Up
ALTER TABLE dl_menu_items ADD COLUMN IF NOT EXISTS set_name VARCHAR(50);
ALTER TABLE dl_menu_items ADD COLUMN IF NOT EXISTS group_type VARCHAR(50);
