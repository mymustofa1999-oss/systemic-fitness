-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  007: Meal Plans, Meal Plan Items & Nutrition Logs
--  Structured meal planning + daily food tracking
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE meal_plans (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100)  NOT NULL,
    description     TEXT,
    daily_calories  INT           CHECK (daily_calories > 0),
    protein_g       INT           CHECK (protein_g >= 0),
    carbs_g         INT           CHECK (carbs_g >= 0),
    fat_g           INT           CHECK (fat_g >= 0),
    created_by      UUID          REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_meal_plans_name CHECK (char_length(name) >= 1)
);

CREATE INDEX idx_meal_plans_created_by ON meal_plans (created_by);

CREATE TRIGGER trg_meal_plans_updated_at
    BEFORE UPDATE ON meal_plans
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Meal Plan Items ────────────────────────────────────────────

CREATE TABLE meal_plan_items (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_plan_id    UUID          NOT NULL REFERENCES meal_plans(id) ON DELETE CASCADE,
    meal_type       meal_type     NOT NULL,
    day_of_week     INT           CHECK (day_of_week >= 0 AND day_of_week <= 6),
    food_name       VARCHAR(100)  NOT NULL,
    portion         VARCHAR(50),
    calories        INT           CHECK (calories >= 0),
    protein_g       DECIMAL(6,1)  CHECK (protein_g >= 0),
    carbs_g         DECIMAL(6,1)  CHECK (carbs_g >= 0),
    fat_g           DECIMAL(6,1)  CHECK (fat_g >= 0),

    CONSTRAINT chk_meal_plan_items_food CHECK (char_length(food_name) >= 1)
);

CREATE INDEX idx_meal_plan_items_plan     ON meal_plan_items (meal_plan_id);
CREATE INDEX idx_meal_plan_items_day_meal ON meal_plan_items (meal_plan_id, day_of_week, meal_type);

-- ─── Nutrition Logs (daily food tracking) ───────────────────────

CREATE TABLE nutrition_logs (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    logged_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    meal_type   meal_type     NOT NULL,
    food_name   VARCHAR(100)  NOT NULL,
    calories    INT           CHECK (calories >= 0),
    protein_g   DECIMAL(6,1)  CHECK (protein_g >= 0),
    carbs_g     DECIMAL(6,1)  CHECK (carbs_g >= 0),
    fat_g       DECIMAL(6,1)  CHECK (fat_g >= 0),
    photo_url   TEXT,

    CONSTRAINT chk_nutrition_logs_food CHECK (char_length(food_name) >= 1)
);

CREATE INDEX idx_nutrition_logs_user_logged ON nutrition_logs (user_id, logged_at DESC);
-- idx_nutrition_logs_user_date dihapus: (logged_at::DATE) cast dari TIMESTAMPTZ tidak IMMUTABLE.
-- Range query via idx_nutrition_logs_user_logged sudah cukup untuk pattern filter-by-date.

-- +migrate Down
DROP TABLE IF EXISTS nutrition_logs CASCADE;
DROP TABLE IF EXISTS meal_plan_items CASCADE;
DROP TABLE IF EXISTS meal_plans CASCADE;
