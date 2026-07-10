-- +migrate Up
ALTER TABLE user_profiles
ADD COLUMN regional VARCHAR(100),
ADD COLUMN city VARCHAR(100);

-- +migrate Down
ALTER TABLE user_profiles
DROP COLUMN regional,
DROP COLUMN city;
