# 008 — Programs (Training Plans)

## Endpoints

| Method | Path                         | Auth     | Role           |
|--------|------------------------------|----------|----------------|
| GET    | /api/programs                | Required | any            |
| GET    | /api/programs/templates      | Required | any            |
| GET    | /api/programs/{id}           | Required | any            |
| POST   | /api/programs                | Required | admin, trainer |
| PUT    | /api/programs/{id}           | Required | admin, trainer |
| POST   | /api/programs/{id}/assign    | Required | admin, trainer |

---

### GET /api/programs

List programs with filters.

**Query Parameters:**
| Param       | Type   | Default    | Description                    |
|-------------|--------|------------|--------------------------------|
| page        | int    | 1          |                                |
| limit       | int    | 20         | max 100                        |
| search      | string |            | Search by name                 |
| difficulty  | string |            | beginner, intermediate, etc.   |
| goal        | string |            | e.g., gain_muscle, lose_fat    |
| is_template | bool   |            | Filter templates               |
| sort_by     | string | created_at |                                |
| sort_order  | string | desc       |                                |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "PPL Split - 12 Week",
      "description": "Push Pull Legs for intermediate lifters",
      "duration_weeks": 12,
      "difficulty": "intermediate",
      "goal": "gain_muscle",
      "created_by": "uuid",
      "is_template": true,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 10, "total_pages": 1 }
}
```

---

### GET /api/programs/templates

Same as GET /api/programs but returns only templates (`is_template = true`).

---

### GET /api/programs/{id}

Get program detail **with days and workouts** (ProgramDetail).

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "PPL Split - 12 Week",
    "description": "Push Pull Legs for intermediate lifters",
    "duration_weeks": 12,
    "difficulty": "intermediate",
    "goal": "gain_muscle",
    "created_by": "uuid",
    "is_template": true,
    "days": [
      {
        "id": "day-uuid-1",
        "week_number": 1,
        "day_of_week": 1,
        "workout_id": "workout-uuid-push",
        "workout_name": "Push Day A",
        "workout_type": "strength",
        "is_rest_day": false
      },
      {
        "id": "day-uuid-2",
        "week_number": 1,
        "day_of_week": 2,
        "workout_id": "workout-uuid-pull",
        "workout_name": "Pull Day A",
        "workout_type": "strength",
        "is_rest_day": false
      },
      {
        "id": "day-uuid-3",
        "week_number": 1,
        "day_of_week": 3,
        "workout_id": "workout-uuid-legs",
        "workout_name": "Leg Day A",
        "workout_type": "strength",
        "is_rest_day": false
      },
      {
        "id": "day-uuid-4",
        "week_number": 1,
        "day_of_week": 4,
        "workout_id": null,
        "workout_name": null,
        "workout_type": null,
        "is_rest_day": true
      }
    ]
  }
}
```

---

### POST /api/programs

Create a program with days. Admin/trainer only.

**Request:**
```json
{
  "name": "Upper Lower Split",
  "description": "4-day upper/lower split for beginners",
  "duration_weeks": 8,
  "difficulty": "beginner",
  "goal": "gain_muscle",
  "is_template": true,
  "days": [
    {
      "week_number": 1,
      "day_of_week": 1,
      "workout_id": "workout-uuid-upper",
      "is_rest_day": false
    },
    {
      "week_number": 1,
      "day_of_week": 2,
      "workout_id": "workout-uuid-lower",
      "is_rest_day": false
    },
    {
      "week_number": 1,
      "day_of_week": 3,
      "workout_id": null,
      "is_rest_day": true
    },
    {
      "week_number": 1,
      "day_of_week": 4,
      "workout_id": "workout-uuid-upper-b",
      "is_rest_day": false
    },
    {
      "week_number": 1,
      "day_of_week": 5,
      "workout_id": "workout-uuid-lower-b",
      "is_rest_day": false
    },
    {
      "week_number": 1,
      "day_of_week": 6,
      "workout_id": null,
      "is_rest_day": true
    },
    {
      "week_number": 1,
      "day_of_week": 7,
      "workout_id": null,
      "is_rest_day": true
    }
  ]
}
```

**Validation:**
- `name` — required
- `duration_weeks` — 1 to 52
- `difficulty` — beginner, intermediate, advanced, expert
- `days` — array, each needs `week_number` (1-52) and `day_of_week` (1-7)
- Unique constraint: `(program_id, week_number, day_of_week)`

**Response (201):**
```json
{
  "success": true,
  "data": { "...program with id..." },
  "message": "Program created successfully"
}
```

---

### PUT /api/programs/{id}

Update program. Partial update supported.

---

### POST /api/programs/{id}/assign

Assign a program to one or more users. Admin/trainer only.

**Request:**
```json
{
  "user_ids": ["user-uuid-1", "user-uuid-2"],
  "start_date": "2024-02-01"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": [
    {
      "id": "user-program-uuid",
      "user_id": "user-uuid-1",
      "program_id": "program-uuid",
      "assigned_by": "trainer-uuid",
      "start_date": "2024-02-01",
      "end_date": "2024-03-28",
      "status": "active",
      "current_week": 1,
      "current_day": 1
    }
  ],
  "message": "Program assigned successfully"
}
```

## Program Progress Tracking

The `user_programs` table tracks:
- `current_week` — Which week the user is currently on
- `current_day` — Which day within that week
- `status` — active, completed, paused, cancelled
- `start_date` / `end_date` — Calculated from duration_weeks

This enables progress percentage calculation:
```
progress_pct = ((current_week - 1) * 7 + current_day) / (duration_weeks * 7) * 100
```
