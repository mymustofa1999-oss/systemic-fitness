-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  033: Create payment_status_logs table
--
--  Audit trail for every payment status change performed by an admin
--  (or by automated flows in the future). Each row records who made
--  the change, the previous and new status, an optional reason, and
--  whether the change triggered a subscription activation.
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE payment_status_logs (
    id                 UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id         UUID            NOT NULL REFERENCES payment_records(id) ON DELETE CASCADE,
    user_id            UUID            NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    old_status         payment_status,
    new_status         payment_status  NOT NULL,
    changed_by         UUID            NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    changed_by_name    VARCHAR(100),
    reason             TEXT,
    subscription_id    UUID            REFERENCES subscriptions(id) ON DELETE SET NULL,
    metadata           JSONB           DEFAULT '{}',
    created_at         TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payment_status_logs_payment    ON payment_status_logs (payment_id);
CREATE INDEX idx_payment_status_logs_user       ON payment_status_logs (user_id);
CREATE INDEX idx_payment_status_logs_changed_by ON payment_status_logs (changed_by);
CREATE INDEX idx_payment_status_logs_created    ON payment_status_logs (created_at DESC);

-- +migrate Down
DROP TABLE IF EXISTS payment_status_logs CASCADE;
