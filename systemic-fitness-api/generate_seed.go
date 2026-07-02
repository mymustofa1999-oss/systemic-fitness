package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/xuri/excelize/v2"
)

type Movement struct {
	ID             string
	Name           string
	Type           string // "sit", "stand", "mat"
	Pattern        string // "Isolate", "Dynamic"
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

	movements := make(map[string]*Movement) // Key: "Name|Type"

	levelFiles, _ := filepath.Glob("movment/LEVEL *.xlsx")
	levelMap := make(map[int]string)
	for i := 1; i <= 6; i++ {
		var id string
		conn.QueryRow(ctx, "SELECT id FROM dl_levels WHERE level_number = $1", i).Scan(&id)
		levelMap[i] = id
	}

	catMap := make(map[string]string)
	rows, _ := conn.Query(ctx, "SELECT id, code FROM dl_categories")
	for rows.Next() {
		var id, code string
		rows.Scan(&id, &code)
		catMap[strings.ToLower(code)] = id
	}
	rows.Close()

	// First pass: extract all movements
	for _, file := range levelFiles {
		xl, err := excelize.OpenFile(file)
		if err != nil {
			continue
		}
		sheets := xl.GetSheetList()
		if len(sheets) == 0 {
			xl.Close()
			continue
		}
		sheet := sheets[0]
		
		levelNum := 0
		fmt.Sscanf(filepath.Base(file), "LEVEL %d.xlsx", &levelNum)

		defaultType := "stand"
		if levelNum == 1 {
			defaultType = "sit"
		}

		xlRows, _ := xl.GetRows(sheet)
		var currentSeq, currentType, currentSection string

		for _, row := range xlRows {
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
			colSection := getCol(row, 3)
			if colSection != "" {
				currentSection = colSection
			}

			femaleUpper := getCol(row, 4)
			femaleLower := getCol(row, 5)
			femaleVideo := getCol(row, 6)
			
			maleUpper := getCol(row, 7)
			maleLower := getCol(row, 8)
			maleVideo := getCol(row, 9)

			femaleName := femaleUpper
			if femaleName == "" || strings.ToLower(femaleName) == "waitlist" {
				femaleName = femaleLower
			}
			maleName := maleUpper
			if maleName == "" || strings.ToLower(maleName) == "waitlist" {
				maleName = maleLower
			}

			if femaleName == "" && maleName == "" {
				continue
			}
			if strings.ToLower(femaleName) == "waitlist" && strings.ToLower(maleName) == "waitlist" {
				continue
			}

			movementName := femaleName
			if movementName == "" || strings.ToLower(movementName) == "waitlist" {
				movementName = maleName
			}

			catCode := strings.ToUpper(currentSeq)
			if catCode != "FC" && catCode != "CC" && catCode != "MC" {
				catCode = "FC"
			}

			posType := defaultType
			sectionLower := strings.ToLower(currentSection)
			if strings.Contains(sectionLower, "sit") {
				posType = "sit"
			} else if strings.Contains(sectionLower, "stand") {
				posType = "stand"
			} else if strings.Contains(sectionLower, "mat") {
				posType = "mat"
			}

			// Append Category and Level to Name
			displayMovementName := fmt.Sprintf("%s (%s - Level %d)", movementName, catCode, levelNum)
			movKey := displayMovementName + "|" + posType

			if mov, exists := movements[movKey]; !exists {
				movements[movKey] = &Movement{
					ID:             uuid.New().String(),
					Name:           displayMovementName,
					Type:           posType,
					Pattern:        currentType,
					VideoURLFemale: femaleVideo,
					VideoURLMale:   maleVideo,
					BodyPart:       inferBodyPart(currentSection),
					Categories:     []string{strings.ToLower(catCode)},
				}
			} else {
				hasCat := false
				lowerCat := strings.ToLower(catCode)
				for _, c := range mov.Categories {
					if c == lowerCat {
						hasCat = true
						break
					}
				}
				if !hasCat {
					mov.Categories = append(mov.Categories, lowerCat)
				}
				// Allow overwrite of videos if new ones are explicitly found
				if femaleVideo != "" && !strings.Contains(strings.ToLower(femaleVideo), "waitlist") {
					mov.VideoURLFemale = femaleVideo
				}
				if maleVideo != "" && !strings.Contains(strings.ToLower(maleVideo), "waitlist") {
					mov.VideoURLMale = maleVideo
				}
			}
		}
		xl.Close()
	}

	var sql strings.Builder
	sql.WriteString("BEGIN;\n")
	sql.WriteString("TRUNCATE TABLE dl_menu_items, dl_dynamic_items, dl_isolate_items, dl_movements CASCADE;\n")

	for _, mov := range movements {
		cats := "{" + strings.Join(mov.Categories, ",") + "}"
		// Escape single quotes
		name := strings.ReplaceAll(mov.Name, "'", "''")
		female := strings.ReplaceAll(mov.VideoURLFemale, "'", "''")
		if strings.ToLower(female) == "waitlist" {
			female = ""
		}
		male := strings.ReplaceAll(mov.VideoURLMale, "'", "''")
		if strings.ToLower(male) == "waitlist" {
			male = ""
		}
		patternEsc := strings.ReplaceAll(mov.Pattern, "'", "''")
		sql.WriteString(fmt.Sprintf(
			"INSERT INTO dl_movements (id, name, type, pattern, body_part, video_url_male, video_url_female, categories) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');\n",
			mov.ID, name, mov.Type, patternEsc, mov.BodyPart, male, female, cats,
		))
	}

	// Second pass: menu items mapping
	for _, file := range levelFiles {
		xl, _ := excelize.OpenFile(file)
		sheets := xl.GetSheetList()
		if len(sheets) == 0 {
			xl.Close()
			continue
		}
		sheet := sheets[0]
		
		levelNum := 0
		fmt.Sscanf(filepath.Base(file), "LEVEL %d.xlsx", &levelNum)
		levelID := levelMap[levelNum]

		defaultType := "stand"
		if levelNum == 1 {
			defaultType = "sit"
		}

		xlRows, _ := xl.GetRows(sheet)
		var currentSeq, currentSet, currentSection string
		sortOrder := 0

		for _, row := range xlRows {
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
			colSection := getCol(row, 3)
			if colSection != "" { currentSection = colSection }

			femaleUpper := getCol(row, 4)
			femaleLower := getCol(row, 5)
			
			maleUpper := getCol(row, 7)
			maleLower := getCol(row, 8)

			femaleName := femaleUpper
			if femaleName == "" || strings.ToLower(femaleName) == "waitlist" {
				femaleName = femaleLower
			}
			maleName := maleUpper
			if maleName == "" || strings.ToLower(maleName) == "waitlist" {
				maleName = maleLower
			}

			if femaleName == "" && maleName == "" {
				continue
			}
			if strings.ToLower(femaleName) == "waitlist" && strings.ToLower(maleName) == "waitlist" {
				continue
			}

			movementName := femaleName
			if movementName == "" || strings.ToLower(movementName) == "waitlist" {
				movementName = maleName
			}

			catCode := strings.ToUpper(currentSeq)
			catID := catMap[strings.ToLower(catCode)]
			if catID == "" {
				catID = catMap["fc"]
				catCode = "FC"
			}

			posType := defaultType
			sectionLower := strings.ToLower(currentSection)
			if strings.Contains(sectionLower, "sit") {
				posType = "sit"
			} else if strings.Contains(sectionLower, "stand") {
				posType = "stand"
			} else if strings.Contains(sectionLower, "mat") {
				posType = "mat"
			}

			displayMovementName := fmt.Sprintf("%s (%s - Level %d)", movementName, catCode, levelNum)
			movKey := displayMovementName + "|" + posType
			mov := movements[movKey]
			
			if mov == nil || mov.ID == "" {
				// Fallback to searching just by name if position is mismatched
				for _, v := range movements {
					if v.Name == displayMovementName {
						mov = v
						break
					}
				}
				if mov == nil || mov.ID == "" {
					continue
				}
			}

			sortOrder++
			
			setEsc := strings.ReplaceAll(currentSet, "'", "''")
			// We group by Section instead of Type now, e.g. "Sit Upper"
			sectionEsc := strings.ReplaceAll(currentSection, "'", "''")

			sql.WriteString(fmt.Sprintf(
				"INSERT INTO dl_menu_items (id, category_id, level_id, movement_id, body_part, sort_order, set_name, group_type) VALUES ('%s', '%s', '%s', '%s', '%s', %d, '%s', '%s');\n",
				uuid.New().String(), catID, levelID, mov.ID, mov.BodyPart, sortOrder, setEsc, sectionEsc,
			))
		}
		xl.Close()
	}

	sql.WriteString("COMMIT;\n")

	err = os.WriteFile("seed.sql", []byte(sql.String()), 0644)
	if err != nil {
		log.Fatalf("Failed to write seed.sql: %v", err)
	}

	fmt.Println("Generated seed.sql successfully!")
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
