package main

import (
	"bufio"
	"context"
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
	"github.com/xuri/excelize/v2"
)

type MovementData struct {
	Name      string
	Type      string
	Pattern   string
	Level     int
	VideoMale string
	VideoFem  string
}

func main() {
	_ = godotenv.Load(".env")
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres"

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		log.Fatal("Unable to connect to database:", err)
	}
	defer conn.Close(ctx)

	movementsMap := make(map[string]*MovementData)
	
	normalize := func(s string) string {
		return strings.ToLower(strings.TrimSpace(s))
	}

	// 1. Parse Excel Sheets
	f, err := excelize.OpenFile("Modul Gerakan .xlsx")
	if err == nil {
		defer f.Close()
		levelRegex := regexp.MustCompile(`[Ll]evel\s*(\d+)`)

		for _, sheet := range f.GetSheetList() {
			rows, err := f.GetRows(sheet)
			if err != nil || len(rows) < 2 {
				continue
			}

			if sheet == "Menu FC" || sheet == "Menu CC" || sheet == "Menu MC" {
				row0 := rows[0]
				row1 := rows[1]
				for colIdx := 0; colIdx < len(row0); colIdx++ {
					header := strings.TrimSpace(row0[colIdx])
					matches := levelRegex.FindStringSubmatch(header)
					if len(matches) < 2 { continue }
					var level int
					fmt.Sscanf(matches[1], "%d", &level)

					pattern := "Mixed"
					if colIdx < len(row1) {
						p := strings.TrimSpace(row1[colIdx])
						if p != "" { pattern = p }
					}

					typ := "stand"
					if level == 0 { typ = "mat" } else if level == 1 { typ = "sit" }

					for rowIdx := 2; rowIdx < len(rows); rowIdx++ {
						if colIdx >= len(rows[rowIdx]) { continue }
						name := strings.TrimSpace(rows[rowIdx][colIdx])
						if name == "" || name == "1" || name == "2" || name == "3" { continue }

						key := normalize(name)
						if _, exists := movementsMap[key]; !exists {
							movementsMap[key] = &MovementData{
								Name: name, Type: typ, Pattern: pattern, Level: level,
							}
						}
					}
				}
			} else {
				for rowIdx := 0; rowIdx < len(rows); rowIdx++ {
					row := rows[rowIdx]
					for colIdx := 0; colIdx < len(row); colIdx++ {
						cellVal := strings.TrimSpace(strings.ToUpper(row[colIdx]))
						if cellVal == "FEMALE" || cellVal == "MALE" {
							typeColIdx := -1
							for k := 0; k < colIdx; k++ {
								if strings.TrimSpace(strings.ToUpper(row[k])) == "TYPE" { typeColIdx = k }
							}
							for r := rowIdx + 1; r < len(rows); r++ {
								if colIdx >= len(rows[r]) { continue }
								name := strings.TrimSpace(rows[r][colIdx])
								if name == "" || name == "1" || name == "2" || name == "3" || strings.ToLower(name) == "no movements" || strings.HasPrefix(name, "http") { continue }
								pattern := "Mixed"
								if typeColIdx != -1 && typeColIdx < len(rows[r]) {
									p := strings.TrimSpace(rows[r][typeColIdx])
									if p != "" { pattern = p }
								}
								level := 1
								typ := "stand"
								sheetUpper := strings.ToUpper(sheet)
								if strings.Contains(sheetUpper, "LEVEL 0") { level = 0; typ = "mat" } else if strings.Contains(sheetUpper, "LEVEL 1") { level = 1; typ = "sit" } else if strings.Contains(sheetUpper, "LEVEL 2") { level = 2 } else if strings.Contains(sheetUpper, "LEVEL 3") { level = 3 } else if strings.Contains(sheetUpper, "LEVEL 4") { level = 4 } else if strings.Contains(sheetUpper, "LEVEL 5") { level = 5 } else if strings.Contains(sheetUpper, "LEVEL 6") { level = 6 }

								key := normalize(name)
								if _, exists := movementsMap[key]; !exists {
									movementsMap[key] = &MovementData{
										Name: name, Type: typ, Pattern: pattern, Level: level,
									}
								}
							}
						}
					}
				}
			}
		}
		fmt.Printf("Parsed %d unique movements from Excel.\n", len(movementsMap))
	}

	// 2. Parse database/seeds/009_seed_digital_library.sql
	// Format: ('Arm Rotation', 'upper', 'https://youtu.be/Gv0JzAjI4wE', 'https://youtu.be/CDkR0Hqu_B4', '{fc,cc}'),
	seedRegex := regexp.MustCompile(`\('([^']+)',\s*'[^']+',\s*(NULL|'[^']+'),\s*(NULL|'[^']+'),\s*'[^']+'\),?`)
	
	fSeed, err := os.Open("database/seeds/009_seed_digital_library.sql")
	if err == nil {
		scanner := bufio.NewScanner(fSeed)
		for scanner.Scan() {
			line := scanner.Text()
			matches := seedRegex.FindStringSubmatch(line)
			if len(matches) >= 4 {
				name := matches[1]
				maleURL := matches[2]
				femURL := matches[3]

				if maleURL == "NULL" { maleURL = "" } else { maleURL = strings.Trim(maleURL, "'") }
				if femURL == "NULL" { femURL = "" } else { femURL = strings.Trim(femURL, "'") }

				key := normalize(name)
				if val, exists := movementsMap[key]; exists {
					if val.VideoMale == "" { val.VideoMale = maleURL }
					if val.VideoFem == "" { val.VideoFem = femURL }
				} else {
					movementsMap[key] = &MovementData{
						Name:      name,
						Type:      "stand",
						Pattern:   "Mixed",
						Level:     1,
						VideoMale: maleURL,
						VideoFem:  femURL,
					}
				}
			}
		}
		fSeed.Close()
	}

	// 3. Parse movement_videos*.sql files
	files := []string{"movement_videos.sql", "movement_videos_fix.sql", "movement_videos_v2.sql"}
	for _, file := range files {
		fSQL, err := os.Open(file)
		if err != nil { continue }
		scanner := bufio.NewScanner(fSQL)
		for scanner.Scan() {
			line := scanner.Text()
			if strings.HasPrefix(line, "UPDATE dl_movements") {
				nameStart := strings.Index(line, "WHERE name = '") + 14
				if nameStart < 14 { continue }
				nameEnd := strings.Index(line[nameStart:], "';")
				if nameEnd == -1 { nameEnd = strings.Index(line[nameStart:], "'") }
				if nameEnd == -1 { continue }
				name := line[nameStart : nameStart+nameEnd]

				maleURL := ""
				femURL := ""
				mStart := strings.Index(line, "video_url_male = '") 
				if mStart != -1 {
					mStart += 18
					mEnd := strings.Index(line[mStart:], "'")
					if mEnd != -1 { maleURL = line[mStart : mStart+mEnd] }
				}

				fStart := strings.Index(line, "video_url_female = '")
				if fStart != -1 {
					fStart += 20
					fEnd := strings.Index(line[fStart:], "'")
					if fEnd != -1 { femURL = line[fStart : fStart+fEnd] }
				}

				key := normalize(name)
				if val, exists := movementsMap[key]; exists {
					if maleURL != "NULL" && maleURL != "" { val.VideoMale = maleURL }
					if femURL != "NULL" && femURL != "" { val.VideoFem = femURL }
				} else {
					movementsMap[key] = &MovementData{
						Name:      name,
						Type:      "stand",
						Pattern:   "Mixed",
						Level:     1,
						VideoMale: maleURL,
						VideoFem:  femURL,
					}
				}
			}
		}
		fSQL.Close()
	}

	fmt.Printf("Total unique movements to process: %d\n", len(movementsMap))

	// 4. Insert / Update into PostgreSQL
	inserted := 0
	updated := 0
	for _, m := range movementsMap {
		bodyPart := "core"
		p := strings.ToLower(m.Pattern)
		if strings.Contains(p, "upper") { bodyPart = "upper" } else if strings.Contains(p, "lower") { bodyPart = "lower" }

		tag, err := conn.Exec(ctx, `
			UPDATE dl_movements 
			SET type = $1, pattern = $2, level = $3, body_part = $4,
			    video_url_male = COALESCE(NULLIF($5, ''), video_url_male),
			    video_url_female = COALESCE(NULLIF($6, ''), video_url_female)
			WHERE LOWER(name) = LOWER($7)`,
			m.Type, m.Pattern, m.Level, bodyPart, m.VideoMale, m.VideoFem, m.Name,
		)
		if err != nil {
			fmt.Printf("Error updating %s: %v\n", m.Name, err)
			continue
		}

		if tag.RowsAffected() == 0 {
			_, err = conn.Exec(ctx, `
				INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, type, pattern, level) 
				VALUES ($1, $2, NULLIF($3, ''), NULLIF($4, ''), $5, $6, $7)`,
				m.Name, bodyPart, m.VideoMale, m.VideoFem, m.Type, m.Pattern, m.Level,
			)
			if err != nil {
				fmt.Printf("Error inserting %s: %v\n", m.Name, err)
				continue
			}
			inserted++
		} else {
			updated++
		}
	}

	fmt.Printf("Done! Inserted: %d, Updated: %d\n", inserted, updated)
}
