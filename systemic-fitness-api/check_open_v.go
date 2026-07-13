package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	conn, err := pgxpool.New(ctx, connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	rows, _ := conn.Query(ctx, "SELECT name, pattern FROM dl_movements WHERE name ILIKE '%Open V%' OR name ILIKE '%Arm Rotation%'")
	defer rows.Close()
	for rows.Next() {
		var name, pattern string
		rows.Scan(&name, &pattern)
		fmt.Printf("Movement: %s | Pattern: %s\n", name, pattern)
	}
}
