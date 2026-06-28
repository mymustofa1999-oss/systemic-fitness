-- +migrate Up

-- ════════════════════════════════════════════════════════════════════
--  Training Schedule Assessment
--  Consultant assigns trainers to clients with weekly schedules.
--  Supports temporary trainer substitution.
-- ════════════════════════════════════════════════════════════════════

CREATE TYPE training_session_status AS ENUM (
    'scheduled',
    'completed',
    'cancelled',
    'substituted'
);

-- Weekly recurring schedule template (e.g. "Andi trains with Lisa every Monday 08:00-09:00")
CREATE TABLE training_schedules (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id    UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trainer_id   UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    day_of_week  INT          NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Sunday..6=Saturday
    start_time   TIME         NOT NULL,
    end_time     TIME         NOT NULL,
    location     VARCHAR(200),
    notes        TEXT,
    is_active    BOOLEAN      NOT NULL DEFAULT true,
    created_by   UUID         NOT NULL REFERENCES users(id),
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_schedule_time CHECK (end_time > start_time)
);

CREATE INDEX idx_training_schedules_client  ON training_schedules(client_id);
CREATE INDEX idx_training_schedules_trainer ON training_schedules(trainer_id);
CREATE INDEX idx_training_schedules_day     ON training_schedules(day_of_week);
CREATE INDEX idx_training_schedules_active  ON training_schedules(is_active);

CREATE TRIGGER trg_training_schedules_updated_at
    BEFORE UPDATE ON training_schedules
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- Individual session instances (actual dated sessions)
CREATE TABLE training_sessions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id         UUID REFERENCES training_schedules(id) ON DELETE SET NULL,
    client_id           UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trainer_id          UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_date        DATE         NOT NULL,
    start_time          TIME         NOT NULL,
    end_time            TIME         NOT NULL,
    status              training_session_status NOT NULL DEFAULT 'scheduled',
    location            VARCHAR(200),
    notes               TEXT,
    -- Substitution fields
    is_substitute       BOOLEAN      NOT NULL DEFAULT false,
    original_trainer_id UUID REFERENCES users(id),
    substitute_reason   TEXT,
    created_by          UUID         NOT NULL REFERENCES users(id),
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_session_time CHECK (end_time > start_time)
);

CREATE INDEX idx_training_sessions_client      ON training_sessions(client_id);
CREATE INDEX idx_training_sessions_trainer     ON training_sessions(trainer_id);
CREATE INDEX idx_training_sessions_date        ON training_sessions(session_date);
CREATE INDEX idx_training_sessions_status      ON training_sessions(status);
CREATE INDEX idx_training_sessions_schedule    ON training_sessions(schedule_id);
CREATE INDEX idx_training_sessions_substitute  ON training_sessions(is_substitute) WHERE is_substitute = true;

CREATE TRIGGER trg_training_sessions_updated_at
    BEFORE UPDATE ON training_sessions
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- +migrate Down

DROP TABLE IF EXISTS training_sessions;
DROP TABLE IF EXISTS training_schedules;
DROP TYPE IF EXISTS training_session_status;
