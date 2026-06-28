# 004 — Authentication & Authorization

## Auth Flow

```
┌──────────┐   POST /auth/register    ┌──────────┐
│  Client   │ ──────────────────────→ │  Server   │
│           │ ←────────────────────── │           │
│           │   { access_token,       │           │
│           │     refresh_token }     │           │
│           │                         │           │
│           │   POST /auth/login      │           │
│           │ ──────────────────────→ │           │
│           │ ←────────────────────── │           │
│           │   { access_token,       │           │
│           │     refresh_token }     │           │
│           │                         │           │
│           │   GET /api/* (Bearer)   │           │
│           │ ──────────────────────→ │           │
│           │ ←────────────────────── │           │
│           │                         │           │
│           │   POST /auth/refresh    │           │
│           │   { refresh_token }     │           │
│           │ ──────────────────────→ │           │
│           │ ←────────────────────── │           │
│           │   { new access_token,   │           │
│           │     new refresh_token } │           │
└──────────┘                         └──────────┘
```

## Endpoints

### POST /api/auth/register

**Public** — No authentication required.

**Request:**
```json
{
  "email": "john@example.com",
  "password": "securePass123!",
  "full_name": "John Doe",
  "phone": "+6281234567890",
  "role": "client"
}
```

**Validation:**
- `email` — required, valid email format
- `password` — required, min 8 characters
- `full_name` — required, min 2 characters
- `role` — required, one of: owner, admin, finance, trainer, client

**Response (201):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "john@example.com",
      "full_name": "John Doe",
      "phone": "+6281234567890",
      "role": "client",
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOi...",
      "refresh_token": "eyJhbGciOi...",
      "expires_at": "2024-01-01T00:15:00Z"
    }
  },
  "message": "Registration successful"
}
```

**Errors:**
- 400 — Validation error
- 409 — Email already taken

---

### POST /api/auth/login

**Public** — No authentication required.

**Request:**
```json
{
  "email": "john@example.com",
  "password": "securePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "john@example.com",
      "full_name": "John Doe",
      "role": "client",
      "status": "active",
      "avatar_url": null
    },
    "tokens": {
      "access_token": "eyJhbGciOi...",
      "refresh_token": "eyJhbGciOi...",
      "expires_at": "2024-01-01T00:15:00Z"
    }
  }
}
```

**Errors:**
- 400 — Validation error
- 401 — Invalid credentials
- 403 — Account not active (suspended/inactive)

---

### POST /api/auth/refresh

**Public** — No authentication required (uses refresh token in body).

**Request:**
```json
{
  "refresh_token": "eyJhbGciOi..."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOi...",
    "refresh_token": "eyJhbGciOi...",
    "expires_at": "2024-01-01T00:15:00Z"
  }
}
```

**Errors:**
- 401 — Invalid or expired refresh token

---

### POST /api/auth/forgot-password

**Public** — No authentication required.

**Request:**
```json
{
  "email": "john@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "If the email exists, a reset link has been sent"
}
```

---

### GET /api/auth/me

**Authenticated** — Requires Bearer token.

**Headers:**
```
Authorization: Bearer <access_token>
```

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
    },
    "stats": {
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
}
```

---

## JWT Token Structure

**Claims:**
```json
{
  "user_id": "uuid",
  "email": "john@example.com",
  "role": "client",
  "exp": 1704067500,
  "iat": 1704066600
}
```

- **Access Token:** Expires in 15 minutes
- **Refresh Token:** Expires in 7 days (168 hours)
- **Algorithm:** HS256

## Token Usage

All authenticated endpoints require the Authorization header:
```
Authorization: Bearer <access_token>
```

## RBAC Middleware

| Middleware            | Description                                      |
|-----------------------|--------------------------------------------------|
| `Auth`                | Validates JWT, extracts user context              |
| `RequireRole(roles)`  | Restricts to exact roles (owner always bypasses)  |
| `RequireMinRole(role)`| Checks role hierarchy level                       |
| `RequireSelfOrRole`   | Allows access to own data OR specified roles      |
