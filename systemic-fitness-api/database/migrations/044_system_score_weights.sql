-- +migrate Up
-- ════════════════════════════════════════════════════════════════════
--  044: System Score Weights — owner-tunable weights for the v2 engine.
--
--  Default 35 / 35 / 30 (Movement / Nutrition / Rest) per spec §04.
--  Single active row at a time (enforced by partial unique index).
--  Editing requires owner role.
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS system_score_weights (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(80) NOT NULL,
    movement_pct    SMALLINT    NOT NULL,
    nutrition_pct   SMALLINT    NOT NULL,
    rest_pct        SMALLINT    NOT NULL,
    is_active       BOOLEAN     NOT NULL DEFAULT FALSE,
    notes           TEXT,
    created_by      UUID        REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_score_weights_sum
        CHECK (movement_pct + nutrition_pct + rest_pct = 100),
    CONSTRAINT chk_score_weights_nonneg
        CHECK (movement_pct >= 0 AND nutrition_pct >= 0 AND rest_pct >= 0)
);

CREATE TRIGGER set_system_score_weights_updated_at
    BEFORE UPDATE ON system_score_weights
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- Only one active row at a time.
CREATE UNIQUE INDEX IF NOT EXISTS idx_system_score_weights_active
    ON system_score_weights (is_active)
    WHERE is_active = TRUE;

-- Seed default 35 / 35 / 30 (Movement / Nutrition / Rest), active.
INSERT INTO system_score_weights (name, movement_pct, nutrition_pct, rest_pct, is_active, notes)
VALUES (
    'SF Default',
    35,
    35,
    30,
    TRUE,
    'Default System Score weights from SF Master Platform Spec v1.0 / 2026, §04.'
)
ON CONFLICT DO NOTHING;

-- +migrate Down
DROP TABLE IF EXISTS system_score_weights;
