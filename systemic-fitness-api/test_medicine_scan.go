package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	connStr := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?default_query_exec_mode=simple_protocol&statement_cache_capacity=0"
	ctx := context.Background()
	
	pool, err := pgxpool.New(ctx, connStr)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer pool.Close()

	medicineCols := `id, name, category, main_function, side_effects, detail_url,
		image_url, is_system, created_by, active_ingredient, exercise_implications,
		exercise_adjustments, flag_level, created_at, updated_at`

	query := fmt.Sprintf("SELECT %s FROM medicines ORDER BY name ASC LIMIT 100 OFFSET 0", medicineCols)
	rows, err := pool.Query(ctx, query)
	if err != nil {
		log.Fatalf("Query failed: %v", err)
	}
	defer rows.Close()

	var count int
	for rows.Next() {
		var ID string
		var Name string
		var Category *string
		var MainFunction *string
		var SideEffects *string
		var DetailURL *string
		var ImageURL *string
		var IsSystem bool
		var CreatedBy *string
		var ActiveIngredient *string
		var ExerciseImplications *string
		var ExerciseAdjustments *string
		var FlagLevel *string
		var CreatedAt interface{}
		var UpdatedAt interface{}
		
		if err := rows.Scan(
			&ID, &Name, &Category, &MainFunction, &SideEffects,
			&DetailURL, &ImageURL, &IsSystem, &CreatedBy,
			&ActiveIngredient, &ExerciseImplications, &ExerciseAdjustments, &FlagLevel,
			&CreatedAt, &UpdatedAt,
		); err != nil {
			log.Fatalf("Scan failed: %v", err)
		}
		count++
	}
	if rows.Err() != nil {
		log.Fatalf("Rows error: %v", rows.Err())
	}
	
	fmt.Printf("Successfully scanned %d medicines.\n", count)
}
