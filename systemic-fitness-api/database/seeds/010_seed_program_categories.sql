-- 010: Seed Program Categories
-- Master data for program conditioning categories.

INSERT INTO program_categories (name, code, description, parameter_template, display_order, is_active, is_system)
VALUES
(
    'Functional Conditioning',
    'functional',
    'Program latihan fungsional untuk meningkatkan kemampuan gerak sehari-hari dan stabilitas tubuh.',
    '{"bpm_range": true}',
    1,
    TRUE,
    TRUE
),
(
    'Cardiorespiratory Conditioning',
    'cardiorespiratory',
    'Program latihan kardiovaskular untuk meningkatkan daya tahan jantung dan paru-paru.',
    '{"beban_upper": true, "beban_lower": true, "bpm_range": true}',
    2,
    TRUE,
    TRUE
),
(
    'Metabolic Conditioning',
    'metabolic',
    'Program latihan metabolik untuk meningkatkan pembakaran kalori dan efisiensi metabolisme tubuh.',
    '{"beban_upper": true, "beban_lower": true, "resistance": true}',
    3,
    TRUE,
    TRUE
)
ON CONFLICT (code) DO NOTHING;
