package main

import (
	"context"
	"fmt"
	"regexp"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	dbURL := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	pool, err := pgxpool.New(context.Background(), dbURL)
	if err != nil {
		fmt.Println("Error connecting:", err)
		return
	}

	rows, err := pool.Query(context.Background(), "SELECT id, name FROM dl_movements WHERE name LIKE '%http%'")
	if err != nil {
		fmt.Println("Error querying:", err)
		return
	}
	defer rows.Close()

	type update struct {
		id      string
		oldName string
		newName string
	}
	var updates []update

	urlRegex := regexp.MustCompile(`https?://[^\s]+`)
	levelRegex := regexp.MustCompile(`\[L\d\]`)

	for rows.Next() {
		var id, name string
		rows.Scan(&id, &name)
		
		newName := name

		// Extract Level
		level := levelRegex.FindString(name)

		if strings.Contains(name, "|") {
			parts := strings.Split(name, "|")
			
			// Usually parts[0] is the name and parts[1] has the URL. Or vice versa.
			// Let's strip URLs from both parts, and keep the longest non-empty part.
			p0 := strings.TrimSpace(urlRegex.ReplaceAllString(parts[0], ""))
			p1 := strings.TrimSpace(urlRegex.ReplaceAllString(parts[1], ""))
			
			// Remove the level from p0/p1 temporarily to find the real name
			p0_nolevel := strings.TrimSpace(levelRegex.ReplaceAllString(p0, ""))
			p1_nolevel := strings.TrimSpace(levelRegex.ReplaceAllString(p1, ""))
			
			if p0_nolevel != "" {
				newName = p0_nolevel
			} else if p1_nolevel != "" {
				newName = p1_nolevel
			} else {
				newName = "Unknown Movement"
			}
			
		} else {
			// No pipe, just remove URL
			newName = urlRegex.ReplaceAllString(name, "")
			newName = strings.TrimSpace(levelRegex.ReplaceAllString(newName, ""))
			
			if newName == "" {
				newName = "Unknown Movement"
			}
		}
		
		// Append level if it was found and is not already there
		if level != "" && !strings.Contains(newName, level) {
			newName = newName + " " + level
		}
		
		newName = strings.TrimSpace(newName)
		updates = append(updates, update{id: id, oldName: name, newName: newName})
	}

	fmt.Printf("Found %d movements to fix.\n", len(updates))
	for _, u := range updates {
		_, err := pool.Exec(context.Background(), "UPDATE dl_movements SET name = $1 WHERE id = $2", u.newName, u.id)
		if err != nil {
			fmt.Printf("Failed to update ID %s: %v\n", u.id, err)
		} else {
			fmt.Printf("Fixed: '%s' -> '%s'\n", u.oldName, u.newName)
		}
	}
}
