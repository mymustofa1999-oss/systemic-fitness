package main

import (
	"context"
	"fmt"
	"log"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/xuri/excelize/v2"
)

func main() {
	dbURL := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer pool.Close()

	levels := []int{4, 5}
	for _, level := range levels {
		fmt.Printf("Processing Level %d...\n", level)
		femaleFile := fmt.Sprintf("FEMALE- VIDEO LEVEL %d.xlsx", level)
		if level == 5 {
			femaleFile = fmt.Sprintf("FEMALE-VIDEO LEVEL %d.xlsx", level)
		}
		maleFile := fmt.Sprintf("MALE-VIDEO LEVEL %d.xlsx", level)

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

			for len(fRow) < 8 {
				fRow = append(fRow, "")
			}
			for len(mRow) < 8 {
				mRow = append(mRow, "")
			}

			// Get Female Name and Video
			fName := strings.TrimSpace(fRow[4])
			if fName == "" {
				fName = strings.TrimSpace(fRow[5])
			}
			fVideo := strings.TrimSpace(fRow[6])
			if !strings.HasPrefix(fVideo, "http") {
				continue
			}

			// Get Male Video from the wrong columns in Male file
			mVideo := ""
			for _, col := range mRow {
				colTrim := strings.TrimSpace(col)
				if strings.HasPrefix(colTrim, "http") {
					mVideo = colTrim
					break
				}
			}

			if fName == "" {
				continue
			}

			correctName := fmt.Sprintf("%s [L%d]", fName, level)
			levelTag := fmt.Sprintf("%%[L%d]%%", level)

			// Execute Update: we identify the row by its female video URL and level tag.
			// This fixes both the missing male video and the potentially mangled name.
			res, err := pool.Exec(ctx, `
				UPDATE dl_movements 
				SET name = $1, video_url_male = $2 
				WHERE video_url_female = $3 AND name LIKE $4
			`, correctName, mVideo, fVideo, levelTag)

			if err != nil {
				log.Printf("Error updating row %d (Name: %s): %v", i, correctName, err)
			} else {
				if res.RowsAffected() > 0 {
					fmt.Printf("Fixed: %s (MaleVid: %s)\n", correctName, mVideo)
				}
			}
		}
	}
	fmt.Println("Done fixing videos!")
}
