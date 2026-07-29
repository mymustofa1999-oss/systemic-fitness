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
		log.Fatal("Unable to connect to database:", err)
	}
	defer pool.Close()

	sql, err := ioutil.ReadFile("database/migrations/071_seed_consultant_nested_menus.sql")
	if err != nil {
		log.Fatal("Error reading 071:", err)
	}

	if _, err := pool.Exec(ctx, string(sql)); err != nil {
		log.Fatal("Error running 071:", err)
	}
	log.Println("Success running 071")
}
