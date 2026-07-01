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
	// Use port 5432 to avoid PgBouncer statement hanging
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres"

	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil {
		fmt.Println("Unable to connect to database:", err)
		os.Exit(1)
	}
	defer conn.Close(ctx)

	files := []string{"movement_videos.sql", "movement_videos_fix.sql", "movement_videos_v2.sql"}

	type Movement struct {
		Name       string
		VideoMale  string
		VideoFem   string
	}

	movements := make(map[string]Movement)

	for _, file := range files {
		f, err := os.Open(file)
		if err != nil {
			fmt.Println("Error opening file:", file, err)
			continue
		}
		scanner := bufio.NewScanner(f)
		for scanner.Scan() {
			line := scanner.Text()
			if strings.HasPrefix(line, "UPDATE dl_movements") {
				// Parse line: UPDATE dl_movements SET video_url_male = '...', video_url_female = '...' WHERE name = '...';
				nameStart := strings.Index(line, "WHERE name = '") + 14
				if nameStart < 14 {
					continue
				}
				nameEnd := strings.Index(line[nameStart:], "';")
				if nameEnd == -1 {
					nameEnd = strings.Index(line[nameStart:], "'")
				}
				if nameEnd == -1 {
					continue
				}
				name := line[nameStart : nameStart+nameEnd]

				maleURL := ""
				femURL := ""
				
				mStart := strings.Index(line, "video_url_male = '") 
				if mStart != -1 {
					mStart += 18
					mEnd := strings.Index(line[mStart:], "'")
					if mEnd != -1 {
						maleURL = line[mStart : mStart+mEnd]
					}
				}

				fStart := strings.Index(line, "video_url_female = '")
				if fStart != -1 {
					fStart += 20
					fEnd := strings.Index(line[fStart:], "'")
					if fEnd != -1 {
						femURL = line[fStart : fStart+fEnd]
					}
				}

				if maleURL == "NULL" { maleURL = "" }
				if femURL == "NULL" { femURL = "" }

				movements[name] = Movement{
					Name:      name,
					VideoMale: maleURL,
					VideoFem:  femURL,
				}
			}
		}
		f.Close()
	}

	fmt.Printf("Found %d unique movements from SQL files.\n", len(movements))

	inserted := 0
	updated := 0
	for _, m := range movements {
		// Update existing
		tag, err := conn.Exec(ctx, `
			UPDATE dl_movements 
			SET video_url_male = NULLIF($1, ''), 
			    video_url_female = NULLIF($2, '')
			WHERE name = $3`,
			m.VideoMale, m.VideoFem, m.Name,
		)
		if err != nil {
			fmt.Println("Error updating", m.Name, ":", err)
			continue
		}

		if tag.RowsAffected() == 0 {
			// Insert new with defaults
			_, err = conn.Exec(ctx, `
				INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, type, pattern, level) 
				VALUES ($1, $2, NULLIF($3, ''), NULLIF($4, ''), $5, $6, $7)`,
				m.Name, "core", m.VideoMale, m.VideoFem, "stand", "Mixed", 1,
			)
			if err != nil {
				fmt.Println("Error inserting", m.Name, ":", err)
				continue
			}
			inserted++
		} else {
			updated++
		}
	}

	fmt.Printf("Done! Inserted: %d, Updated: %d\n", inserted, updated)
}
