package main

import (
	"context"
	"fmt"
	"log"
	"regexp"
	"strconv"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
	"github.com/xuri/excelize/v2"
)

type MovementData struct {
	Name    string
	Type    string // sit, stand, mat
	Pattern string // Upper, Lower, Core
	Level   int
}

func main() {
	err := godotenv.Load(".env")
	if err != nil {
		fmt.Println("No .env file found, using environment variables")
	}

	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres"

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer conn.Close(ctx)

	f, err := excelize.OpenFile("Modul Gerakan .xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	sheetsToParse := []string{"Menu FC", "Menu CC", "Menu MC"}
	movementsMap := make(map[string]MovementData)

	levelRegex := regexp.MustCompile(`[Ll]evel\s*(\d+)`)

	for _, sheet := range sheetsToParse {
		rows, err := f.GetRows(sheet)
		if err != nil || len(rows) < 2 {
			continue
		}

		row0 := rows[0]
		row1 := rows[1]

		for colIdx := 0; colIdx < len(row0); colIdx++ {
			header := strings.TrimSpace(row0[colIdx])
			if header == "" {
				continue
			}

			// Extract Level
			matches := levelRegex.FindStringSubmatch(header)
			if len(matches) < 2 {
				continue
			}
			level, _ := strconv.Atoi(matches[1])

			// Extract Pattern
			pattern := ""
			if colIdx < len(row1) {
				pattern = strings.TrimSpace(row1[colIdx])
			}
			if pattern == "" {
				pattern = "Mixed" // fallback
			}

			// Determine Type (dl_position)
			typ := "stand"
			if level == 0 {
				typ = "mat"
			} else if level == 1 {
				typ = "sit"
			}

			// Iterate rows for movements
			for rowIdx := 2; rowIdx < len(rows); rowIdx++ {
				if colIdx >= len(rows[rowIdx]) {
					continue
				}
				cellVal := strings.TrimSpace(rows[rowIdx][colIdx])
				if cellVal == "" || cellVal == "1" || cellVal == "2" || cellVal == "3" {
					continue
				}

				name := cellVal

				// Add to map if not exists (keep the lowest level usually since we process left to right)
				if _, exists := movementsMap[name]; !exists {
					movementsMap[name] = MovementData{
						Name:    name,
						Type:    typ,
						Pattern: pattern,
						Level:   level,
					}
				}
			}
		}
	}

	fmt.Printf("Found %d unique movements to seed.\n", len(movementsMap))

	// Insert or Update in PostgreSQL
	successCount := 0
	for _, m := range movementsMap {
		// We use UPSERT to insert if it doesn't exist, or update type/pattern/level if it does.
		// Wait, the primary key or unique constraint in dl_movements is usually `name`?
		// Let's just try to update existing ones first, if rows affected == 0, then insert.
		
		tag, err := conn.Exec(ctx, `
			UPDATE dl_movements 
			SET type = $1, pattern = $2, level = $3 
			WHERE name = $4`,
			m.Type, m.Pattern, m.Level, m.Name,
		)
		if err != nil {
			fmt.Printf("Error updating %s: %v\n", m.Name, err)
			continue
		}

		if tag.RowsAffected() == 0 {
			// Insert it
			_, err = conn.Exec(ctx, `
				INSERT INTO dl_movements (name, type, pattern, level) 
				VALUES ($1, $2, $3, $4)`,
				m.Name, m.Type, m.Pattern, m.Level,
			)
			if err != nil {
				fmt.Printf("Error inserting %s: %v\n", m.Name, err)
				continue
			}
		}
		successCount++
	}

	fmt.Printf("Successfully processed %d movements into PostgreSQL!\n", successCount)
}
