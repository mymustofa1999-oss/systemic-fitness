-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  012: Foods Library (Master Library → Nutrition → Foods)
--  Standalone food items with nutritional info, reusable across meals
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE foods (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(150)  NOT NULL,
    description     TEXT,
    image_url       TEXT,
    meal_types      meal_type[]   NOT NULL DEFAULT '{}',
    calories        INT           CHECK (calories >= 0),
    protein_g       DECIMAL(6,1)  CHECK (protein_g >= 0),
    carbs_g         DECIMAL(6,1)  CHECK (carbs_g >= 0),
    fat_g           DECIMAL(6,1)  CHECK (fat_g >= 0),
    fiber_g         DECIMAL(6,1)  CHECK (fiber_g >= 0),
    serving_size    VARCHAR(50),
    serving_unit    VARCHAR(30),
    is_system       BOOLEAN       NOT NULL DEFAULT false,
    created_by      UUID          REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_foods_name CHECK (char_length(name) >= 1)
);

CREATE INDEX idx_foods_name        ON foods (name);
CREATE INDEX idx_foods_created_by  ON foods (created_by);
CREATE INDEX idx_foods_meal_types  ON foods USING GIN (meal_types);
CREATE INDEX idx_foods_is_system   ON foods (is_system) WHERE is_system = true;

CREATE TRIGGER trg_foods_updated_at
    BEFORE UPDATE ON foods
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- +migrate Down
DROP TABLE IF EXISTS foods CASCADE;
