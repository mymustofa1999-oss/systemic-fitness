# API — Go REST API

FitCoach Platform REST API built with Go 1.22+ and clean architecture.

## Tech Stack

| Component   | Library                    |
|-------------|----------------------------|
| Router      | chi/v5                     |
| Database    | pgx/v5 (PostgreSQL)        |
| Auth        | golang-jwt/v5 (JWT)        |
| Validation  | go-playground/validator    |
| Config      | godotenv                   |
| Logger      | slog (stdlib)              |
| WebSocket   | gorilla/websocket          |
| Scheduler   | robfig/cron/v3             |
| Password    | bcrypt (x/crypto)          |

## Architecture

```
api/
├── cmd/server/main.go         # Entry point, DI, routing, graceful shutdown
├── internal/
│   ├── config/                # Environment config loader
│   ├── middleware/            # Auth JWT, RBAC, Logger, CORS
│   ├── handler/               # HTTP handlers (10 domain handlers)
│   ├── service/               # Business logic layer
│   ├── repository/            # Database queries (pgx)
│   ├── model/                 # Domain models, enums, pagination
│   ├── ws/                    # WebSocket hub + client
│   └── scheduler/             # Cron-based automation runner
├── pkg/
│   ├── response/              # Standard JSON response helpers
│   └── utils/                 # Password hashing, JWT manager
├── go.mod
├── Dockerfile
└── .env.example
```

## Setup

```bash
cp .env.example .env
go mod download
go run ./cmd/server
```

## Routing & Access Control

| Route Group          | Auth     | Roles Allowed              |
|----------------------|----------|----------------------------|
| `/api/auth/*`        | Public   | —                          |
| `/api/auth/me`       | JWT      | Any authenticated          |
| `/api/users/*`       | JWT      | owner, admin               |
| `/api/exercises/*`   | JWT      | Any (create: admin/trainer)|
| `/api/workouts/*`    | JWT      | Any (write: admin/trainer) |
| `/api/programs/*`    | JWT      | Any (write: admin/trainer) |
| `/api/progress/*`    | JWT      | Self or admin/trainer      |
| `/api/nutrition/*`   | JWT      | Self or admin/trainer      |
| `/api/messages/*`    | JWT      | Any authenticated          |
| `/api/automations/*` | JWT      | owner, admin, trainer      |
| `/api/dashboard/*`   | JWT      | owner, admin, finance      |
| `/api/payments/*`    | JWT      | owner, finance             |
| `/ws/messages`       | Token QS | Any authenticated          |

## File Count

- **44 Go files**, ~4,600 lines
- 10 handler files, 10 service files, 9 repository files
- 4 middleware (auth, RBAC, logger, CORS)
