package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load("c:/Users/ITBDG/Documents/SystemicFitness-Handover/CLEAN/systemic-fitness-api/.env")
	dbURL := os.Getenv("DATABASE_URL")
	
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()

	customerID := "2191ef1d-f404-4da1-b125-a005d6ae1dc4"

	var cardID, status string
	err = pool.QueryRow(ctx, "SELECT id, status FROM trainer_cards WHERE customer_id = $1", customerID).Scan(&cardID, &status)
	if err != nil {
		log.Fatal("Training card not found or error: ", err)
	}
	fmt.Printf("Training Card ID: %s, Status: %s\n", cardID, status)

	rows, _ := pool.Query(ctx, "SELECT level FROM trainer_card_templates")
	defer rows.Close()
	fmt.Print("Available template levels: ")
	for rows.Next() {
		var lvl string
		rows.Scan(&lvl)
		fmt.Printf("%s, ", lvl)
	}
	fmt.Println()
}
