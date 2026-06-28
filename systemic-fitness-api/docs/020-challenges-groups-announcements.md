# 020 — Challenges, Groups & Announcements

## Overview

Three community & engagement features added to the platform:

- **Challenges** — Time-bound fitness challenges with participant tracking and progress goals
- **Groups** — Trainer-managed client groups for team organization
- **Announcements** — Role-targeted broadcast messages from admin/trainers

---

## Database Tables

### challenges

```sql
CREATE TYPE challenge_status AS ENUM ('draft', 'active', 'completed', 'cancelled');

challenges (
    id                UUID PRIMARY KEY,
    name              VARCHAR(150) NOT NULL,
    description       TEXT,
    image_url         TEXT,
    status            challenge_status NOT NULL DEFAULT 'draft',
    start_date        DATE NOT NULL,
    end_date          DATE NOT NULL,
    goal_type         VARCHAR(50),          -- e.g. 'total_reps', 'daily_steps', 'body_fat_pct'
    goal_value        DECIMAL(10,2),        -- target value for the goal
    max_participants  INT CHECK (> 0),
    created_by        UUID NOT NULL REFERENCES users(id),
    created_at        TIMESTAMPTZ,
    updated_at        TIMESTAMPTZ,
    CONSTRAINT chk_challenges_dates CHECK (end_date >= start_date)
)
```

### challenge_participants

```sql
challenge_participants (
    id              UUID PRIMARY KEY,
    challenge_id    UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    progress_value  DECIMAL(10,2) NOT NULL DEFAULT 0,
    joined_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at    TIMESTAMPTZ,
    UNIQUE (challenge_id, user_id)
)
```

### groups

```sql
groups (
    id          UUID PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    image_url   TEXT,
    max_members INT CHECK (> 0),
    created_by  UUID NOT NULL REFERENCES users(id),
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
)
```

### group_members

```sql
CREATE TYPE group_role AS ENUM ('admin', 'member');

group_members (
    id        UUID PRIMARY KEY,
    group_id  UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role      group_role NOT NULL DEFAULT 'member',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (group_id, user_id)
)
```

### announcements

```sql
CREATE TYPE announcement_status AS ENUM ('draft', 'published', 'archived');

announcements (
    id           UUID PRIMARY KEY,
    title        VARCHAR(200) NOT NULL,
    body         TEXT NOT NULL,
    image_url    TEXT,
    status       announcement_status NOT NULL DEFAULT 'draft',
    target_roles user_role[],               -- e.g. '{client,trainer}'
    published_at TIMESTAMPTZ,
    created_by   UUID NOT NULL REFERENCES users(id),
    created_at   TIMESTAMPTZ,
    updated_at   TIMESTAMPTZ
)
```

### announcement_reads

```sql
announcement_reads (
    id              UUID PRIMARY KEY,
    announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    read_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (announcement_id, user_id)
)
```

---

## API Endpoints

All endpoints require authentication (JWT Bearer token).

---

### Challenges

#### List Challenges

```
GET /api/challenges?page=1&limit=20&status=active&search=push
```

**Query parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `page` | int | Page number (default: 1) |
| `limit` | int | Items per page (default: 20) |
| `status` | string | Filter by status: `draft`, `active`, `completed`, `cancelled` |
| `search` | string | Search by name (case-insensitive) |

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "30 Day Push-Up Challenge",
      "description": "Complete 3000 push-ups in 30 days.",
      "image_url": null,
      "status": "active",
      "start_date": "2026-03-28",
      "end_date": "2026-04-27",
      "goal_type": "total_reps",
      "goal_value": 3000,
      "max_participants": 50,
      "created_by": "user-uuid",
      "created_at": "2026-03-28T00:25:25Z",
      "updated_at": "2026-03-28T00:25:25Z",
      "participant_count": 3
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 4, "total_pages": 1 }
}
```

#### Get Challenge Detail

```
GET /api/challenges/{id}
```

Returns single challenge object (same shape as list item).

#### Create Challenge (Admin/Trainer)

```
POST /api/challenges
```

**Request body:**

```json
{
  "name": "30 Day Push-Up Challenge",
  "description": "Complete 3000 push-ups in 30 days.",
  "status": "active",
  "start_date": "2026-03-28",
  "end_date": "2026-04-27",
  "goal_type": "total_reps",
  "goal_value": 3000,
  "max_participants": 50,
  "image_id": "upload-uuid",
  "image_url": "https://..."
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `name` | string | Yes | 1-150 chars |
| `status` | string | Yes | `draft`, `active`, `completed`, `cancelled` |
| `start_date` | string | Yes | Date format YYYY-MM-DD |
| `end_date` | string | Yes | Date format YYYY-MM-DD |
| `description` | string | No | |
| `goal_type` | string | No | |
| `goal_value` | number | No | |
| `max_participants` | int | No | > 0 |
| `image_id` | string | No | Upload UUID (takes precedence) |
| `image_url` | string | No | External URL fallback |

**Response (201):** Challenge object

#### Update Challenge (Admin/Trainer)

```
PUT /api/challenges/{id}
```

Same body as Create. **Response (200):** Updated challenge object.

#### Delete Challenge (Admin/Trainer)

```
DELETE /api/challenges/{id}
```

**Response (200):** `{ "success": true, "message": "Challenge deleted" }`

#### Join Challenge

```
POST /api/challenges/{id}/join
```

No request body. Returns the participant record.

**Response (201):**

```json
{
  "success": true,
  "data": {
    "id": "participant-uuid",
    "challenge_id": "challenge-uuid",
    "user_id": "user-uuid",
    "progress_value": 0,
    "joined_at": "2026-03-28T10:00:00Z"
  }
}
```

#### Leave Challenge

```
POST /api/challenges/{id}/leave
```

**Response (200):** `{ "success": true, "message": "Left challenge" }`

#### Update Challenge Progress

```
POST /api/challenges/{id}/progress
```

**Request body:**

```json
{ "value": 150.0 }
```

**Response (200):** `{ "success": true, "message": "Progress updated" }`

#### List Challenge Participants

```
GET /api/challenges/{id}/participants
```

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "participant-uuid",
      "challenge_id": "challenge-uuid",
      "user_id": "user-uuid",
      "progress_value": 580.0,
      "joined_at": "2026-03-28T10:00:00Z",
      "completed_at": null
    }
  ]
}
```

Sorted by `progress_value` descending (leaderboard order).

---

### Groups

#### List Groups

```
GET /api/groups?page=1&limit=20&search=morning
```

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Morning Warriors",
      "description": "Early morning training group",
      "image_url": null,
      "max_members": 12,
      "member_count": 3,
      "created_by": "trainer-uuid",
      "created_at": "2026-03-28T00:25:25Z",
      "updated_at": "2026-03-28T00:25:25Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 5, "total_pages": 1 }
}
```

#### Get Group Detail

```
GET /api/groups/{id}
```

#### Create Group (Admin/Trainer)

```
POST /api/groups
```

```json
{
  "name": "Morning Warriors",
  "description": "Early morning training group",
  "max_members": 12,
  "image_id": "upload-uuid"
}
```

#### Update Group (Admin/Trainer)

```
PUT /api/groups/{id}
```

#### Delete Group (Admin/Trainer)

```
DELETE /api/groups/{id}
```

#### Add Member (Admin/Trainer)

```
POST /api/groups/{id}/members
```

```json
{ "user_id": "client-uuid", "role": "member" }
```

#### List Members

```
GET /api/groups/{id}/members
```

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "member-uuid",
      "group_id": "group-uuid",
      "user_id": "user-uuid",
      "full_name": "Client Name",
      "email": "client@email.com",
      "avatar_url": null,
      "role": "member",
      "joined_at": "2026-03-28T00:25:25Z"
    }
  ]
}
```

#### Remove Member (Admin/Trainer)

```
DELETE /api/groups/{id}/members/{userId}
```

---

### Announcements

#### Get Announcement Feed (Customer)

```
GET /api/announcements/feed?page=1&limit=20&search=welcome
```

Returns only **published** announcements matching the user's role. Includes `is_read` flag.

**Response (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Welcome to Systemic Fitness!",
      "body": "We are excited to launch our new fitness platform...",
      "image_url": null,
      "status": "published",
      "target_roles": ["client", "trainer"],
      "published_at": "2026-03-21T10:00:00Z",
      "created_by": "admin-uuid",
      "created_at": "2026-03-21T10:00:00Z",
      "updated_at": "2026-03-21T10:00:00Z",
      "is_read": false
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 4, "total_pages": 1 }
}
```

#### Get Announcement Detail

```
GET /api/announcements/{id}
```

#### Mark Announcement as Read

```
POST /api/announcements/{id}/read
```

**Response (200):** `{ "success": true, "message": "Marked as read" }`

#### List Announcements (Admin)

```
GET /api/announcements?page=1&limit=20&status=published&search=welcome
```

Returns all announcements regardless of status/role.

#### Create Announcement (Admin)

```
POST /api/announcements
```

```json
{
  "title": "New Feature: Habit Tracking",
  "body": "We have added habit tracking...",
  "status": "published",
  "target_roles": ["client", "trainer"],
  "image_id": "upload-uuid"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `title` | string | Yes | 1-200 chars |
| `body` | string | Yes | |
| `status` | string | Yes | `draft`, `published`, `archived` |
| `target_roles` | string[] | No | `client`, `trainer`, `admin`, `finance` |
| `image_id` | string | No | Upload UUID |
| `image_url` | string | No | External URL fallback |

#### Update Announcement (Admin)

```
PUT /api/announcements/{id}
```

#### Delete Announcement (Admin)

```
DELETE /api/announcements/{id}
```

---

## Updated Endpoint Reference

| # | Method | Path | Auth | Role | Description |
|---|--------|------|------|------|-------------|
| 71 | GET | /api/challenges | Yes | any | List challenges (paginated, filterable) |
| 72 | POST | /api/challenges | Yes | admin, trainer | Create challenge |
| 73 | GET | /api/challenges/{id} | Yes | any | Challenge detail |
| 74 | PUT | /api/challenges/{id} | Yes | admin, trainer | Update challenge |
| 75 | DELETE | /api/challenges/{id} | Yes | admin, trainer | Delete challenge |
| 76 | POST | /api/challenges/{id}/join | Yes | any | Join challenge |
| 77 | POST | /api/challenges/{id}/leave | Yes | any | Leave challenge |
| 78 | POST | /api/challenges/{id}/progress | Yes | any | Update progress |
| 79 | GET | /api/challenges/{id}/participants | Yes | any | Leaderboard |
| 80 | GET | /api/groups | Yes | any | List groups |
| 81 | POST | /api/groups | Yes | admin, trainer | Create group |
| 82 | GET | /api/groups/{id} | Yes | any | Group detail |
| 83 | PUT | /api/groups/{id} | Yes | admin, trainer | Update group |
| 84 | DELETE | /api/groups/{id} | Yes | admin, trainer | Delete group |
| 85 | POST | /api/groups/{id}/members | Yes | admin, trainer | Add member |
| 86 | GET | /api/groups/{id}/members | Yes | any | List members |
| 87 | DELETE | /api/groups/{id}/members/{userId} | Yes | admin, trainer | Remove member |
| 88 | GET | /api/announcements/feed | Yes | any | Announcement feed (role-filtered) |
| 89 | POST | /api/announcements/{id}/read | Yes | any | Mark as read |
| 90 | GET | /api/announcements/{id} | Yes | any | Announcement detail |
| 91 | GET | /api/announcements | Yes | admin | List all announcements |
| 92 | POST | /api/announcements | Yes | admin | Create announcement |
| 93 | PUT | /api/announcements/{id} | Yes | admin | Update announcement |
| 94 | DELETE | /api/announcements/{id} | Yes | admin | Delete announcement |
| 95 | POST | /api/uploads | Yes | any | Upload image (WebP conversion) |
| 96 | GET | /api/uploads/{id} | Yes | any | Get upload detail |
| 97 | DELETE | /api/uploads/{id} | Yes | owner, admin | Delete upload |
| 98 | GET | /api/uploads/my | Yes | any | List my uploads |

---

## User Flows

### Flow 7: Client — Challenge Participation

```
1. GET  /api/challenges?status=active       → Browse active challenges
2. GET  /api/challenges/{id}                → View challenge details
3. POST /api/challenges/{id}/join           → Join the challenge
4. GET  /api/challenges/{id}/participants   → View leaderboard
   ─── During challenge ───
5. POST /api/challenges/{id}/progress       → Update progress (e.g. { "value": 150 })
6. GET  /api/challenges/{id}/participants   → Check ranking
```

### Flow 8: Client — Groups & Announcements

```
─── Groups (view only for clients) ───
1. GET  /api/groups                         → View groups I belong to
2. GET  /api/groups/{id}/members            → View group members

─── Announcements ───
3. GET  /api/announcements/feed             → View announcements for my role
4. POST /api/announcements/{id}/read        → Mark as read
```

### Flow 9: Trainer — Manage Challenges & Groups

```
─── Challenges ───
1. POST /api/challenges                     → Create a challenge
2. PUT  /api/challenges/{id}                → Update challenge details
3. GET  /api/challenges/{id}/participants   → Monitor participant progress
4. DELETE /api/challenges/{id}              → Remove challenge

─── Groups ───
5. POST /api/groups                         → Create a group
6. POST /api/groups/{id}/members            → Add clients to group
7. DELETE /api/groups/{id}/members/{userId} → Remove client from group
```

---

## Architecture

All three features follow the standard layered pattern:

```
Handler (challenge.go / group.go / announcement.go)
  ├── Input validation (struct tags + go-playground/validator)
  ├── Image resolution (image_id → upload URL, or image_url passthrough)
  └── Calls service layer

Service (challenge_service.go / group_service.go / announcement_service.go)
  ├── Business logic
  ├── Error wrapping & structured logging
  └── Calls repository layer

Repository (challenge_repo.go / group_repo.go / announcement_repo.go)
  └── SQL queries via pgx/v5
```

Image uploads are resolved through a shared `imageResolver` utility injected into each handler via the `UploadService`.
