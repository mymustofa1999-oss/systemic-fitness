FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git gcc musl-dev

WORKDIR /app
COPY systemic-fitness-api/go.mod systemic-fitness-api/go.sum ./
RUN go mod download

COPY systemic-fitness-api/ ./
RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-s -w" -o /fitcoach-api ./cmd/server

FROM alpine:3.20
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /app
COPY --from=builder /fitcoach-api .
COPY systemic-fitness-api/.env.example .env

EXPOSE 8080
CMD ["./fitcoach-api"]
