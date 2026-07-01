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

	rows, err := conn.Query(ctx, "SELECT name, type, pattern, level FROM dl_movements LIMIT 5")
	if err != nil {
		fmt.Println("Error:", err)
		os.Exit(1)
	}
	defer rows.Close()

	for rows.Next() {
		var name string
		var typ, pattern *string
		var level *int
		rows.Scan(&name, &typ, &pattern, &level)
		fmt.Printf("Name: %s, Type: %v, Pattern: %v, Level: %v\n", name, typ, pattern, level)
	}
}
