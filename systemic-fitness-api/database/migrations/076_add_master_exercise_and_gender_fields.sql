-- +migrate Up
-- Add active status and explicit gender targeting for Master Exercises (dl_movements)
ALTER TABLE dl_movements
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS target_gender VARCHAR(20) DEFAULT 'universal'; -- 'male', 'female', 'universal'

-- Add target_gender to Trainer Card Templates and Cards
ALTER TABLE trainer_card_templates
ADD COLUMN IF NOT EXISTS target_gender VARCHAR(20) DEFAULT 'universal';

ALTER TABLE trainer_cards
ADD COLUMN IF NOT EXISTS target_gender VARCHAR(20) DEFAULT 'universal';

-- Add snapshot fields to Training Card Items to preserve historical state
ALTER TABLE trainer_card_template_set_items
ADD COLUMN IF NOT EXISTS video_url_snapshot TEXT;

ALTER TABLE trainer_card_set_items
ADD COLUMN IF NOT EXISTS video_url_snapshot TEXT;

-- Add active status to Medicines
ALTER TABLE medicines
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Add classification to User Profiles (e.g., 'personal', 'group', 'online')
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS classification VARCHAR(50);


-- +migrate Down
ALTER TABLE user_profiles
DROP COLUMN IF EXISTS classification;

ALTER TABLE medicines
DROP COLUMN IF EXISTS is_active;

ALTER TABLE trainer_card_set_items
DROP COLUMN IF EXISTS video_url_snapshot;

ALTER TABLE trainer_card_template_set_items
DROP COLUMN IF EXISTS video_url_snapshot;

ALTER TABLE trainer_cards
DROP COLUMN IF EXISTS target_gender;

ALTER TABLE trainer_card_templates
DROP COLUMN IF EXISTS target_gender;

ALTER TABLE dl_movements
DROP COLUMN IF EXISTS is_active,
DROP COLUMN IF EXISTS target_gender;
