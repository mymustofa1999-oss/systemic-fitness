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
	
	var withPipe int
	pool.QueryRow(context.Background(), "SELECT COUNT(*) FROM dl_movements WHERE name LIKE 'http%' AND name LIKE '%|%'").Scan(&withPipe)
	
	var withoutPipe int
	pool.QueryRow(context.Background(), "SELECT COUNT(*) FROM dl_movements WHERE name LIKE 'http%' AND name NOT LIKE '%|%'").Scan(&withoutPipe)
	
	fmt.Printf("With Pipe: %d, Without Pipe: %d\n", withPipe, withoutPipe)
}
