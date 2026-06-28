-- +migrate Up
ALTER TYPE dl_position ADD VALUE IF NOT EXISTS 'mat';
ALTER TYPE dl_body_part ADD VALUE IF NOT EXISTS 'whole body';

-- +migrate Down
-- Removing enum values is not supported by PostgreSQL, but the Up migration is safe and idempotent.
