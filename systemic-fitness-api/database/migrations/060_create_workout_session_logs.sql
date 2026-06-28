-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  060: Workout Session Logs (Level 5/6 guided session completion)
-- ═══════════════════════════════════════════════════════════════════
-- Records each finished guided training session (the "Akhiri Sesi" action
-- on the client Training Card). Distinct from exercise-level progress_logs:
-- one row = one completed session, grouped per daily/full training card.

CREATE TABLE IF NOT EXISTS workout_session_logs (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trainer_card_id  UUID REFERENCES trainer_cards(id) ON DELETE SET NULL,
    session_type     VARCHAR(10) NOT NULL DEFAULT 'full'
                       CHECK (session_type IN ('full', 'daily')),
    level            VARCHAR(10) NOT NULL DEFAULT '',
    duration_seconds INTEGER NOT NULL DEFAULT 0 CHECK (duration_seconds >= 0),
    completed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workout_session_logs_user_completed
    ON workout_session_logs (user_id, completed_at DESC);
CREATE INDEX IF NOT EXISTS idx_workout_session_logs_user_type
    ON workout_session_logs (user_id, session_type);

-- +migrate Down
DROP TABLE IF EXISTS workout_session_logs CASCADE;
