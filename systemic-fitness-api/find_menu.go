package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5"
)

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer conn.Close(ctx)

	rows, err := conn.Query(ctx, "SELECT id, code, label FROM menus WHERE label ILIKE '%Modul%' OR label ILIKE '%Digital%' OR code ILIKE '%dl%'")
	if err != nil {
		log.Fatalf("Query failed: %v", err)
	}
	defer rows.Close()

	for rows.Next() {
		var id, code, label string
		rows.Scan(&id, &code, &label)
		fmt.Printf("Menu: %s | %s | %s\n", id, code, label)
	}
}
