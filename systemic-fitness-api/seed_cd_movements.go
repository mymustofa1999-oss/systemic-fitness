package main

import (
	"context"
	"fmt"
	"log"
	"path/filepath"
	"strings"

	"github.com/google/uuid"
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

	var catID string
	err = conn.QueryRow(ctx, "SELECT id FROM dl_categories WHERE code = 'cd'").Scan(&catID)
	if err != nil {
		log.Fatal(err)
	}

	levelFiles, _ := filepath.Glob("movment/LEVEL *.xlsx")
	addedMovements := 0
	addedMenuItems := 0

	for _, file := range levelFiles {
		xl, _ := excelize.OpenFile(file)
		if xl == nil { continue }
		sheet := xl.GetSheetList()[0]
		rows, _ := xl.GetRows(sheet)

		levelNum := 0
		fmt.Sscanf(filepath.Base(file), "LEVEL %d.xlsx", &levelNum)
		if levelNum == 0 && strings.Contains(filepath.Base(file), "LEVEL 6") {
			levelNum = 6
		}

		var levelID string
		err = conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = $1", levelNum).Scan(&levelID)
		if err != nil {
			log.Printf("Level %d not found in DB\n", levelNum)
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
			index := ""
			if len(row) > 2 { index = strings.TrimSpace(row[2]) }
			
			femaleURL := ""
			if len(row) > 3 { femaleURL = strings.TrimSpace(row[3]) }
			
			maleURL := ""
			if len(row) > 6 { maleURL = strings.TrimSpace(row[6]) }

			if femaleURL == "" { continue }

			movementName := fmt.Sprintf("%s %s (CD - Level %d)", setName, index, levelNum)
			movementName = strings.TrimSpace(movementName)

			var mID string
			err = conn.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1 LIMIT 1", movementName).Scan(&mID)
			
			if err != nil {
				mID = uuid.New().String()
				_, err = conn.Exec(ctx, `
					INSERT INTO dl_movements (id, name, level, categories, body_part, is_active, video_url_female, video_url_male)
					VALUES ($1, $2, $3, ARRAY['cd']::varchar[], $4, $5, $6, $7)
				`, mID, levelNum, "mixed", true, femaleURL, maleURL)
				if err != nil {
					log.Printf("Failed to insert movement %s: %v\n", movementName, err)
					continue
				}
				addedMovements++
			} else {
				conn.Exec(ctx, "UPDATE dl_movements SET video_url_female=$1, video_url_male=$2, categories=array_append(array_remove(categories, 'fc'), 'cd') WHERE id=$3", femaleURL, maleURL, mID)
			}

			var exists bool
			conn.QueryRow(ctx, "SELECT EXISTS(SELECT 1 FROM dl_menu_items WHERE category_id = $1 AND level_id = $2 AND movement_id = $3)", catID, levelID, mID).Scan(&exists)
			
			if !exists {
				sortOrder++
				_, err = conn.Exec(ctx, `
					INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order)
					VALUES ($1, $2, $3, $4, $5)
				`, catID, levelID, mID, "mixed", sortOrder)
				if err != nil {
					log.Printf("Failed to insert menu item for %s: %v\n", movementName, err)
				} else {
					addedMenuItems++
				}
			}
		}
		xl.Close()
	}

	fmt.Printf("Successfully added %d new movements and %d menu items for CD!\n", addedMovements, addedMenuItems)
}

