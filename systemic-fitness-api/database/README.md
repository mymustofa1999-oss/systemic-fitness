# Database — PostgreSQL 16

Complete database schema for FitCoach Platform. 22 tables, 24 ENUM types, automated triggers.

## Architecture

```
database/
├── migrations/                              # Run in order
│   ├── 001_create_extensions_and_enums.sql  #   pgcrypto, pg_trgm, 24 ENUM types, updated_at trigger
│   ├── 002_create_users.sql                 #   users, user_profiles, trainer_clients
│   ├── 003_create_exercises.sql             #   exercises (with GIN index for muscle_group array + trigram search)
│   ├── 004_create_workouts.sql              #   workouts, workout_exercises (with superset support)
│   ├── 005_create_programs.sql              #   programs, program_days, user_programs
│   ├── 006_create_progress.sql              #   progress_logs (JSONB sets), body_metrics
│   ├── 007_create_nutrition.sql             #   meal_plans, meal_plan_items, nutrition_logs
│   ├── 008_create_messaging.sql             #   conversations, conversation_members, messages
│   ├── 009_create_automations.sql           #   automations, automation_logs
│   └── 010_create_payments.sql              #   payment_plans, subscriptions, payment_records
├── seeds/
│   ├── 001_seed_exercises.sql               #   35 exercises across all muscle groups
│   ├── 002_seed_templates.sql               #   3 program templates (Beginner/PPL/Bro Split)
│   └── 003_seed_admin.sql                   #   Default owner account + 4 pricing plans
└── README.md
```

## Quick Start

```bash
# 1. Start PostgreSQL
docker compose up -d postgres

# 2. Run all migrations
make db-migrate

# 3. Seed initial data
make db-seed

# Or from scratch
make db-reset
```

## Table Overview (22 tables)

| # | Table                | Purpose                              | Key Relations              |
|---|----------------------|--------------------------------------|-----------------------------|
| 1 | users                | Core identity, roles, soft-delete    | —                           |
| 2 | user_profiles        | Extended profile (1:1 with users)    | → users                    |
| 3 | trainer_clients      | Trainer ↔ Client assignments (M:M)  | → users × 2                |
| 4 | exercises            | Exercise library (system + custom)   | → users (created_by)       |
| 5 | workouts             | Workout templates                    | → users (created_by)       |
| 6 | workout_exercises    | Exercises in a workout (ordered)     | → workouts, exercises      |
| 7 | programs             | Multi-week training programs         | → users (created_by)       |
| 8 | program_days         | Daily schedule within program        | → programs, workouts       |
| 9 | user_programs        | Program assignments to users         | → users, programs          |
| 10| progress_logs        | Per-exercise tracking (JSONB sets)   | → users, exercises, workouts|
| 11| body_metrics         | Body composition history             | → users                    |
| 12| meal_plans           | Nutrition plan templates             | → users (created_by)       |
| 13| meal_plan_items      | Foods within a meal plan             | → meal_plans               |
| 14| nutrition_logs       | Daily food tracking                  | → users                    |
| 15| conversations        | Chat threads (direct/group)          | —                           |
| 16| conversation_members | Participants in conversations        | → conversations, users     |
| 17| messages             | Chat messages                        | → conversations, users     |
| 18| automations          | Workflow rules (trigger → action)    | → users (created_by)       |
| 19| automation_logs      | Execution history                    | → automations, users       |
| 20| payment_plans        | Pricing tiers                        | —                           |
| 21| subscriptions        | User subscriptions                   | → users, payment_plans     |
| 22| payment_records      | Payment transactions                 | → subscriptions, users     |

## ENUM Types (24 types)

| Category   | Enums                                                                  |
|------------|------------------------------------------------------------------------|
| User       | user_role, user_status, gender_type, fitness_goal, experience_level    |
| Workout    | difficulty_level, workout_type, program_goal, assignment_status        |
| Progress   | mood_type                                                              |
| Nutrition  | meal_type                                                              |
| Messaging  | conversation_type, message_type, conversation_role                     |
| Automation | trigger_type, action_type, automation_log_status                       |
| Payment    | subscription_status, payment_status                                    |

## Key Design Decisions

### Soft Delete
- `users.deleted_at` — soft delete with partial unique index on email (only enforced for non-deleted rows)

### JSONB for Flexible Data
- `progress_logs.sets` — array of set objects `[{set_number, reps, weight_kg, duration_sec, rpe, completed}]`
- `automations.trigger_config` / `action_config` — dynamic config per trigger/action type
- `payment_plans.features` — array of feature strings

### Array Columns
- `exercises.muscle_group` — `VARCHAR(50)[]` with GIN index for efficient array containment queries
- `exercises.instructions` — `TEXT[]` for ordered step list
- `body_metrics.photo_urls` — `TEXT[]` for progress photos

### Auto-Updated Timestamps
All tables with `updated_at` have a `BEFORE UPDATE` trigger calling `fn_set_updated_at()`.

### Messaging Trigger
`messages` INSERT automatically updates `conversations.updated_at` via `fn_message_update_conversation()`.

## Default Credentials

| Account           | Email               | Password        | Role  |
|--------------------|---------------------|-----------------|-------|
| Platform Owner     | admin@fitcoach.app  | FitCoach@2024   | owner |

**Change password immediately in production.**

## Useful Queries

```sql
-- Active clients for a trainer
SELECT u.* FROM users u
JOIN trainer_clients tc ON u.id = tc.client_id
WHERE tc.trainer_id = '<trainer_uuid>' AND tc.status = 'active';

-- User workout streak (last 7 days)
SELECT DATE(logged_at) as day, COUNT(DISTINCT workout_id)
FROM progress_logs
WHERE user_id = '<user_uuid>' AND logged_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(logged_at) ORDER BY day;

-- Search exercises by muscle group
SELECT * FROM exercises
WHERE muscle_group @> ARRAY['chest']
ORDER BY name;

-- Fuzzy search exercises by name
SELECT * FROM exercises
WHERE name % 'bench pres'
ORDER BY similarity(name, 'bench pres') DESC
LIMIT 10;

-- Revenue this month
SELECT SUM(amount) as total, COUNT(*) as txn_count
FROM payment_records
WHERE status = 'completed'
  AND paid_at >= DATE_TRUNC('month', NOW());
```

## Adding a New Migration

```bash
# Convention: NNN_description.sql
# Always include -- +migrate Up and -- +migrate Down
touch database/migrations/011_add_notifications.sql
```
