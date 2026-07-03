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

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Failed to connect to db: ", err)
	}
	defer pool.Close()

	// Find the level_id for level 4
	var levelID string
	err = pool.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = 4").Scan(&levelID)
	if err != nil {
		log.Fatal("No level 4 found: ", err)
	}

	rows, err := pool.Query(ctx, "SELECT id, category_code, set_name FROM dl_menu_items WHERE level_id = $1", levelID)
	if err != nil {
		log.Fatal("Query error: ", err)
	}
	defer rows.Close()

	count := 0
	for rows.Next() {
		var id, code string
		var setName *string
		if err := rows.Scan(&id, &code, &setName); err != nil {
			log.Fatal(err)
		}
		sName := "nil"
		if setName != nil {
			sName = *setName
		}
		fmt.Printf("Item %d: ID=%s, Code=%s, Set=%s\n", count+1, id, code, sName)
		count++
	}
	fmt.Printf("Total items for Level 4: %d\n", count)
}
