package main

import (
	"context"
	"fmt"
	"log"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/xuri/excelize/v2"
)

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	conn, err := pgxpool.New(ctx, connStr)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer conn.Close()

	// Clean up existing CD items first to avoid duplication/update issues
	fmt.Println("Wiping existing CD data from dl_menu_items and dl_movements...")
	_, err = conn.Exec(ctx, `DELETE FROM dl_menu_items WHERE category_id = (SELECT id FROM dl_categories WHERE code = 'cd')`)
	if err != nil {
		log.Fatalf("Failed to delete CD menu items: %v", err)
	}
	
	// We can't easily delete from dl_movements without a cascade if they're used elsewhere,
	// but CD movements are usually only used by CD category.
	_, err = conn.Exec(ctx, `DELETE FROM dl_movements WHERE 'cd' = ANY(categories) AND array_length(categories, 1) = 1`)
	if err != nil {
		log.Fatalf("Failed to delete CD movements: %v", err)
	}

	files := []string{
		"LEVEL_1.xlsx",
		"LEVEL_2.xlsx",
		"LEVEL_3.xlsx",
		"LEVEL_4.xlsx",
		"LEVEL_5.xlsx",
		"LEVEL_6_LOCK.xlsx",
	}

	var catID string
	err = conn.QueryRow(ctx, "SELECT id FROM dl_categories WHERE code = 'cd'").Scan(&catID)
	if err != nil {
		log.Fatalf("Category 'cd' not found: %v\n", err)
	}

	addedMovements := 0
	addedMenuItems := 0

	for _, file := range files {
		path := filepath.Join("movment", file)
		xl, err := excelize.OpenFile(path)
		if err != nil {
			log.Printf("Failed to open %s: %v\n", file, err)
			continue
		}

		sheetName := xl.GetSheetName(0)
		rows, err := xl.GetRows(sheetName)
		if err != nil {
			log.Printf("Failed to read rows from %s: %v\n", file, err)
			continue
		}

		// Extract level number
		levelNumStr := strings.TrimPrefix(strings.Split(file, ".")[0], "LEVEL_")
		levelNumStr = strings.Split(levelNumStr, "_")[0]
		levelNum, _ := strconv.Atoi(levelNumStr)

		var levelID string
		err = conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = $1", levelNum).Scan(&levelID)
		if err != nil {
			log.Printf("Level %d not found: %v\n", levelNum, err)
			continue
		}

		var maxSort int
		conn.QueryRow(ctx, "SELECT COALESCE(MAX(sort_order), 0) FROM dl_menu_items WHERE level_id = $1 AND category_id = $2", levelID, catID).Scan(&maxSort)
		sortOrder := maxSort

		for _, row := range rows {
			if len(row) == 0 { continue }
			seq := strings.TrimSpace(row[0])
			if strings.ToLower(seq) != "cd" { continue }

			setName := ""
			if len(row) > 1 { setName = strings.TrimSpace(row[1]) }
			groupType := ""
			if len(row) > 2 { groupType = strings.TrimSpace(row[2]) }
			pattern := ""
			if len(row) > 3 { pattern = strings.TrimSpace(row[3]) }
			
			index := ""
			if len(row) > 4 { index = strings.TrimSpace(row[4]) }
			
			femaleURL := ""
			if len(row) > 6 { femaleURL = strings.TrimSpace(row[6]) }
			
			maleURL := ""
			if len(row) > 10 { maleURL = strings.TrimSpace(row[10]) }

			if femaleURL == "" { continue }

			movementName := fmt.Sprintf("%s %s %s (CD - Level %d)", setName, groupType, index, levelNum)
			movementName = strings.TrimSpace(movementName)

			var mID string
			err = conn.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1 LIMIT 1", movementName).Scan(&mID)
			
			if err != nil {
				cats := "{cd}"
				err = conn.QueryRow(ctx, `
					INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, pattern)
					VALUES ($1, $2, $3, $4, $5, $6)
					RETURNING id
				`, movementName, "core", maleURL, femaleURL, cats, pattern).Scan(&mID)
				
				if err != nil {
					log.Printf("Failed to insert movement %s: %v\n", movementName, err)
					continue
				}
				addedMovements++
			} else {
				conn.Exec(ctx, "UPDATE dl_movements SET video_url_female=$1, video_url_male=$2, pattern=$3, categories=array_append(array_remove(categories, 'fc'), 'cd') WHERE id=$4", femaleURL, maleURL, pattern, mID)
			}

			var exists bool
			conn.QueryRow(ctx, "SELECT EXISTS(SELECT 1 FROM dl_menu_items WHERE category_id = $1 AND level_id = $2 AND movement_id = $3)", catID, levelID, mID).Scan(&exists)
			
			if !exists {
				sortOrder++
				_, err = conn.Exec(ctx, `
					INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order, set_name, group_type)
					VALUES ($1, $2, $3, $4, $5, $6, $7)
				`, catID, levelID, mID, "core", sortOrder, setName, groupType)
				if err != nil {
					log.Printf("Failed to insert menu item for %s: %v\n", movementName, err)
				} else {
					addedMenuItems++
					fmt.Printf("Added to level %d: %s\n", levelNum, movementName)
				}
			}
		}
		xl.Close()
	}

	fmt.Printf("Successfully added %d new movements and %d menu items for CD!\n", addedMovements, addedMenuItems)
}
