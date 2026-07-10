package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load(".env")
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres"

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer conn.Close(ctx)

	_, err = conn.Exec(ctx, "ALTER TYPE training_category ADD VALUE IF NOT EXISTS 'cd'")
	if err != nil {
		fmt.Println("Warning adding cd enum:", err)
	}
	_, err = conn.Exec(ctx, "ALTER TYPE training_category ADD VALUE IF NOT EXISTS 'mat'")
	if err != nil {
		fmt.Println("Warning adding mat enum:", err)
	}

	_, err = conn.Exec(ctx, "INSERT INTO dl_categories (code, name) VALUES ('cd', 'Cool Down') ON CONFLICT (code) DO NOTHING")
	if err != nil {
		fmt.Println("Error inserting cd:", err)
	}
	_, err = conn.Exec(ctx, "INSERT INTO dl_categories (code, name) VALUES ('mat', 'Mat') ON CONFLICT (code) DO NOTHING")
	if err != nil {
		fmt.Println("Error inserting mat:", err)
	}

	fmt.Println("Enum altered and categories inserted!")
}
