package main
import (
	"context"
	"fmt"
	"github.com/jackc/pgx/v5"
)
func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol"
	ctx := context.Background()
	conn, err := pgx.Connect(ctx, connStr)
	if err != nil { return }
	defer conn.Close(ctx)
	
	rows, err := conn.Query(ctx, "SELECT name, video_url_male, video_url_female FROM dl_movements WHERE video_url_male != '' OR video_url_female != '' LIMIT 5")
	if err != nil { return }
	defer rows.Close()
	
	for rows.Next() {
		var name, vm, vf string
		rows.Scan(&name, &vm, &vf)
		fmt.Printf("Name: %s\nMale: %s\nFemale: %s\n\n", name, vm, vf)
	}
}
