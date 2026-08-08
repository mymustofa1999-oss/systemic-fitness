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
	
	// Check trainer_card_set_items
	rows, _ := pool.Query(context.Background(), "SELECT id, movement_name, movement_id FROM trainer_card_set_items WHERE movement_name LIKE '%http%' LIMIT 5")
	for rows.Next() {
		var id, name, movId string
		rows.Scan(&id, &name, &movId)
		fmt.Printf("TrainerCardSetItem - ID: %s, Name: %s, MovID: %s\n", id, name, movId)
	}

	// Check trainer_card_template_items
	rows2, _ := pool.Query(context.Background(), "SELECT id, movement_name, movement_id FROM trainer_card_template_items WHERE movement_name LIKE '%http%' LIMIT 5")
	for rows2.Next() {
		var id, name, movId string
		rows2.Scan(&id, &name, &movId)
		fmt.Printf("TrainerCardTemplateItem - ID: %s, Name: %s, MovID: %s\n", id, name, movId)
	}
}
