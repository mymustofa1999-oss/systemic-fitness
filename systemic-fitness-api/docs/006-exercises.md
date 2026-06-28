# 006 — Exercise Library

## Endpoints

| Method | Path                 | Auth     | Role            |
|--------|----------------------|----------|-----------------|
| GET    | /api/exercises       | Optional | any (public)    |
| GET    | /api/exercises/{id}  | Optional | any (public)    |
| POST   | /api/exercises       | Required | admin, trainer  |
| PUT    | /api/exercises/{id}  | Required | admin, trainer  |
| DELETE | /api/exercises/{id}  | Required | admin, trainer  |

---

### GET /api/exercises

List exercises with filters.

**Query Parameters:**
| Param        | Type   | Default    | Description                     |
|--------------|--------|------------|---------------------------------|
| page         | int    | 1          | Page number                     |
| limit        | int    | 20         | Items per page (max 100)        |
| search       | string |            | Search by name                  |
| muscle_group | string |            | Filter: chest, back, legs, etc. |
| equipment    | string |            | Filter: barbell, dumbbell, etc. |
| difficulty   | string |            | Filter: beginner, intermediate, advanced, expert |
| sort_by      | string | created_at | Sort field                      |
| sort_order   | string | desc       | asc or desc                     |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Barbell Bench Press",
      "description": "Compound chest exercise",
      "muscle_group": ["chest", "triceps", "shoulders"],
      "equipment": "barbell",
      "difficulty": "intermediate",
      "video_url": "https://example.com/video.mp4",
      "thumbnail_url": "https://example.com/thumb.jpg",
      "instructions": [
        "Lie flat on bench",
        "Grip barbell slightly wider than shoulder width",
        "Lower bar to mid-chest",
        "Press back up to starting position"
      ],
      "is_system": true,
      "created_by": "uuid",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 150, "total_pages": 8 }
}
```

---

### GET /api/exercises/{id}

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Barbell Bench Press",
    "description": "Compound chest exercise",
    "muscle_group": ["chest", "triceps", "shoulders"],
    "equipment": "barbell",
    "difficulty": "intermediate",
    "video_url": "https://example.com/video.mp4",
    "thumbnail_url": "https://example.com/thumb.jpg",
    "instructions": ["..."],
    "is_system": true,
    "created_by": "uuid",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

---

### POST /api/exercises

Create a new exercise. Admin/trainer only.

**Request:**
```json
{
  "name": "Dumbbell Curl",
  "description": "Isolation bicep exercise",
  "muscle_group": ["biceps"],
  "equipment": "dumbbell",
  "difficulty": "beginner",
  "video_url": "https://example.com/curl.mp4",
  "thumbnail_url": "https://example.com/curl-thumb.jpg",
  "instructions": [
    "Stand with dumbbells at sides",
    "Curl weights up with controlled motion",
    "Squeeze at top",
    "Lower slowly"
  ]
}
```

**Validation:**
- `name` — required, min 2 characters
- `muscle_group` — required, at least 1 item
- `equipment` — one of: none, barbell, dumbbell, kettlebell, machine, cable, bodyweight, resistance_band, other
- `difficulty` — one of: beginner, intermediate, advanced, expert

**Response (201):**
```json
{
  "success": true,
  "data": { "...exercise object..." },
  "message": "Exercise created successfully"
}
```

---

### PUT /api/exercises/{id}

Update exercise. Admin can edit system exercises, trainers can only edit their own custom exercises.

**Request:** Same fields as POST (all optional for update).

**Response (200):**
```json
{
  "success": true,
  "data": { "...updated exercise object..." },
  "message": "Exercise updated successfully"
}
```

---

### DELETE /api/exercises/{id}

Delete exercise. Same permission rules as update.

**Response (204):** No content

## Enums Reference

**Equipment:**
`none`, `barbell`, `dumbbell`, `kettlebell`, `machine`, `cable`, `bodyweight`, `resistance_band`, `other`

**Difficulty:**
`beginner`, `intermediate`, `advanced`, `expert`

**Common Muscle Groups (text array):**
`chest`, `back`, `shoulders`, `biceps`, `triceps`, `forearms`, `core`, `quadriceps`, `hamstrings`, `glutes`, `calves`, `full_body`
