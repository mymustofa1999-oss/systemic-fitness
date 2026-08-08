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
	rows, _ := pool.Query(context.Background(), "SELECT id, name, video_url_male, video_url_female FROM dl_movements WHERE name LIKE '%Ij1diXjbLic%'")
	for rows.Next() {
		var id, name, male, female string
		rows.Scan(&id, &name, &male, &female)
		fmt.Printf("ID: %s\nName: %s\nMale: %s\nFemale: %s\n", id, name, male, female)
	}
	
	fmt.Println("--- NO PIPE ---")
	rows2, _ := pool.Query(context.Background(), "SELECT id, name FROM dl_movements WHERE name LIKE 'http%' AND name NOT LIKE '%|%' LIMIT 5")
	for rows2.Next() {
		var id, name string
		rows2.Scan(&id, &name)
		fmt.Printf("ID: %s\nName: %s\n", id, name)
	}
}
