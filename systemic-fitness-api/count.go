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
	var count int
	pool.QueryRow(context.Background(), "SELECT COUNT(*) FROM dl_movements WHERE name LIKE 'http%'").Scan(&count)
	fmt.Printf("Count: %d\n", count)
}
