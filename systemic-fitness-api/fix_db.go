package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	dbUrl := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	
	poolConfig, err := pgxpool.ParseConfig(dbUrl)
	if err != nil {
		log.Fatalf("Unable to parse DATABASE_URL: %v", err)
	}

	conn, err := pgxpool.NewWithConfig(context.Background(), poolConfig)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v", err)
	}
	defer conn.Close()

	// Add regional and city if they don't exist
	_, err = conn.Exec(context.Background(), `ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS regional VARCHAR(100), ADD COLUMN IF NOT EXISTS city VARCHAR(100)`)
	if err != nil {
		log.Fatalf("Failed to alter table: %v", err)
	}
	
	fmt.Println("Successfully added regional and city columns to user_profiles")
}
