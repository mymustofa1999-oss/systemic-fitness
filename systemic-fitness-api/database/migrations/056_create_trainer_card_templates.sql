-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  056: Trainer Card Templates
--  Templates used to pre-populate training cards based on level.
--  Structure: Template (per level) → Sequences → Sets → Items (movements)
-- ═══════════════════════════════════════════════════════════════════

-- ─── 1. Trainer Card Templates (one per level) ────────────────────

CREATE TABLE IF NOT EXISTS trainer_card_templates (
    id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    level       VARCHAR(10)     NOT NULL UNIQUE, -- '1', '2', '3-4', '4-5', '5', etc.
    notes       TEXT,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_trainer_card_templates_updated_at
    BEFORE UPDATE ON trainer_card_templates
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── 2. Trainer Card Template Sequences ───────────────────────────

CREATE TABLE IF NOT EXISTS trainer_card_template_sequences (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id         UUID        NOT NULL REFERENCES trainer_card_templates(id) ON DELETE CASCADE,
    program_category_id UUID        NOT NULL REFERENCES program_categories(id),
    duration            VARCHAR(20),
    sort_order          INT         NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_trainer_card_template_sequence UNIQUE (template_id, program_category_id)
);

CREATE INDEX idx_trainer_card_template_sequences_tmpl ON trainer_card_template_sequences (template_id);

CREATE TRIGGER trg_trainer_card_template_sequences_updated_at
    BEFORE UPDATE ON trainer_card_template_sequences
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── 3. Trainer Card Template Sets ───────────────────────────────

CREATE TABLE IF NOT EXISTS trainer_card_template_sets (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    sequence_id     UUID            NOT NULL REFERENCES trainer_card_template_sequences(id) ON DELETE CASCADE,
    set_number      INT             NOT NULL,
    duration        VARCHAR(20),
    equipment_upper VARCHAR(200),
    equipment_lower VARCHAR(200),
    type_id         UUID            REFERENCES trainer_card_types(id) ON DELETE SET NULL,
    bpm             VARCHAR(30),
    extra_load      VARCHAR(100),
    notes           TEXT,
    sort_order      INT             NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_trainer_card_template_sets_sequence ON trainer_card_template_sets (sequence_id);

CREATE TRIGGER trg_trainer_card_template_sets_updated_at
    BEFORE UPDATE ON trainer_card_template_sets
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── 4. Trainer Card Template Set Items ──────────────────────────

CREATE TABLE IF NOT EXISTS trainer_card_template_set_items (
    id            UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    set_id        UUID            NOT NULL REFERENCES trainer_card_template_sets(id) ON DELETE CASCADE,
    movement_id   UUID            REFERENCES dl_movements(id) ON DELETE SET NULL,
    movement_name VARCHAR(150),
    body_part     VARCHAR(10)     NOT NULL,
    equipment     VARCHAR(200),
    reps          INT,
    sets_count    INT             DEFAULT 1,
    sort_order    INT             NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_trainer_card_template_set_items_body_part
        CHECK (body_part IN ('upper', 'lower', 'core'))
);

CREATE INDEX idx_trainer_card_template_set_items_set ON trainer_card_template_set_items (set_id);
CREATE INDEX idx_trainer_card_template_set_items_movement ON trainer_card_template_set_items (movement_id);

CREATE TRIGGER trg_trainer_card_template_set_items_updated_at
    BEFORE UPDATE ON trainer_card_template_set_items
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- +migrate Down
DROP TABLE IF EXISTS trainer_card_template_set_items CASCADE;
DROP TABLE IF EXISTS trainer_card_template_sets CASCADE;
DROP TABLE IF EXISTS trainer_card_template_sequences CASCADE;
DROP TABLE IF EXISTS trainer_card_templates CASCADE;
