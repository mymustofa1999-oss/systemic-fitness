# 007 — Workouts

## Endpoints

| Method | Path                          | Auth     | Role           |
|--------|-------------------------------|----------|----------------|
| GET    | /api/workouts                 | Required | any            |
| GET    | /api/workouts/{id}            | Required | any            |
| POST   | /api/workouts                 | Required | admin, trainer |
| PUT    | /api/workouts/{id}            | Required | admin, trainer |
| POST   | /api/workouts/{id}/duplicate  | Required | admin, trainer |

---

### GET /api/workouts

List workouts with filters.

**Query Parameters:**
| Param       | Type   | Default    | Description                                   |
|-------------|--------|------------|-----------------------------------------------|
| page        | int    | 1          | Page number                                   |
| limit       | int    | 20         | Items per page (max 100)                      |
| search      | string |            | Search by name                                |
| type        | string |            | Filter: strength, cardio, hiit, flexibility, custom |
| created_by  | string |            | Filter by creator UUID                        |
| is_template | bool   |            | Filter templates only                         |
| sort_by     | string | created_at | Sort field                                    |
| sort_order  | string | desc       | asc or desc                                   |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Push Day A",
      "description": "Chest, shoulders, triceps",
      "type": "strength",
      "estimated_duration_min": 60,
      "created_by": "uuid",
      "is_template": true,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 30, "total_pages": 2 }
}
```

---

### GET /api/workouts/{id}

Get workout detail **with exercises** (WorkoutDetail).

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Push Day A",
    "description": "Chest, shoulders, triceps",
    "type": "strength",
    "estimated_duration_min": 60,
    "created_by": "uuid",
    "is_template": true,
    "created_at": "2024-01-01T00:00:00Z",
    "exercises": [
      {
        "id": "workout-exercise-uuid",
        "exercise_id": "exercise-uuid",
        "exercise_name": "Barbell Bench Press",
        "muscle_group": ["chest", "triceps"],
        "equipment": "barbell",
        "order_index": 1,
        "sets": 4,
        "reps": 8,
        "weight_kg": 80.0,
        "rest_seconds": 120,
        "notes": "Warm up with 50% first",
        "superset_group": null
      },
      {
        "id": "workout-exercise-uuid-2",
        "exercise_id": "exercise-uuid-2",
        "exercise_name": "Incline Dumbbell Press",
        "muscle_group": ["chest", "shoulders"],
        "equipment": "dumbbell",
        "order_index": 2,
        "sets": 3,
        "reps": 12,
        "weight_kg": 30.0,
        "rest_seconds": 90,
        "notes": null,
        "superset_group": 1
      }
    ]
  }
}
```

---

### POST /api/workouts

Create a workout with exercises. Admin/trainer only.

**Request:**
```json
{
  "name": "Pull Day A",
  "description": "Back, biceps",
  "type": "strength",
  "estimated_duration_min": 55,
  "is_template": true,
  "exercises": [
    {
      "exercise_id": "exercise-uuid-1",
      "order_index": 1,
      "sets": 4,
      "reps": 6,
      "weight_kg": 100.0,
      "rest_seconds": 180,
      "notes": "Deadlift warm-up required",
      "superset_group": null
    },
    {
      "exercise_id": "exercise-uuid-2",
      "order_index": 2,
      "sets": 4,
      "reps": 10,
      "weight_kg": null,
      "rest_seconds": 90,
      "notes": null,
      "superset_group": null
    }
  ]
}
```

**Validation:**
- `name` — required
- `type` — one of: strength, cardio, hiit, flexibility, custom
- `exercises` — array, each needs `exercise_id` and `order_index`

**Response (201):**
```json
{
  "success": true,
  "data": { "...workout object with id..." },
  "message": "Workout created successfully"
}
```

---

### PUT /api/workouts/{id}

Update workout. Partial update supported.

**Request:**
```json
{
  "name": "Pull Day A (Updated)",
  "description": "Back, biceps, forearms",
  "exercises": [
    {
      "exercise_id": "exercise-uuid-1",
      "order_index": 1,
      "sets": 5,
      "reps": 5,
      "weight_kg": 110.0,
      "rest_seconds": 180
    }
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "data": { "...updated workout..." },
  "message": "Workout updated successfully"
}
```

---

### POST /api/workouts/{id}/duplicate

Duplicate an existing workout. Creates a copy assigned to the current user.

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "new-workout-uuid",
    "name": "Pull Day A (Copy)",
    "...rest of workout..."
  },
  "message": "Workout duplicated successfully"
}
```

## Workout Types

| Type        | Description                    |
|-------------|--------------------------------|
| strength    | Weight training / resistance   |
| cardio      | Cardiovascular exercises       |
| hiit        | High-intensity interval        |
| flexibility | Stretching / mobility          |
| custom      | User-defined                   |

## Superset Groups

Exercises with the same `superset_group` number are meant to be performed back-to-back without rest. For example, exercises with `superset_group: 1` form one superset pair.
