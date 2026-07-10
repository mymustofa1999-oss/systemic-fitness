-- +migrate Up
ALTER TABLE medicines
ADD COLUMN IF NOT EXISTS active_ingredient VARCHAR(255),
ADD COLUMN IF NOT EXISTS exercise_implications TEXT,
ADD COLUMN IF NOT EXISTS exercise_adjustments TEXT,
ADD COLUMN IF NOT EXISTS flag_level VARCHAR(50);

-- +migrate Down
ALTER TABLE medicines
DROP COLUMN IF EXISTS active_ingredient,
DROP COLUMN IF EXISTS exercise_implications,
DROP COLUMN IF EXISTS exercise_adjustments,
DROP COLUMN IF EXISTS flag_level;
