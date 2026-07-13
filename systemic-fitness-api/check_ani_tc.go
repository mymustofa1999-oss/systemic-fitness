package main

import (
	"context"
	"fmt"
	"log"

	"github.com/mymustofa1999/systemic-fitness/internal/config"
	"github.com/mymustofa1999/systemic-fitness/internal/repository"
	"github.com/mymustofa1999/systemic-fitness/internal/service"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}

	db, err := repository.NewPostgresDB(cfg.DatabaseURL, 5, 20)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	repo := repository.NewTrainerCardRepository(db)
	subRepo := repository.NewClientSubscriptionRepository(db)
	userRepo := repository.NewUserRepository(db)
	trainerCardService := service.NewTrainerCardService(repo, nil, nil, nil, nil) // passing nil for unused dependencies is fine for this test

	svc := service.NewAssessmentV2Service(nil, trainerCardService, subRepo, userRepo, nil)

	ctx := context.Background()
	userID := "2191ef1d-f404-4da1-b125-a005d6ae1dc4" // ani

	tc, err := svc.GetTrainingCard(ctx, userID)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	fmt.Printf("Training Card ID: %s\n", tc.ID)
	fmt.Printf("Sequences count: %d\n", len(tc.Sequences))
}
