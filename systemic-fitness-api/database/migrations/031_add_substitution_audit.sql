-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  031: Substitution Audit
--  Track which consultant performed the trainer substitution + when.
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE training_sessions
    ADD COLUMN substituted_by UUID REFERENCES users(id) ON DELETE SET NULL,
    ADD COLUMN substituted_at TIMESTAMPTZ;

CREATE INDEX idx_training_sessions_substituted_by
    ON training_sessions(substituted_by)
    WHERE substituted_by IS NOT NULL;

-- +migrate Down
ALTER TABLE training_sessions
    DROP COLUMN IF EXISTS substituted_at,
    DROP COLUMN IF EXISTS substituted_by;
