-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  005: Programs & Program Days
--  Multi-week training programs with daily workout schedules
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE programs (
    id              UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100)      NOT NULL,
    description     TEXT,
    duration_weeks  INT               NOT NULL CHECK (duration_weeks >= 1 AND duration_weeks <= 52),
    difficulty      difficulty_level  NOT NULL DEFAULT 'beginner',
    goal            program_goal      NOT NULL DEFAULT 'general_fitness',
    created_by      UUID              REFERENCES users(id) ON DELETE SET NULL,
    is_template     BOOLEAN           NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ       NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_programs_name CHECK (char_length(name) >= 1)
);

CREATE INDEX idx_programs_created_by  ON programs (created_by);
CREATE INDEX idx_programs_difficulty  ON programs (difficulty);
CREATE INDEX idx_programs_is_template ON programs (is_template) WHERE is_template = TRUE;

CREATE TRIGGER trg_programs_updated_at
    BEFORE UPDATE ON programs
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Program Days (workout schedule per day) ────────────────────

CREATE TABLE program_days (
    id            UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id    UUID      NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
    week_number   INT       NOT NULL CHECK (week_number >= 1),
    day_of_week   INT       NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    workout_id    UUID      REFERENCES workouts(id) ON DELETE SET NULL,
    is_rest_day   BOOLEAN   NOT NULL DEFAULT FALSE,

    -- A specific day in a specific week can only appear once per program
    CONSTRAINT uq_program_day UNIQUE (program_id, week_number, day_of_week),
    -- If it's a rest day, no workout should be assigned
    CONSTRAINT chk_program_days_rest CHECK (
        (is_rest_day = TRUE AND workout_id IS NULL) OR
        (is_rest_day = FALSE)
    )
);

CREATE INDEX idx_program_days_program ON program_days (program_id);
CREATE INDEX idx_program_days_workout ON program_days (workout_id);

-- ─── User ↔ Program Assignments ────────────────────────────────

CREATE TABLE user_programs (
    id            UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID              NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    program_id    UUID              NOT NULL REFERENCES programs(id) ON DELETE RESTRICT,
    assigned_by   UUID              REFERENCES users(id) ON DELETE SET NULL,
    start_date    DATE              NOT NULL,
    end_date      DATE,
    status        assignment_status NOT NULL DEFAULT 'active',
    current_week  INT               NOT NULL DEFAULT 1 CHECK (current_week >= 1),
    current_day   INT               NOT NULL DEFAULT 0 CHECK (current_day >= 0 AND current_day <= 6),
    created_at    TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ       NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_user_programs_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE INDEX idx_user_programs_user        ON user_programs (user_id);
CREATE INDEX idx_user_programs_user_status ON user_programs (user_id, status);
CREATE INDEX idx_user_programs_program     ON user_programs (program_id);
CREATE INDEX idx_user_programs_assigned_by ON user_programs (assigned_by);

CREATE TRIGGER trg_user_programs_updated_at
    BEFORE UPDATE ON user_programs
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- +migrate Down
DROP TABLE IF EXISTS user_programs CASCADE;
DROP TABLE IF EXISTS program_days CASCADE;
DROP TABLE IF EXISTS programs CASCADE;
