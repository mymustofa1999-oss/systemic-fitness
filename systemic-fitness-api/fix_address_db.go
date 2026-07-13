package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL is required")
	}

	conn, err := pgx.Connect(context.Background(), dbURL)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close(context.Background())

	query := `
		ALTER TABLE user_profiles
		ADD COLUMN IF NOT EXISTS street_address VARCHAR(255),
		ADD COLUMN IF NOT EXISTS additional_address VARCHAR(255),
		ADD COLUMN IF NOT EXISTS sub_district VARCHAR(100),
		ADD COLUMN IF NOT EXISTS district VARCHAR(100),
		ADD COLUMN IF NOT EXISTS province VARCHAR(100),
		ADD COLUMN IF NOT EXISTS postal_code VARCHAR(20),
		ADD COLUMN IF NOT EXISTS country VARCHAR(100);
	`

	_, err = conn.Exec(context.Background(), query)
	if err != nil {
		log.Fatalf("Failed to alter table: %v", err)
	}

	fmt.Println("Successfully added address columns to user_profiles table.")
}
