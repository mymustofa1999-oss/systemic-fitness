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
	dbURL := os.Getenv("DATABASE_URL")
	pool, err := pgxpool.New(context.Background(), dbURL)
	if err != nil {
		fmt.Println("Error connecting to database", err)
		return
	}
	defer pool.Close()

	_, err = pool.Exec(context.Background(), `
		UPDATE menus 
		SET is_active = false
		WHERE code = 'digital-library'
	`)
	if err != nil {
		fmt.Println("Update digital-library error", err)
		return
	}

	fmt.Println("Successfully set digital-library to inactive!")
}
