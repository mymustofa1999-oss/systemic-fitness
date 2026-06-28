-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  001: Extensions & ENUM Types
--  FitCoach Platform — Foundation types used across all tables
-- ═══════════════════════════════════════════════════════════════════

-- UUID generation (gen_random_uuid is built into PG 13+, but ensure pgcrypto)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Trigram similarity untuk fuzzy search (dipakai di 003_create_exercises, foods, dll)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ─── User & Role ────────────────────────────────────────────────

CREATE TYPE user_role AS ENUM (
    'owner', 'admin', 'finance', 'trainer', 'client'
);

CREATE TYPE user_status AS ENUM (
    'active', 'inactive', 'suspended', 'pending'
);

CREATE TYPE gender_type AS ENUM (
    'male', 'female', 'other'
);

CREATE TYPE fitness_goal AS ENUM (
    'lose_weight', 'gain_muscle', 'maintain', 'improve_endurance', 'flexibility'
);

CREATE TYPE experience_level AS ENUM (
    'beginner', 'intermediate', 'advanced'
);

-- ─── Workout & Exercise ─────────────────────────────────────────

CREATE TYPE difficulty_level AS ENUM (
    'beginner', 'intermediate', 'advanced'
);

CREATE TYPE workout_type AS ENUM (
    'strength', 'cardio', 'hiit', 'flexibility', 'custom'
);

CREATE TYPE program_goal AS ENUM (
    'lose_weight', 'gain_muscle', 'maintain', 'general_fitness'
);

CREATE TYPE assignment_status AS ENUM (
    'active', 'paused', 'completed', 'cancelled'
);

CREATE TYPE mood_type AS ENUM (
    'great', 'good', 'okay', 'tired', 'bad'
);

-- ─── Nutrition ──────────────────────────────────────────────────

CREATE TYPE meal_type AS ENUM (
    'breakfast', 'lunch', 'dinner', 'snack'
);

-- ─── Messaging ──────────────────────────────────────────────────

CREATE TYPE conversation_type AS ENUM (
    'direct', 'group'
);

CREATE TYPE message_type AS ENUM (
    'text', 'image', 'voice', 'system'
);

CREATE TYPE conversation_role AS ENUM (
    'member', 'admin'
);

-- ─── Automation ─────────────────────────────────────────────────

CREATE TYPE trigger_type AS ENUM (
    'on_signup', 'on_program_complete', 'on_inactive_days', 'scheduled', 'on_milestone'
);

CREATE TYPE action_type AS ENUM (
    'send_message', 'assign_program', 'send_reminder', 'send_notification', 'send_email'
);

CREATE TYPE automation_log_status AS ENUM (
    'success', 'failed', 'skipped'
);

-- ─── Payments ───────────────────────────────────────────────────

CREATE TYPE subscription_status AS ENUM (
    'active', 'cancelled', 'expired', 'past_due'
);

CREATE TYPE payment_status AS ENUM (
    'pending', 'completed', 'failed', 'refunded'
);

-- ─── Trigger Function: auto-update updated_at ───────────────────

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- +migrate Down
DROP FUNCTION IF EXISTS fn_set_updated_at() CASCADE;

DROP TYPE IF EXISTS payment_status CASCADE;
DROP TYPE IF EXISTS subscription_status CASCADE;
DROP TYPE IF EXISTS automation_log_status CASCADE;
DROP TYPE IF EXISTS action_type CASCADE;
DROP TYPE IF EXISTS trigger_type CASCADE;
DROP TYPE IF EXISTS conversation_role CASCADE;
DROP TYPE IF EXISTS message_type CASCADE;
DROP TYPE IF EXISTS conversation_type CASCADE;
DROP TYPE IF EXISTS meal_type CASCADE;
DROP TYPE IF EXISTS mood_type CASCADE;
DROP TYPE IF EXISTS assignment_status CASCADE;
DROP TYPE IF EXISTS program_goal CASCADE;
DROP TYPE IF EXISTS workout_type CASCADE;
DROP TYPE IF EXISTS difficulty_level CASCADE;
DROP TYPE IF EXISTS experience_level CASCADE;
DROP TYPE IF EXISTS fitness_goal CASCADE;
DROP TYPE IF EXISTS gender_type CASCADE;
DROP TYPE IF EXISTS user_status CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;
