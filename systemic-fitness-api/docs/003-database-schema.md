# 003 — Database Schema

## Migrations Overview

| File | Content                                  |
|------|------------------------------------------|
| 001  | Extensions (pgcrypto), Enums, Triggers   |
| 002  | Users, Profiles, Trainer-Client mapping  |
| 003  | Exercise Library                         |
| 004  | Workouts & Workout Exercises             |
| 005  | Programs, Program Days, User Programs    |
| 006  | Progress Logs, Body Metrics              |
| 007  | Nutrition (Meal Plans, Items, Logs)      |
| 008  | Messaging (Conversations, Members, Msgs) |
| 009  | Automations & Automation Logs            |
| 010  | Payments, Subscriptions, Payment Records |

## Enums

```sql
-- Roles
CREATE TYPE user_role AS ENUM ('owner','admin','finance','trainer','client');

-- Statuses
CREATE TYPE user_status AS ENUM ('active','inactive','suspended','pending');
CREATE TYPE assignment_status AS ENUM ('active','completed','paused','cancelled');
CREATE TYPE subscription_status AS ENUM ('active','cancelled','expired','past_due');
CREATE TYPE payment_status AS ENUM ('pending','completed','failed','refunded');

-- Fitness
CREATE TYPE difficulty_level AS ENUM ('beginner','intermediate','advanced','expert');
CREATE TYPE workout_type AS ENUM ('strength','cardio','hiit','flexibility','custom');
CREATE TYPE exercise_equipment AS ENUM ('none','barbell','dumbbell','kettlebell','machine','cable','bodyweight','resistance_band','other');
CREATE TYPE gender_type AS ENUM ('male','female','other','prefer_not_to_say');
CREATE TYPE mood_type AS ENUM ('great','good','okay','tired','bad');

-- Messaging
CREATE TYPE conversation_type AS ENUM ('direct','group');
CREATE TYPE message_type AS ENUM ('text','image','voice','system');
CREATE TYPE member_role AS ENUM ('member','admin');

-- Automation
CREATE TYPE trigger_type AS ENUM ('on_signup','on_program_complete','on_inactive_days','scheduled','on_milestone');
CREATE TYPE action_type AS ENUM ('send_message','assign_program','send_reminder','send_notification','send_email');
```

## Entity Relationship Diagram

```
users (1) ──── (1) user_profiles
  │
  ├── (1) ──── (N) trainer_clients (as trainer)
  ├── (1) ──── (N) trainer_clients (as client)
  │
  ├── (1) ──── (N) exercises (created_by)
  ├── (1) ──── (N) workouts (created_by)
  ├── (1) ──── (N) programs (created_by)
  │
  ├── (1) ──── (N) user_programs
  │                    └── (N) ──── (1) programs
  │                                    └── (1) ──── (N) program_days
  │                                                        └── (N) ──── (1) workouts
  │
  ├── (1) ──── (N) progress_logs
  │                    ├── (N) ──── (1) exercises
  │                    └── (N) ──── (1) workouts
  │
  ├── (1) ──── (N) body_metrics
  │
  ├── (1) ──── (N) nutrition_logs
  │
  ├── (1) ──── (N) conversation_members
  │                    └── (N) ──── (1) conversations
  │                                    └── (1) ──── (N) messages
  │
  ├── (1) ──── (N) subscriptions
  │                    ├── (N) ──── (1) payment_plans
  │                    └── (1) ──── (N) payment_records
  │
  └── (1) ──── (N) automations (created_by)
                       └── (1) ──── (N) automation_logs
```

## Table Details

### users
| Column        | Type        | Constraints                     |
|---------------|-------------|---------------------------------|
| id            | UUID        | PK, default gen_random_uuid()   |
| email         | VARCHAR(255)| UNIQUE (where deleted_at IS NULL)|
| password_hash | TEXT        | NOT NULL                        |
| full_name     | VARCHAR(100)| NOT NULL                        |
| phone         | VARCHAR(20) |                                 |
| avatar_url    | TEXT        |                                 |
| role          | user_role   | NOT NULL, default 'client'      |
| status        | user_status | NOT NULL, default 'active'      |
| timezone      | VARCHAR(50) | default 'Asia/Jakarta'          |
| created_at    | TIMESTAMPTZ | NOT NULL, default NOW()         |
| updated_at    | TIMESTAMPTZ | NOT NULL, auto-trigger           |
| deleted_at    | TIMESTAMPTZ | Soft delete                     |

### user_profiles
| Column            | Type         | Constraints              |
|-------------------|--------------|--------------------------|
| user_id           | UUID         | PK, FK → users(id)       |
| date_of_birth     | DATE         |                          |
| gender            | gender_type  |                          |
| height_cm         | DECIMAL(5,2) |                          |
| weight_kg         | DECIMAL(5,2) |                          |
| fitness_goal      | TEXT         |                          |
| experience_level  | difficulty_level |                      |
| medical_notes     | TEXT         |                          |
| emergency_contact | TEXT         |                          |

### trainer_clients
| Column    | Type              | Constraints                |
|-----------|-------------------|----------------------------|
| trainer_id| UUID              | PK, FK → users(id)         |
| client_id | UUID              | PK, FK → users(id)         |
| status    | assignment_status | default 'active'           |
| assigned_at| TIMESTAMPTZ      | default NOW()              |

### exercises
| Column       | Type               | Constraints              |
|-------------|--------------------|--------------------------|
| id           | UUID               | PK                       |
| name         | VARCHAR(200)       | NOT NULL                 |
| description  | TEXT               |                          |
| muscle_group | TEXT[]             | Array of muscle groups   |
| equipment    | exercise_equipment | default 'none'           |
| difficulty   | difficulty_level   | default 'beginner'       |
| video_url    | TEXT               |                          |
| thumbnail_url| TEXT               |                          |
| instructions | TEXT[]             | Array of steps           |
| created_by   | UUID               | FK → users(id)           |
| is_system    | BOOLEAN            | default false            |
| created_at   | TIMESTAMPTZ        |                          |
| updated_at   | TIMESTAMPTZ        |                          |

### workouts
| Column               | Type         | Constraints         |
|----------------------|--------------|---------------------|
| id                    | UUID         | PK                  |
| name                  | VARCHAR(200) | NOT NULL            |
| description           | TEXT         |                     |
| type                  | workout_type | default 'custom'    |
| estimated_duration_min| INT          |                     |
| created_by            | UUID         | FK → users(id)      |
| is_template           | BOOLEAN      | default false       |
| created_at            | TIMESTAMPTZ  |                     |
| updated_at            | TIMESTAMPTZ  |                     |

### workout_exercises
| Column        | Type          | Constraints                           |
|--------------|---------------|---------------------------------------|
| id            | UUID          | PK                                    |
| workout_id    | UUID          | FK → workouts(id) CASCADE             |
| exercise_id   | UUID          | FK → exercises(id)                    |
| order_index   | INT           | NOT NULL, UNIQUE with workout_id      |
| sets          | INT           |                                       |
| reps          | INT           |                                       |
| weight_kg     | DECIMAL(6,2)  |                                       |
| rest_seconds  | INT           |                                       |
| notes         | TEXT          |                                       |
| superset_group| INT           |                                       |

### programs
| Column         | Type            | Constraints         |
|---------------|-----------------|---------------------|
| id             | UUID            | PK                  |
| name           | VARCHAR(200)    | NOT NULL            |
| description    | TEXT            |                     |
| duration_weeks | INT             | 1-52                |
| difficulty     | difficulty_level|                     |
| goal           | TEXT            |                     |
| created_by     | UUID            | FK → users(id)      |
| is_template    | BOOLEAN         | default false       |
| created_at     | TIMESTAMPTZ     |                     |
| updated_at     | TIMESTAMPTZ     |                     |

### program_days
| Column      | Type    | Constraints                                      |
|------------|---------|--------------------------------------------------|
| id          | UUID    | PK                                               |
| program_id  | UUID    | FK → programs(id) CASCADE                        |
| week_number | INT     | NOT NULL, UNIQUE with (program_id, day_of_week)  |
| day_of_week | INT     | 1-7, NOT NULL                                    |
| workout_id  | UUID    | FK → workouts(id)                                |
| is_rest_day | BOOLEAN | default false                                    |

### user_programs
| Column      | Type              | Constraints          |
|------------|-------------------|----------------------|
| id          | UUID              | PK                   |
| user_id     | UUID              | FK → users(id)       |
| program_id  | UUID              | FK → programs(id)    |
| assigned_by | UUID              | FK → users(id)       |
| start_date  | DATE              | NOT NULL             |
| end_date    | DATE              |                      |
| status      | assignment_status | default 'active'     |
| current_week| INT               | default 1            |
| current_day | INT               | default 1            |
| created_at  | TIMESTAMPTZ       |                      |
| updated_at  | TIMESTAMPTZ       |                      |

### progress_logs
| Column     | Type      | Constraints          |
|-----------|-----------|----------------------|
| id         | UUID      | PK                   |
| user_id    | UUID      | FK → users(id)       |
| exercise_id| UUID      | FK → exercises(id)   |
| workout_id | UUID      | FK → workouts(id)    |
| logged_at  | TIMESTAMPTZ| default NOW()       |
| sets       | JSONB     | Array of set objects |
| notes      | TEXT      |                      |
| mood       | mood_type |                      |

**Sets JSONB Structure:**
```json
[
  {
    "set_number": 1,
    "reps": 10,
    "weight_kg": 60.0,
    "duration_sec": null,
    "rpe": 7,
    "completed": true
  }
]
```

### body_metrics
| Column        | Type          | Constraints     |
|--------------|---------------|-----------------|
| id            | UUID          | PK              |
| user_id       | UUID          | FK → users(id)  |
| logged_at     | TIMESTAMPTZ   | default NOW()   |
| weight_kg     | DECIMAL(5,2)  |                 |
| body_fat_pct  | DECIMAL(4,1)  |                 |
| muscle_mass_kg| DECIMAL(5,2)  |                 |
| photo_urls    | TEXT[]        | Array           |
| notes         | TEXT          |                 |

### meal_plans
| Column        | Type         | Constraints     |
|--------------|-------------|-----------------|
| id            | UUID         | PK              |
| name          | VARCHAR(200) | NOT NULL        |
| description   | TEXT         |                 |
| daily_calories| INT          |                 |
| protein_g     | DECIMAL(6,1) |                 |
| carbs_g       | DECIMAL(6,1) |                 |
| fat_g         | DECIMAL(6,1) |                 |
| created_by    | UUID         | FK → users(id)  |
| created_at    | TIMESTAMPTZ  |                 |
| updated_at    | TIMESTAMPTZ  |                 |

### meal_plan_items
| Column      | Type         | Constraints                |
|------------|-------------|----------------------------|
| id          | UUID         | PK                         |
| meal_plan_id| UUID         | FK → meal_plans(id) CASCADE|
| meal_type   | VARCHAR(20)  | breakfast/lunch/dinner/snack|
| day_of_week | INT          | 1-7                        |
| food_name   | VARCHAR(200) | NOT NULL                   |
| portion     | VARCHAR(100) |                            |
| calories    | INT          |                            |
| protein_g   | DECIMAL(6,1) |                            |
| carbs_g     | DECIMAL(6,1) |                            |
| fat_g       | DECIMAL(6,1) |                            |

### nutrition_logs
| Column    | Type         | Constraints     |
|----------|-------------|-----------------|
| id        | UUID         | PK              |
| user_id   | UUID         | FK → users(id)  |
| logged_at | TIMESTAMPTZ  | default NOW()   |
| meal_type | VARCHAR(20)  |                 |
| food_name | VARCHAR(200) | NOT NULL        |
| calories  | INT          |                 |
| protein_g | DECIMAL(6,1) |                 |
| carbs_g   | DECIMAL(6,1) |                 |
| fat_g     | DECIMAL(6,1) |                 |
| photo_url | TEXT         |                 |

### conversations
| Column    | Type              | Constraints     |
|----------|-------------------|-----------------|
| id        | UUID              | PK              |
| type      | conversation_type | NOT NULL        |
| name      | VARCHAR(100)      | For groups only |
| created_at| TIMESTAMPTZ       |                 |
| updated_at| TIMESTAMPTZ       |                 |

### conversation_members
| Column         | Type        | Constraints                    |
|---------------|-------------|--------------------------------|
| conversation_id| UUID        | PK, FK → conversations(id)     |
| user_id        | UUID        | PK, FK → users(id)             |
| joined_at      | TIMESTAMPTZ | default NOW()                  |
| role           | member_role | default 'member'               |
| is_muted       | BOOLEAN     | default false                  |
| last_read_at   | TIMESTAMPTZ |                                |

### messages
| Column         | Type         | Constraints                   |
|---------------|-------------|-------------------------------|
| id             | UUID         | PK                            |
| conversation_id| UUID         | FK → conversations(id) CASCADE|
| sender_id      | UUID         | FK → users(id)                |
| content        | TEXT         |                               |
| type           | message_type | default 'text'                |
| media_url      | TEXT         |                               |
| is_read        | BOOLEAN      | default false                 |
| created_at     | TIMESTAMPTZ  | default NOW()                 |

### automations
| Column        | Type         | Constraints     |
|--------------|-------------|-----------------|
| id            | UUID         | PK              |
| name          | VARCHAR(200) | NOT NULL        |
| description   | TEXT         |                 |
| trigger_type  | trigger_type | NOT NULL        |
| trigger_config| JSONB        |                 |
| action_type   | action_type  | NOT NULL        |
| action_config | JSONB        |                 |
| is_active     | BOOLEAN      | default true    |
| created_by    | UUID         | FK → users(id)  |
| created_at    | TIMESTAMPTZ  |                 |
| updated_at    | TIMESTAMPTZ  |                 |

### automation_logs
| Column       | Type        | Constraints                 |
|-------------|-------------|-----------------------------|
| id           | UUID        | PK                          |
| automation_id| UUID        | FK → automations(id) CASCADE|
| user_id      | UUID        | FK → users(id)              |
| triggered_at | TIMESTAMPTZ | default NOW()               |
| status       | VARCHAR(20) | success/failed/skipped      |
| result       | JSONB       |                             |
| error_message| TEXT        |                             |

### payment_plans
| Column         | Type          | Constraints     |
|---------------|--------------|-----------------|
| id             | UUID          | PK              |
| name           | VARCHAR(200)  | NOT NULL        |
| description    | TEXT          |                 |
| price          | DECIMAL(12,2) | NOT NULL        |
| currency       | VARCHAR(3)    | default 'IDR'   |
| duration_months| INT           | NOT NULL        |
| features       | JSONB         | Array           |
| max_clients    | INT           |                 |
| is_active      | BOOLEAN       | default true    |
| created_at     | TIMESTAMPTZ   |                 |
| updated_at     | TIMESTAMPTZ   |                 |

### subscriptions
| Column        | Type               | Constraints          |
|--------------|--------------------|----------------------|
| id            | UUID               | PK                   |
| user_id       | UUID               | FK → users(id)       |
| plan_id       | UUID               | FK → payment_plans(id)|
| status        | subscription_status| default 'active'     |
| started_at    | TIMESTAMPTZ        | NOT NULL             |
| expires_at    | TIMESTAMPTZ        | NOT NULL             |
| cancelled_at  | TIMESTAMPTZ        |                      |
| payment_method| VARCHAR(50)        |                      |
| created_at    | TIMESTAMPTZ        |                      |
| updated_at    | TIMESTAMPTZ        |                      |

### payment_records
| Column         | Type          | Constraints                   |
|---------------|--------------|-------------------------------|
| id             | UUID          | PK                            |
| subscription_id| UUID          | FK → subscriptions(id)        |
| user_id        | UUID          | FK → users(id)                |
| amount         | DECIMAL(12,2) | NOT NULL                      |
| currency       | VARCHAR(3)    | default 'IDR'                 |
| status         | payment_status| default 'pending'             |
| payment_method | VARCHAR(50)   |                               |
| external_id    | VARCHAR(200)  | Payment gateway reference     |
| paid_at        | TIMESTAMPTZ   |                               |
| failed_at      | TIMESTAMPTZ   |                               |
| refunded_at    | TIMESTAMPTZ   |                               |
| metadata       | JSONB         |                               |
| created_at     | TIMESTAMPTZ   |                               |
| updated_at     | TIMESTAMPTZ   |                               |
