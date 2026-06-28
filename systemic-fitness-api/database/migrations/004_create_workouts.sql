-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  004: Workouts & Workout Exercises
--  Workout templates composed of exercises with sets/reps config
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE workouts (
    id                     UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name                   VARCHAR(100)  NOT NULL,
    description            TEXT,
    type                   workout_type  NOT NULL DEFAULT 'custom',
    estimated_duration_min INT           CHECK (estimated_duration_min > 0),
    created_by             UUID          REFERENCES users(id) ON DELETE SET NULL,
    is_template            BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at             TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at             TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_workouts_name CHECK (char_length(name) >= 1)
);

CREATE INDEX idx_workouts_created_by  ON workouts (created_by);
CREATE INDEX idx_workouts_type        ON workouts (type);
CREATE INDEX idx_workouts_is_template ON workouts (is_template) WHERE is_template = TRUE;

CREATE TRIGGER trg_workouts_updated_at
    BEFORE UPDATE ON workouts
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Exercises within a Workout ─────────────────────────────────

CREATE TABLE workout_exercises (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id      UUID          NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id     UUID          NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
    order_index     INT           NOT NULL,
    sets            INT           CHECK (sets > 0),
    reps            VARCHAR(20),
    weight_kg       DECIMAL(5,1)  CHECK (weight_kg >= 0),
    rest_seconds    INT           CHECK (rest_seconds >= 0),
    notes           TEXT,
    superset_group  INT,

    CONSTRAINT uq_workout_exercise_order UNIQUE (workout_id, order_index)
);

CREATE INDEX idx_workout_exercises_workout  ON workout_exercises (workout_id);
CREATE INDEX idx_workout_exercises_exercise ON workout_exercises (exercise_id);

-- +migrate Down
DROP TABLE IF EXISTS workout_exercises CASCADE;
DROP TABLE IF EXISTS workouts CASCADE;
