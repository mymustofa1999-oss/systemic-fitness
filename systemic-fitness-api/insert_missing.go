package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"regexp"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load(".env")
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres"

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		fmt.Println("Unable to connect to database:", err)
		os.Exit(1)
	}
	defer conn.Close(ctx)

	file, err := os.Open("movement_videos.sql")
	if err != nil {
		fmt.Println("Error opening file:", err)
		os.Exit(1)
	}
	defer file.Close()

	// UPDATE dl_movements SET video_url_male = '...', video_url_female = '...' WHERE name = 'Arm Rotation' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];
	// or
	// UPDATE dl_movements SET video_url_male = '...' WHERE name = 'Barbel Row' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

	re := regexp.MustCompile(`WHERE name = '([^']+)' AND body_part = '([^']+)' AND categories @> ARRAY\['([^']+)'\]`)

	scanner := bufio.NewScanner(file)
	inserted := 0
	
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "UPDATE dl_movements") {
			matches := re.FindStringSubmatch(line)
			if len(matches) == 4 {
				name := matches[1]
				bodyPart := matches[2]
				category := matches[3]

				maleURL := ""
				femaleURL := ""
				
				if strings.Contains(line, "video_url_male = '") {
					maleURL = strings.Split(strings.Split(line, "video_url_male = '")[1], "'")[0]
				}
				if strings.Contains(line, "video_url_female = '") {
					femaleURL = strings.Split(strings.Split(line, "video_url_female = '")[1], "'")[0]
				}

				// Attempt to insert
				var mUrl, fUrl *string
				if maleURL != "" { mUrl = &maleURL }
				if femaleURL != "" { fUrl = &femaleURL }

				q := `INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories) 
					  VALUES ($1, $2, $3, $4, ARRAY[$5]::training_category[])
					  ON CONFLICT (name) DO UPDATE SET 
					      video_url_male = COALESCE(dl_movements.video_url_male, EXCLUDED.video_url_male),
					      video_url_female = COALESCE(dl_movements.video_url_female, EXCLUDED.video_url_female)`
					      
				_, err = conn.Exec(ctx, q, name, bodyPart, mUrl, fUrl, category)
				if err != nil {
					fmt.Println("Error inserting", name, ":", err)
				} else {
					inserted++
				}
			}
		}
	}
	
	fmt.Printf("Processed %d inserts/updates from movement_videos.sql\n", inserted)
	
	var total int
	conn.QueryRow(ctx, "SELECT count(*) FROM dl_movements").Scan(&total)
	fmt.Println("Total dl_movements now:", total)
}
