package main

import (
	"context"
	"fmt"
	"log"
	"path/filepath"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/xuri/excelize/v2"
)

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	conn, err := pgxpool.New(ctx, connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	conn.Exec(ctx, "INSERT INTO dl_categories (code, name) VALUES ('cd', 'Cool Down') ON CONFLICT DO NOTHING")
	var catID string
	err = conn.QueryRow(ctx, "SELECT id FROM dl_categories WHERE code = 'cd'").Scan(&catID)
	if err != nil {
		log.Fatal(err)
	}

	levelFiles, _ := filepath.Glob("movment/LEVEL *.xlsx")
	updated := 0

	for _, file := range levelFiles {
		xl, _ := excelize.OpenFile(file)
		if xl == nil {
			continue
		}
		sheet := xl.GetSheetList()[0]
		rows, _ := xl.GetRows(sheet)

		levelNum := 0
		fmt.Sscanf(filepath.Base(file), "LEVEL %d.xlsx", &levelNum)

		var levelID string
		conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = $1", levelNum).Scan(&levelID)

		var currentSeq string

		for _, row := range rows {
			if len(row) == 0 {
				continue
			}

			colSeq := ""
			if len(row) > 0 {
				colSeq = strings.TrimSpace(row[0])
			}
			if colSeq != "" && strings.ToUpper(colSeq) != "SEQUENCE" && !strings.Contains(strings.ToUpper(colSeq), "LEVEL") {
				currentSeq = colSeq
			}

			femaleName, maleName := "", ""
			if len(row) > 3 {
				femaleName = strings.TrimSpace(row[3])
			}
			if len(row) > 4 {
				maleName = strings.TrimSpace(row[4])
			}
			
			// For Level 6, the columns are different!
			if levelNum == 6 {
				if len(row) > 4 {
					femaleName = strings.TrimSpace(row[4])
				}
				if len(row) > 5 {
					maleName = strings.TrimSpace(row[5])
				}
			}

			movementName := femaleName
			if movementName == "" || strings.ToLower(movementName) == "waitlist" {
				movementName = maleName
			}
			if movementName == "" || strings.ToLower(movementName) == "waitlist" {
				continue
			}

			catCode := strings.ToLower(currentSeq)
			if catCode == "cd" || catCode == "cooldown" || catCode == "cool down" {
				
				badName := fmt.Sprintf("%s (FC - Level %d)", movementName, levelNum)
				goodName := fmt.Sprintf("%s (CD - Level %d)", movementName, levelNum)
				
				// Some might not have suffix if seeded by seed_new_movements.go
				rawName := movementName

				var mID string
				err := conn.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1 LIMIT 1", badName).Scan(&mID)
				if err != nil {
					err = conn.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1 LIMIT 1", rawName).Scan(&mID)
				}
				if err != nil {
					err = conn.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1 LIMIT 1", goodName).Scan(&mID)
				}

				if mID != "" {
					// Update dl_movements
					// Ensure categories has cd
					conn.Exec(ctx, "UPDATE dl_movements SET categories = array_append(array_remove(categories, 'fc'), 'cd'), name = $2 WHERE id = $1 AND NOT (categories @> ARRAY['cd']::varchar[])", mID, goodName)
					
					// Update name anyway if it was bad
					conn.Exec(ctx, "UPDATE dl_movements SET name = $2 WHERE id = $1 AND name = $3", mID, goodName, badName)

					// Update dl_menu_items
					tag, err := conn.Exec(ctx, "UPDATE dl_menu_items SET category_id = $1 WHERE level_id = $2 AND movement_id = $3", catID, levelID, mID)
					if err == nil && tag.RowsAffected() > 0 {
						updated++
						fmt.Printf("Updated %s -> %s\n", movementName, goodName)
					}
				} else {
					fmt.Printf("Could not find movement for CD: %s (tried %s, %s)\n", movementName, badName, rawName)
				}
			}
		}
		xl.Close()
	}

	fmt.Printf("Successfully updated %d CD menu items!\n", updated)
}

