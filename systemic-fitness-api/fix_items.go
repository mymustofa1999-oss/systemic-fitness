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
	
	query1 := `
		UPDATE trainer_card_set_items tci
		SET movement_name = m.name
		FROM dl_movements m
		WHERE tci.movement_id = m.id
		AND tci.movement_name LIKE '%http%';
	`
	tag, err := pool.Exec(context.Background(), query1)
	if err != nil {
		fmt.Printf("Error updating set items: %v\n", err)
	} else {
		fmt.Printf("Updated %d rows in trainer_card_set_items\n", tag.RowsAffected())
	}

	query2 := `
		UPDATE trainer_card_template_items tci
		SET movement_name = m.name
		FROM dl_movements m
		WHERE tci.movement_id = m.id
		AND tci.movement_name LIKE '%http%';
	`
	tag2, err2 := pool.Exec(context.Background(), query2)
	if err2 != nil {
		fmt.Printf("Error updating template items: %v\n", err2)
	} else {
		fmt.Printf("Updated %d rows in trainer_card_template_items\n", tag2.RowsAffected())
	}
}
