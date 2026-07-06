package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load("c:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-api/.env")
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL is required")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Failed to connect to db: ", err)
	}
	defer pool.Close()

	_, err = pool.Exec(ctx, `
		ALTER TABLE trainer_cards ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'draft';
		CREATE INDEX IF NOT EXISTS idx_trainer_cards_status ON trainer_cards(status);
	`)
	if err != nil {
		log.Fatal("Failed to alter trainer_cards: ", err)
	}

	fmt.Println("Successfully added status column to trainer_cards")
}
