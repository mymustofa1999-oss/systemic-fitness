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

func normalize(s string) string {
	return strings.ToLower(strings.TrimSpace(s))
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

	f, err := excelize.OpenFile("Modul Gerakan .xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	sheets := []string{"LEVEL 1-2", "LEVEL 3", "LEVEL 4", "LEVEL 5", "LEVEL 6"}

	updatedCount := 0

	for _, sheet := range sheets {
		rows, err := f.GetRows(sheet)
		if err != nil {
			continue
		}

		// Look for header row: SEQUENCE SET TYPE FEMALE MALE
		// There can be multiple tables side by side
		for rowIdx, row := range rows {
			var tableCols []int // Starting col indices for SEQUENCE
			for colIdx, cell := range row {
				if normalize(cell) == "sequence" {
					// Found a table! Check if it has SET, TYPE
					if colIdx+4 < len(row) && normalize(row[colIdx+1]) == "set" || normalize(row[colIdx+1]) == "set 1" {
						tableCols = append(tableCols, colIdx)
					}
				}
			}

			if len(tableCols) > 0 {
				// Parse rows below the header
				for r := rowIdx + 1; r < len(rows); r++ {
					currentRow := rows[r]
					for i, startCol := range tableCols {
						// Determine level based on sheet and table index
						level := 0
						if sheet == "LEVEL 1-2" {
							if i == 0 { level = 1 } else { level = 2 }
						} else if sheet == "LEVEL 3" { level = 3 
						} else if sheet == "LEVEL 4" { level = 4 
						} else if sheet == "LEVEL 5" { level = 5 
						} else if sheet == "LEVEL 6" { level = 6 }

						if startCol+4 >= len(currentRow) {
							continue
						}

						sequence := strings.TrimSpace(currentRow[startCol])
						set := strings.TrimSpace(currentRow[startCol+1])
						typ := strings.TrimSpace(currentRow[startCol+2])
						femaleName := strings.TrimSpace(currentRow[startCol+3])
						maleName := strings.TrimSpace(currentRow[startCol+4])

						// Carry over sequence, set, type if empty (merged cells in Excel)
						if sequence == "" {
							// Look up previous rows
							for pr := r - 1; pr > rowIdx; pr-- {
								if startCol < len(rows[pr]) && strings.TrimSpace(rows[pr][startCol]) != "" {
									sequence = strings.TrimSpace(rows[pr][startCol])
									break
								}
							}
						}
						if set == "" {
							for pr := r - 1; pr > rowIdx; pr-- {
								if startCol+1 < len(rows[pr]) && strings.TrimSpace(rows[pr][startCol+1]) != "" {
									set = strings.TrimSpace(rows[pr][startCol+1])
									break
								}
							}
						}
						if typ == "" {
							for pr := r - 1; pr > rowIdx; pr-- {
								if startCol+2 < len(rows[pr]) && strings.TrimSpace(rows[pr][startCol+2]) != "" {
									typ = strings.TrimSpace(rows[pr][startCol+2])
									break
								}
							}
						}

						// If both male and female are empty or just header, skip
						if (femaleName == "" && maleName == "") || normalize(femaleName) == "female" {
							continue
						}

						movementName := femaleName
						if movementName == "" {
							movementName = maleName
						}
						if normalize(movementName) == "no movements" {
							continue
						}

						// Update DB
						categoryCode := normalize(sequence)
						if categoryCode != "fc" && categoryCode != "cc" && categoryCode != "mc" {
							continue
						}

						// 1. Get movement ID
						var movementID string
						err := conn.QueryRow(ctx, "SELECT id FROM dl_movements WHERE LOWER(name) = $1", normalize(movementName)).Scan(&movementID)
						if err != nil {
							// Movement might not exist if it was skipped or misspelled
							continue
						}

						// 2. Get category ID
						var categoryID string
						err = conn.QueryRow(ctx, "SELECT id FROM dl_categories WHERE code = $1", categoryCode).Scan(&categoryID)
						if err != nil {
							continue
						}

						// 3. Get level ID
						var levelID string
						err = conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = $1", level).Scan(&levelID)
						if err != nil {
							continue
						}

						// 4. Upsert menu item with set_name and group_type!
						// But remember there is sort_order. We can just update the existing one if it exists, or insert new
						tag, err := conn.Exec(ctx, `
							UPDATE dl_menu_items 
							SET set_name = $1, group_type = $2 
							WHERE category_id = $3 AND level_id = $4 AND movement_id = $5`,
							set, typ, categoryID, levelID, movementID)
						
						if err != nil {
							fmt.Println("Update error:", err)
						} else if tag.RowsAffected() > 0 {
							updatedCount++
						} else {
							// If not found, insert it!
							_, err = conn.Exec(ctx, `
								INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, set_name, group_type, sort_order)
								VALUES ($1, $2, $3, 'upper', $4, $5, $6)`,
								categoryID, levelID, movementID, set, typ, r * 10)
							if err == nil {
								updatedCount++
							}
						}
					}
				}
			}
		}
	}
	
	fmt.Printf("Successfully updated/inserted %d menu items with SET and TYPE.\n", updatedCount)
}
