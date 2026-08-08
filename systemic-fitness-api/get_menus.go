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
	godotenv.Load()
	dbURL := os.Getenv("DATABASE_URL")
	pool, err := pgxpool.New(context.Background(), dbURL)
    if err != nil {
        log.Fatal(err)
    }
	rows, _ := pool.Query(context.Background(), "SELECT code, label FROM menus WHERE label = 'My Clients' OR label = 'Clients'")
	for rows.Next() {
		var code, label string
		rows.Scan(&code, &label)
		fmt.Printf("%s: %s\n", code, label)
	}
}
