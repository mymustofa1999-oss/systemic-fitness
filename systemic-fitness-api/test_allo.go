package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=bind"
	pool, err := pgxpool.New(context.Background(), connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()

	var name, flag, imp, adj, cat string
	err = pool.QueryRow(context.Background(), "SELECT name, flag_level, exercise_implications, exercise_adjustments, category FROM medicines WHERE name ILIKE '%Allopurinol%' LIMIT 1").Scan(&name, &flag, &imp, &adj, &cat)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Name: %s\nFlag: %s\nImp: %s\nAdj: %s\nCat: %s\n", name, flag, imp, adj, cat)
}
