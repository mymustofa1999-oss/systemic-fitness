# 009 — Progress Tracking

## Endpoints

| Method | Path                                  | Auth     | Role                 |
|--------|---------------------------------------|----------|----------------------|
| POST   | /api/progress/log                     | Required | any                  |
| POST   | /api/progress/body-metric             | Required | any                  |
| GET    | /api/progress/user/{id}               | Required | self, admin, trainer |
| GET    | /api/progress/user/{id}/charts        | Required | self, admin, trainer |
| GET    | /api/progress/user/{id}/body-metrics  | Required | self, admin, trainer |

---

### POST /api/progress/log

Log workout progress (exercise performance).

**Request:**
```json
{
  "exercise_id": "exercise-uuid",
  "workout_id": "workout-uuid",
  "sets": [
    {
      "set_number": 1,
      "reps": 10,
      "weight_kg": 60.0,
      "duration_sec": null,
      "rpe": 7,
      "completed": true
    },
    {
      "set_number": 2,
      "reps": 8,
      "weight_kg": 60.0,
      "duration_sec": null,
      "rpe": 8,
      "completed": true
    },
    {
      "set_number": 3,
      "reps": 6,
      "weight_kg": 60.0,
      "duration_sec": null,
      "rpe": 9,
      "completed": true
    },
    {
      "set_number": 4,
      "reps": 5,
      "weight_kg": 60.0,
      "duration_sec": null,
      "rpe": 10,
      "completed": false
    }
  ],
  "notes": "Felt strong today, almost got all reps",
  "mood": "good"
}
```

**Set Object Fields:**
| Field        | Type    | Description                       |
|-------------|---------|-----------------------------------|
| set_number   | int     | Set order (1, 2, 3...)            |
| reps         | int     | Repetitions performed             |
| weight_kg    | float   | Weight used (null for bodyweight) |
| duration_sec | int     | For timed exercises (planks, etc.)|
| rpe          | int     | Rate of Perceived Exertion (1-10) |
| completed    | bool    | Whether set was completed fully   |

**Mood Options:** `great`, `good`, `okay`, `tired`, `bad`

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "progress-log-uuid",
    "user_id": "user-uuid",
    "exercise_id": "exercise-uuid",
    "workout_id": "workout-uuid",
    "logged_at": "2024-01-15T10:30:00Z",
    "sets": [...],
    "notes": "Felt strong today",
    "mood": "good"
  },
  "message": "Progress logged successfully"
}
```

---

### POST /api/progress/body-metric

Log body composition measurements.

**Request:**
```json
{
  "weight_kg": 72.5,
  "body_fat_pct": 15.2,
  "muscle_mass_kg": 58.0,
  "photo_urls": [
    "https://example.com/front.jpg",
    "https://example.com/side.jpg"
  ],
  "notes": "After 4 weeks of cutting"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "body-metric-uuid",
    "user_id": "user-uuid",
    "logged_at": "2024-01-15T08:00:00Z",
    "weight_kg": 72.5,
    "body_fat_pct": 15.2,
    "muscle_mass_kg": 58.0,
    "photo_urls": ["..."],
    "notes": "After 4 weeks of cutting"
  },
  "message": "Body metric logged successfully"
}
```

---

### GET /api/progress/user/{id}

Get progress history with filters.

**Query Parameters:**
| Param       | Type   | Default    | Description                    |
|-------------|--------|------------|--------------------------------|
| page        | int    | 1          |                                |
| limit       | int    | 20         | max 100                        |
| exercise_id | string |            | Filter by specific exercise    |
| workout_id  | string |            | Filter by specific workout     |
| date_from   | string |            | ISO date (2024-01-01)          |
| date_to     | string |            | ISO date (2024-12-31)          |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "log-uuid",
      "exercise_id": "exercise-uuid",
      "exercise_name": "Bench Press",
      "workout_id": "workout-uuid",
      "logged_at": "2024-01-15T10:30:00Z",
      "sets": [
        { "set_number": 1, "reps": 10, "weight_kg": 60.0, "rpe": 7, "completed": true }
      ],
      "notes": "Good session",
      "mood": "good"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 100, "total_pages": 5 }
}
```

---

### GET /api/progress/user/{id}/charts

Get aggregated chart data for progress visualization.

**Query Parameters:**
| Param       | Type   | Description                    |
|-------------|--------|--------------------------------|
| exercise_id | string | Filter by exercise             |
| date_from   | string | Start date                     |
| date_to     | string | End date                       |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "exercise_progress": [
      {
        "date": "2024-01-01",
        "max_weight_kg": 60.0,
        "total_volume": 1800,
        "avg_rpe": 7.5
      },
      {
        "date": "2024-01-08",
        "max_weight_kg": 62.5,
        "total_volume": 1950,
        "avg_rpe": 8.0
      }
    ]
  }
}
```

**Volume Calculation:** `total_volume = sum(sets × reps × weight_kg)`

---

### GET /api/progress/user/{id}/body-metrics

Get body composition history.

**Query Parameters:**
| Param | Type | Default | Description     |
|-------|------|---------|-----------------|
| page  | int  | 1       |                 |
| limit | int  | 20      | max 100         |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "metric-uuid",
      "logged_at": "2024-01-15T08:00:00Z",
      "weight_kg": 72.5,
      "body_fat_pct": 15.2,
      "muscle_mass_kg": 58.0,
      "photo_urls": ["..."],
      "notes": "After 4 weeks of cutting"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 12, "total_pages": 1 }
}
```
