-- 040: SF Master — Klasifikasi Kondisi Fisik (Phase 1)
-- 5 klasifikasi induk (Imun & Inflamasi, Renal & Uric, Cardiorespiratory,
-- Metabolic, Musculoskeletal) yang dipakai Phase A assessment dan kurasi
-- program oleh Consultant.
-- Reference: SF_Master_Platform_Spec.docx §02 (Tiga Program Utama, formula
-- waktu per pilar) & halaman 168–181 (Kondisi Spesifik per Klasifikasi).
--
-- Schema additive — tidak menyentuh table lain.

CREATE TYPE focus_pillar AS ENUM ('FC', 'CC', 'MC');

CREATE TABLE IF NOT EXISTS condition_classifications (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug                   VARCHAR(64)   NOT NULL UNIQUE,
    label                  VARCHAR(120)  NOT NULL,
    description            TEXT,
    focus_pillar           focus_pillar  NOT NULL,
    -- Full Program 60 mnt formula: e.g. {"FC":35,"CC":15,"MC":10}
    full_program_formula   JSONB         NOT NULL DEFAULT '{}'::jsonb,
    -- Daily Reset 30 mnt formula: e.g. {"FC":20,"CC":10}
    daily_reset_formula    JSONB         NOT NULL DEFAULT '{}'::jsonb,
    sort_order             SMALLINT      NOT NULL DEFAULT 0,
    is_active              BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at             TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at             TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE TRIGGER set_condition_classifications_updated_at
    BEFORE UPDATE ON condition_classifications
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX IF NOT EXISTS idx_condition_classifications_active_sort
    ON condition_classifications (is_active, sort_order);

-- ──────────────────────────────────────────────────────────────────────
-- Seed: 5 klasifikasi inti dari spec.
-- Formula referensi spec hal. 76–135 (Formula Waktu per Pilar per Program).
-- ──────────────────────────────────────────────────────────────────────
INSERT INTO condition_classifications
    (slug, label, description, focus_pillar, full_program_formula, daily_reset_formula, sort_order)
VALUES
    (
        'imun-inflamasi',
        'Imun & Inflamasi',
        'Autoimun, alergi kronis, inflamasi sistemik, kista, tumor jinak, fibromyalgia. Pilar dominan: Functional Conditioning.',
        'FC',
        '{"FC":35,"CC":15,"MC":10}'::jsonb,
        '{"FC":20,"CC":10}'::jsonb,
        1
    ),
    (
        'renal-uric',
        'Renal & Uric System',
        'Gangguan ginjal (CKD 1–3), batu ginjal, asam urat / gout, hiperkalemia ringan. Pilar dominan: Cardiorespiratory Conditioning.',
        'CC',
        '{"FC":10,"CC":35,"MC":15}'::jsonb,
        '{"FC":10,"CC":20}'::jsonb,
        2
    ),
    (
        'cardiorespiratory',
        'Cardiorespiratory',
        'Hipertensi (stadium 1–2), penyakit jantung koroner stabil, aritmia ringan, asma terkontrol, PPOK ringan, kolesterol tinggi, gangguan syaraf pusat. Pilar dominan: Cardiorespiratory Conditioning.',
        'CC',
        '{"FC":10,"CC":35,"MC":15}'::jsonb,
        '{"CC":20,"MC":10}'::jsonb,
        3
    ),
    (
        'metabolic',
        'Metabolic',
        'Diabetes Tipe 2 (terkontrol), pre-diabetes, PCOS, gangguan tiroid, resistensi insulin, obesitas metabolik. Pilar dominan: Metabolic Conditioning.',
        'MC',
        '{"FC":10,"CC":15,"MC":35}'::jsonb,
        '{"CC":10,"MC":20}'::jsonb,
        4
    ),
    (
        'musculoskeletal',
        'Musculoskeletal',
        'Osteoarthritis, osteoporosis, HNP, spondylosis, frozen shoulder, skoliosis, neuropati perifer, kelemahan otot pasca imobilisasi. Pilar dominan: Metabolic Conditioning.',
        'MC',
        '{"FC":10,"CC":15,"MC":35}'::jsonb,
        '{"FC":10,"MC":20}'::jsonb,
        5
    )
ON CONFLICT (slug) DO NOTHING;
