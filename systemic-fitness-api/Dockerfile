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
ENV DATABASE_URL="postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?sslmode=disable"
ENV CORS_ALLOWED_ORIGINS="*"
ENV JWT_SECRET="FitcoachSecret2026!"

EXPOSE 8080
CMD ["./fitcoach-api"]
