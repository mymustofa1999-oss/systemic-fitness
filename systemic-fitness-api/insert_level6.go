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

	_, err = conn.Exec(ctx, `ALTER TABLE dl_levels DROP CONSTRAINT IF EXISTS dl_levels_level_number_check;`)
	if err != nil {
		log.Printf("Failed to drop constraint: %v", err)
	}

	_, err = conn.Exec(ctx, `ALTER TABLE dl_levels ADD CONSTRAINT dl_levels_level_number_check CHECK (level_number >= 0 AND level_number <= 6);`)
	if err != nil {
		log.Printf("Failed to add constraint: %v", err)
	}

	_, err = conn.Exec(ctx, `
		INSERT INTO dl_levels (level_number, name, name_id, description)
		VALUES (6, 'Level 6', 'Level 6', 'Level 6')
		ON CONFLICT (level_number) DO NOTHING;
	`)
	if err != nil {
		log.Printf("Failed to insert level 6: %v", err)
	}

	fmt.Println("Level 6 added successfully!")
}
