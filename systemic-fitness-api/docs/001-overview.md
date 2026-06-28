# 001 — Project Overview & Architecture

## Tech Stack

| Layer       | Technology                     |
|-------------|--------------------------------|
| Language    | Go 1.22+                       |
| Router      | Chi v5                         |
| Database    | PostgreSQL 16 + pgxpool (pgx)  |
| Cache       | Redis                          |
| Auth        | JWT (HS256) + bcrypt           |
| WebSocket   | gorilla/websocket              |
| Validation  | go-playground/validator        |
| Logging     | slog (structured)              |
| Config      | godotenv                       |

## Layered Architecture

```
┌─────────────────────────────────────────────────┐
│                   HTTP Client                    │
├─────────────────────────────────────────────────┤
│  Middleware (CORS → Logger → Auth → RBAC)        │
├─────────────────────────────────────────────────┤
│  Handler Layer   (/internal/handler/)            │
│  - Parse request, validate input, return JSON    │
├─────────────────────────────────────────────────┤
│  Service Layer   (/internal/service/)            │
│  - Business logic, authorization, orchestration  │
├─────────────────────────────────────────────────┤
│  Repository Layer (/internal/repository/)        │
│  - SQL queries, database access, pgx            │
├─────────────────────────────────────────────────┤
│  PostgreSQL + Redis                              │
└─────────────────────────────────────────────────┘
```

## Project Structure

```
systemic-fitness-api/
├── cmd/server/main.go          # Entry point, wiring, graceful shutdown
├── database/migrations/        # 001-010 SQL migration files
├── internal/
│   ├── config/config.go        # Env-based configuration
│   ├── handler/                # HTTP handlers (auth, user, workout, etc.)
│   ├── middleware/              # auth, rbac, cors, logger
│   ├── model/models.go         # Domain models, enums, DTOs
│   ├── repository/             # Database access layer
│   ├── scheduler/              # Background job automation
│   ├── service/                # Business logic layer
│   └── ws/                     # WebSocket hub & client
├── pkg/
│   ├── response/response.go    # Standard JSON response envelope
│   └── utils/                  # JWT manager, password hashing
├── .env                        # Environment variables
├── go.mod / go.sum             # Dependencies
└── docs/                       # This documentation
```

## Response Envelope (All Endpoints)

```json
{
  "success": true,
  "data": { ... },
  "message": "optional message",
  "errors": ["validation error 1", "..."],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

## Role Hierarchy

| Role    | Level | Access Scope                          |
|---------|-------|---------------------------------------|
| owner   | 100   | Full system access, bypasses all RBAC |
| admin   | 80    | Manage users, exercises, programs     |
| finance | 60    | Payments, subscriptions, reports      |
| trainer | 40    | Manage assigned clients only          |
| client  | 20    | Own data, workouts, progress          |

## HTTP Status Codes

| Code | Usage                              |
|------|------------------------------------|
| 200  | Success (GET, PUT)                 |
| 201  | Created (POST)                     |
| 204  | No Content (DELETE)                |
| 400  | Bad Request / Validation Error     |
| 401  | Unauthorized (missing/invalid JWT) |
| 403  | Forbidden (insufficient role)      |
| 404  | Not Found                          |
| 409  | Conflict (duplicate email, etc.)   |
| 500  | Internal Server Error              |
