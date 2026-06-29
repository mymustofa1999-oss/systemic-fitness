FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git gcc musl-dev

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-s -w" -o /fitcoach-api ./cmd/server

FROM alpine:3.20
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /app
COPY --from=builder /fitcoach-api .

EXPOSE 8080
CMD ["./fitcoach-api"]
