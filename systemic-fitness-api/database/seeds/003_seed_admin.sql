-- ═══════════════════════════════════════════════════════════════════
--  Seed: Staff Accounts (Owner, Admin, Finance, Trainers)
--
--  Default passwords (bcrypt cost 12):
--    Owner/Admin/Finance: FitCoach@2024
--    Trainers:            Trainer@2024
--
--  ⚠ CHANGE THESE PASSWORDS IMMEDIATELY IN PRODUCTION
-- ═══════════════════════════════════════════════════════════════════

-- ─── OWNER ────────────────────────────────────────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'admin@systemic.app',
    -- bcrypt hash of 'password123' with cost 10
    '$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK',
    'FitCoach Admin',
    '+6281234567890',
    'owner',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, gender, experience_level)
SELECT id, 'male', 'advanced'
FROM users
WHERE email = 'admin@systemic.app'
ON CONFLICT (user_id) DO NOTHING;

-- ─── ADMIN ────────────────────────────────────────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'denny@fitcoach.app',
    '$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK',
    'Denny Septiady',
    '+6281234567891',
    'admin',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, gender, experience_level)
SELECT id, 'male', 'advanced'
FROM users
WHERE email = 'denny@fitcoach.app'
ON CONFLICT (user_id) DO NOTHING;

-- ─── FINANCE ──────────────────────────────────────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'finance@fitcoach.app',
    '$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK',
    'Rina Kartika',
    '+6281234567892',
    'finance',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, gender, experience_level)
SELECT id, 'female', 'intermediate'
FROM users
WHERE email = 'finance@fitcoach.app'
ON CONFLICT (user_id) DO NOTHING;

-- ─── TRAINER 1 ────────────────────────────────────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'coach.arif@fitcoach.app',
    -- bcrypt hash of 'Trainer@2024' with cost 12
    '$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK',
    'Arif Setiawan',
    '+6281300000001',
    'trainer',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1988-04-10', 'male', 178, 82, 'gain_muscle', 'advanced'
FROM users WHERE email = 'coach.arif@fitcoach.app'
ON CONFLICT (user_id) DO NOTHING;

-- ─── TRAINER 2 ────────────────────────────────────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'coach.lisa@fitcoach.app',
    '$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK',
    'Lisa Andriani',
    '+6281300000002',
    'trainer',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1991-09-25', 'female', 165, 58, 'maintain', 'advanced'
FROM users WHERE email = 'coach.lisa@fitcoach.app'
ON CONFLICT (user_id) DO NOTHING;

-- ─── TRAINER 3 ────────────────────────────────────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'coach.fajar@fitcoach.app',
    '$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK',
    'Fajar Nugroho',
    '+6281300000003',
    'trainer',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1993-12-05', 'male', 182, 88, 'gain_muscle', 'advanced'
FROM users WHERE email = 'coach.fajar@fitcoach.app'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Seed default payment plans ───────────────────────────────────

INSERT INTO payment_plans (name, description, price, currency, duration_months, features, is_active)
VALUES
('Basic', 'Perfect for getting started with personal training.', 299000, 'IDR', 1,
 '["Akses workout library", "1 program aktif", "Progress tracking", "Chat dengan trainer"]'::JSONB,
 TRUE),
('Pro', 'Most popular plan for serious fitness enthusiasts.', 499000, 'IDR', 1,
 '["Semua fitur Basic", "Unlimited programs", "Nutrition tracking", "Body metrics & foto", "Prioritas support"]'::JSONB,
 TRUE),
('Premium', 'Complete package with personal coaching.', 999000, 'IDR', 1,
 '["Semua fitur Pro", "1-on-1 video call per minggu", "Custom meal plan", "Dedicated trainer", "Akses automation"]'::JSONB,
 TRUE),
('Annual Pro', 'Pro plan — save 20% with annual billing.', 4790000, 'IDR', 12,
 '["Semua fitur Pro", "Hemat 20%", "2 bulan gratis"]'::JSONB,
 TRUE);
