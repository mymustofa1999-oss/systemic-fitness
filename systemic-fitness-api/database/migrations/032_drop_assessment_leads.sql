-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  032: Drop assessment_leads table
--
--  Public anonymous lead capture has been removed from the product.
--  All assessments must now be submitted by authenticated users, so
--  the leads table is no longer needed.
--
--  Existing data (if any) will be permanently deleted.
-- ═══════════════════════════════════════════════════════════════════

DROP TABLE IF EXISTS assessment_leads CASCADE;

-- +migrate Down
-- Re-create the table on rollback so old data flows can resume.
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
