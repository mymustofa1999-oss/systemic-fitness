package main

import (
	"context"
	"io/ioutil"
	"log"
	"os"
	"strings"

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

	sqlBytes, err := ioutil.ReadFile("database/migrations/073_remove_my_clients_menu.sql")
	if err != nil {
		log.Fatal("Failed to read sql file:", err)
	}

	// Just execute the whole file as it's an UP migration.
    sql := string(sqlBytes)
    upQuery := strings.Split(sql, "-- +migrate Down")[0]
	upQuery = strings.Replace(upQuery, "-- +migrate Up", "", -1)

	if _, err := pool.Exec(ctx, upQuery); err != nil {
		log.Fatal("Failed to execute migration:", err)
	}

	log.Println("Successfully ran migration 073!")
}
