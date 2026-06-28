-- ═══════════════════════════════════════════════════════════════════
--  Seed: Foods Library (Master Library → Nutrition → Foods)
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO foods (name, description, image_url, meal_types, calories, protein_g, carbs_g, fat_g, fiber_g, serving_size, serving_unit, is_system, created_by)
SELECT
    v.name, v.description, NULL, v.meal_types::meal_type[], v.calories, v.protein_g, v.carbs_g, v.fat_g, v.fiber_g,
    v.serving_size, v.serving_unit, true,
    (SELECT id FROM users WHERE email = 'admin@fitcoach.app')
FROM (VALUES
    -- Breakfast items
    ('Oatmeal with Banana', 'Classic whole grain oats topped with sliced banana and honey', '{breakfast}', 350, 12.0, 58.0, 7.0, 6.0, '1', 'bowl'),
    ('Scrambled Eggs on Toast', 'Two scrambled eggs on whole wheat toast', '{breakfast}', 380, 22.0, 30.0, 18.0, 3.0, '1', 'serving'),
    ('Greek Yogurt Parfait', 'Greek yogurt with granola and mixed berries', '{breakfast,snack}', 280, 18.0, 35.0, 8.0, 3.0, '1', 'cup'),
    ('Protein Smoothie Bowl', 'Blended protein shake with fruits and toppings', '{breakfast}', 420, 30.0, 48.0, 10.0, 5.0, '1', 'bowl'),
    ('Avocado Toast', 'Smashed avocado on sourdough with egg', '{breakfast,lunch}', 390, 14.0, 32.0, 24.0, 8.0, '1', 'serving'),

    -- Lunch items
    ('Grilled Chicken Breast', 'Seasoned chicken breast grilled to perfection', '{lunch,dinner}', 285, 42.0, 0.0, 12.0, 0.0, '200', 'gram'),
    ('Chicken Caesar Salad', 'Romaine lettuce with grilled chicken and caesar dressing', '{lunch}', 420, 35.0, 12.0, 26.0, 3.0, '1', 'bowl'),
    ('Brown Rice & Salmon', 'Pan-seared salmon with steamed brown rice and vegetables', '{lunch,dinner}', 520, 38.0, 45.0, 18.0, 4.0, '1', 'plate'),
    ('Tuna Wrap', 'Whole wheat wrap with tuna salad and veggies', '{lunch}', 380, 28.0, 35.0, 14.0, 4.0, '1', 'wrap'),
    ('Chicken Steak Bowl', 'Grilled chicken with rice, beans, and salsa', '{lunch,dinner}', 550, 40.0, 52.0, 16.0, 8.0, '1', 'bowl'),

    -- Dinner items
    ('Beef Stir Fry', 'Lean beef strips with mixed vegetables in soy sauce', '{dinner}', 450, 35.0, 20.0, 25.0, 4.0, '1', 'plate'),
    ('Baked Sweet Potato', 'Baked sweet potato with cottage cheese topping', '{dinner,lunch}', 320, 16.0, 48.0, 6.0, 7.0, '1', 'piece'),
    ('Salmon Quinoa Bowl', 'Grilled salmon with quinoa and roasted vegetables', '{dinner}', 530, 40.0, 42.0, 20.0, 6.0, '1', 'bowl'),
    ('Tofu Stir Fry', 'Firm tofu with broccoli and brown rice', '{dinner,lunch}', 380, 22.0, 40.0, 14.0, 6.0, '1', 'plate'),
    ('Chicken Breast with Caprese Salad', 'Grilled chicken with tomato, mozzarella and basil', '{lunch,dinner}', 480, 45.0, 8.0, 28.0, 2.0, '1', 'plate'),

    -- Snack items
    ('Protein Bar', 'High protein energy bar', '{snack}', 220, 20.0, 25.0, 8.0, 3.0, '1', 'bar'),
    ('Mixed Nuts', 'Almonds, cashews, and walnuts', '{snack}', 280, 10.0, 12.0, 22.0, 4.0, '50', 'gram'),
    ('Banana with Peanut Butter', 'Fresh banana with natural peanut butter', '{snack,breakfast}', 290, 8.0, 35.0, 16.0, 4.0, '1', 'serving'),
    ('Hard Boiled Eggs', 'Two hard boiled eggs', '{snack}', 155, 13.0, 1.0, 11.0, 0.0, '2', 'eggs'),
    ('Cottage Cheese with Fruit', 'Low-fat cottage cheese with mixed berries', '{snack}', 180, 20.0, 18.0, 3.0, 2.0, '1', 'cup')
) AS v(name, description, meal_types, calories, protein_g, carbs_g, fat_g, fiber_g, serving_size, serving_unit)
WHERE NOT EXISTS (SELECT 1 FROM foods WHERE foods.name = v.name AND foods.is_system = true);
