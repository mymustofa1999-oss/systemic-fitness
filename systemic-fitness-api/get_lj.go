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
	var id, name, male, female string
	err := pool.QueryRow(context.Background(), "SELECT id, name, COALESCE(video_url_male, ''), COALESCE(video_url_female, '') FROM dl_movements WHERE name LIKE '%lj1diXjbLic%'").Scan(&id, &name, &male, &female)
	if err != nil { fmt.Println(err); return }
	fmt.Printf("ID: %s\nName: %s\nMale: %s\nFemale: %s\n", id, name, male, female)
}
