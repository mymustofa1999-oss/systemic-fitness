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
	Categories     []string
}

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	conn, err := pgxpool.New(ctx, connStr)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer conn.Close()

	// Clean tables
	fmt.Println("Wiping existing dl_menu_items, dl_dynamic_items, dl_isolate_items, dl_movements...")
	_, err = conn.Exec(ctx, `TRUNCATE TABLE dl_menu_items, dl_dynamic_items, dl_isolate_items, dl_movements CASCADE`)
	if err != nil {
		log.Fatalf("Failed to truncate tables: %v", err)
	}

	femaleVideos := make(map[string]string)
	parseVideoSheet("movment/FEMALE SYSTEMIC MOVEMENT.xlsx", femaleVideos)

	maleVideos := make(map[string]string)
	parseVideoSheet("movment/MALE SYSTEMIC MOVEMENT.xlsx", maleVideos)

	movements := make(map[string]*Movement)

	levelFiles, _ := filepath.Glob("movment/LEVEL *.xlsx")
	for _, file := range levelFiles {
		xl, err := excelize.OpenFile(file)
		if err != nil {
			log.Printf("Error opening %s: %v", file, err)
			continue
		}
		sheets := xl.GetSheetList()
		if len(sheets) == 0 {
			continue
		}
		sheet := sheets[0]
		
		levelNum := 0
		fmt.Sscanf(filepath.Base(file), "LEVEL %d.xlsx", &levelNum)

		var levelID string
		err = conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = $1", levelNum).Scan(&levelID)
		if err != nil {
			log.Printf("Level %d not found in DB: %v", levelNum, err)
			continue
		}

		rows, err := xl.GetRows(sheet)
		if err != nil {
			continue
		}

		fmt.Printf("Processing %s (Level %d)\n", file, levelNum)

		var currentSeq, currentType string

		for _, row := range rows {
			if len(row) == 0 {
				continue
			}
			
			if strings.Contains(strings.ToUpper(row[0]), "SEQUENCE") || strings.Contains(strings.ToUpper(row[0]), "LEVEL") {
				continue
			}

			colSeq := getCol(row, 0)
			if colSeq != "" {
				currentSeq = colSeq
			}
			
			colType := getCol(row, 2)
			if colType != "" {
				currentType = colType
			}

			femaleName := getCol(row, 3)
			maleName := getCol(row, 4)

			if femaleName == "" && maleName == "" {
				continue
			}

			movementName := femaleName
			if movementName == "" {
				movementName = maleName
			}

			catCode := strings.ToLower(currentSeq)
			if catCode != "fc" && catCode != "cc" && catCode != "mc" {
				catCode = "fc"
			}

			if mov, exists := movements[movementName]; !exists {
				movements[movementName] = &Movement{
					Name:           movementName,
					VideoURLFemale: femaleVideos[femaleName],
					VideoURLMale:   maleVideos[maleName],
					BodyPart:       inferBodyPart(currentType),
					Categories:     []string{catCode},
				}
			} else {
				hasCat := false
				for _, c := range mov.Categories {
					if c == catCode {
						hasCat = true
						break
					}
				}
				if !hasCat {
					mov.Categories = append(mov.Categories, catCode)
				}
				if mov.VideoURLFemale == "" {
					mov.VideoURLFemale = femaleVideos[femaleName]
				}
				if mov.VideoURLMale == "" {
					mov.VideoURLMale = maleVideos[maleName]
				}
			}
		}
		xl.Close()
	}

	fmt.Printf("Found %d unique movements. Inserting...\n", len(movements))
	for name, mov := range movements {
		var movID string
		cats := "{" + strings.Join(mov.Categories, ",") + "}"
		err := conn.QueryRow(ctx, `
			INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories)
			VALUES ($1, $2, $3, $4, $5)
			RETURNING id
		`, mov.Name, mov.BodyPart, mov.VideoURLMale, mov.VideoURLFemale, cats).Scan(&movID)
		if err != nil {
			log.Printf("Failed to insert movement %s: %v", name, err)
			continue
		}
		mov.ID = movID
	}

	for _, file := range levelFiles {
		xl, _ := excelize.OpenFile(file)
		sheet := xl.GetSheetList()[0]
		levelNum := 0
		fmt.Sscanf(filepath.Base(file), "LEVEL %d.xlsx", &levelNum)

		var levelID string
		conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = $1", levelNum).Scan(&levelID)

		rows, _ := xl.GetRows(sheet)
		var currentSeq, currentSet, currentType string
		sortOrder := 0

		for _, row := range rows {
			if len(row) == 0 {
				continue
			}
			
			if strings.Contains(strings.ToUpper(row[0]), "SEQUENCE") || strings.Contains(strings.ToUpper(row[0]), "LEVEL") {
				continue
			}

			colSeq := getCol(row, 0)
			if colSeq != "" { currentSeq = colSeq }
			colSet := getCol(row, 1)
			if colSet != "" { currentSet = colSet }
			colType := getCol(row, 2)
			if colType != "" { currentType = colType }

			femaleName := getCol(row, 3)
			maleName := getCol(row, 4)

			if femaleName == "" && maleName == "" {
				continue
			}

			movementName := femaleName
			if movementName == "" {
				movementName = maleName
			}

			catCode := strings.ToLower(currentSeq)
			var catID string
			err := conn.QueryRow(ctx, "SELECT id FROM dl_categories WHERE code = $1", catCode).Scan(&catID)
			if err != nil {
				conn.QueryRow(ctx, "SELECT id FROM dl_categories WHERE code = 'fc'").Scan(&catID)
			}

			mov := movements[movementName]
			if mov == nil || mov.ID == "" {
				continue
			}

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

	fmt.Println("Done seeding movements and menu items!")
}

func parseVideoSheet(file string, videoMap map[string]string) {
	xl, err := excelize.OpenFile(file)
	if err != nil {
		return
	}
	sheets := xl.GetSheetList()
	if len(sheets) == 0 {
		return
	}
	sheet := sheets[0]
	rows, err := xl.GetRows(sheet)
	if err != nil {
		return
	}
	
	for _, row := range rows {
		if len(row) < 4 {
			continue
		}
		name := strings.TrimSpace(row[1])
		url := strings.TrimSpace(row[3])
		
		if name != "" && strings.HasPrefix(url, "http") {
			videoMap[name] = url
		}
	}
	xl.Close()
}

func getCol(row []string, idx int) string {
	if idx < len(row) {
		return strings.TrimSpace(row[idx])
	}
	return ""
}

func inferBodyPart(groupType string) string {
	lower := strings.ToLower(groupType)
	if strings.Contains(lower, "upper") {
		return "upper"
	}
	if strings.Contains(lower, "lower") {
		return "lower"
	}
	if strings.Contains(lower, "core") {
		return "core"
	}
	return "upper"
}
