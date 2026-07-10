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

	idxFU := colMap["FEMALE_MOVEMENT_UPPER"]
	idxFL := colMap["FEMALE_MOVEMENT_LOWER"]
	idxFV := colMap["FEMALE_VIDEO_LINK"]

	idxMU := colMap["MALE_MOVEMENT_UPPER"]
	idxML := colMap["MALE_MOVEMENT_LOWER"]
	idxMV := colMap["MALE_VIDEO_LINK"]

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

		fv := getCol(idxFV)
		mv := getCol(idxMV)

		// Female movements
		females := []string{getCol(idxFU), getCol(idxFL)}
		for _, m := range females {
			if m != "" && m != "1" && m != "2" && m != "3" && !strings.HasPrefix(m, "http") {
				if fv != "" && strings.HasPrefix(fv, "http") {
					_, err := conn.Exec(ctx, "UPDATE dl_movements SET video_url_female = $1 WHERE name = $2 AND level = 6", fv, m)
					if err != nil {
						fmt.Println("Error updating female video for:", m, err)
					}
				}
			}
		}

		// Male movements
		males := []string{getCol(idxMU), getCol(idxML)}
		for _, m := range males {
			if m != "" && m != "1" && m != "2" && m != "3" && !strings.HasPrefix(m, "http") {
				if mv != "" && strings.HasPrefix(mv, "http") {
					_, err := conn.Exec(ctx, "UPDATE dl_movements SET video_url_male = $1 WHERE name = $2 AND level = 6", mv, m)
					if err != nil {
						fmt.Println("Error updating male video for:", m, err)
					}
				}
			}
		}
	}

	fmt.Println("Videos fixed!")
}
