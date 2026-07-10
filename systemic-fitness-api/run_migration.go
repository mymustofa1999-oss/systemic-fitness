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
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, relying on environment variables")
	}

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL must be set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer pool.Close()

	// 065
	sql1, err := ioutil.ReadFile("database/migrations/065_add_attachment_to_subscriptions.sql")
	if err == nil {
		upQuery := strings.Split(string(sql1), "-- +migrate Down")[0]
		upQuery = strings.Replace(upQuery, "-- +migrate Up", "", -1)
		if _, err := pool.Exec(ctx, upQuery); err != nil {
			log.Println("Error running 065:", err)
		} else {
			log.Println("Success running 065")
		}
	}

	// 066
	sql2, err := ioutil.ReadFile("database/migrations/066_add_medicine_columns.sql")
	if err == nil {
		upQuery := strings.Split(string(sql2), "-- +migrate Down")[0]
		upQuery = strings.Replace(upQuery, "-- +migrate Up", "", -1)
		if _, err := pool.Exec(ctx, upQuery); err != nil {
			log.Println("Error running 066:", err)
		} else {
			log.Println("Success running 066")
		}
	}
}
