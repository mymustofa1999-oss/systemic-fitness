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

type Movement struct {
	ID             string
	Name           string
	VideoURLMale   string
	VideoURLFemale string
	BodyPart       string
	Pattern        string
	Categories     []string
}

func normalizeName(n string) string {
	n = strings.ToLower(strings.TrimSpace(n))
	n = strings.ReplaceAll(n, "-", " ")
	return strings.Join(strings.Fields(n), " ") // remove extra spaces
}

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	conn, err := pgxpool.New(ctx, connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	// Truncate tables
	fmt.Println("Wiping existing dl_menu_items and dl_movements...")
	_, err = conn.Exec(ctx, `TRUNCATE TABLE dl_menu_items, dl_movements CASCADE`)
	if err != nil {
		log.Fatal(err)
	}

	femaleVideos := make(map[string]string)
	parseVideoSheet("movment/FEMALE SYSTEMIC MOVEMENT.xlsx", femaleVideos)

	maleVideos := make(map[string]string)
	parseVideoSheet("movment/MALE SYSTEMIC MOVEMENT.xlsx", maleVideos)

	movements := make(map[string]*Movement)

	levelFiles, _ := filepath.Glob("movment/LEVEL_*.xlsx")
	for _, file := range levelFiles {
		xl, err := excelize.OpenFile(file)
		if err != nil { continue }
		sheet := xl.GetSheetList()[0]
		
		levelNum := 0
		fmt.Sscanf(filepath.Base(file), "LEVEL_%d.xlsx", &levelNum)
		if levelNum == 0 && strings.Contains(filepath.Base(file), "LEVEL_6") {
			levelNum = 6
		}

		rows, err := xl.GetRows(sheet)
		if err != nil || len(rows) == 0 { continue }
		
		fmt.Printf("Processing %s (Level %d)\n", file, levelNum)

		headers := rows[0]
		colMap := make(map[string]int)
		for i, h := range headers {
			colMap[strings.TrimSpace(strings.ToUpper(h))] = i
		}

		idxSeq := colMap["SEQUENCE"]
		idxType := colMap["TYPE"]
		idxFU := colMap["FEMALE_MOVEMENT_UPPER"]
		idxFL := colMap["FEMALE_MOVEMENT_LOWER"]
		idxFVideo := colMap["FEMALE_VIDEO_LINK"]
		idxMU := colMap["MALE_MOVEMENT_UPPER"]
		idxML := colMap["MALE_MOVEMENT_LOWER"]
		idxMVideo := colMap["MALE_VIDEO_LINK"]
		idxSection := colMap["SECTION"]

		var currentSeq, currentType, currentSection string

		for i, row := range rows {
			if i == 0 || len(row) == 0 { continue }

			getCol := func(idx int) string {
				if idx != -1 && idx < len(row) { return strings.TrimSpace(row[idx]) }
				return ""
			}

			colSeq := getCol(idxSeq)
			if colSeq != "" { currentSeq = colSeq }
			
			colType := getCol(idxType)
			if colType != "" { currentType = colType }
			
			colSection := getCol(idxSection)
			if colSection != "" { currentSection = colSection }

			fU, fL := getCol(idxFU), getCol(idxFL)
			mU, mL := getCol(idxMU), getCol(idxML)
			fLink, mLink := getCol(idxFVideo), getCol(idxMVideo)
			
			if fU == "" && fL == "" && mU == "" && mL == "" { continue }

			catCode := strings.ToLower(currentSeq)
			if catCode != "fc" && catCode != "cc" && catCode != "mc" { continue }

			var femaleName, maleName string
			var bodyPart string
			isDynamic := strings.Contains(strings.ToLower(currentType), "dynamic")

			if isDynamic {
				// Combine for dynamic
				if fU != "" && fL != "" { femaleName = fU + "-" + fL } else { femaleName = fU + fL }
				if mU != "" && mL != "" { maleName = mU + "-" + mL } else { maleName = mU + mL }
				bodyPart = "whole body"
			} else {
				// For isolate, we usually just take the non-empty one
				femaleName = fU
				if femaleName == "" { femaleName = fL }
				maleName = mU
				if maleName == "" { maleName = mL }
				bodyPart = inferBodyPart(currentSection) // e.g. "upper" or "lower"
			}

			movementName := femaleName
			if maleName != "" && maleName != femaleName {
				if femaleName == "" {
					movementName = maleName
				} else {
					movementName = femaleName + " | " + maleName
				}
			}
			if movementName == "" { continue }

			movementName = fmt.Sprintf("%s [L%d]", movementName, levelNum)

			// Link video from videoMap (fallback to explicit column link if available)
			fVideo := fLink
			if fVideo == "" {
				fVideo = femaleVideos[normalizeName(femaleName)]
				if fVideo == "" && isDynamic { fVideo = femaleVideos[normalizeName(fU + " " + fL)] }
			}

			mVideo := mLink
			if mVideo == "" {
				mVideo = maleVideos[normalizeName(maleName)]
				if mVideo == "" && isDynamic { mVideo = maleVideos[normalizeName(mU + " " + mL)] }
			}

			if mov, exists := movements[movementName]; !exists {
				movements[movementName] = &Movement{
					Name:           movementName,
					VideoURLFemale: fVideo,
					VideoURLMale:   mVideo,
					BodyPart:       bodyPart,
					Pattern:        currentSection,
					Categories:     []string{catCode},
				}
			} else {
				hasCat := false
				for _, c := range mov.Categories {
					if c == catCode { hasCat = true; break }
				}
				if !hasCat { mov.Categories = append(mov.Categories, catCode) }
				if mov.VideoURLFemale == "" { mov.VideoURLFemale = fVideo }
				if mov.VideoURLMale == "" { mov.VideoURLMale = mVideo }
			}
		}
		xl.Close()
	}

	fmt.Printf("Found %d unique systemic movements. Inserting into dl_movements...\n", len(movements))
	for name, mov := range movements {
		var movID string
		fmt.Printf("Inserting %s...", name)
		cats := "{" + strings.Join(mov.Categories, ",") + "}"
		err := conn.QueryRow(ctx, `
			INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, pattern)
			VALUES ($1, $2, $3, $4, $5, $6)
			RETURNING id
		`, mov.Name, mov.BodyPart, mov.VideoURLMale, mov.VideoURLFemale, cats, mov.Pattern).Scan(&movID)
		if err != nil {
			fmt.Println(" Failed:", err)
			log.Printf("Failed to insert movement %s: %v", name, err)
			continue
		}
		fmt.Println(" OK")
		mov.ID = movID
	}

	// Now insert menu items
	for _, file := range levelFiles {
		xl, _ := excelize.OpenFile(file)
		sheet := xl.GetSheetList()[0]
		levelNum := 0
		fmt.Sscanf(filepath.Base(file), "LEVEL_%d.xlsx", &levelNum)
		if levelNum == 0 && strings.Contains(filepath.Base(file), "LEVEL_6") {
			levelNum = 6
		}

		var levelID string
		conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = $1", levelNum).Scan(&levelID)

		rows, _ := xl.GetRows(sheet)
		var currentSeq, currentSet, currentType string
		sortOrder := 0
		
		headers := rows[0]
		colMap := make(map[string]int)
		for i, h := range headers {
			colMap[strings.TrimSpace(strings.ToUpper(h))] = i
		}

		idxSeq := colMap["SEQUENCE"]
		idxSet := colMap["SET/TRACK"]
		if idxSet == 0 { idxSet = colMap["SET"] }
		idxType := colMap["TYPE"]
		idxFU := colMap["FEMALE_MOVEMENT_UPPER"]
		idxFL := colMap["FEMALE_MOVEMENT_LOWER"]
		idxMU := colMap["MALE_MOVEMENT_UPPER"]
		idxML := colMap["MALE_MOVEMENT_LOWER"]

		for i, row := range rows {
			if i == 0 || len(row) == 0 { continue }

			getCol := func(idx int) string {
				if idx != -1 && idx < len(row) { return strings.TrimSpace(row[idx]) }
				return ""
			}

			colSeq := getCol(idxSeq)
			if colSeq != "" { currentSeq = colSeq }
			colSet := getCol(idxSet)
			if colSet != "" { currentSet = colSet }
			colType := getCol(idxType)
			if colType != "" { currentType = colType }

			fU, fL := getCol(idxFU), getCol(idxFL)
			mU, mL := getCol(idxMU), getCol(idxML)
			
			if fU == "" && fL == "" && mU == "" && mL == "" { continue }

			catCode := strings.ToLower(currentSeq)
			if catCode != "fc" && catCode != "cc" && catCode != "mc" { continue }

			var femaleName, maleName string
			isDynamic := strings.Contains(strings.ToLower(currentType), "dynamic")

			if isDynamic {
				if fU != "" && fL != "" { femaleName = fU + "-" + fL } else { femaleName = fU + fL }
				if mU != "" && mL != "" { maleName = mU + "-" + mL } else { maleName = mU + mL }
			} else {
				femaleName = fU
				if femaleName == "" { femaleName = fL }
				maleName = mU
				if maleName == "" { maleName = mL }
			}

			movementName := femaleName
			if maleName != "" && maleName != femaleName {
				if femaleName == "" {
					movementName = maleName
				} else {
					movementName = femaleName + " | " + maleName
				}
			}
			if movementName == "" { continue }

			movementName = fmt.Sprintf("%s [L%d]", movementName, levelNum)

			var catID string
			conn.QueryRow(ctx, "SELECT id FROM dl_categories WHERE code = $1", catCode).Scan(&catID)

			mov := movements[movementName]
			if mov == nil || mov.ID == "" { continue }

			sortOrder++
			
			_, err = conn.Exec(ctx, `
				INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order, set_name, group_type)
				VALUES ($1, $2, $3, $4, $5, $6, $7)
			`, catID, levelID, mov.ID, mov.BodyPart, sortOrder, currentSet, currentType)
			if err != nil {
				log.Printf("Failed to insert menu item %s: %v", movementName, err)
			}
		}
		xl.Close()
	}
	fmt.Println("Done seeding systemic movements and menu items!")
}

func parseVideoSheet(file string, videoMap map[string]string) {
	xl, err := excelize.OpenFile(file)
	if err != nil { return }
	sheets := xl.GetSheetList()
	if len(sheets) == 0 { return }
	sheet := sheets[0]
	rows, err := xl.GetRows(sheet)
	if err != nil { return }
	
	for _, row := range rows {
		if len(row) < 4 { continue }
		name := strings.TrimSpace(row[1])
		lowerName := ""
		if len(row) > 2 {
			lowerName = strings.TrimSpace(row[2])
		}
		url := strings.TrimSpace(row[3])
		
		if name != "" && strings.HasPrefix(url, "http") {
			if lowerName != "" {
				videoMap[normalizeName(name + "-" + lowerName)] = url
				videoMap[normalizeName(name + " " + lowerName)] = url
			} else {
				videoMap[normalizeName(name)] = url
			}
		}
	}
	xl.Close()
}

func inferBodyPart(groupType string) string {
	lower := strings.ToLower(groupType)
	if strings.Contains(lower, "upper") { return "upper" }
	if strings.Contains(lower, "lower") { return "lower" }
	if strings.Contains(lower, "core") { return "core" }
	return "upper"
}

