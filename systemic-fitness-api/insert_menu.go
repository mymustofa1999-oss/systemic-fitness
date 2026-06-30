package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()
	connStr := os.Getenv("DATABASE_URL")
	if connStr == "" {
		log.Fatal("DATABASE_URL is not set")
	}
	// override port 5432 to 6543
	connStr = "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres"

	conn, err := pgx.Connect(context.Background(), connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close(context.Background())

	_, err = conn.Exec(context.Background(), `
		INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) 
		VALUES ('a0000000-0000-0000-0000-000000000099', 'a0000000-0000-0000-0000-000000000010', 'modul-card', 'Modul Card', 'Layers', '/modul-card', 2)
		ON CONFLICT (code) DO NOTHING;

		INSERT INTO menu_role_privileges (menu_id, role, can_access) VALUES
		('a0000000-0000-0000-0000-000000000099', 'owner', true),
		('a0000000-0000-0000-0000-000000000099', 'admin', true),
		('a0000000-0000-0000-0000-000000000099', 'trainer', true)
		ON CONFLICT (menu_id, role) DO NOTHING;
	`)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Successfully inserted Modul Card menu and privileges!")
}
