package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func executeSQLFile(ctx context.Context, conn *pgx.Conn, filepath string) error {
	content, err := os.ReadFile(filepath)
	if err != nil {
		return err
	}

	sqlString := string(content)
	statements := strings.Split(sqlString, ";")
	
	fmt.Printf("Executing %s (%d statements)...\n", filepath, len(statements))

	success := 0
	failed := 0
	for _, stmt := range statements {
		s := strings.TrimSpace(stmt)
		if s == "" {
			continue
		}
		
		_, err = conn.Exec(ctx, s)
		if err != nil {
			// We expect some duplicates, just log it briefly
			if !strings.Contains(err.Error(), "duplicate key") {
				fmt.Printf("Error in statement: %s...\n-> %v\n", s[:min(50, len(s))], err)
			}
			failed++
		} else {
			success++
		}
	}

	fmt.Printf("Finished %s. Success: %d, Failed: %d\n", filepath, success, failed)
	return nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func main() {
	_ = godotenv.Load(".env")
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres"

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer conn.Close(ctx)

	files := []string{
		"database/migrations/062_add_set_type_to_dl_menu.sql",
	}

	for _, file := range files {
		executeSQLFile(ctx, conn, file)
	}
}
