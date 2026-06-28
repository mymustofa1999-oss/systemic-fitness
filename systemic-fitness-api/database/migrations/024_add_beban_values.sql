-- +migrate Up
ALTER TABLE customer_program_assignments ADD COLUMN IF NOT EXISTS beban_upper_value DECIMAL(5,1);
ALTER TABLE customer_program_assignments ADD COLUMN IF NOT EXISTS beban_lower_value DECIMAL(5,1);

-- +migrate Down
ALTER TABLE customer_program_assignments DROP COLUMN IF EXISTS beban_upper_value;
ALTER TABLE customer_program_assignments DROP COLUMN IF EXISTS beban_lower_value;
