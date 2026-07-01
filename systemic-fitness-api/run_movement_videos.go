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
	
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres"

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		fmt.Println("Unable to connect to database:", err)
		os.Exit(1)
	}
	defer conn.Close(ctx)

	files := []string{
		"movement_videos.sql",
		"movement_videos_fix.sql",
		"movement_videos_v2.sql",
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
