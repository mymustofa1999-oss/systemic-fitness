# 011 — Messaging & WebSocket

## REST Endpoints

| Method | Path                                       | Auth     | Role |
|--------|--------------------------------------------|----------|------|
| POST   | /api/messages/direct                       | Required | any  |
| POST   | /api/messages/group                        | Required | any  |
| POST   | /api/messages/send                         | Required | any  |
| GET    | /api/messages/conversations                | Required | any  |
| GET    | /api/messages/conversations/{id}           | Required | any  |
| POST   | /api/messages/conversations/{id}/read      | Required | any  |

## WebSocket Endpoint

| Protocol | Path                         | Auth              |
|----------|------------------------------|--------------------|
| WS       | /ws/messages?token=JWT_TOKEN | JWT via query param|

---

### POST /api/messages/direct

Get or create a direct (1-to-1) conversation with a user.

**Request:**
```json
{
  "user_id": "target-user-uuid"
}
```

**Response (200 or 201):**
```json
{
  "success": true,
  "data": {
    "id": "conversation-uuid",
    "type": "direct",
    "name": null,
    "members": [
      {
        "user_id": "my-uuid",
        "full_name": "John Doe",
        "avatar_url": null,
        "role": "member"
      },
      {
        "user_id": "target-user-uuid",
        "full_name": "Jane Smith",
        "avatar_url": "https://...",
        "role": "member"
      }
    ],
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

If a direct conversation already exists between the two users, it returns the existing one.

---

### POST /api/messages/group

Create a group conversation.

**Request:**
```json
{
  "name": "Team Alpha Training",
  "user_ids": ["user-uuid-1", "user-uuid-2", "user-uuid-3"]
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "conversation-uuid",
    "type": "group",
    "name": "Team Alpha Training",
    "members": [
      { "user_id": "my-uuid", "full_name": "Trainer", "role": "admin" },
      { "user_id": "user-uuid-1", "full_name": "Client 1", "role": "member" },
      { "user_id": "user-uuid-2", "full_name": "Client 2", "role": "member" },
      { "user_id": "user-uuid-3", "full_name": "Client 3", "role": "member" }
    ],
    "created_at": "2024-01-15T00:00:00Z"
  },
  "message": "Group created successfully"
}
```

The creator automatically gets the "admin" member role.

---

### POST /api/messages/send

Send a message to a conversation. Validates that sender is a member.

**Request:**
```json
{
  "conversation_id": "conversation-uuid",
  "content": "Great workout today! Keep it up!",
  "type": "text",
  "media_url": null
}
```

**Message Types:**
| Type   | Description              | media_url |
|--------|--------------------------|-----------|
| text   | Text message             | null      |
| image  | Image attachment         | required  |
| voice  | Voice note               | required  |
| system | System-generated message | null      |

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "message-uuid",
    "conversation_id": "conversation-uuid",
    "sender_id": "my-uuid",
    "content": "Great workout today! Keep it up!",
    "type": "text",
    "media_url": null,
    "is_read": false,
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**Side Effects:**
- Broadcasts message to all online conversation members via WebSocket
- Updates `conversations.updated_at` (auto-trigger)

---

### GET /api/messages/conversations

List current user's conversations.

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
      "id": "conv-uuid-1",
      "type": "direct",
      "name": null,
      "last_message": {
        "content": "See you tomorrow!",
        "sender_name": "Jane Smith",
        "created_at": "2024-01-15T18:00:00Z"
      },
      "unread_count": 3,
      "members": [
        { "user_id": "uuid", "full_name": "Jane Smith", "avatar_url": "..." }
      ],
      "updated_at": "2024-01-15T18:00:00Z"
    },
    {
      "id": "conv-uuid-2",
      "type": "group",
      "name": "Team Alpha Training",
      "last_message": {
        "content": "New program starts Monday",
        "sender_name": "Trainer",
        "created_at": "2024-01-15T14:00:00Z"
      },
      "unread_count": 0,
      "members": [
        { "user_id": "uuid", "full_name": "Client 1", "avatar_url": null },
        { "user_id": "uuid", "full_name": "Client 2", "avatar_url": null }
      ],
      "updated_at": "2024-01-15T14:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 5, "total_pages": 1 }
}
```

Ordered by `updated_at DESC` (most recent conversation first).

---

### GET /api/messages/conversations/{id}

Get messages in a conversation (paginated, newest first).

**Query Parameters:**
| Param | Type | Default | Description     |
|-------|------|---------|-----------------|
| page  | int  | 1       |                 |
| limit | int  | 50      | max 100         |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "conversation": {
      "id": "conv-uuid",
      "type": "direct",
      "name": null,
      "members": [...]
    },
    "messages": [
      {
        "id": "msg-uuid-3",
        "sender_id": "user-uuid-2",
        "sender_name": "Jane Smith",
        "sender_avatar": "https://...",
        "content": "See you tomorrow!",
        "type": "text",
        "media_url": null,
        "is_read": false,
        "created_at": "2024-01-15T18:00:00Z"
      },
      {
        "id": "msg-uuid-2",
        "sender_id": "my-uuid",
        "sender_name": "John Doe",
        "sender_avatar": null,
        "content": "Sounds good!",
        "type": "text",
        "media_url": null,
        "is_read": true,
        "created_at": "2024-01-15T17:55:00Z"
      }
    ]
  },
  "meta": { "page": 1, "limit": 50, "total": 25, "total_pages": 1 }
}
```

---

### POST /api/messages/conversations/{id}/read

Mark all messages in a conversation as read (updates `last_read_at`).

**Response (200):**
```json
{
  "success": true,
  "message": "Messages marked as read"
}
```

---

## WebSocket Protocol

### Connection

```
ws://localhost:8080/ws/messages?token=<JWT_ACCESS_TOKEN>
```

JWT is passed as query parameter for WebSocket upgrade.

### Events (Server → Client)

**On Connect — Unread Count:**
```json
{
  "type": "unread_count",
  "data": {
    "count": 5
  }
}
```

**New Message:**
```json
{
  "type": "new_message",
  "data": {
    "id": "message-uuid",
    "conversation_id": "conv-uuid",
    "sender_id": "user-uuid",
    "sender_name": "Jane Smith",
    "content": "Hello!",
    "type": "text",
    "media_url": null,
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**User Online/Offline:**
```json
{
  "type": "user_online",
  "data": {
    "user_id": "user-uuid"
  }
}
```

```json
{
  "type": "user_offline",
  "data": {
    "user_id": "user-uuid"
  }
}
```

### Connection Rules

- One WebSocket connection per user (new connection replaces old)
- Messages are broadcast to all online members of the conversation
- Connection requires valid JWT (validated on upgrade)
- Ping/pong keepalive for connection health
