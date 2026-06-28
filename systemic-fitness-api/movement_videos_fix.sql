-- ════════════════════════════════════════════════════════════════════
--  Movement Video URL — Fix unmatched + Add missing movements
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ── Fix: Name mappings (Excel → DB) ──
-- Excel 'Squat Curtsy Lunges' → DB 'Curtsy Lunges'
UPDATE dl_movements SET video_url_female = 'https://youtu.be/7llhcX_p1Qw' WHERE name = 'Curtsy Lunges';

-- Excel 'Triceps Press' → DB 'Tricep Press'
UPDATE dl_movements SET video_url_male = 'https://youtu.be/UkFjVk5QcCY', video_url_female = 'https://youtu.be/Q8Et1YRNA1s' WHERE name = 'Tricep Press';

-- Excel 'Squat-Press Up' → DB 'Squat Press'
UPDATE dl_movements SET video_url_male = 'https://youtu.be/UR3zf5_kbdU' WHERE name = 'Squat Press';

-- Excel 'Pedal band' → DB 'Pedal Band'
UPDATE dl_movements SET video_url_female = 'https://youtu.be/caeEgVqXUxE' WHERE name = 'Pedal Band';

-- ── New movements from Excel (not in DB) ──
-- New: Barbel Row (upper, {mc})
INSERT INTO dl_movements (name, body_part, categories, video_url_male, video_url_female)
VALUES ('Barbel Row', 'upper', ARRAY['mc']::training_category[], 'https://youtu.be/dQPys_dgoGY', NULL)
ON CONFLICT (name) DO UPDATE SET video_url_male = EXCLUDED.video_url_male, video_url_female = EXCLUDED.video_url_female;

-- New: Dumbbell Rows (upper, {mc})
INSERT INTO dl_movements (name, body_part, categories, video_url_male, video_url_female)
VALUES ('Dumbbell Rows', 'upper', ARRAY['mc']::training_category[], 'https://youtu.be/1gPBgQn3JiA', NULL)
ON CONFLICT (name) DO UPDATE SET video_url_male = EXCLUDED.video_url_male, video_url_female = EXCLUDED.video_url_female;

-- New: Front Lift - Sit (lower, {cc})
INSERT INTO dl_movements (name, body_part, categories, video_url_male, video_url_female)
VALUES ('Front Lift - Sit', 'lower', ARRAY['cc']::training_category[], NULL, 'https://youtu.be/Atb_GRZ8sWE')
ON CONFLICT (name) DO UPDATE SET video_url_male = EXCLUDED.video_url_male, video_url_female = EXCLUDED.video_url_female;

-- New: Front Raise (upper, {mc})
INSERT INTO dl_movements (name, body_part, categories, video_url_male, video_url_female)
VALUES ('Front Raise', 'upper', ARRAY['mc']::training_category[], 'https://youtu.be/VOzvuZKDrL4', NULL)
ON CONFLICT (name) DO UPDATE SET video_url_male = EXCLUDED.video_url_male, video_url_female = EXCLUDED.video_url_female;

-- New: Squat-Cross Up (upper, {mc})
INSERT INTO dl_movements (name, body_part, categories, video_url_male, video_url_female)
VALUES ('Squat-Cross Up', 'upper', ARRAY['mc']::training_category[], NULL, 'https://youtu.be/h6T2Uc7Q-Go')
ON CONFLICT (name) DO UPDATE SET video_url_male = EXCLUDED.video_url_male, video_url_female = EXCLUDED.video_url_female;

-- New: Variasi Crunch (lower, {mc})
INSERT INTO dl_movements (name, body_part, categories, video_url_male, video_url_female)
VALUES ('Variasi Crunch', 'lower', ARRAY['mc']::training_category[], 'https://youtu.be/yCu79ggGrME', NULL)
ON CONFLICT (name) DO UPDATE SET video_url_male = EXCLUDED.video_url_male, video_url_female = EXCLUDED.video_url_female;

COMMIT;

-- Verification
SELECT 'RESULT' AS status,
    COUNT(*) FILTER (WHERE video_url_male IS NOT NULL) AS male,
    COUNT(*) FILTER (WHERE video_url_female IS NOT NULL) AS female,
    COUNT(*) FILTER (WHERE video_url_male IS NOT NULL OR video_url_female IS NOT NULL) AS with_video,
    COUNT(*) FILTER (WHERE video_url_male IS NULL AND video_url_female IS NULL) AS no_video,
    COUNT(*) AS total
FROM dl_movements;

-- Remaining without video
SELECT name, body_part, categories FROM dl_movements
WHERE video_url_male IS NULL AND video_url_female IS NULL
ORDER BY name;