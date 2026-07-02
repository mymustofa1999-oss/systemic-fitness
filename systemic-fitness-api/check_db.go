package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5"
)

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:5432/postgres"
	conn, err := pgx.Connect(context.Background(), connStr)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer conn.Close(context.Background())

	var email string
	err = conn.QueryRow(context.Background(), "SELECT email FROM users WHERE email = 'consultant.maya@fitcoach.app'").Scan(&email)
	if err != nil {
		fmt.Println("User not found:", err)
		return
	}
	fmt.Println("User exists:", email)
}
