-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  003: Exercise Library
--  Shared exercise catalog — system defaults + trainer-created
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE exercises (
    id              UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100)      NOT NULL,
    description     TEXT,
    muscle_group    VARCHAR(50)[]     NOT NULL DEFAULT '{}',
    equipment       VARCHAR(50),
    difficulty      difficulty_level  NOT NULL DEFAULT 'beginner',
    video_url       TEXT,
    thumbnail_url   TEXT,
    instructions    TEXT[]            DEFAULT '{}',
    created_by      UUID              REFERENCES users(id) ON DELETE SET NULL,
    is_system       BOOLEAN           NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ       NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_exercises_name CHECK (char_length(name) >= 1),
    CONSTRAINT chk_exercises_muscle_group CHECK (array_length(muscle_group, 1) > 0 OR muscle_group = '{}')
);

CREATE INDEX idx_exercises_muscle_group ON exercises USING GIN (muscle_group);
CREATE INDEX idx_exercises_difficulty    ON exercises (difficulty);
CREATE INDEX idx_exercises_is_system     ON exercises (is_system) WHERE is_system = TRUE;
CREATE INDEX idx_exercises_created_by    ON exercises (created_by);
CREATE INDEX idx_exercises_name_trgm     ON exercises USING GIN (name gin_trgm_ops);

-- Enable trigram extension for fuzzy name search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TRIGGER trg_exercises_updated_at
    BEFORE UPDATE ON exercises
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- +migrate Down
DROP TABLE IF EXISTS exercises CASCADE;
