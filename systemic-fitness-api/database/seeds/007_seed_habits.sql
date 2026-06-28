-- ═══════════════════════════════════════════════════════════════════
--  Seed: Habit Folders & Habits (Master Library → Habits)
-- ═══════════════════════════════════════════════════════════════════

-- ─── Folders ────────────────────────────────────────────────────────

INSERT INTO habit_folders (id, name, sort_order, created_by)
SELECT gen_random_uuid(), v.name, v.sort_order, (SELECT id FROM users WHERE email = 'admin@fitcoach.app')
FROM (VALUES
    ('Nutrition Portion Guides', 1),
    ('Nutrition', 2),
    ('Active Living / Movement', 3),
    ('Mindfulness', 4),
    ('Sleep', 5)
) AS v(name, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM habit_folders WHERE habit_folders.name = v.name);

-- ─── Habits: Nutrition Portion Guides ───────────────────────────────

INSERT INTO habits (name, description, icon, folder_id, is_system, created_by)
SELECT v.name, v.description, v.icon,
    (SELECT id FROM habit_folders WHERE habit_folders.name = 'Nutrition Portion Guides'),
    true,
    (SELECT id FROM users WHERE email = 'admin@fitcoach.app')
FROM (VALUES
    ('Eat protein', 'This habit focuses on having clients consume protein with each of their meals.', 'protein'),
    ('Eat good fats', 'This habit focuses on having clients consume good fats with each of their meals.', 'fat'),
    ('Eat complex carbs', 'This habit focuses on having clients consume complex carbs with each of their meals.', 'carbs'),
    ('Eat vegetables', 'This habit focuses on having clients consume vegetables with each of their meals.', 'vegetable'),
    ('Follow portion guides', 'This habit focuses on having clients practice following portion guides for their meals.', 'portion')
) AS v(name, description, icon)
WHERE NOT EXISTS (SELECT 1 FROM habits WHERE habits.name = v.name AND habits.is_system = true);

-- ─── Habits: Nutrition ──────────────────────────────────────────────

INSERT INTO habits (name, description, icon, folder_id, is_system, created_by)
SELECT v.name, v.description, v.icon,
    (SELECT id FROM habit_folders WHERE habit_folders.name = 'Nutrition'),
    true,
    (SELECT id FROM users WHERE email = 'admin@fitcoach.app')
FROM (VALUES
    ('Drink enough water', 'Drink at least 8 glasses of water throughout the day.', 'water'),
    ('Eat slowly', 'Practice mindful eating by taking at least 20 minutes per meal.', 'clock'),
    ('Eat until 80% full', 'Stop eating when you feel satisfied, not stuffed.', 'plate'),
    ('Prepare meals in advance', 'Meal prep for the next day or the week ahead.', 'meal_prep'),
    ('Avoid sugary drinks', 'Replace sodas and juices with water or unsweetened beverages.', 'no_sugar')
) AS v(name, description, icon)
WHERE NOT EXISTS (SELECT 1 FROM habits WHERE habits.name = v.name AND habits.is_system = true);

-- ─── Habits: Active Living / Movement ───────────────────────────────

INSERT INTO habits (name, description, icon, folder_id, is_system, created_by)
SELECT v.name, v.description, v.icon,
    (SELECT id FROM habit_folders WHERE habit_folders.name = 'Active Living / Movement'),
    true,
    (SELECT id FROM users WHERE email = 'admin@fitcoach.app')
FROM (VALUES
    ('Take 10,000 steps', 'Walk at least 10,000 steps throughout the day.', 'steps'),
    ('Stretch for 10 minutes', 'Perform a 10-minute stretching routine daily.', 'stretch'),
    ('Take the stairs', 'Choose stairs over elevators whenever possible.', 'stairs'),
    ('Stand up every hour', 'Get up and move around for at least 2 minutes every hour.', 'stand')
) AS v(name, description, icon)
WHERE NOT EXISTS (SELECT 1 FROM habits WHERE habits.name = v.name AND habits.is_system = true);

-- ─── Habits: Mindfulness ────────────────────────────────────────────

INSERT INTO habits (name, description, icon, folder_id, is_system, created_by)
SELECT v.name, v.description, v.icon,
    (SELECT id FROM habit_folders WHERE habit_folders.name = 'Mindfulness'),
    true,
    (SELECT id FROM users WHERE email = 'admin@fitcoach.app')
FROM (VALUES
    ('Meditate for 5 minutes', 'Practice 5 minutes of guided or silent meditation.', 'meditation'),
    ('Practice gratitude', 'Write down 3 things you are grateful for today.', 'gratitude'),
    ('Deep breathing exercises', 'Do 5 rounds of deep belly breathing.', 'breathing'),
    ('Journal your thoughts', 'Spend 5 minutes writing in your journal.', 'journal')
) AS v(name, description, icon)
WHERE NOT EXISTS (SELECT 1 FROM habits WHERE habits.name = v.name AND habits.is_system = true);

-- ─── Habits: Sleep ──────────────────────────────────────────────────

INSERT INTO habits (name, description, icon, folder_id, is_system, created_by)
SELECT v.name, v.description, v.icon,
    (SELECT id FROM habit_folders WHERE habit_folders.name = 'Sleep'),
    true,
    (SELECT id FROM users WHERE email = 'admin@fitcoach.app')
FROM (VALUES
    ('Sleep 7-8 hours', 'Aim for 7 to 8 hours of quality sleep each night.', 'sleep'),
    ('No screens before bed', 'Avoid screens for at least 30 minutes before bedtime.', 'no_screen'),
    ('Consistent bedtime', 'Go to bed at the same time every night.', 'bedtime')
) AS v(name, description, icon)
WHERE NOT EXISTS (SELECT 1 FROM habits WHERE habits.name = v.name AND habits.is_system = true);
