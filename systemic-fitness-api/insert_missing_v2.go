package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
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

	file, err := os.Open("movement_videos_v2.sql")
	if err != nil {
		fmt.Println("Error opening file:", err)
		os.Exit(1)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	inserted := 0
	
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "UPDATE dl_movements") {
			// Extract name
			if !strings.Contains(line, "WHERE name = '") { continue }
			nameParts := strings.Split(line, "WHERE name = '")
			name := strings.TrimSuffix(nameParts[1], "';")

			maleURL := ""
			femaleURL := ""
			
			if strings.Contains(line, "video_url_male = '") {
				maleURL = strings.Split(strings.Split(line, "video_url_male = '")[1], "'")[0]
			}
			if strings.Contains(line, "video_url_female = '") {
				femaleURL = strings.Split(strings.Split(line, "video_url_female = '")[1], "'")[0]
			}

			// Check if exists
			var count int
			err := conn.QueryRow(ctx, "SELECT count(*) FROM dl_movements WHERE name = $1", name).Scan(&count)
			if err != nil {
				fmt.Println("Error checking", name, ":", err)
				continue
			}

			if count == 0 {
				var mUrl, fUrl *string
				if maleURL != "" { mUrl = &maleURL }
				if femaleURL != "" { fUrl = &femaleURL }

				q := `INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories) 
					  VALUES ($1, 'upper', $2, $3, '{"FC"}')`
					      
				_, err = conn.Exec(ctx, q, name, mUrl, fUrl)
				if err != nil {
					fmt.Println("Error inserting", name, ":", err)
				} else {
					fmt.Println("Inserted missing movement:", name)
					inserted++
				}
			}
		}
	}
	
	fmt.Printf("Processed %d new inserts from movement_videos_v2.sql\n", inserted)
	
	var total int
	conn.QueryRow(ctx, "SELECT count(*) FROM dl_movements").Scan(&total)
	fmt.Println("Total dl_movements now:", total)
}
