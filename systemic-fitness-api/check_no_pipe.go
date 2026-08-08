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
	
	rows, _ := pool.Query(context.Background(), "SELECT id, name, COALESCE(video_url_male, ''), COALESCE(video_url_female, '') FROM dl_movements WHERE name LIKE 'http%' AND name NOT LIKE '%|%'")
	for rows.Next() {
		var id, name, male, female string
		rows.Scan(&id, &name, &male, &female)
		fmt.Printf("Name: %s\nMale: %s\nFemale: %s\n\n", name, male, female)
	}
}
