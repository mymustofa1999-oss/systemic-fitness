-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  006: Progress Logs & Body Metrics
--  Per-exercise tracking with JSONB sets + body composition history
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE progress_logs (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    exercise_id   UUID        NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
    workout_id    UUID        REFERENCES workouts(id) ON DELETE SET NULL,
    logged_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sets          JSONB       NOT NULL,
    notes         TEXT,
    mood          mood_type,

    -- Validate sets is a non-empty array
    CONSTRAINT chk_progress_sets_array CHECK (
        jsonb_typeof(sets) = 'array' AND jsonb_array_length(sets) > 0
    )
);

COMMENT ON COLUMN progress_logs.sets IS
    'Array of set objects: [{set_number, reps, weight_kg, duration_sec, rpe, completed}]';

CREATE INDEX idx_progress_logs_user_logged     ON progress_logs (user_id, logged_at DESC);
CREATE INDEX idx_progress_logs_exercise        ON progress_logs (exercise_id);
CREATE INDEX idx_progress_logs_workout         ON progress_logs (workout_id);
CREATE INDEX idx_progress_logs_user_exercise   ON progress_logs (user_id, exercise_id, logged_at DESC);
CREATE INDEX idx_progress_logs_logged_at       ON progress_logs (logged_at DESC);

-- ─── Body Metrics ───────────────────────────────────────────────

CREATE TABLE body_metrics (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    logged_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    weight_kg       DECIMAL(5,1)  CHECK (weight_kg > 0 AND weight_kg < 500),
    body_fat_pct    DECIMAL(4,1)  CHECK (body_fat_pct >= 0 AND body_fat_pct <= 100),
    muscle_mass_kg  DECIMAL(5,1)  CHECK (muscle_mass_kg >= 0),
    photo_urls      TEXT[]        DEFAULT '{}',
    notes           TEXT,

    -- At least one measurement must be provided
    CONSTRAINT chk_body_metrics_has_data CHECK (
        weight_kg IS NOT NULL OR
        body_fat_pct IS NOT NULL OR
        muscle_mass_kg IS NOT NULL OR
        array_length(photo_urls, 1) > 0
    )
);

CREATE INDEX idx_body_metrics_user_logged ON body_metrics (user_id, logged_at DESC);

-- +migrate Down
DROP TABLE IF EXISTS body_metrics CASCADE;
DROP TABLE IF EXISTS progress_logs CASCADE;
