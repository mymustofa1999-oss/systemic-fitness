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
		SELECT code, parent_id, label, is_active, href FROM menus WHERE code IN ('digital-library', 'modul-card')
	`)
	if err != nil {
		fmt.Println("Query error", err)
		return
	}
	defer rows.Close()

	for rows.Next() {
		var code, label string
		var parentId, href *string
		var isActive bool
		rows.Scan(&code, &parentId, &label, &isActive, &href)
		pid := "NULL"
		if parentId != nil {
			pid = *parentId
		}
		h := "NULL"
		if href != nil {
			h = *href
		}
		fmt.Printf("Code: %s, Label: %s, Parent: %s, Active: %v, Href: %s\n", code, label, pid, isActive, h)
	}

}
