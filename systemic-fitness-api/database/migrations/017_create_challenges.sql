-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  017: Challenges
--  Time-bound fitness challenges with participant tracking
-- ═══════════════════════════════════════════════════════════════════

CREATE TYPE challenge_status AS ENUM (
    'draft', 'active', 'completed', 'cancelled'
);

CREATE TABLE challenges (
    id              UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(150)     NOT NULL,
    description     TEXT,
    image_url       TEXT,
    status          challenge_status NOT NULL DEFAULT 'draft',
    start_date      DATE             NOT NULL,
    end_date        DATE             NOT NULL,
    goal_type       VARCHAR(50),
    goal_value      DECIMAL(10,2),
    max_participants INT             CHECK (max_participants > 0),
    created_by      UUID             NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_challenges_name  CHECK (char_length(name) >= 1),
    CONSTRAINT chk_challenges_dates CHECK (end_date >= start_date)
);

CREATE INDEX idx_challenges_status  ON challenges (status);
CREATE INDEX idx_challenges_dates   ON challenges (start_date, end_date);
CREATE INDEX idx_challenges_creator ON challenges (created_by);

CREATE TRIGGER trg_challenges_updated_at
    BEFORE UPDATE ON challenges
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Challenge Participants ───────────────────────────────────────

CREATE TABLE challenge_participants (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id    UUID          NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    user_id         UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    progress_value  DECIMAL(10,2) NOT NULL DEFAULT 0,
    joined_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    completed_at    TIMESTAMPTZ,

    CONSTRAINT uq_challenge_participants UNIQUE (challenge_id, user_id)
);

CREATE INDEX idx_challenge_participants_challenge ON challenge_participants (challenge_id);
CREATE INDEX idx_challenge_participants_user      ON challenge_participants (user_id);

-- +migrate Down
DROP TABLE IF EXISTS challenge_participants CASCADE;
DROP TABLE IF EXISTS challenges CASCADE;
DROP TYPE IF EXISTS challenge_status CASCADE;
