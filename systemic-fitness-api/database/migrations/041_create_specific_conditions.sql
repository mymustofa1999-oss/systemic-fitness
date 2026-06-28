-- 041: SF Master — Kondisi Spesifik per Klasifikasi (Phase 1)
-- Sub-pilihan setelah user memilih klasifikasi di Phase A Q2 assessment.
-- Reference: SF_Master_Platform_Spec.docx halaman 168–181 +
-- https://docs.google.com/spreadsheets/d/1agBgHglT40cJFEhxbBslVdBRPsHeSkfsOPh1mcApZlI/edit
-- ditambah kolom yang di "Template Workout.xlsx" (sheet "Program Map").
--
-- Schema additive — tidak menyentuh table lain.

CREATE TABLE IF NOT EXISTS specific_conditions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classification_id   UUID NOT NULL REFERENCES condition_classifications(id) ON DELETE RESTRICT,
    slug                VARCHAR(80)   NOT NULL UNIQUE,
    label               VARCHAR(160)  NOT NULL,
    description         TEXT,
    -- Severity hint for the engine: "mild", "moderate", "severe", "monitor".
    severity_default    VARCHAR(16),
    -- Free-form clinical/program notes used by Consultant kurasi:
    -- {"medical_priority": true, "lab_required": false, "trigger_flags": [...]}
    notes               JSONB         NOT NULL DEFAULT '{}'::jsonb,
    sort_order          SMALLINT      NOT NULL DEFAULT 0,
    is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE TRIGGER set_specific_conditions_updated_at
    BEFORE UPDATE ON specific_conditions
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX IF NOT EXISTS idx_specific_conditions_classification
    ON specific_conditions (classification_id, is_active, sort_order);

-- ──────────────────────────────────────────────────────────────────────
-- Seed: kondisi spesifik dari spec.
-- ──────────────────────────────────────────────────────────────────────
WITH cls AS (
    SELECT id, slug FROM condition_classifications
)
INSERT INTO specific_conditions
    (classification_id, slug, label, severity_default, notes, sort_order)
SELECT cls.id, t.slug, t.label, t.severity, t.notes::jsonb, t.sort_order
FROM cls
JOIN (
    VALUES
        -- ── Imun & Inflamasi ──
        ('imun-inflamasi','autoimun',                'Autoimun (Lupus, RA, MS, dll)',                       'monitor',  '{}',                                    1),
        ('imun-inflamasi','alergi-kronis',           'Alergi kronis',                                       'mild',     '{}',                                    2),
        ('imun-inflamasi','inflamasi-sistemik',      'Inflamasi sistemik',                                  'moderate', '{}',                                    3),
        ('imun-inflamasi','kista',                   'Kista (ovarium, payudara, tiroid)',                   'monitor',  '{"medical_priority":true}',             4),
        ('imun-inflamasi','tumor-jinak',             'Tumor jinak',                                         'monitor',  '{"medical_priority":true}',             5),
        ('imun-inflamasi','fibromyalgia',            'Fibromyalgia',                                        'moderate', '{}',                                    6),

        -- ── Renal & Uric ──
        ('renal-uric','ckd-1-3',                     'Gangguan ginjal (CKD stadium 1–3)',                   'moderate', '{"lab_required":true}',                 1),
        ('renal-uric','batu-ginjal',                 'Batu ginjal',                                         'mild',     '{}',                                    2),
        ('renal-uric','asam-urat',                   'Asam urat / Gout',                                    'mild',     '{}',                                    3),
        ('renal-uric','hiperkalemia-ringan',         'Hiperkalemia ringan',                                 'mild',     '{"lab_required":true}',                 4),

        -- ── Cardiorespiratory ──
        ('cardiorespiratory','hipertensi',           'Hipertensi (stadium 1–2)',                            'moderate', '{}',                                    1),
        ('cardiorespiratory','penyakit-jantung',     'Penyakit jantung koroner stabil',                     'severe',   '{"medical_priority":true}',             2),
        ('cardiorespiratory','aritmia-ringan',       'Aritmia ringan',                                      'moderate', '{}',                                    3),
        ('cardiorespiratory','asma-terkontrol',      'Asma terkontrol',                                     'mild',     '{}',                                    4),
        ('cardiorespiratory','ppok-ringan',          'PPOK ringan',                                         'mild',     '{}',                                    5),
        ('cardiorespiratory','kolesterol',           'Kolesterol tinggi',                                   'mild',     '{}',                                    6),
        ('cardiorespiratory','gangguan-syaraf-pusat','Gangguan syaraf pusat (post-stroke, MS ringan)',      'severe',   '{"medical_priority":true}',             7),

        -- ── Metabolic ──
        ('metabolic','diabetes-tipe-2',              'Diabetes Tipe 2 (terkontrol)',                        'moderate', '{}',                                    1),
        ('metabolic','pre-diabetes',                 'Pre-diabetes',                                        'mild',     '{}',                                    2),
        ('metabolic','pcos',                         'PCOS',                                                'moderate', '{}',                                    3),
        ('metabolic','tiroid',                       'Gangguan tiroid (hipotiroid / hipertiroid terkontrol)','moderate','{}',                                    4),
        ('metabolic','resistensi-insulin',           'Resistensi insulin',                                  'mild',     '{}',                                    5),
        ('metabolic','obesitas-metabolik',           'Obesitas metabolik',                                  'moderate', '{}',                                    6),

        -- ── Musculoskeletal ──
        ('musculoskeletal','osteoarthritis',         'Osteoarthritis',                                      'moderate', '{}',                                    1),
        ('musculoskeletal','osteoporosis',           'Osteoporosis',                                        'moderate', '{}',                                    2),
        ('musculoskeletal','hnp',                    'Hernia Nukleus Pulposus (HNP)',                       'severe',   '{}',                                    3),
        ('musculoskeletal','spondylosis',            'Spondylosis',                                         'moderate', '{}',                                    4),
        ('musculoskeletal','frozen-shoulder',        'Frozen shoulder',                                     'mild',     '{}',                                    5),
        ('musculoskeletal','skoliosis',              'Skoliosis',                                           'moderate', '{}',                                    6),
        ('musculoskeletal','neuropati-perifer',      'Gangguan syaraf tepi (neuropati perifer)',            'moderate', '{}',                                    7),
        ('musculoskeletal','lemah-otot-pasca-imobilisasi','Kelemahan otot pasca imobilisasi',               'mild',     '{}',                                    8)
) AS t(classification_slug, slug, label, severity, notes, sort_order)
ON cls.slug = t.classification_slug
ON CONFLICT (slug) DO NOTHING;
