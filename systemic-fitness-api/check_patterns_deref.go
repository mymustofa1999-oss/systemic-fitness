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

	rows, err := db.Query(context.Background(), "SELECT name, pattern, level FROM dl_movements LIMIT 10")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	for rows.Next() {
		var name string
		var pattern *string
		var level *int
		if err := rows.Scan(&name, &pattern, &level); err != nil {
			log.Fatal(err)
		}
		p := "NULL"
		if pattern != nil {
			p = *pattern
		}
		l := "NULL"
		if level != nil {
			l = fmt.Sprintf("%d", *level)
		}
		fmt.Printf("Name: %s, Pattern: %s, Level: %s\n", name, p, l)
	}
}
