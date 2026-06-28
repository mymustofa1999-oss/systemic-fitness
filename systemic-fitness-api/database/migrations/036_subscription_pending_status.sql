-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  036: Subscription Pending Status (strict pay-before-access gating)
--
--  Adds 'pending' to the subscription_status enum so customers can
--  subscribe and have their subscription stay inactive until the
--  payment is verified (manual transfer) or settled (Midtrans webhook).
--
--  Why:
--    Before this migration, CreateSubscription used status='active'
--    immediately on subscribe even though payment was still pending.
--    This meant customers could access paid features without paying.
--    With strict gating, the subscription only becomes 'active' when
--    the corresponding payment_record reaches 'completed'.
--
--  Note on PostgreSQL enum extension:
--    PG 12+ allows ALTER TYPE ... ADD VALUE inside a transaction,
--    EXCEPT when the new value is referenced in the same transaction.
--    Since this migration only adds the value (no INSERT using it),
--    it's safe.
-- ═══════════════════════════════════════════════════════════════════

ALTER TYPE subscription_status ADD VALUE IF NOT EXISTS 'pending' BEFORE 'active';

-- +migrate Down
-- Removing an enum value is not supported in PostgreSQL without
-- recreating the type. Down migration is intentionally a no-op to
-- avoid data loss; if you need to roll back, manually:
--   1. UPDATE subscriptions SET status='cancelled' WHERE status='pending';
--   2. CREATE TYPE subscription_status_new AS ENUM ('active', 'cancelled', 'expired', 'past_due');
--   3. ALTER TABLE subscriptions ALTER COLUMN status TYPE subscription_status_new
--      USING status::text::subscription_status_new;
--   4. DROP TYPE subscription_status;
--   5. ALTER TYPE subscription_status_new RENAME TO subscription_status;
SELECT 1;
