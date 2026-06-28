# 002 — Setup & Configuration

## Environment Variables (.env)

```env
# Server
PORT=8080
ENV=development              # development | staging | production

# Database (PostgreSQL)
DATABASE_URL=postgres://fitcoach:fitcoach@localhost:5432/fitcoach?sslmode=disable
DB_MAX_CONNS=20
DB_MIN_CONNS=5

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=change-me-in-production-use-64-char-random-string
JWT_ACCESS_EXPIRY=15m        # Access token lifetime
JWT_REFRESH_EXPIRY=168h      # Refresh token lifetime (7 days)

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# Bcrypt
BCRYPT_COST=12               # Password hashing cost

# File Upload
MAX_UPLOAD_SIZE_MB=10
UPLOAD_DIR=./uploads
```

## Prerequisites

1. **Go 1.22+** installed
2. **PostgreSQL 16** running on port 5432
3. **Redis** running on port 6379
4. Database `fitcoach` created with user `fitcoach`

## Running the Server

```bash
# 1. Clone & install dependencies
cd systemic-fitness-api
go mod download

# 2. Create database
createdb fitcoach

# 3. Run migrations (applied automatically or manually)
# Migrations are in database/migrations/ (001-010)

# 4. Start server
go run cmd/server/main.go
# Server starts on http://localhost:8080
```

## Startup Flow (main.go)

```
1. Load .env → config.Load()
2. Connect PostgreSQL → pgxpool.New()
3. Initialize JWT Manager
4. Initialize WebSocket Hub → ws.NewHub()
5. Create all Repositories (inject db pool)
6. Create all Services (inject repos + jwt)
7. Create all Handlers (inject services)
8. Setup Chi Router with middleware chain
9. Register all route groups
10. Start HTTP server with graceful shutdown (30s timeout)
```

## Middleware Chain (Applied Order)

```
Global:
  1. CORS
  2. RequestLogger
  3. Recoverer (panic recovery)
  4. RealIP

Per-Route Group:
  5. Auth (JWT validation → sets user_id, email, role in context)
  6. RequireRole / RequireMinRole / RequireSelfOrRole
```
