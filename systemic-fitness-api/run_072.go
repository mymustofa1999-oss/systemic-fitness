package main

import (
	"context"
	"io/ioutil"
	"log"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL must be set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Unable to connect:", err)
	}
	defer pool.Close()

	sql, err := ioutil.ReadFile("database/migrations/072_create_systemic_session_logs.sql")
	if err != nil {
		log.Fatal("Failed to read sql file:", err)
	}

	if _, err := pool.Exec(ctx, string(sql)); err != nil {
		log.Fatal("Failed to execute migration:", err)
	}

	log.Println("Successfully ran migration 072!")
}
