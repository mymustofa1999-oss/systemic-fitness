package main

import (
	"context"
	"fmt"
	"log"
	"regexp"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/xuri/excelize/v2"
)

func normalizeName(name string) string {
	name = strings.ToLower(strings.TrimSpace(name))
	name = strings.ReplaceAll(name, "-", " ")
	name = strings.ReplaceAll(name, "|", " ")
	
	// Normalize common synonyms/typos between the files
	name = strings.ReplaceAll(name, "side step", "step touch")
	name = strings.ReplaceAll(name, "side lift", "step touch") // some male sheets use side lift
	
	// Fix the "front step" issue carefully without mangling "cross front"
	if strings.HasSuffix(name, "front step") {
		name = strings.Replace(name, "front step", "step touch", 1)
	}

	// Collapse multiple spaces
	re := regexp.MustCompile(`\s+`)
	name = re.ReplaceAllString(name, " ")
	return strings.TrimSpace(name)
}

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
		fmt.Printf("\n--- Processing Level %d ---\n", level)
		maleFile := fmt.Sprintf("MALE-VIDEO LEVEL %d.xlsx", level)

		fMale, err := excelize.OpenFile(maleFile)
		if err != nil {
			log.Printf("Skip male file level %d: %v", level, err)
			continue
		}
		maleRows, _ := fMale.GetRows(fMale.GetSheetList()[0])
		fMale.Close()

		// Build Map of Male Videos
		maleVideos := make(map[string]string)
		
		for i := 1; i < len(maleRows); i++ {
			mRow := maleRows[i]
			for len(mRow) < 8 {
				mRow = append(mRow, "")
			}
			
			mName := strings.TrimSpace(mRow[3])
			if mName == "" {
				mName = strings.TrimSpace(mRow[4])
			}
			
			mVideo := ""
			for _, col := range mRow {
				colTrim := strings.TrimSpace(col)
				if strings.HasPrefix(colTrim, "http") {
					mVideo = colTrim
					break
				}
			}

			if mName != "" && mVideo != "" {
				norm := normalizeName(mName)
				maleVideos[norm] = mVideo
			}
		}

		// Query DB for this level
		rows, err := pool.Query(ctx, "SELECT id, name, COALESCE(video_url_male, '') FROM dl_movements WHERE name LIKE $1", fmt.Sprintf("%%[L%d]%%", level))
		if err != nil {
			log.Fatal(err)
		}

		type Update struct {
			ID  string
			Vid string
		}
		var updates []Update

		matchedCount := 0
		totalCount := 0

		for rows.Next() {
			var id, dbName string
			var dbMaleVid string
			rows.Scan(&id, &dbName, &dbMaleVid)
			totalCount++

			baseName := dbName
			idx := strings.Index(baseName, "[L")
			if idx != -1 {
				baseName = baseName[:idx]
			}
			
			normDB := normalizeName(baseName)
			
			if correctVid, exists := maleVideos[normDB]; exists {
				// Only update if it's currently wrong or missing
				if dbMaleVid != correctVid {
					updates = append(updates, Update{ID: id, Vid: correctVid})
				}
				matchedCount++
			} else {
				// We don't try partial matches to avoid bugs.
				// If it didn't match perfectly, it probably shouldn't have a video anyway.
			}
		}
		rows.Close()
		
		fmt.Printf("Level %d: Matched %d / %d. Need to update %d rows.\n", level, matchedCount, totalCount, len(updates))
		
		for _, u := range updates {
			_, err := pool.Exec(ctx, "UPDATE dl_movements SET video_url_male = $1 WHERE id = $2", u.Vid, u.ID)
			if err != nil {
				log.Printf("Error updating ID %s: %v\n", u.ID, err)
			}
		}
	}
	fmt.Println("Done updating DB!")
}
