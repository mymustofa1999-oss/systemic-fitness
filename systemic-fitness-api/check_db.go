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

	var total int
	err = conn.QueryRow(ctx, "SELECT count(*) FROM dl_movements").Scan(&total)
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Println("Total dl_movements:", total)
	}

	var withVideo int
	err = conn.QueryRow(ctx, "SELECT count(*) FROM dl_movements WHERE video_url_male IS NOT NULL OR video_url_female IS NOT NULL").Scan(&withVideo)
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Println("With video:", withVideo)
	}
}
