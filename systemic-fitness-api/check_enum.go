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

	rows, err := conn.Query(ctx, "SELECT unnest(enum_range(NULL::dl_body_part))")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	fmt.Println("dl_body_part enum values:")
	for rows.Next() {
		var val string
		err := rows.Scan(&val)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(val)
	}
}

