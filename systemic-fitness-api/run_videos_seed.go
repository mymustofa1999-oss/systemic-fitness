package main

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load(".env")
	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		fmt.Println("DATABASE_URL not found")
		os.Exit(1)
	}

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, dbUrl)
	if err != nil {
		fmt.Println("Unable to connect to database:", err)
		os.Exit(1)
	}
	defer conn.Close(ctx)

	files := []string{
		"database/seeds/008_seed_new_features.sql",
		"database/seeds/009_seed_digital_library.sql",
	}

	for _, file := range files {
		content, err := os.ReadFile(file)
		if err != nil {
			fmt.Printf("Skipping %s: %v\n", file, err)
			continue
		}
		
		fmt.Printf("Executing %s...\n", file)
		
		_, err = conn.Exec(ctx, string(content))
		if err != nil {
			fmt.Printf("Error executing %s: %v\n", file, err)
		} else {
			fmt.Printf("Success executing %s\n", file)
		}
	}
	
	fmt.Println("Done!")
}
