-- ═══════════════════════════════════════════════════════════════════
--  Seed: Program Templates (3 programs with workouts & exercises)
--  1. Beginner Full Body (3 days/week, 4 weeks)
--  2. Intermediate PPL (6 days/week, 8 weeks)
--  3. Advanced Bodybuilding Split (5 days/week, 12 weeks)
-- ═══════════════════════════════════════════════════════════════════

-- We need exercise IDs for the workout_exercises. Look them up by name.
-- Using a DO block with variables for clarity.

DO $$
DECLARE
    -- Exercise IDs
    ex_bench_press       UUID;
    ex_incline_press     UUID;
    ex_push_up           UUID;
    ex_chest_fly         UUID;
    ex_deadlift          UUID;
    ex_pull_up           UUID;
    ex_bent_over_row     UUID;
    ex_lat_pulldown      UUID;
    ex_cable_row         UUID;
    ex_squat             UUID;
    ex_rdl               UUID;
    ex_leg_press         UUID;
    ex_walking_lunge     UUID;
    ex_leg_curl          UUID;
    ex_leg_extension     UUID;
    ex_calf_raise        UUID;
    ex_ohp               UUID;
    ex_lateral_raise     UUID;
    ex_face_pull         UUID;
    ex_barbell_curl      UUID;
    ex_hammer_curl       UUID;
    ex_tricep_pushdown   UUID;
    ex_cgbp              UUID;
    ex_plank             UUID;
    ex_hanging_leg_raise UUID;
    ex_russian_twist     UUID;
    ex_hip_thrust        UUID;
    ex_bulgarian_split   UUID;
    ex_treadmill         UUID;
    ex_burpees           UUID;

    -- Workout IDs
    w_fb_a    UUID;  -- Full Body A
    w_fb_b    UUID;  -- Full Body B
    w_fb_c    UUID;  -- Full Body C
    w_push    UUID;  -- Push
    w_pull    UUID;  -- Pull
    w_legs    UUID;  -- Legs
    w_chest   UUID;  -- Chest & Triceps
    w_back    UUID;  -- Back & Biceps
    w_shoulders UUID; -- Shoulders
    w_legs_adv UUID; -- Legs Advanced
    w_arms    UUID;  -- Arms

    -- Program IDs
    p_beginner UUID;
    p_ppl      UUID;
    p_bro      UUID;

    -- Loop variables
    w INT;
BEGIN

    -- ─── Fetch Exercise IDs ─────────────────────────────────────
    SELECT id INTO ex_bench_press     FROM exercises WHERE name = 'Barbell Bench Press'    AND is_system LIMIT 1;
    SELECT id INTO ex_incline_press   FROM exercises WHERE name = 'Dumbbell Incline Press' AND is_system LIMIT 1;
    SELECT id INTO ex_push_up         FROM exercises WHERE name = 'Push-Up'                AND is_system LIMIT 1;
    SELECT id INTO ex_chest_fly       FROM exercises WHERE name = 'Dumbbell Chest Fly'     AND is_system LIMIT 1;
    SELECT id INTO ex_deadlift        FROM exercises WHERE name = 'Barbell Deadlift'       AND is_system LIMIT 1;
    SELECT id INTO ex_pull_up         FROM exercises WHERE name = 'Pull-Up'                AND is_system LIMIT 1;
    SELECT id INTO ex_bent_over_row   FROM exercises WHERE name = 'Barbell Bent-Over Row'  AND is_system LIMIT 1;
    SELECT id INTO ex_lat_pulldown    FROM exercises WHERE name = 'Lat Pulldown'           AND is_system LIMIT 1;
    SELECT id INTO ex_cable_row       FROM exercises WHERE name = 'Seated Cable Row'       AND is_system LIMIT 1;
    SELECT id INTO ex_squat           FROM exercises WHERE name = 'Barbell Back Squat'     AND is_system LIMIT 1;
    SELECT id INTO ex_rdl             FROM exercises WHERE name = 'Romanian Deadlift'      AND is_system LIMIT 1;
    SELECT id INTO ex_leg_press       FROM exercises WHERE name = 'Leg Press'              AND is_system LIMIT 1;
    SELECT id INTO ex_walking_lunge   FROM exercises WHERE name = 'Walking Lunges'         AND is_system LIMIT 1;
    SELECT id INTO ex_leg_curl        FROM exercises WHERE name = 'Leg Curl'               AND is_system LIMIT 1;
    SELECT id INTO ex_leg_extension   FROM exercises WHERE name = 'Leg Extension'          AND is_system LIMIT 1;
    SELECT id INTO ex_calf_raise      FROM exercises WHERE name = 'Calf Raise'             AND is_system LIMIT 1;
    SELECT id INTO ex_ohp             FROM exercises WHERE name = 'Overhead Press'         AND is_system LIMIT 1;
    SELECT id INTO ex_lateral_raise   FROM exercises WHERE name = 'Dumbbell Lateral Raise' AND is_system LIMIT 1;
    SELECT id INTO ex_face_pull       FROM exercises WHERE name = 'Face Pull'              AND is_system LIMIT 1;
    SELECT id INTO ex_barbell_curl    FROM exercises WHERE name = 'Barbell Curl'           AND is_system LIMIT 1;
    SELECT id INTO ex_hammer_curl     FROM exercises WHERE name = 'Dumbbell Hammer Curl'   AND is_system LIMIT 1;
    SELECT id INTO ex_tricep_pushdown FROM exercises WHERE name = 'Tricep Pushdown'        AND is_system LIMIT 1;
    SELECT id INTO ex_cgbp            FROM exercises WHERE name = 'Close-Grip Bench Press' AND is_system LIMIT 1;
    SELECT id INTO ex_plank           FROM exercises WHERE name = 'Plank'                  AND is_system LIMIT 1;
    SELECT id INTO ex_hanging_leg_raise FROM exercises WHERE name = 'Hanging Leg Raise'    AND is_system LIMIT 1;
    SELECT id INTO ex_russian_twist   FROM exercises WHERE name = 'Russian Twist'          AND is_system LIMIT 1;
    SELECT id INTO ex_hip_thrust      FROM exercises WHERE name = 'Hip Thrust'             AND is_system LIMIT 1;
    SELECT id INTO ex_bulgarian_split FROM exercises WHERE name = 'Bulgarian Split Squat'  AND is_system LIMIT 1;
    SELECT id INTO ex_treadmill       FROM exercises WHERE name = 'Treadmill Run'          AND is_system LIMIT 1;
    SELECT id INTO ex_burpees         FROM exercises WHERE name = 'Burpees'                AND is_system LIMIT 1;

    -- ═════════════════════════════════════════════════════════════
    --  TEMPLATE 1: Beginner Full Body (3 days/week, 4 weeks)
    -- ═════════════════════════════════════════════════════════════

    -- Workouts
    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'Beginner Full Body A', 'Focus on squat + push + pull fundamentals', 'strength', 45, TRUE)
    RETURNING id INTO w_fb_a;

    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'Beginner Full Body B', 'Focus on deadlift + press + row fundamentals', 'strength', 45, TRUE)
    RETURNING id INTO w_fb_b;

    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'Beginner Full Body C', 'Lighter day with bodyweight and cardio', 'strength', 40, TRUE)
    RETURNING id INTO w_fb_c;

    -- Full Body A exercises
    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds) VALUES
    (w_fb_a, ex_squat,          1, 3, '8-10',  120),
    (w_fb_a, ex_bench_press,    2, 3, '8-10',  90),
    (w_fb_a, ex_lat_pulldown,   3, 3, '10-12', 90),
    (w_fb_a, ex_leg_curl,       4, 3, '12',    60),
    (w_fb_a, ex_plank,          5, 3, '30s',   60);

    -- Full Body B exercises
    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds) VALUES
    (w_fb_b, ex_deadlift,       1, 3, '5',     180),
    (w_fb_b, ex_ohp,            2, 3, '8-10',  90),
    (w_fb_b, ex_cable_row,      3, 3, '10-12', 90),
    (w_fb_b, ex_leg_press,      4, 3, '12',    90),
    (w_fb_b, ex_barbell_curl,   5, 2, '12',    60);

    -- Full Body C exercises
    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds) VALUES
    (w_fb_c, ex_push_up,        1, 3, 'AMRAP', 60),
    (w_fb_c, ex_walking_lunge,  2, 3, '12',    60),
    (w_fb_c, ex_face_pull,      3, 3, '15',    60),
    (w_fb_c, ex_russian_twist,  4, 3, '20',    45),
    (w_fb_c, ex_treadmill,      5, 1, '15min', 0);

    -- Program
    INSERT INTO programs (id, name, description, duration_weeks, difficulty, goal, is_template)
    VALUES (gen_random_uuid(), 'Beginner Full Body', 'Perfect starting program. 3 days per week with full body workouts focusing on compound movements and proper form.', 4, 'beginner', 'general_fitness', TRUE)
    RETURNING id INTO p_beginner;

    -- Program days: Mon/Wed/Fri for 4 weeks
    FOR w IN 1..4 LOOP
        INSERT INTO program_days (program_id, week_number, day_of_week, workout_id, is_rest_day) VALUES
        (p_beginner, w, 0, w_fb_a,  FALSE),  -- Monday: Full Body A
        (p_beginner, w, 1, NULL,    TRUE),    -- Tuesday: Rest
        (p_beginner, w, 2, w_fb_b,  FALSE),  -- Wednesday: Full Body B
        (p_beginner, w, 3, NULL,    TRUE),    -- Thursday: Rest
        (p_beginner, w, 4, w_fb_c,  FALSE),  -- Friday: Full Body C
        (p_beginner, w, 5, NULL,    TRUE),    -- Saturday: Rest
        (p_beginner, w, 6, NULL,    TRUE);    -- Sunday: Rest
    END LOOP;

    -- ═════════════════════════════════════════════════════════════
    --  TEMPLATE 2: Intermediate PPL (6 days/week, 8 weeks)
    -- ═════════════════════════════════════════════════════════════

    -- Push Workout
    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'PPL: Push Day', 'Chest, shoulders, triceps', 'strength', 60, TRUE)
    RETURNING id INTO w_push;

    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds) VALUES
    (w_push, ex_bench_press,     1, 4, '6-8',   120),
    (w_push, ex_incline_press,   2, 3, '8-10',  90),
    (w_push, ex_ohp,             3, 3, '8-10',  90),
    (w_push, ex_lateral_raise,   4, 3, '12-15', 60),
    (w_push, ex_chest_fly,       5, 3, '12',    60),
    (w_push, ex_tricep_pushdown, 6, 3, '12-15', 60);

    -- Pull Workout
    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'PPL: Pull Day', 'Back, biceps, rear delts', 'strength', 60, TRUE)
    RETURNING id INTO w_pull;

    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds) VALUES
    (w_pull, ex_deadlift,      1, 3, '5',     180),
    (w_pull, ex_pull_up,       2, 4, 'AMRAP', 120),
    (w_pull, ex_bent_over_row, 3, 3, '8-10',  90),
    (w_pull, ex_cable_row,     4, 3, '10-12', 90),
    (w_pull, ex_face_pull,     5, 3, '15',    60),
    (w_pull, ex_barbell_curl,  6, 3, '10-12', 60),
    (w_pull, ex_hammer_curl,   7, 2, '12',    60);

    -- Legs Workout
    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'PPL: Leg Day', 'Quads, hamstrings, glutes, calves', 'strength', 65, TRUE)
    RETURNING id INTO w_legs;

    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds) VALUES
    (w_legs, ex_squat,           1, 4, '6-8',  180),
    (w_legs, ex_rdl,             2, 3, '8-10', 120),
    (w_legs, ex_leg_press,       3, 3, '10-12', 90),
    (w_legs, ex_walking_lunge,   4, 3, '12',    60),
    (w_legs, ex_leg_curl,        5, 3, '12',    60),
    (w_legs, ex_leg_extension,   6, 3, '12',    60),
    (w_legs, ex_calf_raise,      7, 4, '15',    45);

    -- Program
    INSERT INTO programs (id, name, description, duration_weeks, difficulty, goal, is_template)
    VALUES (gen_random_uuid(), 'Intermediate PPL', 'Push/Pull/Legs split — 6 days per week. Run each PPL rotation twice. Ideal for lifters with 6+ months experience wanting to build muscle.', 8, 'intermediate', 'gain_muscle', TRUE)
    RETURNING id INTO p_ppl;

    -- PPL schedule: Push/Pull/Legs/Push/Pull/Legs/Rest
    FOR w IN 1..8 LOOP
        INSERT INTO program_days (program_id, week_number, day_of_week, workout_id, is_rest_day) VALUES
        (p_ppl, w, 0, w_push, FALSE),  -- Monday: Push
        (p_ppl, w, 1, w_pull, FALSE),  -- Tuesday: Pull
        (p_ppl, w, 2, w_legs, FALSE),  -- Wednesday: Legs
        (p_ppl, w, 3, w_push, FALSE),  -- Thursday: Push
        (p_ppl, w, 4, w_pull, FALSE),  -- Friday: Pull
        (p_ppl, w, 5, w_legs, FALSE),  -- Saturday: Legs
        (p_ppl, w, 6, NULL,   TRUE);   -- Sunday: Rest
    END LOOP;

    -- ═════════════════════════════════════════════════════════════
    --  TEMPLATE 3: Advanced Bodybuilding Split (5 days/week, 12 weeks)
    -- ═════════════════════════════════════════════════════════════

    -- Chest & Triceps
    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'Bro Split: Chest & Triceps', 'High volume chest and triceps', 'strength', 70, TRUE)
    RETURNING id INTO w_chest;

    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds, superset_group) VALUES
    (w_chest, ex_bench_press,     1, 4, '6-8',   120, NULL),
    (w_chest, ex_incline_press,   2, 4, '8-10',  90,  NULL),
    (w_chest, ex_chest_fly,       3, 3, '12',    60,  NULL),
    (w_chest, ex_push_up,         4, 3, 'AMRAP', 60,  NULL),
    (w_chest, ex_cgbp,            5, 4, '8-10',  90,  NULL),
    (w_chest, ex_tricep_pushdown, 6, 3, '12-15', 45,  1),
    (w_chest, ex_plank,           7, 3, '45s',   45,  1);

    -- Back & Biceps
    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'Bro Split: Back & Biceps', 'High volume back and biceps', 'strength', 70, TRUE)
    RETURNING id INTO w_back;

    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds, superset_group) VALUES
    (w_back, ex_deadlift,       1, 4, '5',     180, NULL),
    (w_back, ex_pull_up,        2, 4, 'AMRAP', 120, NULL),
    (w_back, ex_bent_over_row,  3, 4, '8-10',  90,  NULL),
    (w_back, ex_cable_row,      4, 3, '10-12', 90,  NULL),
    (w_back, ex_lat_pulldown,   5, 3, '12',    60,  NULL),
    (w_back, ex_barbell_curl,   6, 4, '8-10',  60,  NULL),
    (w_back, ex_hammer_curl,    7, 3, '12',    45,  NULL);

    -- Shoulders
    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'Bro Split: Shoulders', 'All three delt heads + traps', 'strength', 55, TRUE)
    RETURNING id INTO w_shoulders;

    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds) VALUES
    (w_shoulders, ex_ohp,           1, 4, '6-8',   120),
    (w_shoulders, ex_lateral_raise, 2, 4, '12-15', 60),
    (w_shoulders, ex_face_pull,     3, 4, '15',    60),
    (w_shoulders, ex_incline_press, 4, 3, '10',    90),
    (w_shoulders, ex_russian_twist, 5, 3, '20',    45);

    -- Legs (Advanced)
    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'Bro Split: Legs', 'Heavy compound + isolation', 'strength', 75, TRUE)
    RETURNING id INTO w_legs_adv;

    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds) VALUES
    (w_legs_adv, ex_squat,           1, 5, '5',     180),
    (w_legs_adv, ex_hip_thrust,      2, 4, '8-10',  120),
    (w_legs_adv, ex_bulgarian_split, 3, 3, '10',    90),
    (w_legs_adv, ex_rdl,             4, 3, '10',    90),
    (w_legs_adv, ex_leg_extension,   5, 3, '12-15', 60),
    (w_legs_adv, ex_leg_curl,        6, 3, '12-15', 60),
    (w_legs_adv, ex_calf_raise,      7, 5, '15',    45);

    -- Arms Day
    INSERT INTO workouts (id, name, description, type, estimated_duration_min, is_template)
    VALUES (gen_random_uuid(), 'Bro Split: Arms', 'Dedicated arm day — biceps, triceps, forearms', 'strength', 50, TRUE)
    RETURNING id INTO w_arms;

    INSERT INTO workout_exercises (workout_id, exercise_id, order_index, sets, reps, rest_seconds, superset_group) VALUES
    (w_arms, ex_barbell_curl,    1, 4, '8-10',  90,  NULL),
    (w_arms, ex_cgbp,            2, 4, '8-10',  90,  NULL),
    (w_arms, ex_hammer_curl,     3, 3, '12',    45,  1),
    (w_arms, ex_tricep_pushdown, 4, 3, '12-15', 45,  1),
    (w_arms, ex_hanging_leg_raise, 5, 3, '15',  60,  NULL);

    -- Program
    INSERT INTO programs (id, name, description, duration_weeks, difficulty, goal, is_template)
    VALUES (gen_random_uuid(), 'Advanced Bodybuilding Split', '5-day bro split for experienced lifters. High volume with supersets. Chest/Back/Shoulders/Legs/Arms. Requires solid strength foundation.', 12, 'advanced', 'gain_muscle', TRUE)
    RETURNING id INTO p_bro;

    -- Bro split: Chest/Back/Shoulders/Legs/Arms/Rest/Rest
    FOR w IN 1..12 LOOP
        INSERT INTO program_days (program_id, week_number, day_of_week, workout_id, is_rest_day) VALUES
        (p_bro, w, 0, w_chest,     FALSE),  -- Monday: Chest & Triceps
        (p_bro, w, 1, w_back,      FALSE),  -- Tuesday: Back & Biceps
        (p_bro, w, 2, w_shoulders, FALSE),  -- Wednesday: Shoulders
        (p_bro, w, 3, w_legs_adv,  FALSE),  -- Thursday: Legs
        (p_bro, w, 4, w_arms,      FALSE),  -- Friday: Arms
        (p_bro, w, 5, NULL,        TRUE),   -- Saturday: Rest
        (p_bro, w, 6, NULL,        TRUE);   -- Sunday: Rest
    END LOOP;

    RAISE NOTICE 'Seeded 3 program templates with % workouts and schedule', 11;
END $$;
