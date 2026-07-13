
DELETE FROM equipments;
INSERT INTO equipments (id, name, category, is_active, sort_order) VALUES
  (gen_random_uuid(), 'Stick / Tongkat', 'upper', true, 1),
  (gen_random_uuid(), 'Suspension Strap', 'upper', true, 2),
  (gen_random_uuid(), 'Chair / Kursi', 'upper', true, 3),
  (gen_random_uuid(), 'Wearable Weights 0.25', 'upper', true, 4),
  (gen_random_uuid(), 'Wearable Weights 0.5', 'upper', true, 5),
  (gen_random_uuid(), 'Wearable Weights 1', 'upper', true, 6),
  (gen_random_uuid(), 'Wearable Weights 1.5', 'upper', true, 7),
  (gen_random_uuid(), 'Wearable Weights 2', 'upper', true, 8),
  (gen_random_uuid(), 'Wearable Weights 2.5', 'upper', true, 9),
  (gen_random_uuid(), 'Wearable Weights 3', 'upper', true, 10),
  (gen_random_uuid(), 'Dumbell 1 kg', 'upper', true, 11),
  (gen_random_uuid(), 'Dumbell 2 kg', 'upper', true, 12),
  (gen_random_uuid(), 'Dumbell 3 kg', 'upper', true, 13),
  (gen_random_uuid(), 'Dumbell 5 kg', 'upper', true, 14),
  (gen_random_uuid(), 'Barbell 5 - 10 kg', 'upper', true, 15),
  (gen_random_uuid(), 'Resistance Band Medium', 'upper', true, 16),
  (gen_random_uuid(), 'Resistance Band Hard', 'upper', true, 17),
  (gen_random_uuid(), 'Mat', 'upper', true, 18);

