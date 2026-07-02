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

	// Consultant Role code is likely 'consultant'
	var roleID string
	err = conn.QueryRow(ctx, "SELECT id FROM roles WHERE code = 'consultant'").Scan(&roleID)
	if err != nil {
		log.Fatalf("Consultant role not found: %v", err)
	}

	menus := []string{"modul-card", "digital-library"}
	for _, m := range menus {
		var menuID string
		err = conn.QueryRow(ctx, "SELECT id FROM menus WHERE code = $1", m).Scan(&menuID)
		if err != nil {
			log.Printf("Menu %s not found: %v", m, err)
			continue
		}

		_, err = conn.Exec(ctx, `
			INSERT INTO role_menus (role_id, menu_id, can_create, can_read, can_update, can_delete)
			VALUES ($1, $2, true, true, true, true)
			ON CONFLICT (role_id, menu_id) DO UPDATE SET
				can_create = true, can_read = true, can_update = true, can_delete = true
		`, roleID, menuID)
		if err != nil {
			log.Printf("Failed to assign %s: %v", m, err)
		} else {
			fmt.Printf("Assigned %s to consultant.\n", m)
		}
	}
}
