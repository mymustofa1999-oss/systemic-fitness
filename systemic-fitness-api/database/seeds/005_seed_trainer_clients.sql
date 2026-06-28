-- ═══════════════════════════════════════════════════════════════════
--  Seed: Trainer ↔ Client Assignments
--
--  Coach Arif  → Budi, Andi, Hendra (strength/muscle clients)
--  Coach Lisa  → Sari, Maya, Diana  (cardio/flexibility clients)
--  Coach Fajar → Rizki, Wati (paused — inactive client)
-- ═══════════════════════════════════════════════════════════════════

-- Coach Arif → Budi (active)
INSERT INTO trainer_clients (trainer_id, client_id, status)
SELECT t.id, c.id, 'active'
FROM users t, users c
WHERE t.email = 'coach.arif@fitcoach.app' AND c.email = 'budi@example.com'
ON CONFLICT (trainer_id, client_id) DO NOTHING;

-- Coach Arif → Andi (active)
INSERT INTO trainer_clients (trainer_id, client_id, status)
SELECT t.id, c.id, 'active'
FROM users t, users c
WHERE t.email = 'coach.arif@fitcoach.app' AND c.email = 'andi@example.com'
ON CONFLICT (trainer_id, client_id) DO NOTHING;

-- Coach Arif → Hendra (active)
INSERT INTO trainer_clients (trainer_id, client_id, status)
SELECT t.id, c.id, 'active'
FROM users t, users c
WHERE t.email = 'coach.arif@fitcoach.app' AND c.email = 'hendra@example.com'
ON CONFLICT (trainer_id, client_id) DO NOTHING;

-- Coach Lisa → Sari (active)
INSERT INTO trainer_clients (trainer_id, client_id, status)
SELECT t.id, c.id, 'active'
FROM users t, users c
WHERE t.email = 'coach.lisa@fitcoach.app' AND c.email = 'sari@example.com'
ON CONFLICT (trainer_id, client_id) DO NOTHING;

-- Coach Lisa → Maya (active)
INSERT INTO trainer_clients (trainer_id, client_id, status)
SELECT t.id, c.id, 'active'
FROM users t, users c
WHERE t.email = 'coach.lisa@fitcoach.app' AND c.email = 'maya@example.com'
ON CONFLICT (trainer_id, client_id) DO NOTHING;

-- Coach Lisa → Diana (active)
INSERT INTO trainer_clients (trainer_id, client_id, status)
SELECT t.id, c.id, 'active'
FROM users t, users c
WHERE t.email = 'coach.lisa@fitcoach.app' AND c.email = 'diana@example.com'
ON CONFLICT (trainer_id, client_id) DO NOTHING;

-- Coach Fajar → Rizki (active)
INSERT INTO trainer_clients (trainer_id, client_id, status)
SELECT t.id, c.id, 'active'
FROM users t, users c
WHERE t.email = 'coach.fajar@fitcoach.app' AND c.email = 'rizki@example.com'
ON CONFLICT (trainer_id, client_id) DO NOTHING;

-- Coach Fajar → Wati (paused — client inactive)
INSERT INTO trainer_clients (trainer_id, client_id, status)
SELECT t.id, c.id, 'paused'
FROM users t, users c
WHERE t.email = 'coach.fajar@fitcoach.app' AND c.email = 'wati@example.com'
ON CONFLICT (trainer_id, client_id) DO NOTHING;
