-- +migrate Up

-- 1. Add pattern and breathing columns to sets and items
ALTER TABLE trainer_card_sets ADD COLUMN IF NOT EXISTS pattern VARCHAR(150);
ALTER TABLE trainer_card_sets ADD COLUMN IF NOT EXISTS breathing_core VARCHAR(100);
ALTER TABLE trainer_card_sets ADD COLUMN IF NOT EXISTS breathing_diaphragm VARCHAR(100);

ALTER TABLE trainer_card_template_sets ADD COLUMN IF NOT EXISTS pattern VARCHAR(150);
ALTER TABLE trainer_card_template_sets ADD COLUMN IF NOT EXISTS breathing_core VARCHAR(100);
ALTER TABLE trainer_card_template_sets ADD COLUMN IF NOT EXISTS breathing_diaphragm VARCHAR(100);

ALTER TABLE trainer_card_set_items ADD COLUMN IF NOT EXISTS breathing_core VARCHAR(100);
ALTER TABLE trainer_card_set_items ADD COLUMN IF NOT EXISTS breathing_diaphragm VARCHAR(100);

ALTER TABLE trainer_card_template_set_items ADD COLUMN IF NOT EXISTS breathing_core VARCHAR(100);
ALTER TABLE trainer_card_template_set_items ADD COLUMN IF NOT EXISTS breathing_diaphragm VARCHAR(100);

-- 2. Add EN suffix fields to digital library movements, health articles, doctor videos
ALTER TABLE dl_movements ADD COLUMN IF NOT EXISTS name_en VARCHAR(150);
ALTER TABLE dl_movements ADD COLUMN IF NOT EXISTS instructions_en TEXT[] DEFAULT '{}';
ALTER TABLE dl_movements ADD COLUMN IF NOT EXISTS description_en TEXT;

ALTER TABLE health_articles ADD COLUMN IF NOT EXISTS title_en TEXT;
ALTER TABLE health_articles ADD COLUMN IF NOT EXISTS content_en TEXT;

ALTER TABLE doctor_videos ADD COLUMN IF NOT EXISTS title_en TEXT;
ALTER TABLE doctor_videos ADD COLUMN IF NOT EXISTS description_en TEXT;

-- 3. Delete workouts menu (Sesi)
DELETE FROM menus WHERE code = 'workouts';

-- +migrate Down
ALTER TABLE trainer_card_sets DROP COLUMN IF EXISTS pattern;
ALTER TABLE trainer_card_sets DROP COLUMN IF EXISTS breathing_core;
ALTER TABLE trainer_card_sets DROP COLUMN IF EXISTS breathing_diaphragm;

ALTER TABLE trainer_card_template_sets DROP COLUMN IF EXISTS pattern;
ALTER TABLE trainer_card_template_sets DROP COLUMN IF EXISTS breathing_core;
ALTER TABLE trainer_card_template_sets DROP COLUMN IF EXISTS breathing_diaphragm;

ALTER TABLE trainer_card_set_items DROP COLUMN IF EXISTS breathing_core;
ALTER TABLE trainer_card_set_items DROP COLUMN IF EXISTS breathing_diaphragm;

ALTER TABLE trainer_card_template_set_items DROP COLUMN IF EXISTS breathing_core;
ALTER TABLE trainer_card_template_set_items DROP COLUMN IF EXISTS breathing_diaphragm;

ALTER TABLE dl_movements DROP COLUMN IF EXISTS name_en;
ALTER TABLE dl_movements DROP COLUMN IF EXISTS instructions_en;
ALTER TABLE dl_movements DROP COLUMN IF EXISTS description_en;

ALTER TABLE health_articles DROP COLUMN IF EXISTS title_en;
ALTER TABLE health_articles DROP COLUMN IF EXISTS content_en;

ALTER TABLE doctor_videos DROP COLUMN IF EXISTS title_en;
ALTER TABLE doctor_videos DROP COLUMN IF EXISTS description_en;
