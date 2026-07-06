-- +migrate Up
ALTER TABLE trainer_cards 
ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'draft';

CREATE INDEX idx_trainer_cards_status ON trainer_cards(status);

-- +migrate Down
DROP INDEX IF EXISTS idx_trainer_cards_status;
ALTER TABLE trainer_cards DROP COLUMN status;
