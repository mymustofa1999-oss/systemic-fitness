package main

import (
	"context"
	"fmt"
	"os"
	"strings"
	"regexp"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()
	pool, err := pgxpool.New(context.Background(), os.Getenv("DATABASE_URL"))
	if err != nil {
		fmt.Println("Error connecting:", err)
		return
	}

	rows, err := pool.Query(context.Background(), "SELECT id, name FROM dl_movements WHERE name LIKE 'http%'")
	if err != nil {
		fmt.Println("Error querying:", err)
		return
	}
	defer rows.Close()

	type update struct {
		id      string
		newName string
	}
	var updates []update

	for rows.Next() {
		var id, name string
		rows.Scan(&id, &name)
		
		newName := name
		
		// If it has pipe
		if strings.Contains(name, "|") {
			parts := strings.Split(name, "|")
			if len(parts) > 1 {
				newName = strings.TrimSpace(parts[1])
			}
		} else {
			// Strip out the YouTube URL using regex
			re := regexp.MustCompile(`https?://[^\s]+`)
			newName = re.ReplaceAllString(name, "")
			newName = strings.TrimSpace(newName)
			
			// If we are just left with e.g. "[L3]" or it's empty
			if newName == "" {
				newName = "Unknown Movement"
			} else if strings.HasPrefix(newName, "[") && strings.HasSuffix(newName, "]") {
				newName = "Unknown Movement " + newName
			}
		}
		
		updates = append(updates, update{id: id, newName: newName})
	}

	fmt.Printf("Found %d movements to fix.\n", len(updates))
	for _, u := range updates {
		_, err := pool.Exec(context.Background(), "UPDATE dl_movements SET name = $1 WHERE id = $2", u.newName, u.id)
		if err != nil {
			fmt.Printf("Failed to update ID %s: %v\n", u.id, err)
		} else {
			fmt.Printf("Updated -> %s\n", u.newName)
		}
	}
}
