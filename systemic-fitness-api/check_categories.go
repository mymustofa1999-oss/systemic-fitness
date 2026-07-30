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
	rows, _ := pool.Query(context.Background(), "SELECT id, code, label FROM program_categories")
	defer rows.Close()
	for rows.Next() {
		var id, code, label string
		rows.Scan(&id, &code, &label)
		fmt.Println(code, label, id)
	}
}
