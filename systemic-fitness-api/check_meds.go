package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load()
	dbURL := os.Getenv("DATABASE_URL")
	pool, _ := pgxpool.New(context.Background(), dbURL)
	defer pool.Close()

	var cat, mf, se, ai, ei, ea, fl *string
	err := pool.QueryRow(context.Background(), "SELECT category, main_function, side_effects, active_ingredient, exercise_implications, exercise_adjustments, flag_level FROM medicines WHERE name ILIKE '%amlodipine%'").Scan(&cat, &mf, &se, &ai, &ei, &ea, &fl)
	if err != nil {
		log.Fatal(err)
	}

	p := func(s *string) string {
		if s == nil {
			return "<nil>"
		}
		return *s
	}

	fmt.Printf("Amlodipine\nCategory: %s\nMainFunction: %s\nSideEffects: %s\nActiveIngredient: %s\nExerciseImplications: %s\nExerciseAdjustments: %s\nFlagLevel: %s\n", p(cat), p(mf), p(se), p(ai), p(ei), p(ea), p(fl))
}
