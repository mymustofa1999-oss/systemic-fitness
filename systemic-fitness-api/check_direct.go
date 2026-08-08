package main

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	dbURL := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	pool, _ := pgxpool.New(context.Background(), dbURL)
	
	rows, _ := pool.Query(context.Background(), "SELECT id, name FROM dl_movements WHERE name LIKE '%http%'")
	count := 0
	for rows.Next() {
		var id, name string
		rows.Scan(&id, &name)
		fmt.Printf("Remaining: %s\n", name)
		count++
	}
	fmt.Printf("Total remaining found: %d\n", count)
}
