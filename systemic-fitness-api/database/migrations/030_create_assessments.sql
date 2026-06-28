-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  030: Basic Assessments (Free + Paid)
--  Sleep / Movement / Metabolic scoring with auto classification
--  Supports anonymous public lead capture and authed user submissions
-- ═══════════════════════════════════════════════════════════════════

-- ─── ENUM types ──────────────────────────────────────────────────

CREATE TYPE assessment_tier AS ENUM ('free', 'paid');

CREATE TYPE assessment_status AS ENUM ('submitted', 'verified', 'revised');

CREATE TYPE assessment_classification AS ENUM (
    'optimal', 'compromised', 'critical',
    'stable', 'compensation', 'dysfunction',
    'efficient', 'at_risk', 'dysregulated'
);

-- ─── assessments ─────────────────────────────────────────────────

CREATE TABLE assessments (
    id              UUID                      PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID                      REFERENCES users(id) ON DELETE CASCADE,
    tier            assessment_tier           NOT NULL,
    status          assessment_status         NOT NULL DEFAULT 'submitted',

    -- Raw inputs (JSONB for full audit trail; key fields are also stored
    -- in computed score columns below for fast filtering / sorting).
    sleep_input     JSONB                     NOT NULL,
    movement_input  JSONB                     NOT NULL,
    metabolic_input JSONB,

    -- Computed scores
    sleep_score     SMALLINT                  NOT NULL,
    recovery_score  SMALLINT                  NOT NULL,
    movement_score  SMALLINT                  NOT NULL,
    metabolic_score SMALLINT,
    system_score    SMALLINT                  NOT NULL,

    sleep_class     assessment_classification NOT NULL,
    movement_class  assessment_classification NOT NULL,
    metabolic_class assessment_classification,

    flags           TEXT[]                    NOT NULL DEFAULT '{}',
    insight         TEXT                      NOT NULL,
    recommendations TEXT[]                    NOT NULL DEFAULT '{}',

    -- Trainer review (paid only)
    reviewed_by     UUID                      REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at     TIMESTAMPTZ,
    reviewer_notes  TEXT,

    created_at      TIMESTAMPTZ               NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ               NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_assessments_paid_metabolic
        CHECK (tier <> 'paid' OR metabolic_input IS NOT NULL)
);

CREATE INDEX idx_assessments_user_created
    ON assessments (user_id, created_at DESC)
    WHERE user_id IS NOT NULL;

CREATE INDEX idx_assessments_pending_review
    ON assessments (created_at DESC)
    WHERE tier = 'paid' AND status = 'submitted';

CREATE INDEX idx_assessments_tier   ON assessments (tier);
CREATE INDEX idx_assessments_status ON assessments (status);

CREATE TRIGGER trg_assessments_updated_at
    BEFORE UPDATE ON assessments
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── assessment_leads ────────────────────────────────────────────
-- Anonymous public submissions linked back to a real user account
-- once they register with the same email.

CREATE TABLE assessment_leads (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id     UUID         NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    email             VARCHAR(255) NOT NULL,
    full_name         VARCHAR(100),
    phone             VARCHAR(20),
    source            VARCHAR(50),
    converted_user_id UUID         REFERENCES users(id) ON DELETE SET NULL,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_assessment_leads_email
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_assessment_leads_email          ON assessment_leads (LOWER(email));
CREATE INDEX idx_assessment_leads_assessment_id  ON assessment_leads (assessment_id);
CREATE INDEX idx_assessment_leads_converted     ON assessment_leads (converted_user_id) WHERE converted_user_id IS NOT NULL;

-- +migrate Down
DROP TABLE IF EXISTS assessment_leads CASCADE;
DROP TABLE IF EXISTS assessments      CASCADE;
DROP TYPE  IF EXISTS assessment_classification;
DROP TYPE  IF EXISTS assessment_status;
DROP TYPE  IF EXISTS assessment_tier;
