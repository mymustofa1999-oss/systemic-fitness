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
	if err != nil {
		fmt.Println("Connect error:", err)
		return
	}
	defer conn.Close(ctx)
	
	rows, err := conn.Query(ctx, "SELECT pid, state, query FROM pg_stat_activity WHERE state != 'idle' AND pid != pg_backend_pid()")
	if err != nil {
		fmt.Println("Query error:", err)
		return
	}
	defer rows.Close()
	
	fmt.Println("Active queries:")
	for rows.Next() {
		var pid int
		var state, query string
		rows.Scan(&pid, &state, &query)
		fmt.Printf("PID: %d, State: %s\nQuery: %s\n---\n", pid, state, query)
	}
}

