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
	rows, _ := pool.Query(context.Background(), "SELECT level FROM trainer_card_templates")
	defer rows.Close()
	for rows.Next() {
		var lvl string
		rows.Scan(&lvl)
		fmt.Println(lvl)
	}
}
