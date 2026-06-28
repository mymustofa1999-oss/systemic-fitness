-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  034: Nutrition Guidance & Monitoring Engine
--  - nutrition_health_profiles : structured health profile per user
--  - nutrition_daily_logs      : boolean intake log + computed score
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE nutrition_health_profiles (
    user_id           UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    gender            TEXT NOT NULL CHECK (gender IN ('male','female')),
    age_group         TEXT NOT NULL CHECK (age_group IN ('under_18','18_40','41_60','over_60')),
    female_condition  TEXT CHECK (female_condition IN ('normal','pregnant','menopause')),
    goal              TEXT NOT NULL CHECK (goal IN ('maintenance','fat_loss','recovery')),
    weight_kg         NUMERIC(5,2) NOT NULL DEFAULT 0,
    allergies         TEXT[] NOT NULL DEFAULT '{}',
    conditions        TEXT[] NOT NULL DEFAULT '{}',
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE nutrition_daily_logs (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    log_date           DATE NOT NULL,
    vegetable_intake   BOOLEAN NOT NULL DEFAULT false,
    protein_intake     BOOLEAN NOT NULL DEFAULT false,
    hydration_ok       BOOLEAN NOT NULL DEFAULT false,
    sugar_excess       BOOLEAN NOT NULL DEFAULT false,
    diet_violation     BOOLEAN NOT NULL DEFAULT false,
    score              INT  NOT NULL DEFAULT 0,
    status             TEXT NOT NULL CHECK (status IN ('stable','warning','risk')),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, log_date)
);

CREATE INDEX idx_nutrition_daily_logs_user_date
    ON nutrition_daily_logs(user_id, log_date DESC);

-- +migrate Down
DROP INDEX IF EXISTS idx_nutrition_daily_logs_user_date;
DROP TABLE IF EXISTS nutrition_daily_logs;
DROP TABLE IF EXISTS nutrition_health_profiles;
