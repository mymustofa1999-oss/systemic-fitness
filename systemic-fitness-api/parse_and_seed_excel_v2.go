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

type MovementData struct {
	Name    string
	Type    string
	Pattern string
	Level   int
}

func main() {
	_ = godotenv.Load(".env")

	// Use 5432 to avoid PgBouncer prepared statement hanging issues
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres"

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

	movementsMap := make(map[string]MovementData)

	// We will scan ALL sheets
	for _, sheet := range f.GetSheetList() {
		rows, err := f.GetRows(sheet)
		if err != nil {
			continue
		}

		// Find "TYPE", "FEMALE", "MALE" columns
		for rowIdx := 0; rowIdx < len(rows); rowIdx++ {
			row := rows[rowIdx]
			for colIdx := 0; colIdx < len(row); colIdx++ {
				cellVal := strings.TrimSpace(strings.ToUpper(row[colIdx]))
				if cellVal == "FEMALE" || cellVal == "MALE" {
					
					typeColIdx := -1
					for k := 0; k < colIdx; k++ {
						if strings.TrimSpace(strings.ToUpper(row[k])) == "TYPE" {
							typeColIdx = k
						}
					}

					for r := rowIdx + 1; r < len(rows); r++ {
						if colIdx >= len(rows[r]) {
							continue
						}
						name := strings.TrimSpace(rows[r][colIdx])
						if name == "" || name == "1" || name == "2" || name == "3" || strings.ToLower(name) == "no movements" || strings.HasPrefix(name, "http") || strings.HasPrefix(name, "https") {
							continue
						}

						pattern := "Mixed"
						if typeColIdx != -1 && typeColIdx < len(rows[r]) {
							p := strings.TrimSpace(rows[r][typeColIdx])
							if p != "" {
								pattern = p
							}
						}

						level := 1
						typ := "stand"
						
						sheetUpper := strings.ToUpper(sheet)
						if strings.Contains(sheetUpper, "LEVEL 0") {
							level = 0
							typ = "mat"
						} else if strings.Contains(sheetUpper, "LEVEL 1") {
							level = 1
							typ = "sit"
						} else if strings.Contains(sheetUpper, "LEVEL 2") {
							level = 2
						} else if strings.Contains(sheetUpper, "LEVEL 3") {
							level = 3
						} else if strings.Contains(sheetUpper, "LEVEL 4") {
							level = 4
						} else if strings.Contains(sheetUpper, "LEVEL 5") {
							level = 5
						} else if strings.Contains(sheetUpper, "LEVEL 6") {
							level = 6
						}

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
		}
	}

	fmt.Printf("Found %d unique movements from Excel to seed.\n", len(movementsMap))

	successCount := 0
	for _, m := range movementsMap {
		// body_part inference
		bodyPart := "core" // default
		p := strings.ToLower(m.Pattern)
		if strings.Contains(p, "upper") {
			bodyPart = "upper"
		} else if strings.Contains(p, "lower") {
			bodyPart = "lower"
		}

		tag, err := conn.Exec(ctx, `
			UPDATE dl_movements 
			SET type = $1, pattern = $2, level = $3, body_part = $4
			WHERE name = $5`,
			m.Type, m.Pattern, m.Level, bodyPart, m.Name,
		)
		if err != nil {
			fmt.Printf("Error updating %s: %v\n", m.Name, err)
			continue
		}

		if tag.RowsAffected() == 0 {
			// Insert it
			_, err = conn.Exec(ctx, `
				INSERT INTO dl_movements (name, type, pattern, level, body_part) 
				VALUES ($1, $2, $3, $4, $5)`,
				m.Name, m.Type, m.Pattern, m.Level, bodyPart,
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
