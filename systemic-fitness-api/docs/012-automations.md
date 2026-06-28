# 012 — Automations

## Endpoints

| Method | Path                          | Auth     | Role           |
|--------|-------------------------------|----------|----------------|
| GET    | /api/automations              | Required | admin, trainer |
| GET    | /api/automations/{id}         | Required | admin, trainer |
| POST   | /api/automations              | Required | admin, trainer |
| PUT    | /api/automations/{id}         | Required | admin, trainer |
| DELETE | /api/automations/{id}         | Required | admin, trainer |
| GET    | /api/automations/{id}/logs    | Required | admin, trainer |

---

### GET /api/automations

List automations with filters.

**Query Parameters:**
| Param        | Type   | Default    | Description                |
|--------------|--------|------------|----------------------------|
| page         | int    | 1          |                            |
| limit        | int    | 20         | max 100                    |
| search       | string |            | Search by name             |
| trigger_type | string |            | Filter by trigger type     |
| is_active    | bool   |            | Filter active/inactive     |
| sort_by      | string | created_at |                            |
| sort_order   | string | desc       |                            |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "automation-uuid",
      "name": "Welcome Message",
      "description": "Send welcome message to new signups",
      "trigger_type": "on_signup",
      "trigger_config": {},
      "action_type": "send_message",
      "action_config": {
        "message": "Welcome to FitCoach! Your journey starts here."
      },
      "is_active": true,
      "created_by": "admin-uuid",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 8, "total_pages": 1 }
}
```

---

### POST /api/automations

Create a new automation.

**Request:**
```json
{
  "name": "Inactive User Reminder",
  "description": "Send reminder after 3 days of inactivity",
  "trigger_type": "on_inactive_days",
  "trigger_config": {
    "days": 3
  },
  "action_type": "send_reminder",
  "action_config": {
    "title": "We miss you!",
    "message": "You haven't worked out in 3 days. Time to get back on track!"
  },
  "is_active": true
}
```

### Trigger Types & Configs

| Trigger               | trigger_config                          | Description                       |
|-----------------------|-----------------------------------------|-----------------------------------|
| `on_signup`           | `{}`                                    | When a new user registers         |
| `on_program_complete` | `{}`                                    | When user finishes a program      |
| `on_inactive_days`    | `{ "days": 3 }`                         | After N days without workout      |
| `scheduled`           | `{ "cron": "0 9 * * MON" }`            | Cron schedule                     |
| `on_milestone`        | `{ "type": "streak", "value": 7 }`     | When user hits a milestone        |

### Action Types & Configs

| Action              | action_config                                          | Description           |
|---------------------|--------------------------------------------------------|-----------------------|
| `send_message`      | `{ "message": "text" }`                                | Send in-app message   |
| `assign_program`    | `{ "program_id": "uuid" }`                             | Auto-assign a program |
| `send_reminder`     | `{ "title": "...", "message": "..." }`                 | Push notification     |
| `send_notification` | `{ "title": "...", "body": "...", "data": {} }`        | Custom notification   |
| `send_email`        | `{ "subject": "...", "template": "...", "vars": {} }`  | Email notification    |

**Response (201):**
```json
{
  "success": true,
  "data": { "...automation object with id..." },
  "message": "Automation created successfully"
}
```

---

### PUT /api/automations/{id}

Update automation. Partial update supported.

---

### DELETE /api/automations/{id}

Delete automation permanently.

**Response (204):** No content

---

### GET /api/automations/{id}/logs

Get execution logs for an automation.

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
      "id": "log-uuid",
      "automation_id": "automation-uuid",
      "user_id": "target-user-uuid",
      "triggered_at": "2024-01-15T09:00:00Z",
      "status": "success",
      "result": {
        "message_sent": true,
        "conversation_id": "conv-uuid"
      },
      "error_message": null
    },
    {
      "id": "log-uuid-2",
      "automation_id": "automation-uuid",
      "user_id": "target-user-uuid-2",
      "triggered_at": "2024-01-15T09:00:00Z",
      "status": "failed",
      "result": null,
      "error_message": "User not found"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 45, "total_pages": 3 }
}
```

**Log Statuses:** `success`, `failed`, `skipped`

## Scheduler (Background)

The scheduler runs as a background process started at server initialization:
- Checks for `scheduled` automations on cron intervals
- Checks for `on_inactive_days` triggers periodically
- Event-based triggers (`on_signup`, `on_program_complete`, `on_milestone`) are fired from the respective service methods
- All executions are logged to `automation_logs`
