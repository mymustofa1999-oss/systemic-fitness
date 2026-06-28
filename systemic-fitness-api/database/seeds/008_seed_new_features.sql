-- ═══════════════════════════════════════════════════════════════════
--  Seed: Forms, Scheduling, Groups, Challenges, Announcements
-- ═══════════════════════════════════════════════════════════════════

-- ─── Forms ──────────────────────────────────────────────────────────

INSERT INTO forms (id, name, description, status, is_system, created_by)
SELECT gen_random_uuid(), v.name, v.description, 'published', true,
    (SELECT id FROM users WHERE email = 'admin@systemic.app')
FROM (VALUES
    ('Client Onboarding Form', 'Collect essential information from new clients before their first session.'),
    ('Weekly Check-in Form', 'Weekly progress check-in questionnaire for active clients.'),
    ('Injury & Health Assessment', 'Pre-training health screening and injury history form.'),
    ('Nutrition Assessment', 'Assess dietary habits and preferences for meal planning.')
) AS v(name, description)
WHERE NOT EXISTS (SELECT 1 FROM forms WHERE forms.name = v.name);

-- Add fields to Client Onboarding Form
INSERT INTO form_fields (form_id, label, field_type, required, options, sort_order)
SELECT f.id, v.label, v.field_type::form_field_type, v.required, v.options::JSONB, v.sort_order
FROM forms f
CROSS JOIN (VALUES
    ('What are your fitness goals?', 'multi_select', true, '{"choices": ["Lose weight", "Build muscle", "Improve endurance", "Flexibility", "General health"]}', 0),
    ('Current fitness level', 'select', true, '{"choices": ["Beginner", "Intermediate", "Advanced"]}', 1),
    ('How many days per week can you train?', 'select', true, '{"choices": ["1-2 days", "3-4 days", "5-6 days", "Every day"]}', 2),
    ('Do you have any injuries or medical conditions?', 'textarea', true, NULL, 3),
    ('Preferred training time', 'select', false, '{"choices": ["Morning (6-9 AM)", "Midday (10 AM-1 PM)", "Afternoon (2-5 PM)", "Evening (6-9 PM)"]}', 4),
    ('Rate your nutrition knowledge (1-5)', 'rating', false, '{"min": 1, "max": 5}', 5)
) AS v(label, field_type, required, options, sort_order)
WHERE f.name = 'Client Onboarding Form'
  AND NOT EXISTS (SELECT 1 FROM form_fields ff WHERE ff.form_id = f.id AND ff.label = v.label);

-- ─── Event Types ────────────────────────────────────────────────────

INSERT INTO event_types (name, description, category, duration_min, color, is_active, created_by)
SELECT v.name, v.description, v.category::event_category, v.duration_min, v.color, true,
    (SELECT id FROM users WHERE email = 'admin@systemic.app')
FROM (VALUES
    ('1 on 1 Personal Training', 'Private personal training session', 'one_on_one', 60, '#3B82F6'),
    ('Group Fitness Class', 'Group training session (max 12 participants)', 'group_class', 45, '#10B981'),
    ('Online Consultation', 'Virtual consultation via video call', 'one_on_one', 30, '#8B5CF6'),
    ('HIIT Boot Camp', 'High-intensity interval training group class', 'group_class', 45, '#F59E0B'),
    ('Yoga & Stretch', 'Guided yoga and stretching session', 'group_class', 60, '#EC4899'),
    ('Nutrition Coaching', 'One-on-one nutrition consultation', 'one_on_one', 45, '#06B6D4'),
    ('Personal Event', 'Personal time block', 'personal', 60, '#6B7280')
) AS v(name, description, category, duration_min, color)
WHERE NOT EXISTS (SELECT 1 FROM event_types WHERE event_types.name = v.name);

-- ─── Calendar Events (sample) ───────────────────────────────────────

INSERT INTO calendar_events (title, description, category, status, start_at, end_at, location, max_participants, created_by, event_type_id)
SELECT v.title, v.description, v.category::event_category, 'scheduled',
    (CURRENT_DATE + v.day_offset) + v.start_time::TIME,
    (CURRENT_DATE + v.day_offset) + v.end_time::TIME,
    v.location, v.max_participants,
    (SELECT id FROM users WHERE email = 'coach.arif@fitcoach.app'),
    (SELECT id FROM event_types WHERE name = v.event_type_name LIMIT 1)
FROM (VALUES
    ('Morning PT - Client A', 'Personal training session', 'one_on_one', 1, '07:00', '08:00', 'Studio A', NULL, '1 on 1 Personal Training'),
    ('HIIT Boot Camp', 'High intensity group class', 'group_class', 1, '09:00', '09:45', 'Main Floor', 12, 'HIIT Boot Camp'),
    ('Afternoon PT - Client B', 'Personal training session', 'one_on_one', 2, '14:00', '15:00', 'Studio B', NULL, '1 on 1 Personal Training'),
    ('Yoga & Stretch', 'Evening yoga session', 'group_class', 2, '17:00', '18:00', 'Yoga Room', 15, 'Yoga & Stretch'),
    ('Online Consultation', 'Video call with remote client', 'one_on_one', 3, '10:00', '10:30', 'Zoom', NULL, 'Online Consultation'),
    ('Group Fitness Class', 'Full body workout class', 'group_class', 4, '08:00', '08:45', 'Main Floor', 12, 'Group Fitness Class')
) AS v(title, description, category, day_offset, start_time, end_time, location, max_participants, event_type_name)
WHERE NOT EXISTS (SELECT 1 FROM calendar_events WHERE calendar_events.title = v.title AND calendar_events.start_at::DATE = CURRENT_DATE + v.day_offset);

-- ─── Trainer Availability ───────────────────────────────────────────

INSERT INTO trainer_availability (trainer_id, day_of_week, start_time, end_time, is_active)
SELECT u.id, v.day_of_week, v.start_time::TIME, v.end_time::TIME, true
FROM users u
CROSS JOIN (VALUES
    (1, '07:00', '12:00'),
    (1, '14:00', '20:00'),
    (2, '07:00', '12:00'),
    (2, '14:00', '20:00'),
    (3, '08:00', '13:00'),
    (3, '15:00', '21:00'),
    (4, '08:00', '13:00'),
    (4, '15:00', '21:00'),
    (5, '07:00', '12:00'),
    (5, '14:00', '18:00')
) AS v(day_of_week, start_time, end_time)
WHERE u.email = 'coach.arif@fitcoach.app'
  AND NOT EXISTS (SELECT 1 FROM trainer_availability ta WHERE ta.trainer_id = u.id AND ta.day_of_week = v.day_of_week AND ta.start_time = v.start_time::TIME);

-- ─── Groups ─────────────────────────────────────────────────────────

INSERT INTO groups (id, name, description, max_members, created_by)
SELECT gen_random_uuid(), v.name, v.description, v.max_members,
    (SELECT id FROM users WHERE email = 'coach.arif@fitcoach.app')
FROM (VALUES
    ('Morning Warriors', 'Early morning training group — 6 AM sessions', 12),
    ('Weight Loss Squad', 'Dedicated group for weight loss transformation clients', 15),
    ('Muscle Builders', 'Hypertrophy-focused training group', 10),
    ('Yoga & Wellness', 'Mind-body balance group sessions', 20),
    ('Competition Prep', 'Athletes preparing for competitions', 8)
) AS v(name, description, max_members)
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE groups.name = v.name);

-- Add some clients to groups
INSERT INTO group_members (group_id, user_id, role)
SELECT g.id, u.id, 'member'
FROM groups g, users u
WHERE g.name = 'Morning Warriors'
  AND u.email IN ('client1@email.com', 'client2@email.com', 'client3@email.com')
  AND NOT EXISTS (SELECT 1 FROM group_members gm WHERE gm.group_id = g.id AND gm.user_id = u.id);

INSERT INTO group_members (group_id, user_id, role)
SELECT g.id, u.id, 'member'
FROM groups g, users u
WHERE g.name = 'Weight Loss Squad'
  AND u.email IN ('client4@email.com', 'client5@email.com', 'client6@email.com')
  AND NOT EXISTS (SELECT 1 FROM group_members gm WHERE gm.group_id = g.id AND gm.user_id = u.id);

-- ─── Challenges ─────────────────────────────────────────────────────

INSERT INTO challenges (name, description, status, start_date, end_date, goal_type, goal_value, max_participants, created_by)
SELECT v.name, v.description, v.status::challenge_status, v.start_date::DATE, v.end_date::DATE,
    v.goal_type, v.goal_value, v.max_participants,
    (SELECT id FROM users WHERE email = 'coach.arif@fitcoach.app')
FROM (VALUES
    ('30 Day Push-Up Challenge', 'Complete 3000 push-ups in 30 days. Start with 50 per day and increase gradually!', 'active',
     CURRENT_DATE::TEXT, (CURRENT_DATE + 30)::TEXT, 'total_reps', 3000.0, 50),
    ('10K Steps Daily', 'Walk at least 10,000 steps every day for 21 days straight.', 'active',
     CURRENT_DATE::TEXT, (CURRENT_DATE + 21)::TEXT, 'daily_steps', 10000.0, 100),
    ('Body Transformation 90 Days', 'Complete 90-day body transformation program. Track your progress weekly!', 'active',
     CURRENT_DATE::TEXT, (CURRENT_DATE + 90)::TEXT, 'body_fat_pct', 5.0, 30),
    ('Hydration Challenge', 'Drink at least 3 liters of water every day for 14 days.', 'draft',
     (CURRENT_DATE + 7)::TEXT, (CURRENT_DATE + 21)::TEXT, 'daily_water_ml', 3000.0, NULL)
) AS v(name, description, status, start_date, end_date, goal_type, goal_value, max_participants)
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE challenges.name = v.name);

-- Add participants to active challenges
INSERT INTO challenge_participants (challenge_id, user_id, progress_value)
SELECT c.id, u.id, v.progress
FROM challenges c, users u,
    (VALUES ('client1@email.com', 450.0), ('client2@email.com', 320.0), ('client3@email.com', 580.0)) AS v(email, progress)
WHERE c.name = '30 Day Push-Up Challenge' AND u.email = v.email
  AND NOT EXISTS (SELECT 1 FROM challenge_participants cp WHERE cp.challenge_id = c.id AND cp.user_id = u.id);

-- ─── Announcements ──────────────────────────────────────────────────

INSERT INTO announcements (title, body, status, target_roles, published_at, created_by)
SELECT v.title, v.body, v.status::announcement_status, v.target_roles::user_role[], v.published_at,
    (SELECT id FROM users WHERE email = 'admin@systemic.app')
FROM (VALUES
    ('Welcome to Systemic Fitness!', 'We are excited to launch our new fitness platform. Explore workouts, programs, and track your progress all in one place. Let''s get started on your fitness journey!',
     'published', '{client,trainer}', NOW() - INTERVAL '7 days'),
    ('New Feature: Habit Tracking', 'We have added habit tracking to help you build consistent daily routines. Check out the Habits section in your dashboard to get started.',
     'published', '{client,trainer}', NOW() - INTERVAL '3 days'),
    ('Holiday Schedule Update', 'Please note that gym hours will be reduced during the upcoming holiday period. Check the calendar for updated class schedules.',
     'published', '{client,trainer,admin}', NOW() - INTERVAL '1 day'),
    ('Trainer Workshop: Advanced Programming', 'All trainers are invited to the advanced programming workshop next Monday at 2 PM. Topics include periodization and progressive overload strategies.',
     'published', '{trainer}', NOW()),
    ('System Maintenance Notice', 'Scheduled maintenance will occur this weekend between 2-4 AM. Services may be briefly unavailable.',
     'draft', '{client,trainer,admin,finance}', NULL)
) AS v(title, body, status, target_roles, published_at)
WHERE NOT EXISTS (SELECT 1 FROM announcements WHERE announcements.title = v.title);
