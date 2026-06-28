-- +migrate Up
-- ════════════════════════════════════════════════════════════════════
--  046: SF Lab Consultations — booking & hasil sesi konsultasi.
--  Wajib untuk Tier 3 (sebelum program aktif), opsional untuk Tier 1-2.
--  Reference: SF Master Spec §05.
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS lab_consultations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Konsultan yang menangani (admin/owner/trainer untuk sekarang;
    -- akan jadi consultant role di Fase 7).
    consultant_id   UUID REFERENCES users(id) ON DELETE SET NULL,

    -- Optional link ke assessment v2 yang trigger booking ini.
    assessment_id   UUID REFERENCES assessments(id) ON DELETE SET NULL,

    -- Optional link ke payment record (jika dibayar terpisah).
    payment_id      UUID REFERENCES payment_records(id) ON DELETE SET NULL,

    status          VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending','scheduled','completed','cancelled','no_show')),

    -- Booking metadata
    fee_amount      DECIMAL(12,2) NOT NULL DEFAULT 350000,
    booking_note    TEXT,
    preferred_at    TIMESTAMPTZ,
    scheduled_at    TIMESTAMPTZ,

    -- Hasil sesi (consultant fill-in)
    completed_at    TIMESTAMPTZ,
    result_summary  TEXT,
    result_payload  JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER set_lab_consultations_updated_at
    BEFORE UPDATE ON lab_consultations
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX IF NOT EXISTS idx_lab_consultations_user
    ON lab_consultations (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_lab_consultations_status
    ON lab_consultations (status, created_at DESC)
    WHERE status IN ('pending','scheduled');
CREATE INDEX IF NOT EXISTS idx_lab_consultations_consultant
    ON lab_consultations (consultant_id, status)
    WHERE consultant_id IS NOT NULL;

-- +migrate Down
DROP TABLE IF EXISTS lab_consultations;
