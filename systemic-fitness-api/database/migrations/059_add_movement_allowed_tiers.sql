-- +migrate Up

-- Per-movement package access. Empty array '{}' means the movement is open to
-- every tier (backward-compatible default). Otherwise it lists the subscription
-- tier codes (e.g. 'sf_tier_2', 'sf_tier_3') allowed to see/play the movement.
ALTER TABLE trainer_card_template_set_items ADD COLUMN IF NOT EXISTS allowed_tiers TEXT[] NOT NULL DEFAULT '{}';
ALTER TABLE trainer_card_set_items          ADD COLUMN IF NOT EXISTS allowed_tiers TEXT[] NOT NULL DEFAULT '{}';

-- +migrate Down
ALTER TABLE trainer_card_template_set_items DROP COLUMN IF EXISTS allowed_tiers;
ALTER TABLE trainer_card_set_items          DROP COLUMN IF EXISTS allowed_tiers;
