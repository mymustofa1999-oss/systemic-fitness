-- Add reset token columns to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_expires_at TIMESTAMP;

-- Add index for fast lookup
CREATE INDEX IF NOT EXISTS idx_users_reset_token ON users(reset_token);
