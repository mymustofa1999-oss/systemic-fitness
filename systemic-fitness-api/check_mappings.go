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
	defer pool.Close()
	rows, _ := pool.Query(context.Background(), "SELECT code, name FROM program_categories")
	defer rows.Close()
	for rows.Next() {
		var code, name string
		rows.Scan(&code, &name)
		fmt.Println(code, "-", name)
	}
	
	fmt.Println("\nTrainer Card Types:")
	rows2, _ := pool.Query(context.Background(), "SELECT code, name FROM trainer_card_types")
	defer rows2.Close()
	for rows2.Next() {
		var code, name string
		rows2.Scan(&code, &name)
		fmt.Println(code, "-", name)
	}
}
