package main

import (
	"context"
	"fmt"
	"log"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
	"github.com/xuri/excelize/v2"
)

func main() {
	_ = godotenv.Load(".env")
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer conn.Close(ctx)

	conn.Exec(ctx, `ALTER TABLE medicines ALTER COLUMN category TYPE TEXT`)
	conn.Exec(ctx, `ALTER TABLE medicines ALTER COLUMN flag_level TYPE TEXT`)

	f, err := excelize.OpenFile("obat/Daftar Obat.xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	sheets := f.GetSheetList()
	if len(sheets) == 0 {
		log.Fatal("No sheets found")
	}

	rows, err := f.GetRows(sheets[0])
	if err != nil {
		log.Fatal(err)
	}

	for i, row := range rows {
		if i == 0 {
			continue // Skip header
		}
		
		getCol := func(idx int) string {
			if idx < len(row) {
				return strings.TrimSpace(row[idx])
			}
			return ""
		}
		
		name := getCol(1)
		if name == "" {
			continue
		}
		category := getCol(2)
		implications := getCol(3)
		adjustments := getCol(4)
		flag := getCol(5)

		// Wait, medicines table does not have a unique constraint on name!
		// Let's check if it exists by name first.
		
		var existingId string
		err = conn.QueryRow(ctx, "SELECT id::text FROM medicines WHERE name = $1 LIMIT 1", name).Scan(&existingId)
		if err == pgx.ErrNoRows {
			// Insert
			_, err = conn.Exec(ctx, `
				INSERT INTO medicines (name, category, exercise_implications, exercise_adjustments, flag_level, is_system)
				VALUES ($1, $2, $3, $4, $5, true)
			`, name, category, implications, adjustments, flag)
			if err != nil {
				log.Printf("Error inserting %s: %v\n", name, err)
			} else {
				fmt.Printf("Inserted %s\n", name)
			}
		} else if err == nil {
			// Update
			_, err = conn.Exec(ctx, `
				UPDATE medicines 
				SET category = $2, exercise_implications = $3, exercise_adjustments = $4, flag_level = $5
				WHERE id = $1
			`, existingId, category, implications, adjustments, flag)
			if err != nil {
				log.Printf("Error updating %s: %v\n", name, err)
			} else {
				fmt.Printf("Updated %s\n", name)
			}
		} else {
			log.Printf("Error querying %s: %v\n", name, err)
		}
	}
	fmt.Println("Done")
}
