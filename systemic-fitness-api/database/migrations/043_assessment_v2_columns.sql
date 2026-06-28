-- +migrate Up
-- ════════════════════════════════════════════════════════════════════
--  043: Assessment v2 — Phase A/B/C, Chronobiology, System Score 35/35/30
--
--  ADDITIVE migration. Existing v1 rows keep their data and continue to
--  use sleep_input/movement_input/metabolic_input + sleep/recovery/
--  movement/metabolic/system scores. New v2 rows live in the same table
--  and are identified by version='v2', populating phase_a/b/c_payload
--  and the new score columns (rest_score, nutrition_score,
--  movement_score_v2, system_score_v2).
--
--  Reference: SF_Master_Platform_Spec.docx §03 (Assessment Flow), §04
--  (System Score 35/35/30), halaman 333–456 (Chronobiology Window per
--  Kondisi).
-- ════════════════════════════════════════════════════════════════════

-- Version flag: every existing row stays 'v1' (backfill below).
ALTER TABLE assessments
    ADD COLUMN IF NOT EXISTS version VARCHAR(8) NOT NULL DEFAULT 'v1';

-- Raw payloads for new flow
ALTER TABLE assessments
    ADD COLUMN IF NOT EXISTS phase_a_payload JSONB,
    ADD COLUMN IF NOT EXISTS phase_b_payload JSONB,
    ADD COLUMN IF NOT EXISTS phase_c_payload JSONB;

-- v2 scores (NUMERIC for half-point precision; v1 stays in SMALLINT cols)
ALTER TABLE assessments
    ADD COLUMN IF NOT EXISTS rest_score        NUMERIC(5,2),
    ADD COLUMN IF NOT EXISTS nutrition_score   NUMERIC(5,2),
    ADD COLUMN IF NOT EXISTS movement_score_v2 NUMERIC(5,2),
    ADD COLUMN IF NOT EXISTS system_score_v2   NUMERIC(5,2);

-- Chronobiology Window (resolved by engine):
--   { "ideal_start":"15:00", "ideal_end":"17:00",
--     "alt_start":"13:00",   "alt_end":"15:00",
--     "avoid":"Sebelum 07.30",
--     "override_reason":"B3>45 mnt: geser ke sore" }
ALTER TABLE assessments
    ADD COLUMN IF NOT EXISTS chronobiology_window JSONB;

-- Phase A outputs (denormalized for fast filter/queue queries)
ALTER TABLE assessments
    ADD COLUMN IF NOT EXISTS classification_id     UUID REFERENCES condition_classifications(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS specific_condition_id UUID REFERENCES specific_conditions(id)        ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS physical_status_level VARCHAR(16),  -- level_0_1 | level_2_3 | level_4_5_perf
    ADD COLUMN IF NOT EXISTS program_type          VARCHAR(40);  -- see CHECK below

-- Allowed values for program_type (kept open as plain VARCHAR for cheap rollback;
-- spec values: condition_specific | preventive | performance_women_35_45 |
-- performance_women_46_60 | performance_men_35_45 | performance_men_46_60 |
-- waitlist).
ALTER TABLE assessments
    ADD CONSTRAINT chk_assessments_program_type
    CHECK (program_type IS NULL OR program_type IN (
        'condition_specific',
        'preventive',
        'performance_women_35_45',
        'performance_women_46_60',
        'performance_men_35_45',
        'performance_men_46_60',
        'waitlist'
    ));

-- Existing constraints assume v1 only — relax them for v2.
-- Drop the old NOT NULL on sleep_input/movement_input so v2 rows can
-- skip these columns; preserve them for v1 by re-adding a conditional
-- check.
ALTER TABLE assessments ALTER COLUMN sleep_input    DROP NOT NULL;
ALTER TABLE assessments ALTER COLUMN movement_input DROP NOT NULL;
ALTER TABLE assessments ALTER COLUMN sleep_score    DROP NOT NULL;
ALTER TABLE assessments ALTER COLUMN recovery_score DROP NOT NULL;
ALTER TABLE assessments ALTER COLUMN movement_score DROP NOT NULL;
ALTER TABLE assessments ALTER COLUMN system_score   DROP NOT NULL;
ALTER TABLE assessments ALTER COLUMN sleep_class    DROP NOT NULL;
ALTER TABLE assessments ALTER COLUMN movement_class DROP NOT NULL;
ALTER TABLE assessments ALTER COLUMN insight        DROP NOT NULL;

-- Hard rule: each row must populate either v1 columns or v2 columns.
ALTER TABLE assessments
    ADD CONSTRAINT chk_assessments_version_payload
    CHECK (
        (version = 'v1' AND sleep_input IS NOT NULL AND movement_input IS NOT NULL)
        OR
        (version = 'v2' AND phase_a_payload IS NOT NULL)
    );

-- Index for v2 queue / filter
CREATE INDEX IF NOT EXISTS idx_assessments_version_v2
    ON assessments (version, created_at DESC)
    WHERE version = 'v2';

CREATE INDEX IF NOT EXISTS idx_assessments_classification
    ON assessments (classification_id)
    WHERE classification_id IS NOT NULL;

-- +migrate Down
ALTER TABLE assessments DROP CONSTRAINT IF EXISTS chk_assessments_version_payload;
ALTER TABLE assessments DROP CONSTRAINT IF EXISTS chk_assessments_program_type;
DROP INDEX IF EXISTS idx_assessments_version_v2;
DROP INDEX IF EXISTS idx_assessments_classification;

ALTER TABLE assessments
    DROP COLUMN IF EXISTS chronobiology_window,
    DROP COLUMN IF EXISTS phase_a_payload,
    DROP COLUMN IF EXISTS phase_b_payload,
    DROP COLUMN IF EXISTS phase_c_payload,
    DROP COLUMN IF EXISTS rest_score,
    DROP COLUMN IF EXISTS nutrition_score,
    DROP COLUMN IF EXISTS movement_score_v2,
    DROP COLUMN IF EXISTS system_score_v2,
    DROP COLUMN IF EXISTS classification_id,
    DROP COLUMN IF EXISTS specific_condition_id,
    DROP COLUMN IF EXISTS physical_status_level,
    DROP COLUMN IF EXISTS program_type,
    DROP COLUMN IF EXISTS version;

-- Restore v1 NOT NULL constraints
ALTER TABLE assessments ALTER COLUMN sleep_input    SET NOT NULL;
ALTER TABLE assessments ALTER COLUMN movement_input SET NOT NULL;
ALTER TABLE assessments ALTER COLUMN sleep_score    SET NOT NULL;
ALTER TABLE assessments ALTER COLUMN recovery_score SET NOT NULL;
ALTER TABLE assessments ALTER COLUMN movement_score SET NOT NULL;
ALTER TABLE assessments ALTER COLUMN system_score   SET NOT NULL;
ALTER TABLE assessments ALTER COLUMN sleep_class    SET NOT NULL;
ALTER TABLE assessments ALTER COLUMN movement_class SET NOT NULL;
ALTER TABLE assessments ALTER COLUMN insight        SET NOT NULL;
