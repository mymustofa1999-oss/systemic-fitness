-- +migrate Up
-- ════════════════════════════════════════════════════════════════════
--  049: SF Phase 7b — Clinical Notes (catatan klinis Health Consultant)
--
--  Why:
--    Setelah Phase 7a menambah role 'consultant', kita butuh tempat
--    consultant menyimpan catatan klinis hasil review:
--      - per-Asesmen v2 (rekomendasi tindak lanjut, flag merah)
--      - per-klien free-form (catatan progres lintas asesmen)
--      - opsional terkait Lab Consultation (interpretasi hasil lab)
--
--  Design:
--    - assessment_id NULLABLE: catatan bisa stand-alone (per-klien),
--      atau attached ke 1 asesmen.
--    - client_id NOT NULL: identifikasi pasien yang dirujuk.
--    - consultant_id NOT NULL: penulis (audit trail).
--    - is_visible_to_client: consultant draft → publish workflow.
--      Default FALSE supaya draft tidak bocor ke mobile sebelum siap.
--    - attachments JSONB array: [{url, name, mime, size}].
--    - Soft delete (deleted_at) supaya audit history kekal.
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS clinical_notes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    assessment_id   UUID REFERENCES assessments(id) ON DELETE SET NULL,
    client_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    consultant_id   UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

    title           VARCHAR(160) NOT NULL DEFAULT '',
    content         TEXT NOT NULL,
    attachments     JSONB NOT NULL DEFAULT '[]'::jsonb,

    is_visible_to_client  BOOLEAN NOT NULL DEFAULT FALSE,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT chk_clinical_notes_not_self
        CHECK (client_id <> consultant_id)
);

CREATE TRIGGER set_clinical_notes_updated_at
    BEFORE UPDATE ON clinical_notes
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- Index untuk halaman "Catatan Saya" (consultant filter by author).
CREATE INDEX IF NOT EXISTS idx_clinical_notes_consultant_created
    ON clinical_notes (consultant_id, created_at DESC)
    WHERE deleted_at IS NULL;

-- Index untuk halaman "Catatan per-Klien".
CREATE INDEX IF NOT EXISTS idx_clinical_notes_client_created
    ON clinical_notes (client_id, created_at DESC)
    WHERE deleted_at IS NULL;

-- Index untuk lookup per-Asesmen (apakah asesmen ini sudah di-review).
CREATE INDEX IF NOT EXISTS idx_clinical_notes_assessment
    ON clinical_notes (assessment_id)
    WHERE assessment_id IS NOT NULL AND deleted_at IS NULL;

-- +migrate Down
DROP TABLE IF EXISTS clinical_notes;
