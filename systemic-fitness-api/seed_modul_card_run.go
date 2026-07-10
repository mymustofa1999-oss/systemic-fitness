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

	// Get Level 6 ID
	var levelID string
	err = conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = 6 LIMIT 1").Scan(&levelID)
	if err != nil {
		log.Fatal("Level 6 not found in db")
	}

	// Make sure CD and Mat categories exist
	conn.Exec(ctx, "INSERT INTO dl_categories (code, name) VALUES ('cd', 'Cool Down') ON CONFLICT DO NOTHING")
	conn.Exec(ctx, "INSERT INTO dl_categories (code, name) VALUES ('mat', 'Mat') ON CONFLICT DO NOTHING")

	// Load categories
	catMap := make(map[string]string)
	rowsCat, _ := conn.Query(ctx, "SELECT code, id FROM dl_categories")
	for rowsCat.Next() {
		var code, id string
		rowsCat.Scan(&code, &id)
		catMap[strings.ToLower(code)] = id
	}
	rowsCat.Close()

	// Parse Excel
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
	idxFL := colMap["FEMALE_MOVEMENT_LOWER"]
	idxMU := colMap["MALE_MOVEMENT_UPPER"]
	idxML := colMap["MALE_MOVEMENT_LOWER"]

	// Clear existing level 6 modul cards
	conn.Exec(ctx, "DELETE FROM dl_menu_items WHERE level_id = $1", levelID)

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
		if seq == "" {
			continue
		}
		catID := catMap[seq]
		if catID == "" {
			fmt.Println("Warning: Category not found for seq:", seq)
			continue
		}

		setName := getCol(idxSet)
		if setName == "" {
			setName = "Set 1" // fallback
		}

		groupType := getCol(idxType)
		if groupType == "" {
			groupType = "Mixed"
		}

		movements := []struct {
			name     string
			bodyPart string
		}{
			{getCol(idxFU), "upper"},
			{getCol(idxFL), "lower"},
			{getCol(idxMU), "upper"},
			{getCol(idxML), "lower"},
		}

		for _, m := range movements {
			if m.name == "" || m.name == "1" || m.name == "2" || m.name == "3" || strings.HasPrefix(m.name, "http") {
				continue
			}

			// find movement id
			var mID string
			err := conn.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1 AND level = 6 LIMIT 1", m.name).Scan(&mID)
			if err != nil {
				err = conn.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1 LIMIT 1", m.name).Scan(&mID)
				if err != nil {
					fmt.Println("Movement not found in DB:", m.name)
					continue
				}
			}

			key := fmt.Sprintf("%s-%s-%s-%s", catID, setName, groupType, mID)
			if !insertedMap[key] {
				_, err = conn.Exec(ctx, `
					INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, set_name, group_type, sort_order)
					VALUES ($1, $2, $3, $4, $5, $6, $7)
				`, catID, levelID, mID, m.bodyPart, setName, groupType, i)
				
				if err != nil {
					fmt.Println("Error inserting dl_menu_items:", err)
				}
				insertedMap[key] = true
			}
		}
	}

	fmt.Println("Modul Card Level 6 successfully seeded!")
}
