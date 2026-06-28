-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  002: Users & Profiles
--  Core identity tables with soft-delete support
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE users (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255)    NOT NULL,
    password_hash   VARCHAR(255)    NOT NULL,
    full_name       VARCHAR(100)    NOT NULL,
    phone           VARCHAR(20),
    avatar_url      TEXT,
    role            user_role       NOT NULL DEFAULT 'client',
    status          user_status     NOT NULL DEFAULT 'pending',
    timezone        VARCHAR(50)     NOT NULL DEFAULT 'Asia/Jakarta',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Partial unique index: email must be unique only among non-deleted rows
CREATE UNIQUE INDEX uq_users_email_active ON users (email) WHERE deleted_at IS NULL;

CREATE INDEX idx_users_role       ON users (role);
CREATE INDEX idx_users_status     ON users (status);
CREATE INDEX idx_users_deleted_at ON users (deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX idx_users_created_at ON users (created_at);

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── User Profiles (1-to-1 extension) ──────────────────────────

CREATE TABLE user_profiles (
    user_id           UUID          PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth     DATE,
    gender            gender_type,
    height_cm         DECIMAL(5,1)  CHECK (height_cm > 0 AND height_cm < 300),
    weight_kg         DECIMAL(5,1)  CHECK (weight_kg > 0 AND weight_kg < 500),
    fitness_goal      fitness_goal,
    experience_level  experience_level,
    medical_notes     TEXT,
    emergency_contact VARCHAR(100),
    updated_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Trainer ↔ Client Assignments ───────────────────────────────

CREATE TABLE trainer_clients (
    trainer_id  UUID              NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id   UUID              NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    status      assignment_status NOT NULL DEFAULT 'active',

    PRIMARY KEY (trainer_id, client_id),
    CONSTRAINT chk_trainer_clients_not_self CHECK (trainer_id != client_id)
);

CREATE INDEX idx_trainer_clients_client  ON trainer_clients (client_id);
CREATE INDEX idx_trainer_clients_status  ON trainer_clients (status);

-- +migrate Down
DROP TABLE IF EXISTS trainer_clients CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;
