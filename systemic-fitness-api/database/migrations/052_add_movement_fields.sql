-- +migrate Up
-- ════════════════════════════════════════════════════════════════════
--  052: Add type, pattern, level columns to dl_movements table
--       Remove equipment, duration, and description columns
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE dl_movements ADD COLUMN IF NOT EXISTS type dl_position;
ALTER TABLE dl_movements ADD COLUMN IF NOT EXISTS pattern VARCHAR(50);
ALTER TABLE dl_movements ADD COLUMN IF NOT EXISTS level INT;

ALTER TABLE dl_movements DROP COLUMN IF EXISTS equipment;
ALTER TABLE dl_movements DROP COLUMN IF EXISTS duration;
ALTER TABLE dl_movements DROP COLUMN IF EXISTS description;

-- +migrate Down
ALTER TABLE dl_movements DROP COLUMN IF EXISTS type;
ALTER TABLE dl_movements DROP COLUMN IF EXISTS pattern;
ALTER TABLE dl_movements DROP COLUMN IF EXISTS level;

ALTER TABLE dl_movements ADD COLUMN equipment VARCHAR(100);
ALTER TABLE dl_movements ADD COLUMN duration VARCHAR(20);
ALTER TABLE dl_movements ADD COLUMN description TEXT;
