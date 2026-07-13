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
	
	fmt.Println("dl_movements cols:")
	rows, _ := conn.Query(ctx, "SELECT column_name FROM information_schema.columns WHERE table_name = 'dl_movements'")
	for rows.Next() {
		var col string
		rows.Scan(&col)
		fmt.Println("- " + col)
	}
	rows.Close()
	
	fmt.Println("\ndl_menu_items cols:")
	rows2, _ := conn.Query(ctx, "SELECT column_name FROM information_schema.columns WHERE table_name = 'dl_menu_items'")
	for rows2.Next() {
		var col string
		rows2.Scan(&col)
		fmt.Println("- " + col)
	}
	rows2.Close()
}
