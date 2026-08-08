package main
import (
	"context"
	"fmt"
	"os"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)
func main() {
	godotenv.Load()
	pool, _ := pgxpool.New(context.Background(), os.Getenv("DATABASE_URL"))
	
	// Check dl_dynamic_items
	rows, _ := pool.Query(context.Background(), "SELECT movement_name FROM dl_dynamic_items WHERE movement_name LIKE '%2DFVV%' LIMIT 1")
	for rows.Next() {
		var name string
		rows.Scan(&name)
		fmt.Printf("In dl_dynamic_items: %s\n", name)
	}

	// Check dl_isolate_items
	rows2, _ := pool.Query(context.Background(), "SELECT movement_name FROM dl_isolate_items WHERE movement_name LIKE '%2DFVV%' LIMIT 1")
	for rows2.Next() {
		var name string
		rows2.Scan(&name)
		fmt.Printf("In dl_isolate_items: %s\n", name)
	}
}
