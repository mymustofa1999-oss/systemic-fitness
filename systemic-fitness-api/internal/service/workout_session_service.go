package service

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type WorkoutSessionService struct {
	repo            *repository.WorkoutSessionRepository
	trainerCardRepo *repository.TrainerCardRepository
	logger          *slog.Logger
}

func NewWorkoutSessionService(
	repo *repository.WorkoutSessionRepository,
	trainerCardRepo *repository.TrainerCardRepository,
	logger *slog.Logger,
) *WorkoutSessionService {
	return &WorkoutSessionService{repo: repo, trainerCardRepo: trainerCardRepo, logger: logger}
}

// LogWorkoutSessionInput is the body for finishing a guided training session.
type LogWorkoutSessionInput struct {
	SessionType     string `json:"session_type"     validate:"required,oneof=full daily"`
	DurationSeconds int    `json:"duration_seconds" validate:"min=0"`
	Level           string `json:"level"`
}

// Log records a completed session, enriching it with the client's current
// trainer card (id + level) when one exists.
func (s *WorkoutSessionService) Log(ctx context.Context, userID string, in LogWorkoutSessionInput) (*repository.WorkoutSessionLog, error) {
	log := &repository.WorkoutSessionLog{
		UserID:          userID,
		SessionType:     in.SessionType,
		DurationSeconds: in.DurationSeconds,
		Level:           in.Level,
	}

	if card, err := s.trainerCardRepo.GetByCustomerID(ctx, userID); err == nil && card != nil {
		cardID := card.ID
		log.TrainerCardID = &cardID
		if log.Level == "" {
			log.Level = card.Level
		}
	}

	if err := s.repo.Create(ctx, log); err != nil {
		s.logger.Error("log workout session", "user_id", userID, "error", err)
		return nil, fmt.Errorf("logging workout session: %w", err)
	}
	s.logger.Info("workout session logged",
		"user_id", userID, "type", in.SessionType, "duration_s", in.DurationSeconds)
	return log, nil
}

func (s *WorkoutSessionService) ListMine(ctx context.Context, userID string, params model.PaginationParams, f repository.WorkoutSessionFilter) ([]repository.WorkoutSessionLog, model.PaginationMeta, error) {
	logs, total, err := s.repo.ListByUser(ctx, userID, params, f)
	if err != nil {
		s.logger.Error("list workout sessions", "user_id", userID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return logs, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *WorkoutSessionService) MyStats(ctx context.Context, userID string) (*repository.WorkoutSessionStats, error) {
	stats, err := s.repo.Stats(ctx, userID)
	if err != nil {
		s.logger.Error("workout session stats", "user_id", userID, "error", err)
		return nil, err
	}
	return stats, nil
}
