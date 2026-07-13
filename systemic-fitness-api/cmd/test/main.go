package main

import (
	"context"
	"fmt"
	"log"

	"github.com/fitcoach/api/database"
	"github.com/fitcoach/api/internal/repository"
)

func main() {
	dbURL := "postgres://postgres.udaihnvoqvrfzniqzqun:Fitcoach2026@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres"
	db, err := database.NewPostgresDB(dbURL, 5, 20)
	if err != nil {
		log.Fatal(err)
	}

	repo := repository.NewTrainerCardRepository(db)

	customerID := "0e58838e-cd5c-4875-8019-416ccb112262"
	adminID := "00000000-0000-0000-0000-000000000000"
    movementID := "2e1b1933-c87d-411a-ab93-432a9390234a" // dummy valid or invalid movement, doesn't matter much if it's nil

	card := &repository.TrainerCard{
		CustomerID: customerID,
		Level:      "1",
		CreatedBy:  &adminID,
		Sequences: []repository.TrainerCardSequence{
			{
				ProgramCategoryID: "0fab3849-b661-4199-9ac5-f4d6deffa597",
				SortOrder:         0,
				Sets: []repository.TrainerCardSet{
					{
						SetNumber: 1,
						SortOrder: 0,
						Items: []repository.TrainerCardSetItem{
							{
								BodyPart: "upper", 
                                MovementID: nil,
                                SetsCount: func() *int { i := 1; return &i }(),
							},
						},
					},
				},
			},
		},
	}

	err = repo.UpsertCard(context.Background(), card)
	if err != nil {
		fmt.Printf("ERROR UPSERTING: %v\n", err)
	} else {
		fmt.Println("UPSERT SUCCESSFUL")
	}
}

