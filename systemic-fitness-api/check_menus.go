package main

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()
	dbURL := os.Getenv("DATABASE_URL")
	pool, err := pgxpool.New(context.Background(), dbURL)
	if err != nil {
		fmt.Println("Error connecting to database", err)
		return
	}
	defer pool.Close()

	rows, err := pool.Query(context.Background(), `
		SELECT code, parent_id, label FROM menus WHERE code IN ('digital-library', 'modul-card', 'master-libraries')
	`)
	if err != nil {
		fmt.Println("Query error", err)
		return
	}
	defer rows.Close()

	fmt.Println("Menus found:")
	for rows.Next() {
		var code, label string
		var parentId *string
		rows.Scan(&code, &parentId, &label)
		pid := "NULL"
		if parentId != nil {
			pid = *parentId
		}
		fmt.Printf("Code: %s, Label: %s, Parent: %s\n", code, label, pid)
	}

	fmt.Println("\nPrivileges for modul-card:")
	rows2, err := pool.Query(context.Background(), `
		SELECT m.code, p.role FROM menu_role_privileges p
		JOIN menus m ON m.id = p.menu_id
		WHERE m.code IN ('digital-library', 'modul-card', 'master-libraries')
		ORDER BY m.code, p.role
	`)
	if err != nil {
		fmt.Println("Query error", err)
		return
	}
	defer rows2.Close()
	
	for rows2.Next() {
		var code, role string
		rows2.Scan(&code, &role)
		fmt.Printf("Menu: %s, Role: %s\n", code, role)
	}
}
