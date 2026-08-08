package main

import (
	"context"
	"fmt"
	"log"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/xuri/excelize/v2"
)

type MovementData struct {
	Level              int
	Sequence           string
	SetTrack           string
	Type               string
	Section            string
	FemaleMovementName string
	FemaleVideoLink    string
	MaleMovementName   string
	MaleVideoLink      string
	BodyPart           string
}

func main() {
	dbURL := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres"
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer pool.Close()

	// Load categories and levels
	categories := make(map[string]string) // code -> id
	rows, err := pool.Query(ctx, "SELECT id, code FROM dl_categories")
	if err != nil {
		log.Fatal(err)
	}
	for rows.Next() {
		var id, code string
		rows.Scan(&id, &code)
		categories[strings.ToLower(code)] = id
	}
	rows.Close()

	levels := make(map[int]string) // level_number -> id
	rows, err = pool.Query(ctx, "SELECT id, level_number FROM dl_levels")
	if err != nil {
		log.Fatal(err)
	}
	for rows.Next() {
		var id string
		var num int
		rows.Scan(&id, &num)
		levels[num] = id
	}
	rows.Close()

	for level := 1; level <= 6; level++ {
		fmt.Printf("Processing Level %d...\n", level)
		femaleFile := fmt.Sprintf("FEMALE-VIDEO LEVEL %d.xlsx", level)
		maleFile := fmt.Sprintf("MALE-VIDEO LEVEL %d.xlsx", level)
		if level == 2 || level == 3 || level == 4 {
			// Some files have a space after FEMALE-
			femaleFile = fmt.Sprintf("FEMALE- VIDEO LEVEL %d.xlsx", level)
		}
		if level == 3 {
			maleFile = fmt.Sprintf("MALE- VIDEO LEVEL %d.xlsx", level)
		}

		fFemale, err := excelize.OpenFile(femaleFile)
		if err != nil {
			log.Printf("Skip female file level %d: %v", level, err)
			continue
		}
		femaleRows, _ := fFemale.GetRows(fFemale.GetSheetList()[0])
		fFemale.Close()

		fMale, err := excelize.OpenFile(maleFile)
		if err != nil {
			log.Printf("Skip male file level %d: %v", level, err)
			continue
		}
		maleRows, _ := fMale.GetRows(fMale.GetSheetList()[0])
		fMale.Close()

		minRows := len(femaleRows)
		if len(maleRows) < minRows {
			minRows = len(maleRows)
		}

		for i := 1; i < minRows; i++ {
			fRow := femaleRows[i]
			mRow := maleRows[i]

			// Ensure rows have enough columns
			for len(fRow) < 8 {
				fRow = append(fRow, "")
			}
			for len(mRow) < 8 {
				mRow = append(mRow, "")
			}

			seq := strings.TrimSpace(fRow[0])
			setTrack := strings.TrimSpace(fRow[1])
			grpType := strings.TrimSpace(fRow[2])

			fUpper := strings.TrimSpace(fRow[4])
			fLower := strings.TrimSpace(fRow[5])
			fVideo := strings.TrimSpace(fRow[6])

			mUpper := strings.TrimSpace(mRow[4])
			mLower := strings.TrimSpace(mRow[5])
			mVideo := strings.TrimSpace(mRow[6])

			fName := fUpper
			bodyPart := "upper"
			if fName == "" {
				fName = fLower
				bodyPart = "lower"
			}
			mName := mUpper
			if mName == "" {
				mName = mLower
			}

			if fName == "" && mName == "" {
				continue
			}

			// Clean up video link if it's "OK" or "waitlist"
			if !strings.HasPrefix(fVideo, "http") {
				fVideo = ""
			}
			if !strings.HasPrefix(mVideo, "http") {
				mVideo = ""
			}

			// Construct single movement name
			var baseName string
			if fName == mName {
				baseName = fName
			} else if fName != "" && mName != "" {
				baseName = fName + " | " + mName
			} else if fName != "" {
				baseName = fName
			} else {
				baseName = mName
			}

			movementName := fmt.Sprintf("%s [L%d]", baseName, level)

			// 1. Insert Movement
			var movementID string
			err = pool.QueryRow(ctx, `
				INSERT INTO dl_movements (name, body_part, video_url_female, video_url_male, categories)
				VALUES ($1, $2, $3, $4, '{}')
				ON CONFLICT (name, type) DO UPDATE SET video_url_female = EXCLUDED.video_url_female, video_url_male = EXCLUDED.video_url_male
				RETURNING id`, movementName, bodyPart, fVideo, mVideo).Scan(&movementID)
			
			if err != nil {
				// Handle ON CONFLICT which doesn't return ID directly easily if it didn't update something sometimes, but we use DO UPDATE.
				if movementID == "" {
					pool.QueryRow(ctx, "SELECT id FROM dl_movements WHERE name = $1 LIMIT 1", movementName).Scan(&movementID)
				}
			}

			// 2. Insert Menu Item
			catID, okCat := categories[strings.ToLower(seq)]
			levID, okLev := levels[level]

			if okCat && okLev && movementID != "" {
				// Check if exists
				var existingMenu string
				pool.QueryRow(ctx, `SELECT id FROM dl_menu_items WHERE category_id = $1 AND level_id = $2 AND movement_id = $3 LIMIT 1`, catID, levID, movementID).Scan(&existingMenu)
				if existingMenu == "" {
					_, err = pool.Exec(ctx, `
						INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, set_name, group_type, sort_order)
						VALUES ($1, $2, $3, $4, $5, $6, $7)`,
						catID, levID, movementID, bodyPart, setTrack, grpType, i)
					if err != nil {
						log.Printf("Error inserting menu item: %v", err)
					}
				}
			}
		}
	}
	fmt.Println("Sync Complete!")
}
