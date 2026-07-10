-- +migrate Up
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS attachment_url VARCHAR(500);

-- +migrate Down
ALTER TABLE subscriptions DROP COLUMN IF EXISTS attachment_url;
