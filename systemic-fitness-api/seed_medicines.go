package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/xuri/excelize/v2"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, relying on environment variables")
	}

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Fatal("DATABASE_URL must be set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer pool.Close()

	f, err := excelize.OpenFile("obat/Daftar Obat.xlsx")
	if err != nil {
		log.Fatal("Failed to open excel:", err)
	}
	defer f.Close()

	// Use the first sheet
	sheetName := f.GetSheetList()[0]
	rows, err := f.GetRows(sheetName)
	if err != nil {
		log.Fatal("Failed to read rows:", err)
	}

	if len(rows) < 2 {
		log.Fatal("No data found in excel")
	}

	inserted := 0

	for i, row := range rows {
		if i == 0 {
			continue // skip header
		}

		// Ensure row has enough columns
		for len(row) < 8 {
			row = append(row, "")
		}

		name := strings.TrimSpace(row[1])
		if name == "" {
			continue
		}

		activeIngredient := strings.TrimSpace(row[2])
		category := strings.TrimSpace(row[3])
		mainFunction := strings.TrimSpace(row[4])
		implications := strings.TrimSpace(row[5])
		adjustments := strings.TrimSpace(row[6])
		flag := strings.TrimSpace(row[7])

		var createdBy *string = nil

		// Check if exists
		var id string
		err = pool.QueryRow(ctx, "SELECT id FROM medicines WHERE name = $1 LIMIT 1", name).Scan(&id)
		
		if err != nil { // not found, insert
			query := `
				INSERT INTO medicines (
					name, active_ingredient, category, main_function, 
					exercise_implications, exercise_adjustments, flag_level, 
					is_system, created_by
				) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`
			_, err = pool.Exec(ctx, query,
				name, activeIngredient, category, mainFunction,
				implications, adjustments, flag, true, createdBy,
			)
			if err != nil {
				log.Printf("Failed to insert %s: %v", name, err)
			} else {
				inserted++
			}
		} else {
			// Update
			query := `
				UPDATE medicines SET
					active_ingredient = $2, category = $3, main_function = $4,
					exercise_implications = $5, exercise_adjustments = $6, flag_level = $7
				WHERE id = $1`
			_, err = pool.Exec(ctx, query, id, activeIngredient, category, mainFunction, implications, adjustments, flag)
			if err != nil {
				log.Printf("Failed to update %s: %v", name, err)
			} else {
				inserted++
			}
		}
	}

	fmt.Printf("Successfully processed %d medicines.\n", inserted)
}
