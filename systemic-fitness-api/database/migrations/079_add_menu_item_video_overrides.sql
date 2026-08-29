-- +migrate Up
ALTER TABLE dl_menu_items ADD COLUMN IF NOT EXISTS video_url_male TEXT;
ALTER TABLE dl_menu_items ADD COLUMN IF NOT EXISTS video_url_female TEXT;

-- +migrate Down
ALTER TABLE dl_menu_items DROP COLUMN IF EXISTS video_url_male;
ALTER TABLE dl_menu_items DROP COLUMN IF EXISTS video_url_female;
