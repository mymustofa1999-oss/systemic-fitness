package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	db, err := pgxpool.New(context.Background(), "postgres://postgres:postgres@localhost:5432/systemic_fitness?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	rows, err := db.Query(context.Background(), "SELECT name, pattern FROM dl_movements LIMIT 20")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	for rows.Next() {
		var name string
		var pattern *string
		if err := rows.Scan(&name, &pattern); err != nil {
			log.Fatal(err)
		}
		p := "NULL"
		if pattern != nil {
			p = *pattern
		}
		fmt.Printf("Name: %s, Pattern: %s\n", name, p)
	}
}
