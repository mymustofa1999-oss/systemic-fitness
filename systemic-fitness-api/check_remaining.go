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
	pool, _ := pgxpool.New(context.Background(), os.Getenv("DATABASE_URL"))
	
	rows, _ := pool.Query(context.Background(), "SELECT id, name FROM dl_movements WHERE name LIKE '%http%' LIMIT 10")
	count := 0
	for rows.Next() {
		var id, name string
		rows.Scan(&id, &name)
		fmt.Printf("Remaining: %s\n", name)
		count++
	}
	fmt.Printf("Total remaining found: %d\n", count)
}
