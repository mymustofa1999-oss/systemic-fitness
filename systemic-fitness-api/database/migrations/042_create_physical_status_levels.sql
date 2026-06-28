-- 042: SF Master — Physical Status Levels (Phase 1)
-- Output Q1 Phase A assessment: 3 buket level fungsional yang menentukan
-- routing user ke waitlist (Level 0–3), basic movement test (Preventive),
-- atau lanjut langsung ke Q2 (Level 4–5 / Performance).
-- Reference: SF_Master_Platform_Spec.docx halaman 145–158 (Phase A • Q1).

CREATE TABLE IF NOT EXISTS physical_status_levels (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug              VARCHAR(32)  NOT NULL UNIQUE,
    label             VARCHAR(160) NOT NULL,
    description       TEXT,
    -- Routing decision: "waitlist" | "preventive_movement_test" | "continue".
    routing           VARCHAR(32)  NOT NULL,
    -- Copy used by client when this level routes to waitlist (Level 0–3).
    waitlist_message  TEXT,
    sort_order        SMALLINT     NOT NULL DEFAULT 0,
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TRIGGER set_physical_status_levels_updated_at
    BEFORE UPDATE ON physical_status_levels
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX IF NOT EXISTS idx_physical_status_levels_active_sort
    ON physical_status_levels (is_active, sort_order);

-- ──────────────────────────────────────────────────────────────────────
-- Seed: 3 buket level dari spec.
-- ──────────────────────────────────────────────────────────────────────
INSERT INTO physical_status_levels (slug, label, description, routing, waitlist_message, sort_order)
VALUES
    (
        'level_0_1',
        'Saya hanya bisa berbaring atau duduk. Berdiri sendiri sangat sulit.',
        'Level 0–1: mobilitas dasar terbatas. Akses ke program aktif belum tersedia.',
        'waitlist',
        'Program Systemic Fitness saat ini dirancang untuk mereka yang sudah bisa bergerak mandiri. Kami sedang mengembangkan program khusus untuk anda — dan anda adalah alasan kami membangun platform ini lebih cepat.',
        1
    ),
    (
        'level_2_3',
        'Saya bisa berdiri, tapi berjalan masih terbatas atau butuh bantuan.',
        'Level 2–3: mampu berdiri dengan keterbatasan. Akses program aktif belum tersedia, tetap masuk waitlist + akses gratis modul "Gerakan dari Kursi".',
        'waitlist',
        'Program Systemic Fitness saat ini dirancang untuk mereka yang sudah bisa bergerak mandiri. Kami sedang mengembangkan program khusus untuk anda — dan anda adalah alasan kami membangun platform ini lebih cepat.',
        2
    ),
    (
        'level_4_5_perf',
        'Saya bisa berjalan, tapi gerakan fisik saya masih sangat terbatas dan stamina rendah.',
        'Level 4–5 / Performance: lanjut ke Phase A Q2 untuk menentukan kondisi medis & program. Untuk Preventive (tidak ada kondisi medis), lakukan Basic Movement Test sebelum Q2.',
        'continue',
        NULL,
        3
    )
ON CONFLICT (slug) DO NOTHING;
