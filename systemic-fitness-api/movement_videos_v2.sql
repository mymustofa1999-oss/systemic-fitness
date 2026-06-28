-- ════════════════════════════════════════════════════════════════════
--  Systemic Fitness — Movement Video URL Migration (v2)
--  Match by movement name only (UNIQUE constraint in production)
--  Total unique movements: 62
-- ════════════════════════════════════════════════════════════════════

-- Pre-check
SELECT 'BEFORE' AS status,
    COUNT(*) FILTER (WHERE video_url_male IS NOT NULL) AS male,
    COUNT(*) FILTER (WHERE video_url_female IS NOT NULL) AS female,
    COUNT(*) AS total
FROM dl_movements;

BEGIN;

-- Arm Rotation
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Gv0JzAjI4wE', video_url_female = 'https://youtu.be/CDkR0Hqu_B4' WHERE name = 'Arm Rotation';

-- Arm Swing
UPDATE dl_movements SET video_url_male = 'https://youtu.be/dgGHE1Sdl44', video_url_female = 'https://youtu.be/bPdopl2Jf3M' WHERE name = 'Arm Swing';

-- Back step - Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/2yhPBvyZSUU', video_url_female = 'https://youtu.be/0F48EbjjQTw' WHERE name = 'Back step - Chair';

-- Barbel Row
UPDATE dl_movements SET video_url_male = 'https://youtu.be/dQPys_dgoGY' WHERE name = 'Barbel Row';

-- Bent Over Fly
UPDATE dl_movements SET video_url_male = 'https://youtu.be/prz4V9AacSE' WHERE name = 'Bent Over Fly';

-- Bicep Curls
UPDATE dl_movements SET video_url_male = 'https://youtu.be/SZKOhGoXcTI' WHERE name = 'Bicep Curls';

-- Chest Press
UPDATE dl_movements SET video_url_male = 'https://youtu.be/wuH_zwLy6EM' WHERE name = 'Chest Press';

-- Cross Front
UPDATE dl_movements SET video_url_male = 'https://youtu.be/E9IzR-wui8o', video_url_female = 'https://youtu.be/h-Qk-6DWgsQ' WHERE name = 'Cross Front';

-- Cross Up
UPDATE dl_movements SET video_url_female = 'https://youtu.be/qy2ldvISD2Y' WHERE name = 'Cross Up';

-- Doggy Pee Band
UPDATE dl_movements SET video_url_female = 'https://youtu.be/xJXlQ3eAb3U' WHERE name = 'Doggy Pee Band';

-- Donkey Kick
UPDATE dl_movements SET video_url_female = 'https://youtu.be/REjEINo4nJc' WHERE name = 'Donkey Kick';

-- Donkey Kick Band
UPDATE dl_movements SET video_url_female = 'https://youtu.be/qmOF8yrtw4M' WHERE name = 'Donkey Kick Band';

-- Dumbbell Rows
UPDATE dl_movements SET video_url_male = 'https://youtu.be/1gPBgQn3JiA' WHERE name = 'Dumbbell Rows';

-- Front Lift - Sit
UPDATE dl_movements SET video_url_female = 'https://youtu.be/Atb_GRZ8sWE' WHERE name = 'Front Lift - Sit';

-- Front Lift Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/R63B9LnlbZE', video_url_female = 'https://youtu.be/JheecrPIpmM' WHERE name = 'Front Lift Chair';

-- Front Lift Sit
UPDATE dl_movements SET video_url_female = 'https://youtu.be/2X7EtSq2T6s' WHERE name = 'Front Lift Sit';

-- Front Raise
UPDATE dl_movements SET video_url_male = 'https://youtu.be/VOzvuZKDrL4' WHERE name = 'Front Raise';

-- Glute Bridge Band
UPDATE dl_movements SET video_url_female = 'https://youtu.be/2DzvTS7g394' WHERE name = 'Glute Bridge Band';

-- High Knee Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/CknG49mGjcs', video_url_female = 'https://youtu.be/oOGxaCNDeE4' WHERE name = 'High Knee Chair';

-- High Plank
UPDATE dl_movements SET video_url_female = 'https://youtu.be/6mFaXOZwqOw' WHERE name = 'High Plank';

-- Jog-Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/8sWa8vyjwvA', video_url_female = 'https://youtu.be/qSKkOd9gylg' WHERE name = 'Jog-Chair';

-- Kick Back
UPDATE dl_movements SET video_url_female = 'https://youtu.be/K-TIOy5Vft0' WHERE name = 'Kick Back';

-- Kick Back Band
UPDATE dl_movements SET video_url_female = 'https://youtu.be/nvSk5r4ZtMY' WHERE name = 'Kick Back Band';

-- Knee Drive Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Rg_XddCoNZ4', video_url_female = 'https://youtu.be/SeEB4tTMy3g' WHERE name = 'Knee Drive Chair';

-- Lateral Lunge
UPDATE dl_movements SET video_url_male = 'https://youtu.be/DZI61Qlo3n4', video_url_female = 'https://youtu.be/pIlDIlALdbc' WHERE name = 'Lateral Lunge';

-- Lateral Lunge Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/O9jBkVxvV6w', video_url_female = 'https://youtu.be/A8zrLo4iuns' WHERE name = 'Lateral Lunge Chair';

-- Lunges
UPDATE dl_movements SET video_url_male = 'https://youtu.be/ztKJWHeKSdU', video_url_female = 'https://youtu.be/ZcbOg4goUWY' WHERE name = 'Lunges';

-- Lunges Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/IcfCRJexRx4', video_url_female = 'https://youtu.be/ekUL39z6KzQ' WHERE name = 'Lunges Chair';

-- Open Arm
UPDATE dl_movements SET video_url_male = 'https://youtu.be/CmPzKXUH9GQ', video_url_female = 'https://youtu.be/Wh_4iamBMMc' WHERE name = 'Open Arm';

-- Open Chest
UPDATE dl_movements SET video_url_male = 'https://youtu.be/OnCUQ1_RYTE', video_url_female = 'https://youtu.be/pIWz19u3Xw0' WHERE name = 'Open Chest';

-- Open V
UPDATE dl_movements SET video_url_male = 'https://youtu.be/ICoAkaFoMAQ', video_url_female = 'https://youtu.be/qjKyIhvRSto' WHERE name = 'Open V';

-- Overhead Press
UPDATE dl_movements SET video_url_male = 'https://youtu.be/NFsWcXn8HmU' WHERE name = 'Overhead Press';

-- Overhead Squat
UPDATE dl_movements SET video_url_male = 'https://youtu.be/syENYeSA1-4', video_url_female = 'https://youtu.be/Zz_kb0SUEvM' WHERE name = 'Overhead Squat';

-- Overhead Squat TRX
UPDATE dl_movements SET video_url_male = 'https://youtu.be/zuD0fWUmQlc', video_url_female = 'https://youtu.be/Y6dZVU7lfM4' WHERE name = 'Overhead Squat TRX';

-- Pedal band
UPDATE dl_movements SET video_url_female = 'https://youtu.be/caeEgVqXUxE' WHERE name = 'Pedal band';

-- Plank
UPDATE dl_movements SET video_url_male = 'https://youtu.be/vnifs9riEJY' WHERE name = 'Plank';

-- Press Front
UPDATE dl_movements SET video_url_male = 'https://youtu.be/J5wWtoTR-ak', video_url_female = 'https://youtu.be/y2ApZiAYNH0' WHERE name = 'Press Front';

-- Press Up
UPDATE dl_movements SET video_url_male = 'https://youtu.be/vQl_OVtbI00', video_url_female = 'https://youtu.be/aFbveSHv7cQ' WHERE name = 'Press Up';

-- Pull Down
UPDATE dl_movements SET video_url_male = 'https://youtu.be/S6zwg686YrY', video_url_female = 'https://youtu.be/3vimOX9AHQc' WHERE name = 'Pull Down';

-- Pull Side Down
UPDATE dl_movements SET video_url_female = 'https://youtu.be/jgOaIUNOQww' WHERE name = 'Pull Side Down';

-- Push Up
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Q4fCSHL8FlU' WHERE name = 'Push Up';

-- Push Up Plank
UPDATE dl_movements SET video_url_female = 'https://youtu.be/qGa0DdAFp8A' WHERE name = 'Push Up Plank';

-- Side Lift Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/XFv3FOuQuqM', video_url_female = 'https://youtu.be/D-ekkwKHtSs' WHERE name = 'Side Lift Chair';

-- Side Step Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/VlqR1OxrXhE', video_url_female = 'https://youtu.be/3OFDAcpR3cU' WHERE name = 'Side Step Chair';

-- Sit Overhead Squat TRX
UPDATE dl_movements SET video_url_male = 'https://youtu.be/WLXNxVgKWWk' WHERE name = 'Sit Overhead Squat TRX';

-- Sit Squat TRX
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Nk-WOfTOKDk' WHERE name = 'Sit Squat TRX';

-- Sit Sumo Squat TRX
UPDATE dl_movements SET video_url_male = 'https://youtu.be/KmhFbTEOzq0' WHERE name = 'Sit Sumo Squat TRX';

-- Sit Up
UPDATE dl_movements SET video_url_male = 'https://youtu.be/CLweukibDg0', video_url_female = 'https://youtu.be/Po3qKd74lpg' WHERE name = 'Sit Up';

-- Squat
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Z_efCtyd2dQ', video_url_female = 'https://youtu.be/XyS-XmW2Pwc' WHERE name = 'Squat';

-- Squat Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/xxeOLPbsK7Y', video_url_female = 'https://youtu.be/lZbEjnKuygo' WHERE name = 'Squat Chair';

-- Squat Curtsy Lunges
UPDATE dl_movements SET video_url_female = 'https://youtu.be/7llhcX_p1Qw' WHERE name = 'Squat Curtsy Lunges';

-- Squat Step
UPDATE dl_movements SET video_url_male = 'https://youtu.be/BnfKGJrSCvk', video_url_female = 'https://youtu.be/lx7tnAYnfqU' WHERE name = 'Squat Step';

-- Squat Step Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/qY3b9178JnA', video_url_female = 'https://youtu.be/co1rOOnWJpo' WHERE name = 'Squat Step Chair';

-- Squat TRX
UPDATE dl_movements SET video_url_male = 'https://youtu.be/OJ_dpcSszR8', video_url_female = 'https://youtu.be/aEXUq7v5EvE' WHERE name = 'Squat TRX';

-- Squat-Band
UPDATE dl_movements SET video_url_female = 'https://youtu.be/eeq1nRoE7g8' WHERE name = 'Squat-Band';

-- Squat-Cross Up
UPDATE dl_movements SET video_url_female = 'https://youtu.be/h6T2Uc7Q-Go' WHERE name = 'Squat-Cross Up';

-- Squat-Press Up
UPDATE dl_movements SET video_url_male = 'https://youtu.be/UR3zf5_kbdU' WHERE name = 'Squat-Press Up';

-- Sumo Squat
UPDATE dl_movements SET video_url_male = 'https://youtu.be/z669Jt8SD8A', video_url_female = 'https://youtu.be/fLjY9iWHM5g' WHERE name = 'Sumo Squat';

-- Sumo Squat Chair
UPDATE dl_movements SET video_url_male = 'https://youtu.be/pyAAJmwFpH0', video_url_female = 'https://youtu.be/O2tJsvOTbiQ' WHERE name = 'Sumo Squat Chair';

-- Sumo Squat TRX
UPDATE dl_movements SET video_url_male = 'https://youtu.be/RMp3AABx4-I', video_url_female = 'https://youtu.be/o-I54NprOe4' WHERE name = 'Sumo Squat TRX';

-- Triceps Press
UPDATE dl_movements SET video_url_male = 'https://youtu.be/UkFjVk5QcCY', video_url_female = 'https://youtu.be/Q8Et1YRNA1s' WHERE name = 'Triceps Press';

-- Variasi Crunch
UPDATE dl_movements SET video_url_male = 'https://youtu.be/yCu79ggGrME' WHERE name = 'Variasi Crunch';

COMMIT;

-- Verification
SELECT 'AFTER' AS status,
    COUNT(*) FILTER (WHERE video_url_male IS NOT NULL) AS male,
    COUNT(*) FILTER (WHERE video_url_female IS NOT NULL) AS female,
    COUNT(*) FILTER (WHERE video_url_male IS NOT NULL OR video_url_female IS NOT NULL) AS with_video,
    COUNT(*) FILTER (WHERE video_url_male IS NULL AND video_url_female IS NULL) AS no_video,
    COUNT(*) AS total
FROM dl_movements;

-- Movements still without video
SELECT name, body_part, categories FROM dl_movements
WHERE video_url_male IS NULL AND video_url_female IS NULL
ORDER BY name;