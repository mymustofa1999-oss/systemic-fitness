package main

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()
	dbURL := os.Getenv("DATABASE_URL")
	pool, err := pgxpool.New(context.Background(), dbURL)
	if err != nil {
		fmt.Println("Error connecting to database", err)
		return
	}
	defer pool.Close()
	ctx := context.Background()

	_, err = pool.Exec(ctx, "ALTER TABLE trainer_card_templates ALTER COLUMN level TYPE VARCHAR(50)")
	if err != nil {
		fmt.Println("Error altering table", err)
	} else {
		fmt.Println("Success altering table")
	}
}
