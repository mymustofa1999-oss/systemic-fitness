-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  020: Digital Library — Master Data for Fitness Conditioning
--  Pre-fitness health detection & conditioning movement library
--  Categories: FC (Functional), CC (Cardio), MC (Metabolic)
--  Levels 0-5 represent patient progression from bed-bound to full dynamic
-- ═══════════════════════════════════════════════════════════════════

-- ─── ENUM Types ─────────────────────────────────────────────────

CREATE TYPE training_category AS ENUM ('fc', 'cc', 'mc');
CREATE TYPE training_phase AS ENUM ('menu', 'isolate', 'dynamic');
CREATE TYPE dl_body_part AS ENUM ('upper', 'lower', 'core');
CREATE TYPE dl_position AS ENUM ('sit', 'stand');

-- ─── Training Categories ────────────────────────────────────────

CREATE TABLE dl_categories (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    code            training_category NOT NULL UNIQUE,
    name            VARCHAR(100)    NOT NULL,
    description     TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_dl_categories_updated_at
    BEFORE UPDATE ON dl_categories
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── Training Levels ────────────────────────────────────────────

CREATE TABLE dl_levels (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    level_number    INT             NOT NULL UNIQUE CHECK (level_number >= 0 AND level_number <= 5),
    name            VARCHAR(100)    NOT NULL,
    name_id         VARCHAR(100)    NOT NULL,   -- Indonesian name
    description     TEXT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_dl_levels_updated_at
    BEFORE UPDATE ON dl_levels
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── Movements (Master Exercise Catalog) ────────────────────────

CREATE TABLE dl_movements (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(150)    NOT NULL UNIQUE,
    body_part       dl_body_part    NOT NULL,
    description     TEXT,
    video_url_male  TEXT,
    video_url_female TEXT,
    image_url       TEXT,
    duration        VARCHAR(20),
    instructions    TEXT[]          DEFAULT '{}',
    equipment       VARCHAR(100),
    categories      training_category[] NOT NULL DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dl_movements_body_part   ON dl_movements (body_part);
CREATE INDEX idx_dl_movements_categories  ON dl_movements USING GIN (categories);
CREATE INDEX idx_dl_movements_name_trgm   ON dl_movements USING GIN (name gin_trgm_ops);

CREATE TRIGGER trg_dl_movements_updated_at
    BEFORE UPDATE ON dl_movements
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── Menu Items (Level-based progression) ───────────────────────
--  Links a movement to a specific category + level with ordering

CREATE TABLE dl_menu_items (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id     UUID            NOT NULL REFERENCES dl_categories(id) ON DELETE CASCADE,
    level_id        UUID            NOT NULL REFERENCES dl_levels(id) ON DELETE CASCADE,
    movement_id     UUID            NOT NULL REFERENCES dl_movements(id) ON DELETE CASCADE,
    body_part       dl_body_part    NOT NULL,
    sort_order      INT             NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dl_menu_cat_level ON dl_menu_items (category_id, level_id);
CREATE INDEX idx_dl_menu_movement  ON dl_menu_items (movement_id);

CREATE TRIGGER trg_dl_menu_items_updated_at
    BEFORE UPDATE ON dl_menu_items
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── Isolate Items (Individual movements by position) ───────────
--  Position = sit / stand; each movement practised in isolation

CREATE TABLE dl_isolate_items (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id     UUID            NOT NULL REFERENCES dl_categories(id) ON DELETE CASCADE,
    movement_id     UUID            NOT NULL REFERENCES dl_movements(id) ON DELETE CASCADE,
    position        dl_position     NOT NULL,
    sort_order      INT             NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dl_isolate_cat_pos ON dl_isolate_items (category_id, position);

CREATE TRIGGER trg_dl_isolate_items_updated_at
    BEFORE UPDATE ON dl_isolate_items
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── Dynamic Items (Paired upper + lower movements) ─────────────
--  Upper and lower movements performed simultaneously at tempo/BPM

CREATE TABLE dl_dynamic_items (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id         UUID        NOT NULL REFERENCES dl_categories(id) ON DELETE CASCADE,
    upper_movement_id   UUID        REFERENCES dl_movements(id) ON DELETE SET NULL,
    lower_movement_id   UUID        REFERENCES dl_movements(id) ON DELETE SET NULL,
    sort_order          INT         NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_dl_dynamic_has_movement
        CHECK (upper_movement_id IS NOT NULL OR lower_movement_id IS NOT NULL)
);

CREATE INDEX idx_dl_dynamic_category ON dl_dynamic_items (category_id);

CREATE TRIGGER trg_dl_dynamic_items_updated_at
    BEFORE UPDATE ON dl_dynamic_items
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- +migrate Down
DROP TABLE IF EXISTS dl_dynamic_items CASCADE;
DROP TABLE IF EXISTS dl_isolate_items CASCADE;
DROP TABLE IF EXISTS dl_menu_items CASCADE;
DROP TABLE IF EXISTS dl_movements CASCADE;
DROP TABLE IF EXISTS dl_levels CASCADE;
DROP TABLE IF EXISTS dl_categories CASCADE;

DROP TYPE IF EXISTS dl_position CASCADE;
DROP TYPE IF EXISTS dl_body_part CASCADE;
DROP TYPE IF EXISTS training_phase CASCADE;
DROP TYPE IF EXISTS training_category CASCADE;
