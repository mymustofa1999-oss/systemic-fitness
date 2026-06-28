-- +migrate Up
ALTER TABLE customer_hr_zones ADD COLUMN IF NOT EXISTS priority TEXT;

-- +migrate Down
ALTER TABLE customer_hr_zones DROP COLUMN IF EXISTS priority;
