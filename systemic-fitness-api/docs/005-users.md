# 005 — User Management

## Endpoints

| Method | Path                    | Auth       | Role                    |
|--------|-------------------------|------------|-------------------------|
| GET    | /api/users              | Required   | admin, trainer          |
| POST   | /api/users/invite       | Required   | admin                   |
| GET    | /api/users/{id}         | Required   | self, admin, trainer    |
| PUT    | /api/users/{id}         | Required   | self, admin             |
| DELETE | /api/users/{id}         | Required   | admin                   |
| GET    | /api/users/{id}/stats   | Required   | self, admin, trainer    |
| GET    | /api/users/online       | Required   | any                     |
| POST   | /api/users/online/check | Required   | any                     |

---

### GET /api/users

List users with filters and pagination. Trainers can only see their assigned clients.

**Query Parameters:**
| Param      | Type   | Default     | Description                    |
|------------|--------|-------------|--------------------------------|
| page       | int    | 1           | Page number                    |
| limit      | int    | 20          | Items per page (max 100)       |
| role       | string |             | Filter: client, trainer, etc.  |
| status     | string |             | Filter: active, inactive, etc. |
| search     | string |             | Search by name or email        |
| sort_by    | string | created_at  | Sort field                     |
| sort_order | string | desc        | asc or desc                    |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "email": "john@example.com",
      "full_name": "John Doe",
      "phone": "+6281234567890",
      "avatar_url": null,
      "role": "client",
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "total_pages": 3
  }
}
```

---

### POST /api/users/invite

Create a new user with pending status (admin only).

**Request:**
```json
{
  "email": "jane@example.com",
  "role": "trainer",
  "full_name": "Jane Smith"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "jane@example.com",
    "full_name": "Jane Smith",
    "role": "trainer",
    "status": "pending"
  },
  "message": "User invited successfully"
}
```

---

### GET /api/users/{id}

Get user detail. Self-access or admin/trainer (trainer only for assigned clients).

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "john@example.com",
    "full_name": "John Doe",
    "phone": "+6281234567890",
    "avatar_url": null,
    "role": "client",
    "status": "active",
    "timezone": "Asia/Jakarta",
    "created_at": "2024-01-01T00:00:00Z",
    "profile": {
      "date_of_birth": "1990-05-15",
      "gender": "male",
      "height_cm": 175.5,
      "weight_kg": 72.0,
      "fitness_goal": "Build muscle",
      "experience_level": "intermediate",
      "medical_notes": null,
      "emergency_contact": null
    }
  }
}
```

---

### PUT /api/users/{id}

Update user details. Self or admin.

**Request:**
```json
{
  "full_name": "John Updated",
  "phone": "+6281234567899",
  "avatar_url": "https://example.com/avatar.jpg",
  "status": "active"
}
```

All fields are optional — only send fields you want to update.

**Response (200):**
```json
{
  "success": true,
  "data": { "...updated user object..." },
  "message": "User updated successfully"
}
```

---

### DELETE /api/users/{id}

Soft delete a user (admin only). Sets `deleted_at` timestamp.

**Response (204):** No content

---

### GET /api/users/{id}/stats

Get aggregated statistics for a user.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_workouts": 45,
    "workouts_this_week": 3,
    "workouts_this_month": 12,
    "current_streak_days": 5,
    "longest_streak_days": 14,
    "total_exercise_minutes": 2700,
    "active_program_name": "PPL Split",
    "active_program_id": "uuid",
    "program_progress_pct": 65.0,
    "last_workout_at": "2024-01-15T10:00:00Z"
  }
}
```

---

### GET /api/users/online

Get list of currently online user IDs (connected via WebSocket).

**Response (200):**
```json
{
  "success": true,
  "data": ["uuid-1", "uuid-2", "uuid-3"]
}
```

---

### POST /api/users/online/check

Check online status for specific users.

**Request:**
```json
{
  "user_ids": ["uuid-1", "uuid-2", "uuid-3"]
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "uuid-1": true,
    "uuid-2": false,
    "uuid-3": true
  }
}
```

## Access Control Summary

- **Trainers** can only view their assigned clients (enforced at service layer)
- **Admins** can view/edit all users
- **Users** can view/edit their own profile
- **Owner** bypasses all role checks
