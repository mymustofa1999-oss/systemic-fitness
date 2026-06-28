# 017 — Notifications & FCM (Push Notifications)

## Overview

The notification system supports:
- **Push notifications** via Firebase Cloud Messaging (FCM HTTP v1 API)
- **In-app notification center** with read/unread status
- **Broadcast/promo notifications** to all users or filtered by roles
- **Automated notifications** via the scheduler (workout reminders, payment due, etc.)

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│ Automation   │────→│ Notification │────→│ FCM HTTP v1 │────→ Android/iOS
│ Scheduler    │     │ Service      │     │ Client      │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
┌─────────────┐            │              ┌─────────────┐
│ Admin API   │────────────┘              │ PostgreSQL  │
│ (broadcast) │                           │ device_tokens│
└─────────────┘                           │ notifications│
                                          └─────────────┘
```

## Setup

### 1. Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create/select project
3. Go to **Project Settings → Service Accounts**
4. Click **Generate new private key** → download JSON file
5. Place the file in the API root (e.g., `./firebase-service-account.json`)
6. **Add to .gitignore** — never commit this file!

### 2. Environment Variable

```env
# .env
FCM_CREDENTIALS_FILE=./firebase-service-account.json
```

If `FCM_CREDENTIALS_FILE` is empty, the API runs in **noop mode** — push notifications are logged but not actually sent (useful for development).

### 3. Database Migration

Run migration `011_create_notifications.sql` which creates:
- `device_tokens` — FCM token registry per user/device
- `notifications` — In-app notification history
- `broadcast_notifications` — Promo/announcement broadcast records

---

## API Endpoints

| Method | Path | Auth | Role | Description |
|--------|------|------|------|-------------|
| POST | /api/notifications/device-token | Yes | any | Register FCM token |
| DELETE | /api/notifications/device-token | Yes | any | Unregister FCM token (logout) |
| GET | /api/notifications | Yes | any | List user's notifications |
| GET | /api/notifications/unread-count | Yes | any | Get unread count |
| POST | /api/notifications/{id}/read | Yes | any | Mark one as read |
| POST | /api/notifications/read-all | Yes | any | Mark all as read |
| POST | /api/notifications/broadcast | Yes | admin | Send broadcast/promo |
| GET | /api/notifications/broadcasts | Yes | admin | List broadcast history |

---

### POST /api/notifications/device-token

Register device FCM token. Call this on:
- App launch (after login)
- Token refresh (FCM may rotate tokens)

**Request:**
```json
{
  "token": "fcm-device-token-string...",
  "platform": "android",
  "device_name": "Samsung Galaxy S24"
}
```

**Validation:**
- `token` — required
- `platform` — required, one of: `android`, `ios`, `web`
- `device_name` — optional

**Response (200):**
```json
{
  "success": true,
  "data": { "status": "registered" }
}
```

If the token already exists (e.g., reinstall), it gets reassigned to the current user.

---

### DELETE /api/notifications/device-token

Unregister token on logout (stops push to this device).

**Request:**
```json
{
  "token": "fcm-device-token-string..."
}
```

**Response (204):** No content

---

### GET /api/notifications

List user's in-app notifications (notification center).

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page | int | 1 | |
| limit | int | 20 | max 100 |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "notif-uuid",
      "user_id": "user-uuid",
      "title": "Waktunya Latihan!",
      "body": "Push Day A menunggu kamu hari ini",
      "type": "workout_reminder",
      "data": {
        "type": "workout_reminder",
        "target_id": "workout-uuid"
      },
      "status": "unread",
      "sent_via_push": true,
      "push_sent_at": "2024-01-15T08:00:00Z",
      "read_at": null,
      "created_at": "2024-01-15T08:00:00Z"
    },
    {
      "id": "notif-uuid-2",
      "title": "Streak 7 Hari!",
      "body": "Keren! Kamu sudah latihan 7 hari berturut-turut",
      "type": "milestone",
      "data": { "type": "milestone" },
      "status": "read",
      "sent_via_push": true,
      "read_at": "2024-01-14T10:00:00Z",
      "created_at": "2024-01-14T08:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 25, "total_pages": 2 }
}
```

---

### GET /api/notifications/unread-count

**Response (200):**
```json
{
  "success": true,
  "data": { "unread_count": 5 }
}
```

---

### POST /api/notifications/{id}/read

Mark a single notification as read.

**Response (200):**
```json
{
  "success": true,
  "data": { "status": "read" }
}
```

---

### POST /api/notifications/read-all

Mark all user's notifications as read.

**Response (200):**
```json
{
  "success": true,
  "data": { "status": "all_read" }
}
```

---

### POST /api/notifications/broadcast

Send a push notification to all users or filtered by roles (admin only).

**Request:**
```json
{
  "title": "Promo Akhir Tahun!",
  "body": "Diskon 50% untuk semua paket Pro. Berlaku sampai 31 Desember.",
  "type": "promo",
  "data": {
    "type": "promo",
    "target_id": "plan-uuid"
  },
  "target_roles": ["client", "trainer"],
  "image_url": "https://example.com/promo-banner.jpg"
}
```

**Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | yes | Notification title (max 200) |
| body | string | yes | Notification body |
| type | string | yes | `promo`, `announcement`, `maintenance`, `general` |
| data | object | no | Deep link payload |
| target_roles | string[] | no | Empty = all users |
| image_url | string | no | Promo banner image |

**Response (201):**
```json
{
  "success": true,
  "data": { "status": "broadcast_sent" },
  "message": "Broadcast sent successfully"
}
```

---

### GET /api/notifications/broadcasts

List broadcast history (admin only).

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "broadcast-uuid",
      "title": "Promo Akhir Tahun!",
      "body": "Diskon 50%...",
      "type": "promo",
      "target_roles": ["client", "trainer"],
      "image_url": "https://example.com/promo.jpg",
      "scheduled_at": null,
      "sent_at": "2024-12-20T09:00:00Z",
      "sent_count": 150,
      "created_by": "admin-uuid",
      "created_at": "2024-12-20T09:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 10, "total_pages": 1 }
}
```

---

## Notification Types

| Type | Trigger | Description |
|------|---------|-------------|
| `workout_reminder` | `on_inactive_days` / `scheduled` | Reminder to workout |
| `program_reminder` | `scheduled` | Daily program schedule |
| `subscription_expiring` | `scheduled` | Subscription about to expire |
| `payment_due` | `scheduled` | Payment reminder |
| `new_message` | Real-time | New chat message |
| `milestone` | `on_milestone` | Achievement unlocked |
| `promo` | Admin broadcast | Promotional offer |
| `announcement` | Admin broadcast | Platform announcement |
| `maintenance` | Admin broadcast | Maintenance notice |
| `general` | Various | Generic notification |

## Push Notification Payload Format

Every FCM push includes a `data` field for deep linking:

```json
{
  "notification": {
    "title": "Waktunya Latihan!",
    "body": "Push Day A menunggu kamu hari ini"
  },
  "data": {
    "type": "workout_reminder",
    "target_id": "workout-uuid"
  },
  "android": {
    "priority": "high",
    "notification": { "sound": "default" }
  },
  "apns": {
    "payload": {
      "aps": { "sound": "default", "badge": 1 }
    }
  }
}
```

## FCM Token Lifecycle

```
App Launch → getToken() → POST /api/notifications/device-token
                                │
Token Refresh (FCM rotates) → POST /api/notifications/device-token (upsert)
                                │
Logout → DELETE /api/notifications/device-token
                                │
Push fails (404/410) → Server auto-deactivates token
```

## Development Mode (Noop)

When `FCM_CREDENTIALS_FILE` is empty:
- FCM client runs in **noop mode**
- Push notifications are **logged** to stdout but NOT sent
- In-app notifications are still saved to database
- All API endpoints work normally
