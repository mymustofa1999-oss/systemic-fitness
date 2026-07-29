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

	// Move them to top level and update sort_order
	_, err = pool.Exec(context.Background(), `
		UPDATE menus 
		SET parent_id = NULL, sort_order = 8
		WHERE code = 'digital-library'
	`)
	if err != nil {
		fmt.Println("Update digital-library error", err)
		return
	}
	
	_, err = pool.Exec(context.Background(), `
		UPDATE menus 
		SET parent_id = NULL, sort_order = 9
		WHERE code = 'modul-card'
	`)
	if err != nil {
		fmt.Println("Update modul-card error", err)
		return
	}

	fmt.Println("Successfully moved digital-library and modul-card to top level!")
}
