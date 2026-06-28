-- 022: Daily Journal & Customer Health Tracking
-- Tables for customer daily session journal, HR zones, program categories,
-- customer medicine assignments, and vital signs tracking.

-- ─── 1. Program Categories (Master) ────────────────────────────────

CREATE TABLE IF NOT EXISTS program_categories (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name               VARCHAR(200)  NOT NULL,
    code               VARCHAR(50)   NOT NULL UNIQUE,
    description        TEXT,
    parameter_template JSONB         DEFAULT '{}',
    display_order      INT           NOT NULL DEFAULT 0,
    is_active          BOOLEAN       NOT NULL DEFAULT TRUE,
    is_system          BOOLEAN       NOT NULL DEFAULT FALSE,
    created_by         UUID          REFERENCES users(id),
    created_at         TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE TRIGGER set_program_categories_updated_at
    BEFORE UPDATE ON program_categories
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX IF NOT EXISTS idx_program_categories_code ON program_categories (code);
CREATE INDEX IF NOT EXISTS idx_program_categories_name_trgm ON program_categories USING gin (name gin_trgm_ops);

-- ─── 2. ALTER trainer_clients — add role_type ──────────────────────

ALTER TABLE trainer_clients
    ADD COLUMN IF NOT EXISTS role_type VARCHAR(20) NOT NULL DEFAULT 'trainer';

ALTER TABLE trainer_clients
    ADD CONSTRAINT chk_trainer_clients_role_type
    CHECK (role_type IN ('trainer', 'consultant'));

-- ─── 3. Customer HR Zones ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS customer_hr_zones (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id   UUID NOT NULL REFERENCES users(id) UNIQUE,
    max_hr_upper  INT,
    max_hr_lower  INT,
    zone5_upper   INT,
    zone5_lower   INT,
    zone4_upper   INT,
    zone4_lower   INT,
    zone3_upper   INT,
    zone3_lower   INT,
    zone2_upper   INT,
    zone2_lower   INT,
    zone1_upper   INT,
    zone1_lower   INT,
    notes         TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_customer_hr_zones_updated_at
    BEFORE UPDATE ON customer_hr_zones
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── 4. Customer Medicines (pivot) ─────────────────────────────────

CREATE TABLE IF NOT EXISTS customer_medicines (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id  UUID    NOT NULL REFERENCES users(id),
    medicine_id  UUID    NOT NULL REFERENCES medicines(id),
    notes        TEXT,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (customer_id, medicine_id)
);

CREATE INDEX IF NOT EXISTS idx_customer_medicines_customer ON customer_medicines (customer_id);

-- ─── 5. Customer Program Assignments ───────────────────────────────

CREATE TABLE IF NOT EXISTS customer_program_assignments (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id          UUID    NOT NULL REFERENCES users(id),
    program_category_id  UUID    NOT NULL REFERENCES program_categories(id),
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    bpm_upper            INT,
    bpm_lower            INT,
    has_beban_upper      BOOLEAN NOT NULL DEFAULT FALSE,
    has_beban_lower      BOOLEAN NOT NULL DEFAULT FALSE,
    has_resistance       BOOLEAN NOT NULL DEFAULT FALSE,
    parameter_notes      TEXT,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (customer_id, program_category_id)
);

CREATE TRIGGER set_customer_program_assignments_updated_at
    BEFORE UPDATE ON customer_program_assignments
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX IF NOT EXISTS idx_customer_program_assignments_customer ON customer_program_assignments (customer_id);

-- ─── 6. Daily Journal Sessions ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS daily_journal_sessions (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id    UUID        NOT NULL REFERENCES users(id),
    session_number INT         NOT NULL,
    session_date   DATE        NOT NULL,
    month_year     VARCHAR(7),
    notes          TEXT,
    created_by     UUID        REFERENCES users(id),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (customer_id, session_date)
);

CREATE TRIGGER set_daily_journal_sessions_updated_at
    BEFORE UPDATE ON daily_journal_sessions
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX IF NOT EXISTS idx_daily_journal_sessions_customer ON daily_journal_sessions (customer_id);
CREATE INDEX IF NOT EXISTS idx_daily_journal_sessions_month ON daily_journal_sessions (month_year);

-- ─── 7. Session Medicines ──────────────────────────────────────────

CREATE TABLE IF NOT EXISTS session_medicines (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id  UUID NOT NULL REFERENCES daily_journal_sessions(id) ON DELETE CASCADE,
    medicine_id UUID NOT NULL REFERENCES medicines(id),
    notes       TEXT,
    UNIQUE (session_id, medicine_id)
);

CREATE INDEX IF NOT EXISTS idx_session_medicines_session ON session_medicines (session_id);

-- ─── 8. Session Meals ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS session_meals (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id       UUID NOT NULL REFERENCES daily_journal_sessions(id) ON DELETE CASCADE,
    meal_time        TIME,
    food_description TEXT,
    food_id          UUID REFERENCES foods(id),
    notes            TEXT
);

CREATE INDEX IF NOT EXISTS idx_session_meals_session ON session_meals (session_id);

-- ─── 9. Session Vitals (BP Pre/Post Workout) ──────────────────────

CREATE TABLE IF NOT EXISTS session_vitals (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id       UUID        NOT NULL REFERENCES daily_journal_sessions(id) ON DELETE CASCADE,
    measurement_type VARCHAR(20) NOT NULL,
    systolic         INT,
    diastolic        INT,
    heartrate        INT,
    notes            TEXT,
    CONSTRAINT chk_session_vitals_type CHECK (measurement_type IN ('pre_workout', 'post_workout')),
    UNIQUE (session_id, measurement_type)
);

CREATE INDEX IF NOT EXISTS idx_session_vitals_session ON session_vitals (session_id);
