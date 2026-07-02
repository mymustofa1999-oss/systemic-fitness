package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5"
)

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	conn, err := pgx.Connect(context.Background(), connStr)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer conn.Close(context.Background())

	var tier string
	err = conn.QueryRow(context.Background(), "SELECT current_tier FROM user_profiles WHERE user_id = 'fe082a2a-ce5d-4380-9177-97c2749af729'").Scan(&tier)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	fmt.Println("Julio's current tier:", tier)
}
