-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  025: Trainer Cards
--  Consultant-configured exercise cards that trainers use as a guide
--  when conducting sessions with clients.
--  Structure: Card → Sequences (FC/CC/MC) → Sets → Items (movements)
-- ═══════════════════════════════════════════════════════════════════

-- ─── 1. Trainer Card Types (Master: Isolate, Dynamic, etc.) ────────

CREATE TABLE IF NOT EXISTS trainer_card_types (
    id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(50)     NOT NULL UNIQUE,
    description TEXT,
    is_active   BOOLEAN         NOT NULL DEFAULT TRUE,
    sort_order  INT             NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_trainer_card_types_updated_at
    BEFORE UPDATE ON trainer_card_types
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- Seed default types
INSERT INTO trainer_card_types (name, description, sort_order) VALUES
    ('Isolate',  'Gerakan isolasi — satu bagian tubuh per gerakan', 1),
    ('Dynamic',  'Gerakan dinamis — kombinasi upper dan lower body', 2);

-- ─── 2. Trainer Cards (one per customer) ───────────────────────────

CREATE TABLE IF NOT EXISTS trainer_cards (
    id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    level       VARCHAR(10)     NOT NULL,
    notes       TEXT,
    created_by  UUID            REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_trainer_cards_customer UNIQUE (customer_id)
);

CREATE INDEX idx_trainer_cards_customer ON trainer_cards (customer_id);
CREATE INDEX idx_trainer_cards_created_by ON trainer_cards (created_by);

CREATE TRIGGER trg_trainer_cards_updated_at
    BEFORE UPDATE ON trainer_cards
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── 3. Trainer Card Sequences (FC / CC / MC per card) ─────────────

CREATE TABLE IF NOT EXISTS trainer_card_sequences (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    trainer_card_id     UUID        NOT NULL REFERENCES trainer_cards(id) ON DELETE CASCADE,
    program_category_id UUID        NOT NULL REFERENCES program_categories(id),
    duration            VARCHAR(20),
    sort_order          INT         NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_trainer_card_sequence UNIQUE (trainer_card_id, program_category_id)
);

CREATE INDEX idx_trainer_card_sequences_card ON trainer_card_sequences (trainer_card_id);

CREATE TRIGGER trg_trainer_card_sequences_updated_at
    BEFORE UPDATE ON trainer_card_sequences
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── 4. Trainer Card Sets (sets within a sequence) ─────────────────

CREATE TABLE IF NOT EXISTS trainer_card_sets (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    sequence_id     UUID            NOT NULL REFERENCES trainer_card_sequences(id) ON DELETE CASCADE,
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

CREATE INDEX idx_trainer_card_sets_sequence ON trainer_card_sets (sequence_id);

CREATE TRIGGER trg_trainer_card_sets_updated_at
    BEFORE UPDATE ON trainer_card_sets
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ─── 5. Trainer Card Set Items (movements within a set) ────────────

CREATE TABLE IF NOT EXISTS trainer_card_set_items (
    id            UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    set_id        UUID            NOT NULL REFERENCES trainer_card_sets(id) ON DELETE CASCADE,
    movement_id   UUID            REFERENCES dl_movements(id) ON DELETE SET NULL,
    movement_name VARCHAR(150),
    body_part     VARCHAR(10)     NOT NULL,
    equipment     VARCHAR(200),
    reps          INT,
    sets_count    INT             DEFAULT 1,
    sort_order    INT             NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_trainer_card_set_items_body_part
        CHECK (body_part IN ('upper', 'lower', 'core'))
);

CREATE INDEX idx_trainer_card_set_items_set ON trainer_card_set_items (set_id);
CREATE INDEX idx_trainer_card_set_items_movement ON trainer_card_set_items (movement_id);

CREATE TRIGGER trg_trainer_card_set_items_updated_at
    BEFORE UPDATE ON trainer_card_set_items
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- +migrate Down
DROP TABLE IF EXISTS trainer_card_set_items CASCADE;
DROP TABLE IF EXISTS trainer_card_sets CASCADE;
DROP TABLE IF EXISTS trainer_card_sequences CASCADE;
DROP TABLE IF EXISTS trainer_cards CASCADE;
DROP TABLE IF EXISTS trainer_card_types CASCADE;
