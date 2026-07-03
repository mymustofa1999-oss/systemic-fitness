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
	if err := godotenv.Load("c:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-api/.env"); err != nil {
		log.Println("No .env file found or error loading it")
	}
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL is required")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Failed to connect to db: ", err)
	}
	defer pool.Close()

	rows, err := pool.Query(ctx, "SELECT id, name, body_part, pattern FROM dl_movements LIMIT 10")
	if err != nil {
		log.Fatal("Failed to query: ", err)
	}
	defer rows.Close()

	count := 0
	for rows.Next() {
		var id, name, bp string
		var pattern *string
		if err := rows.Scan(&id, &name, &bp, &pattern); err != nil {
			log.Fatal(err)
		}
		p := "NULL"
		if pattern != nil {
			p = *pattern
		}
		fmt.Printf("Movement: ID=%s, Name=%s, BodyPart=%s, Pattern=%s\n", id, name, bp, p)
		count++
	}
	fmt.Printf("Total checked: %d\n", count)
}
