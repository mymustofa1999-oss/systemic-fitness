-- ═══════════════════════════════════════════════════════════════════
--  Seed: SF Phase 7a — Default Health Consultant account
--
--  Why:
--    Phase 6 sudah membuat tabel lab_consultations & tier4_waitlist_entries
--    yang butuh assignee role 'consultant'. Tanpa minimal 1 consultant
--    seed, halaman Consultant Dashboard (Fase 7c) tidak punya user untuk
--    di-test. Seed ini idempoten (ON CONFLICT DO NOTHING) dan hanya
--    membuat 1 default consultant.
--
--  Default password (bcrypt cost 12):
--    consultant.maya@fitcoach.app  →  Consultant@2024
--
--  ⚠ CHANGE PASSWORD IMMEDIATELY IN PRODUCTION via /api/users/{id}/password
--    atau lewat admin web UI setelah seed berjalan pertama kali.
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO users (email, password_hash, full_name, phone, role, status, timezone)
VALUES (
    'consultant.maya@fitcoach.app',
    -- bcrypt hash of 'Consultant@2024' with cost 12 (verified)
    '$2a$12$7TEnCWoPa8eT1EfVbffEE.p5tMi0c0fUUiOpeKSA6G9nSZu/BBrie',
    'dr. Maya Pranatasari',
    '+6281300000004',
    'consultant',
    'active',
    'Asia/Jakarta'
) ON CONFLICT (email) DO NOTHING;

INSERT INTO user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level)
SELECT id, '1986-07-14', 'female', 162, 56, 'maintain', 'advanced'
FROM users WHERE email = 'consultant.maya@fitcoach.app'
ON CONFLICT (user_id) DO NOTHING;
