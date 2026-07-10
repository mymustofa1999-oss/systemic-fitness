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
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres"

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer conn.Close(ctx)

	var levelID string
	err = conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = 6 LIMIT 1").Scan(&levelID)
	if err != nil {
		log.Fatal("Level 6 not found in db")
	}

	catMap := make(map[string]string)
	rowsCat, _ := conn.Query(ctx, "SELECT code, id FROM dl_categories")
	for rowsCat.Next() {
		var code, id string
		rowsCat.Scan(&code, &id)
		catMap[strings.ToLower(code)] = id
	}
	rowsCat.Close()

	f6, err := excelize.OpenFile("movment/LEVEL 6 (LOCK).xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f6.Close()

	sheets6 := f6.GetSheetList()
	if len(sheets6) == 0 {
		return
	}
	rows, _ := f6.GetRows(sheets6[0])
	if len(rows) == 0 {
		return
	}

	headers := rows[0]
	colMap := make(map[string]int)
	for i, h := range headers {
		colMap[strings.TrimSpace(strings.ToUpper(h))] = i
	}

	idxSeq := colMap["SEQUENCE"]
	idxSet := colMap["SET"]
	idxType := colMap["TYPE"]
	idxFU := colMap["FEMALE_MOVEMENT_UPPER"]
	idxFV := colMap["FEMALE_VIDEO_LINK"]
	// idxMU := colMap["MALE_MOVEMENT_UPPER"]
	idxMV := colMap["MALE_VIDEO_LINK"]

	insertedMap := make(map[string]bool)

	for i, row := range rows {
		if i == 0 {
			continue
		}

		getCol := func(idx int) string {
			if idx != -1 && idx < len(row) {
				return strings.TrimSpace(row[idx])
			}
			return ""
		}

		seq := strings.ToLower(getCol(idxSeq))
		if seq != "cd" {
			continue // Only process CD
		}

		catID := catMap[seq]
		if catID == "" {
			fmt.Println("Warning: Category not found for seq:", seq)
			continue
		}

		setName := getCol(idxSet) // Basic or Mat
		groupType := getCol(idxType) // Stretching
		fu := getCol(idxFU)
		fv := getCol(idxFV)
		// mu := getCol(idxMU)
		mv := getCol(idxMV)

		if fu == "" || strings.HasPrefix(fu, "http") {
			continue
		}

		// Naming: Basic Stretching 1, Mat Stretching 1
		movementName := fmt.Sprintf("%s Stretching %s", setName, fu)

		// 1. Insert into dl_movements if not exists
		var mID string
		err := conn.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1 LIMIT 1", movementName).Scan(&mID)
		if err != nil {
			err = conn.QueryRow(ctx, `
				INSERT INTO dl_movements (name, type, pattern, level, body_part, video_url_female, video_url_male)
				VALUES ($1, 'stand', 'Mixed', 6, 'core', $2, $3) RETURNING id
			`, movementName, fv, mv).Scan(&mID)
			if err != nil {
				fmt.Println("Error inserting movement:", movementName, err)
				continue
			}
			fmt.Println("Inserted movement:", movementName)
		} else {
			// Update videos just in case
			conn.Exec(ctx, "UPDATE dl_movements SET video_url_female = $1, video_url_male = $2 WHERE id = $3", fv, mv, mID)
		}

		// 2. Insert into dl_menu_items
		key := fmt.Sprintf("%s-%s-%s-%s", catID, setName, groupType, mID)
		if !insertedMap[key] {
			_, err = conn.Exec(ctx, `
				INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, set_name, group_type, sort_order)
				VALUES ($1, $2, $3, $4, $5, $6, $7)
			`, catID, levelID, mID, "core", setName, groupType, i)
			
			if err != nil {
				fmt.Println("Error inserting dl_menu_items:", err)
			}
			insertedMap[key] = true
		}
	}

	fmt.Println("Stretching movements seeded successfully!")
}
