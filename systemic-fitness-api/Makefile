.PHONY: run build test lint tidy

run: ## Run the API server
	go run ./cmd/server

build: ## Build the binary
	CGO_ENABLED=0 go build -ldflags="-s -w" -o bin/fitcoach-api ./cmd/server

test: ## Run all tests
	go test -v -race ./...

lint: ## Run golangci-lint
	golangci-lint run ./...

tidy: ## Tidy and verify dependencies
	go mod tidy
	go mod verify

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
