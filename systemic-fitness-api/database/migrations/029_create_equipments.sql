-- +migrate Up

CREATE TABLE IF NOT EXISTS equipments (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100) NOT NULL,
    category    VARCHAR(10)  NOT NULL CHECK (category IN ('upper', 'lower')),
    description TEXT,
    is_active   BOOLEAN     NOT NULL DEFAULT true,
    sort_order  INT         NOT NULL DEFAULT 0,
    created_by  UUID        REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_equipments_updated_at
    BEFORE UPDATE ON equipments
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX idx_equipments_category ON equipments(category);
CREATE INDEX idx_equipments_is_active ON equipments(is_active);

-- Seed data
INSERT INTO equipments (name, category, sort_order) VALUES
    ('Wrist 0.25 kg', 'upper', 1),
    ('Wrist 0.5 kg',  'upper', 2),
    ('Wrist 1 kg',    'upper', 3),
    ('Wrist 1.5 kg',  'upper', 4),
    ('Wrist 2 kg',    'upper', 5),
    ('Wrist 2.5 kg',  'upper', 6),
    ('Stick 0.5 kg',  'upper', 7),
    ('Stick 1 kg',    'upper', 8),
    ('Stick 1.5 kg',  'upper', 9),
    ('Stick 2 kg',    'upper', 10),
    ('Ankle 0.5 kg',  'lower', 1),
    ('Ankle 1 kg',    'lower', 2),
    ('Ankle 1.5 kg',  'lower', 3),
    ('Ankle 2 kg',    'lower', 4),
    ('Ankle 2.5 kg',  'lower', 5),
    ('Ankle 3 kg',    'lower', 6),
    ('Ankle 3.5 kg',  'lower', 7),
    ('Ankle 4 kg',    'lower', 8);

-- +migrate Down

DROP TABLE IF EXISTS equipments CASCADE;
