-- ═══════════════════════════════════════════════════════════════════
--  Seed: Digital Library — Master Data
--  Source: Digital Library.xlsx (9 sheets)
--  Categories: FC (Functional), CC (Cardio), MC (Metabolic)
-- ═══════════════════════════════════════════════════════════════════

-- ─── 1. Training Categories ─────────────────────────────────────

INSERT INTO dl_categories (code, name, description) VALUES
('fc', 'Functional Conditioning', 'Functional movement patterns for rehabilitation and conditioning. Focuses on basic movement quality, joint stability, and progressive mobility from bed-bound to full dynamic movement.'),
('cc', 'Cardio Conditioning', 'Cardiovascular conditioning movements designed to improve heart rate response, endurance, and aerobic capacity progressively from seated to full dynamic training.'),
('mc', 'Metabolic Conditioning', 'Metabolic and muscle-building movements using resistance bands and bodyweight. Targets muscle hypertrophy, metabolic rate improvement, and core stability.') ON CONFLICT DO NOTHING;

-- ─── 2. Training Levels ─────────────────────────────────────────

INSERT INTO dl_levels (level_number, name, name_id, description) VALUES
(0, 'Level 0 - Lying',        'Level 0 - Berbaring',           'Client is bed-bound or lying down. Minimal movement capacity. Only seated upper-body and basic lower-body exercises.'),
(1, 'Level 1 - Sitting',      'Level 1 - Duduk',               'Client can sit upright. Seated upper-body exercises with TRX-assisted lower-body movements for stability.'),
(2, 'Level 2 - Standing',     'Level 2 - Berdiri',             'Client can stand. Standing exercises with chair/TRX support for balance and safety.'),
(3, 'Level 3 - Limited Walk', 'Level 3 - Jalan Terbatas',      'Client can walk with limitations. Chair-supported exercises with more variety including lunges and lateral movements.'),
(4, 'Level 4 - Normal Walk',  'Level 4 - Jalan Normal',        'Client walks normally. Introduction of dynamic paired movements (upper + lower simultaneously). Chair support optional.'),
(5, 'Level 5 - Full Dynamic', 'Level 5 - Dynamic Full BPM',    'Full dynamic training at target BPM. All movements without support, including advanced compound exercises.') ON CONFLICT DO NOTHING;

-- ─── 3. All Unique Movements ────────────────────────────────────
-- Classified by body_part and which categories they appear in
-- Body Part: upper / lower / core

INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories) VALUES
-- ══ UPPER BODY MOVEMENTS ══
('Arm Rotation', 'upper', 'https://youtu.be/Gv0JzAjI4wE', 'https://youtu.be/CDkR0Hqu_B4', '{fc,cc}'),
('Open V', 'upper', 'https://youtu.be/ICoAkaFoMAQ', 'https://youtu.be/qjKyIhvRSto', '{fc,cc,mc}'),
('Press Up', 'upper', 'https://youtu.be/vQl_OVtbI00', 'https://youtu.be/aFbveSHv7cQ', '{fc,cc,mc}'),
('Press Front', 'upper', 'https://youtu.be/J5wWtoTR-ak', 'https://youtu.be/y2ApZiAYNH0', '{fc,cc,mc}'),
('Open Arm', 'upper', 'https://youtu.be/CmPzKXUH9GQ', 'https://youtu.be/Wh_4iamBMMc', '{fc,cc,mc}'),
('Cross Front', 'upper', 'https://youtu.be/E9IzR-wui8o', 'https://youtu.be/h-Qk-6DWgsQ', '{fc,cc}'),
('Arm Swing', 'upper', 'https://youtu.be/dgGHE1Sdl44', 'https://youtu.be/bPdopl2Jf3M', '{fc,cc}'),
('Pull Side Down', 'upper', NULL, 'https://youtu.be/jgOaIUNOQww', '{fc,cc}'),
('Cross Up', 'upper', NULL, 'https://youtu.be/qy2ldvISD2Y', '{fc,cc,mc}'),
('Pull Down', 'upper', 'https://youtu.be/S6zwg686YrY', 'https://youtu.be/3vimOX9AHQc', '{fc,cc}'),
('Open Chest', 'upper', 'https://youtu.be/OnCUQ1_RYTE', 'https://youtu.be/pIWz19u3Xw0', '{cc}'),
('Tricep Press', 'upper', 'https://youtu.be/UkFjVk5QcCY', 'https://youtu.be/Q8Et1YRNA1s', '{mc}'),
('Partial Lateral Raise', 'upper', NULL, NULL, '{mc}'),
('Triceps Extension', 'upper', NULL, NULL, '{mc}'),
('Lat Pull Down (Close Grip)', 'upper', NULL, NULL, '{mc}'),
('Crossover Lat Pull Down', 'upper', NULL, NULL, '{mc}'),
('Squat Press', 'upper', NULL, NULL, '{mc}'),
('Chest Press', 'upper', 'https://youtu.be/wuH_zwLy6EM', NULL, '{mc}'),
('Bent Over Fly', 'upper', 'https://youtu.be/prz4V9AacSE', NULL, '{mc}'),
('Overhead Press', 'upper', 'https://youtu.be/NFsWcXn8HmU', NULL, '{mc}'),
('Bicep Curls', 'upper', 'https://youtu.be/SZKOhGoXcTI', NULL, '{mc}'),

-- ══ LOWER BODY MOVEMENTS ══
('Front Lift Sit', 'lower', NULL, 'https://youtu.be/2X7EtSq2T6s', '{fc,cc}'),
('Sit Squat TRX', 'lower', 'https://youtu.be/Nk-WOfTOKDk', NULL, '{fc,cc}'),
('Sit Overhead Squat TRX', 'lower', 'https://youtu.be/WLXNxVgKWWk', NULL, '{fc,cc}'),
('Sit Sumo Squat TRX', 'lower', 'https://youtu.be/KmhFbTEOzq0', NULL, '{fc,cc}'),
('Back step - Chair', 'lower', 'https://youtu.be/2yhPBvyZSUU', 'https://youtu.be/0F48EbjjQTw', '{fc,cc}'),
('Side Step Chair', 'lower', 'https://youtu.be/VlqR1OxrXhE', 'https://youtu.be/3OFDAcpR3cU', '{fc,cc}'),
('Side Lift Chair', 'lower', 'https://youtu.be/XFv3FOuQuqM', 'https://youtu.be/D-ekkwKHtSs', '{fc,cc}'),
('Front Lift Chair', 'lower', 'https://youtu.be/R63B9LnlbZE', 'https://youtu.be/JheecrPIpmM', '{fc,cc}'),
('High Knee Chair', 'lower', 'https://youtu.be/CknG49mGjcs', 'https://youtu.be/oOGxaCNDeE4', '{fc,cc}'),
('Knee Drive Chair', 'lower', 'https://youtu.be/Rg_XddCoNZ4', 'https://youtu.be/SeEB4tTMy3g', '{fc,cc}'),
('Jog-Chair', 'lower', 'https://youtu.be/8sWa8vyjwvA', 'https://youtu.be/qSKkOd9gylg', '{fc,cc}'),
('Squat TRX', 'lower', 'https://youtu.be/OJ_dpcSszR8', 'https://youtu.be/aEXUq7v5EvE', '{fc,cc}'),
('Overhead Squat TRX', 'lower', 'https://youtu.be/zuD0fWUmQlc', 'https://youtu.be/Y6dZVU7lfM4', '{fc,cc}'),
('Sumo Squat TRX', 'lower', 'https://youtu.be/RMp3AABx4-I', 'https://youtu.be/o-I54NprOe4', '{fc,cc}'),
('Lunges Chair', 'lower', 'https://youtu.be/IcfCRJexRx4', 'https://youtu.be/ekUL39z6KzQ', '{fc,cc}'),
('Lateral Lunge TRX', 'lower', NULL, NULL, '{fc}'),
('Wide Step Touch', 'lower', NULL, NULL, '{fc,cc}'),
('Back step', 'lower', NULL, NULL, '{fc,cc}'),
('Front Lift', 'lower', NULL, NULL, '{fc,cc}'),
('Side Lift', 'lower', NULL, NULL, '{fc,cc,mc}'),
('Side High Knee', 'lower', NULL, NULL, '{fc,cc}'),
('High Knee', 'lower', NULL, NULL, '{fc,cc}'),
('Knee Drive', 'lower', NULL, NULL, '{fc,cc}'),
('Squat Chair', 'lower', 'https://youtu.be/xxeOLPbsK7Y', 'https://youtu.be/lZbEjnKuygo', '{fc}'),
('Sumo Squat Chair', 'lower', 'https://youtu.be/pyAAJmwFpH0', 'https://youtu.be/O2tJsvOTbiQ', '{fc}'),
('Squat Step Chair', 'lower', 'https://youtu.be/qY3b9178JnA', 'https://youtu.be/co1rOOnWJpo', '{fc}'),
('Lateral Lunge Chair', 'lower', 'https://youtu.be/O9jBkVxvV6w', 'https://youtu.be/A8zrLo4iuns', '{fc}'),
('Squat', 'lower', 'https://youtu.be/Z_efCtyd2dQ', 'https://youtu.be/XyS-XmW2Pwc', '{fc}'),
('Overhead Squat', 'lower', 'https://youtu.be/syENYeSA1-4', 'https://youtu.be/Zz_kb0SUEvM', '{fc}'),
('Sumo Squat', 'lower', 'https://youtu.be/z669Jt8SD8A', 'https://youtu.be/fLjY9iWHM5g', '{fc}'),
('Squat Step', 'lower', 'https://youtu.be/BnfKGJrSCvk', 'https://youtu.be/lx7tnAYnfqU', '{fc}'),
('Lunges', 'lower', 'https://youtu.be/ztKJWHeKSdU', 'https://youtu.be/ZcbOg4goUWY', '{fc}'),
('Lateral Lunge', 'lower', 'https://youtu.be/DZI61Qlo3n4', 'https://youtu.be/pIlDIlALdbc', '{fc}'),
('Curtsy Lunges', 'lower', NULL, 'https://youtu.be/7llhcX_p1Qw', '{fc}'),
('Front Step', 'lower', NULL, NULL, '{cc}'),
('Side Step', 'lower', NULL, NULL, '{cc}'),
('Kick Back', 'lower', NULL, 'https://youtu.be/K-TIOy5Vft0', '{mc}'),
('Donkey Kick', 'lower', NULL, 'https://youtu.be/REjEINo4nJc', '{mc}'),
('Squat-Band', 'lower', NULL, 'https://youtu.be/eeq1nRoE7g8', '{mc}'),
('Doggy Pee Band', 'lower', NULL, 'https://youtu.be/xJXlQ3eAb3U', '{mc}'),
('Donkey Kick Band', 'lower', NULL, 'https://youtu.be/qmOF8yrtw4M', '{mc}'),
('Kick Back Band', 'lower', NULL, 'https://youtu.be/nvSk5r4ZtMY', '{mc}'),

-- ══ CORE MOVEMENTS (MC only) ══
('Push Up', 'core', 'https://youtu.be/Q4fCSHL8FlU', NULL, '{mc}'),
('Pedal', 'core', NULL, NULL, '{mc}'),
('Glute Bridge', 'core', NULL, NULL, '{mc}'),
('Sit Up', 'core', 'https://youtu.be/CLweukibDg0', 'https://youtu.be/Po3qKd74lpg', '{mc}'),
('Push Up Plank', 'core', NULL, 'https://youtu.be/qGa0DdAFp8A', '{mc}'),
('Plank', 'core', 'https://youtu.be/vnifs9riEJY', NULL, '{mc}'),
('High Plank', 'core', NULL, 'https://youtu.be/6mFaXOZwqOw', '{mc}'),
('Sit Up Band', 'core', NULL, NULL, '{mc}'),
('Glute Bridge Band', 'core', NULL, 'https://youtu.be/2DzvTS7g394', '{mc}'),
('Spider Lunge', 'core', NULL, NULL, '{mc}'),
('Pedal Band', 'core', NULL, NULL, '{mc}') ON CONFLICT (name) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════════
--  4. MENU ITEMS — Level-based progression per category
--     Source: Menu FC, Menu CC, Menu MC sheets
-- ═══════════════════════════════════════════════════════════════════

-- Helper: category & level references use subqueries
-- Format: (cat_code, level_num, movement_name, body_part, sort_order)

-- ─────────────────────────────────────────────────────────────────
-- MENU FC — Functional Conditioning
-- ─────────────────────────────────────────────────────────────────

-- FC Level 0 (Berbaring) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
-- FC Level 0 — Lower
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Front Lift Sit'), 'lower', 6);

-- FC Level 1 (Duduk) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
-- FC Level 1 — Lower
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Sit Squat TRX'), 'lower', 6),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Sit Overhead Squat TRX'), 'lower', 7),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Sit Sumo Squat TRX'), 'lower', 8),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Front Lift Sit'), 'lower', 9);

-- FC Level 2 (Berdiri) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
-- FC Level 2 — Lower
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Back step - Chair'), 'lower', 6),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Side Step Chair'), 'lower', 7),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Side Lift Chair'), 'lower', 8),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Front Lift Chair'), 'lower', 9),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='High Knee Chair'), 'lower', 10),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Knee Drive Chair'), 'lower', 11),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Jog-Chair'), 'lower', 12),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Squat TRX'), 'lower', 13),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Overhead Squat TRX'), 'lower', 14),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Sumo Squat TRX'), 'lower', 15);

-- FC Level 3 (Jalan Terbatas) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
-- FC Level 3 — Lower
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Back step - Chair'), 'lower', 6),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Side Step Chair'), 'lower', 7),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Side Lift Chair'), 'lower', 8),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Front Lift Chair'), 'lower', 9),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='High Knee Chair'), 'lower', 10),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Knee Drive Chair'), 'lower', 11),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Jog-Chair'), 'lower', 12),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Squat TRX'), 'lower', 13),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Overhead Squat TRX'), 'lower', 14),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Sumo Squat TRX'), 'lower', 15),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Lunges Chair'), 'lower', 16),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Lateral Lunge TRX'), 'lower', 17);

-- FC Level 4 (Jalan Normal) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Arm Swing'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 5),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 6),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Pull Side Down'), 'upper', 7),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'upper', 8),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Pull Down'), 'upper', 9),
-- FC Level 4 — Lower
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 'lower', 10),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Back step'), 'lower', 11),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Front Lift'), 'lower', 12),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Side Lift'), 'lower', 13),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Side High Knee'), 'lower', 14),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='High Knee'), 'lower', 15),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Knee Drive'), 'lower', 16),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Squat Chair'), 'lower', 17),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Overhead Squat'), 'lower', 18),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Sumo Squat Chair'), 'lower', 19),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Squat Step Chair'), 'lower', 20),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Lunges Chair'), 'lower', 21),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Lateral Lunge Chair'), 'lower', 22);

-- FC Level 5 (Dynamic Full BPM) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Arm Swing'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 5),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 6),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Pull Side Down'), 'upper', 7),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'upper', 8),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Pull Down'), 'upper', 9),
-- FC Level 5 — Lower
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 'lower', 10),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Back step'), 'lower', 11),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Front Lift'), 'lower', 12),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Side Lift'), 'lower', 13),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Side High Knee'), 'lower', 14),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='High Knee'), 'lower', 15),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Knee Drive'), 'lower', 16),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Squat'), 'lower', 17),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Overhead Squat'), 'lower', 18),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Sumo Squat'), 'lower', 19),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Squat Step'), 'lower', 20),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Lunges'), 'lower', 21),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Lateral Lunge'), 'lower', 22),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Curtsy Lunges'), 'lower', 23);

-- ─────────────────────────────────────────────────────────────────
-- MENU CC — Cardio Conditioning
-- ─────────────────────────────────────────────────────────────────

-- CC Level 0 (Berbaring) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
-- CC Level 0 — Lower
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=0), (SELECT id FROM dl_movements WHERE name='Front Lift Sit'), 'lower', 6);

-- CC Level 1 (Duduk) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
-- CC Level 1 — Lower
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Sit Squat TRX'), 'lower', 6),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Sit Overhead Squat TRX'), 'lower', 7),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Sit Sumo Squat TRX'), 'lower', 8),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Front Lift Sit'), 'lower', 9);

-- CC Level 2 (Berdiri) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
-- CC Level 2 — Lower
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Back step - Chair'), 'lower', 6),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Side Step Chair'), 'lower', 7),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Side Lift Chair'), 'lower', 8),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Front Lift Chair'), 'lower', 9),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='High Knee Chair'), 'lower', 10),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Knee Drive Chair'), 'lower', 11),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Jog-Chair'), 'lower', 12),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Squat TRX'), 'lower', 13),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Overhead Squat TRX'), 'lower', 14),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Sumo Squat TRX'), 'lower', 15);

-- CC Level 3 (Jalan Terbatas) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
-- CC Level 3 — Lower
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Back step - Chair'), 'lower', 6),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Side Step Chair'), 'lower', 7),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Side Lift Chair'), 'lower', 8),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Front Lift Chair'), 'lower', 9),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='High Knee Chair'), 'lower', 10),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Knee Drive Chair'), 'lower', 11),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Jog-Chair'), 'lower', 12),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Squat TRX'), 'lower', 13),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Overhead Squat TRX'), 'lower', 14),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Sumo Squat TRX'), 'lower', 15),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Lunges Chair'), 'lower', 16);

-- CC Level 4 (Jalan Normal) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Open Chest'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'upper', 6),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 7),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Arm Swing'), 'upper', 8),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Pull Side Down'), 'upper', 9),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Pull Down'), 'upper', 10),
-- CC Level 4 — Lower
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 'lower', 11),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Front Step'), 'lower', 12),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Side Step'), 'lower', 13),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Back step'), 'lower', 14),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Front Lift'), 'lower', 15),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Side Lift'), 'lower', 16),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Side High Knee'), 'lower', 17),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='High Knee'), 'lower', 18),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Knee Drive'), 'lower', 19);

-- CC Level 5 (Dynamic Full BPM) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Open Chest'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'upper', 5),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'upper', 6),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 7),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Arm Swing'), 'upper', 8),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Pull Side Down'), 'upper', 9),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Pull Down'), 'upper', 10),
-- CC Level 5 — Lower
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 'lower', 11),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Front Step'), 'lower', 12),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Side Step'), 'lower', 13),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Back step'), 'lower', 14),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Front Lift'), 'lower', 15),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Side Lift'), 'lower', 16),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Side High Knee'), 'lower', 17),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='High Knee'), 'lower', 18),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_levels WHERE level_number=5), (SELECT id FROM dl_movements WHERE name='Knee Drive'), 'lower', 19);

-- ─────────────────────────────────────────────────────────────────
-- MENU MC — Metabolic Conditioning
-- (Note: MC has no Level 0; starts at Level 1; Levels 4-5 combined)
-- ─────────────────────────────────────────────────────────────────

-- MC Level 1 (Duduk) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Tricep Press'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'upper', 5),
-- MC Level 1 — Lower
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=1), (SELECT id FROM dl_movements WHERE name='Squat-Band'), 'lower', 6);

-- MC Level 2 (Berdiri) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Tricep Press'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'upper', 5),
-- MC Level 2 — Lower
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Squat-Band'), 'lower', 6),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=2), (SELECT id FROM dl_movements WHERE name='Side Lift'), 'lower', 7);

-- MC Level 3 (Jalan Terbatas) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Tricep Press'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'upper', 5),
-- MC Level 3 — Lower
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Squat-Band'), 'lower', 6),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Side Lift'), 'lower', 7),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=3), (SELECT id FROM dl_movements WHERE name='Kick Back'), 'lower', 8);

-- MC Level 4-5 (Jalan Normal + Dynamic) — Upper
INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Open V'), 'upper', 0),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Press Up'), 'upper', 1),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Press Front'), 'upper', 2),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'upper', 3),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Tricep Press'), 'upper', 4),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'upper', 5),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Partial Lateral Raise'), 'upper', 6),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Triceps Extension'), 'upper', 7),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Lat Pull Down (Close Grip)'), 'upper', 8),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Crossover Lat Pull Down'), 'upper', 9),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Squat Press'), 'upper', 10),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Chest Press'), 'upper', 11),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Bent Over Fly'), 'upper', 12),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Overhead Press'), 'upper', 13),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Bicep Curls'), 'upper', 14),
-- MC Level 4-5 — Lower
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Kick Back'), 'lower', 15),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Donkey Kick'), 'lower', 16),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Side Lift'), 'lower', 17),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Squat-Band'), 'lower', 18),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Doggy Pee Band'), 'lower', 19),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Donkey Kick Band'), 'lower', 20),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Kick Back Band'), 'lower', 21),
-- MC Level 4-5 — Core
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Push Up'), 'core', 22),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Pedal'), 'core', 23),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Glute Bridge'), 'core', 24),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Sit Up'), 'core', 25),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Push Up Plank'), 'core', 26),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Plank'), 'core', 27),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='High Plank'), 'core', 28),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Sit Up Band'), 'core', 29),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Glute Bridge Band'), 'core', 30),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Spider Lunge'), 'core', 31),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_levels WHERE level_number=4), (SELECT id FROM dl_movements WHERE name='Pedal Band'), 'core', 32);


-- ═══════════════════════════════════════════════════════════════════
--  5. ISOLATE ITEMS — Individual movements by position
--     Source: Isolate FC, Isolate CC, Metabolic Basic sheets
-- ═══════════════════════════════════════════════════════════════════

-- ── Isolate FC — Functional Conditioning ────────────────────────

-- FC Upper Sit
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'sit', 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open V'), 'sit', 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Up'), 'sit', 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Front'), 'sit', 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'sit', 5),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'sit', 6);

-- FC Lower Sit
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Front Lift Sit'), 'sit', 7),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Sit Squat TRX'), 'sit', 8),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Sit Overhead Squat TRX'), 'sit', 9),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Sit Sumo Squat TRX'), 'sit', 10);

-- FC Upper Stand
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'stand', 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open V'), 'stand', 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Up'), 'stand', 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Front'), 'stand', 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'stand', 5),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'stand', 6);

-- FC Lower Stand
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Back step - Chair'), 'stand', 7),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Side Step Chair'), 'stand', 8),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Side Lift Chair'), 'stand', 9),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Front Lift Chair'), 'stand', 10),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='High Knee Chair'), 'stand', 11),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Knee Drive Chair'), 'stand', 12),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Jog-Chair'), 'stand', 13),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Squat TRX'), 'stand', 14),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Overhead Squat TRX'), 'stand', 15),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Sumo Squat TRX'), 'stand', 16),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Lunges Chair'), 'stand', 17),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Lateral Lunge TRX'), 'stand', 18);

-- ── Isolate CC — Cardio Conditioning ────────────────────────────

-- CC Upper Sit
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'sit', 1),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open V'), 'sit', 2),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Press Up'), 'sit', 3),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Press Front'), 'sit', 4),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'sit', 5),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'sit', 6);

-- CC Lower Sit
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Front Lift Sit'), 'sit', 7),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Sit Squat TRX'), 'sit', 8),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Sit Overhead Squat TRX'), 'sit', 9),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Sit Sumo Squat TRX'), 'sit', 10);

-- CC Upper Stand
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'stand', 1),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open V'), 'stand', 2),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Press Up'), 'stand', 3),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Press Front'), 'stand', 4),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'stand', 5),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'stand', 6);

-- CC Lower Stand
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Back step - Chair'), 'stand', 7),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Side Step Chair'), 'stand', 8),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Side Lift Chair'), 'stand', 9),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Front Lift Chair'), 'stand', 10),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='High Knee Chair'), 'stand', 11),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Knee Drive Chair'), 'stand', 12),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Jog-Chair'), 'stand', 13),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Squat TRX'), 'stand', 14),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Overhead Squat TRX'), 'stand', 15),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Sumo Squat TRX'), 'stand', 16),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Lunges Chair'), 'stand', 17);

-- ── Isolate MC (Metabolic Basic) ────────────────────────────────

-- MC Upper Sit
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Open V'), 'sit', 1),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Press Up'), 'sit', 2),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Press Front'), 'sit', 3),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'sit', 4),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Tricep Press'), 'sit', 5),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'sit', 6);

-- MC Lower Sit
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Squat-Band'), 'sit', 7);

-- MC Upper Stand
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Open V'), 'stand', 1),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Press Up'), 'stand', 2),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Press Front'), 'stand', 3),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'stand', 4),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Tricep Press'), 'stand', 5),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Cross Up'), 'stand', 6);

-- MC Lower Stand
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Squat-Band'), 'stand', 7),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Side Lift'), 'stand', 8),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Kick Back'), 'stand', 9);


-- ═══════════════════════════════════════════════════════════════════
--  6. DYNAMIC ITEMS — Paired upper + lower movements
--     Source: Dynamic FC, Dynamic CC, Metabolic sheets
-- ═══════════════════════════════════════════════════════════════════

-- ── Dynamic FC — Functional Conditioning ────────────────────────

INSERT INTO dl_dynamic_items (category_id, upper_movement_id, lower_movement_id, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Arm Swing'), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open V'), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Up'), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open V'), (SELECT id FROM dl_movements WHERE name='Back step'), 5),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Up'), (SELECT id FROM dl_movements WHERE name='Back step'), 6),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), (SELECT id FROM dl_movements WHERE name='Back step'), 7),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Front'), (SELECT id FROM dl_movements WHERE name='Front Lift'), 8),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), (SELECT id FROM dl_movements WHERE name='Front Lift'), 9),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), (SELECT id FROM dl_movements WHERE name='Front Lift'), 10),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Arm Swing'), (SELECT id FROM dl_movements WHERE name='Side Lift'), 11),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Pull Side Down'), (SELECT id FROM dl_movements WHERE name='Side High Knee'), 12),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), (SELECT id FROM dl_movements WHERE name='High Knee'), 13),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Cross Up'), (SELECT id FROM dl_movements WHERE name='High Knee'), 14),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Pull Down'), (SELECT id FROM dl_movements WHERE name='High Knee'), 15),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Pull Down'), (SELECT id FROM dl_movements WHERE name='Knee Drive'), 16),
-- FC Dynamic standalone lower movements (no upper pairing)
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Squat Chair'), 17),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Sumo Squat Chair'), 18),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Squat Step Chair'), 19),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Lunges Chair'), 20),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Lateral Lunge Chair'), 21),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Squat'), 22),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Overhead Squat'), 23),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Sumo Squat'), 24),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Squat Step'), 25),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Lunges'), 26),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Lateral Lunge'), 27),
((SELECT id FROM dl_categories WHERE code='fc'), NULL, (SELECT id FROM dl_movements WHERE name='Curtsy Lunges'), 28);

-- ── Dynamic CC — Cardio Conditioning ────────────────────────────

INSERT INTO dl_dynamic_items (category_id, upper_movement_id, lower_movement_id, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 1),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open V'), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 2),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 3),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open Chest'), (SELECT id FROM dl_movements WHERE name='Wide Step Touch'), 4),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Press Front'), (SELECT id FROM dl_movements WHERE name='Front Step'), 5),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), (SELECT id FROM dl_movements WHERE name='Front Step'), 6),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Cross Up'), (SELECT id FROM dl_movements WHERE name='Side Step'), 7),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), (SELECT id FROM dl_movements WHERE name='Side Step'), 8),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Press Up'), (SELECT id FROM dl_movements WHERE name='Side Step'), 9),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open V'), (SELECT id FROM dl_movements WHERE name='Side Step'), 10),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open V'), (SELECT id FROM dl_movements WHERE name='Back step'), 11),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Press Up'), (SELECT id FROM dl_movements WHERE name='Back step'), 12),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), (SELECT id FROM dl_movements WHERE name='Back step'), 13),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Press Front'), (SELECT id FROM dl_movements WHERE name='Front Lift'), 14),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), (SELECT id FROM dl_movements WHERE name='Front Lift'), 15),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), (SELECT id FROM dl_movements WHERE name='Front Lift'), 16),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Arm Swing'), (SELECT id FROM dl_movements WHERE name='Side Lift'), 17),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Pull Side Down'), (SELECT id FROM dl_movements WHERE name='Side High Knee'), 18),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), (SELECT id FROM dl_movements WHERE name='High Knee'), 19),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Cross Up'), (SELECT id FROM dl_movements WHERE name='High Knee'), 20),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Pull Down'), (SELECT id FROM dl_movements WHERE name='High Knee'), 21),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Pull Down'), (SELECT id FROM dl_movements WHERE name='Knee Drive'), 22),
((SELECT id FROM dl_categories WHERE code='cc'), (SELECT id FROM dl_movements WHERE name='Open V'), (SELECT id FROM dl_movements WHERE name='Knee Drive'), 23);

-- ── Dynamic MC (Metabolic full) ─────────────────────────────────
-- MC dynamic = all movements from the Metabolic sheet, grouped by body part
-- These are standalone (not paired), representing the full metabolic catalog

-- MC Upper
INSERT INTO dl_dynamic_items (category_id, upper_movement_id, lower_movement_id, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Open V'), NULL, 1),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Press Up'), NULL, 2),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Press Front'), NULL, 3),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), NULL, 4),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Tricep Press'), NULL, 5),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Cross Up'), NULL, 6),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Partial Lateral Raise'), NULL, 7),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Triceps Extension'), NULL, 8),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Lat Pull Down (Close Grip)'), NULL, 9),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Crossover Lat Pull Down'), NULL, 10),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Squat Press'), NULL, 11),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Chest Press'), NULL, 12),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Bent Over Fly'), NULL, 13),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Overhead Press'), NULL, 14),
((SELECT id FROM dl_categories WHERE code='mc'), (SELECT id FROM dl_movements WHERE name='Bicep Curls'), NULL, 15),
-- MC Lower
((SELECT id FROM dl_categories WHERE code='mc'), NULL, (SELECT id FROM dl_movements WHERE name='Kick Back'), 16),
((SELECT id FROM dl_categories WHERE code='mc'), NULL, (SELECT id FROM dl_movements WHERE name='Donkey Kick'), 17),
((SELECT id FROM dl_categories WHERE code='mc'), NULL, (SELECT id FROM dl_movements WHERE name='Side Lift'), 18),
((SELECT id FROM dl_categories WHERE code='mc'), NULL, (SELECT id FROM dl_movements WHERE name='Squat-Band'), 19),
((SELECT id FROM dl_categories WHERE code='mc'), NULL, (SELECT id FROM dl_movements WHERE name='Doggy Pee Band'), 20),
((SELECT id FROM dl_categories WHERE code='mc'), NULL, (SELECT id FROM dl_movements WHERE name='Donkey Kick Band'), 21),
((SELECT id FROM dl_categories WHERE code='mc'), NULL, (SELECT id FROM dl_movements WHERE name='Kick Back Band'), 22);


-- ─────────────────────────────────────────────────────────────────
-- ISOLATE FUNCTIONAL MOVEMENT (Menu Trainer Custom)
-- ─────────────────────────────────────────────────────────────────
INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order) VALUES
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'sit', 0),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open V'), 'sit', 1),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Up'), 'sit', 2),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Front'), 'sit', 3),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'sit', 4),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'sit', 5),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Front Lift Sit'), 'sit', 6),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Sit Squat TRX'), 'sit', 7),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Sit Overhead Squat TRX'), 'sit', 8),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Sit Sumo Squat TRX'), 'sit', 9),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Arm Rotation'), 'stand', 10),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open V'), 'stand', 11),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Up'), 'stand', 12),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Press Front'), 'stand', 13),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Open Arm'), 'stand', 14),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Cross Front'), 'stand', 15),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Back step - Chair'), 'stand', 16),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Side Step Chair'), 'stand', 17),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Side Lift Chair'), 'stand', 18),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Front Lift Chair'), 'stand', 19),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='High Knee Chair'), 'stand', 20),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Knee Drive Chair'), 'stand', 21),
((SELECT id FROM dl_categories WHERE code='fc'), (SELECT id FROM dl_movements WHERE name='Jog-Chair'), 'stand', 22);
