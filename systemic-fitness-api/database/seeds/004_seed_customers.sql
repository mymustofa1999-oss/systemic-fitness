-- ═══════════════════════════════════════════════════════════════════
--  Seed: Client Accounts
--
--  Password for all clients: Customer@2024  (bcrypt hashed below)
--
--  ⚠ CHANGE THESE PASSWORDS IMMEDIATELY IN PRODUCTION
-- ═══════════════════════════════════════════════════════════════════

-- ─── Client 1: Active, intermediate, gain_muscle ──────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'budi@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Budi Santoso',
    '+6281200000001',
    'client',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1995-03-15', 'male', 175, 78, 'gain_muscle', 'intermediate'
FROM users WHERE email = 'budi@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Client 2: Active, beginner, lose_weight ─────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'sari@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Sari Dewi',
    '+6281200000002',
    'client',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1998-07-22', 'female', 160, 55, 'lose_weight', 'beginner'
FROM users WHERE email = 'sari@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Client 3: Active, beginner, lose_weight ─────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'andi@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Andi Pratama',
    '+6281200000003',
    'client',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1992-11-08', 'male', 170, 85, 'lose_weight', 'beginner'
FROM users WHERE email = 'andi@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Client 4: Active, intermediate, improve_endurance ────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'maya@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Maya Putri',
    '+6281200000004',
    'client',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '2000-01-30', 'female', 165, 60, 'improve_endurance', 'intermediate'
FROM users WHERE email = 'maya@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Client 5: Active, advanced, maintain ─────────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'rizki@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Rizki Ramadhan',
    '+6281200000005',
    'client',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1997-06-12', 'male', 180, 90, 'maintain', 'advanced'
FROM users WHERE email = 'rizki@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Client 6: Active, beginner, flexibility ─────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'diana@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Diana Kusuma',
    '+6281200000006',
    'client',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1999-05-18', 'female', 158, 52, 'flexibility', 'beginner'
FROM users WHERE email = 'diana@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Client 7: Active, intermediate, gain_muscle ──────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'hendra@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Hendra Wijaya',
    '+6281200000007',
    'client',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1994-08-20', 'male', 173, 75, 'gain_muscle', 'intermediate'
FROM users WHERE email = 'hendra@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Client 8: Inactive (lapsed subscription) ────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'wati@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Wati Susilowati',
    '+6281200000008',
    'client',
    'inactive',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1996-02-14', 'female', 162, 65, 'lose_weight', 'beginner'
FROM users WHERE email = 'wati@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Client 9: Pending (baru daftar, belum aktif) ────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'tommy@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Tommy Hidayat',
    '+6281200000009',
    'client',
    'pending',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '2001-10-05', 'male', 168, 70, 'gain_muscle', 'beginner'
FROM users WHERE email = 'tommy@example.com'
ON CONFLICT (user_id) DO NOTHING;

-- ─── Client 10: Suspended ────────────────────────────────────────

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'fika@example.com',
    '$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2',
    'Fika Ramadhani',
    '+6281200000010',
    'client',
    'suspended',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1993-04-28', 'female', 170, 68, 'maintain', 'intermediate'
FROM users WHERE email = 'fika@example.com'
ON CONFLICT (user_id) DO NOTHING;
