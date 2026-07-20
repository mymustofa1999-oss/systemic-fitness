-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  070: Training Session Logs (Manual Input Form)
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS training_session_logs (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    period_name        VARCHAR(255) NOT NULL DEFAULT '', -- e.g., 'Januari 2026'
    session_number     INTEGER NOT NULL DEFAULT 1,
    date               DATE,
    took_medicine      BOOLEAN NOT NULL DEFAULT false,
    last_meal_hours    NUMERIC(5, 2), -- e.g., 3.5 (jam)
    last_meal_food     VARCHAR(255),
    bp_pre_systolic    INTEGER,
    bp_pre_diastolic   INTEGER,
    hr_pre             INTEGER,
    bp_post_systolic   INTEGER,
    bp_post_diastolic  INTEGER,
    hr_post            INTEGER,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_training_session_logs_user_period
    ON training_session_logs (user_id, period_name, session_number);

-- +migrate Down
DROP TABLE IF EXISTS training_session_logs CASCADE;
