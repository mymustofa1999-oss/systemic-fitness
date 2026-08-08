package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	dbURL := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer pool.Close()

	rows, err := pool.Query(ctx, "SELECT id, name, COALESCE(video_url_male, ''), COALESCE(video_url_female, '') FROM dl_movements WHERE name LIKE '%http%'")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	count := 0
	for rows.Next() {
		var id, name, mVid, fVid string
		rows.Scan(&id, &name, &mVid, &fVid)
		fmt.Printf("ID: %s\nName: %s\nMaleVid: %s\nFemaleVid: %s\n\n", id, name, mVid, fVid)
		count++
	}
	fmt.Printf("Total found: %d\n", count)
}
