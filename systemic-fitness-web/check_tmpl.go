package main
import (
	"context"
	"fmt"
	"github.com/jackc/pgx/v5/pgxpool"
)
func main() {
	dbURL := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol"
	ctx := context.Background()
	pool, _ := pgxpool.New(ctx, dbURL)
	defer pool.Close()
	rows, err := pool.Query(ctx, "SELECT level FROM trainer_card_templates")
    if err != nil { fmt.Println("Err:", err); return }
	for rows.Next() {
		var lvl string
		rows.Scan(&lvl)
		fmt.Println("Template Level:", lvl)
	}
}
