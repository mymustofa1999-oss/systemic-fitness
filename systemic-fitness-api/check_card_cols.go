package main
import (
	"context"
	"fmt"
	"github.com/jackc/pgx/v5"
)
func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol"
	ctx := context.Background()
	conn, _ := pgx.Connect(ctx, connStr)
	defer conn.Close(ctx)
	
	rows, _ := conn.Query(ctx, "SELECT column_name FROM information_schema.columns WHERE table_name = 'training_card_items'")
	for rows.Next() {
		var col string
		rows.Scan(&col)
		fmt.Println("- " + col)
	}
	rows.Close()
}
