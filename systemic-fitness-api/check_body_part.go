package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	db, err := pgxpool.New(context.Background(), "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	rows, err := db.Query(context.Background(), "SELECT DISTINCT name, body_part FROM dl_movements WHERE name ILIKE '%sit%'")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	for rows.Next() {
		var name string
		var bp *string
		if err := rows.Scan(&name, &bp); err != nil {
			log.Fatal(err)
		}
		if bp != nil {
			fmt.Printf("%s - %s\n", name, *bp)
		} else {
			fmt.Printf("%s - <nil>\n", name)
		}
	}
}
