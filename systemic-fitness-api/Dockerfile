FROM golang:alpine AS builder

RUN apk add --no-cache git gcc musl-dev

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-s -w" -o /fitcoach-api ./cmd/server

FROM alpine:3.19
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /app
COPY --from=builder /fitcoach-api .

ENV ENV="production"
ENV UPLOAD_DIR="/app/uploads"
# Secrets should be provided at runtime via environment variables (e.g. Railway variables)
# DATABASE_URL, CORS_ALLOWED_ORIGINS, JWT_SECRET must be set in the deployment platform.

RUN mkdir -p /app/uploads


EXPOSE 8080
CMD ["./fitcoach-api"]
