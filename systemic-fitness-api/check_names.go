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

	rows, err := conn.Query(ctx, `
		SELECT name, body_part 
		FROM dl_movements 
		WHERE name ILIKE '%Arm Rotation%'
		ORDER BY name
	`)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	fmt.Println("Movements containing 'Arm Rotation':")
	for rows.Next() {
		var name, bodyPart string
		rows.Scan(&name, &bodyPart)
		fmt.Printf("- %s (Body Part: %s)\n", name, bodyPart)
	}
}

