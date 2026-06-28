-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  061: Workout Reminders (client self-scheduled push reminders)
-- ═══════════════════════════════════════════════════════════════════
-- One reminder config per client. The scheduler checks every minute and
-- sends an FCM push + in-app notification at remind_at (local timezone)
-- on the selected days_of_week. last_sent_on dedupes so a reminder fires
-- at most once per day.

CREATE TABLE IF NOT EXISTS workout_reminders (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    enabled       BOOLEAN NOT NULL DEFAULT TRUE,
    days_of_week  VARCHAR(32) NOT NULL DEFAULT '',          -- comma-separated 0..6 (0=Sun .. 6=Sat)
    remind_at     VARCHAR(5)  NOT NULL DEFAULT '07:00',     -- HH:MM in local timezone
    timezone      VARCHAR(64) NOT NULL DEFAULT 'Asia/Jakarta',
    last_sent_on  DATE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workout_reminders_enabled
    ON workout_reminders (enabled) WHERE enabled = TRUE;

-- +migrate Down
DROP TABLE IF EXISTS workout_reminders CASCADE;
