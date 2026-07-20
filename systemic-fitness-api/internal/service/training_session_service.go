package service

import (
	"context"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type TrainingSessionService interface {
	GetLogsByPeriod(ctx context.Context, userID string, periodName string) ([]model.TrainingSessionLog, error)
	UpsertLogs(ctx context.Context, userID string, periodName string, logs []model.TrainingSessionLog) error
}

type trainingSessionService struct {
	repo repository.TrainingSessionRepo
}

func NewTrainingSessionService(repo repository.TrainingSessionRepo) TrainingSessionService {
	return &trainingSessionService{repo: repo}
}

func (s *trainingSessionService) GetLogsByPeriod(ctx context.Context, userID string, periodName string) ([]model.TrainingSessionLog, error) {
	return s.repo.GetByUserIDAndPeriod(ctx, userID, periodName)
}

func (s *trainingSessionService) UpsertLogs(ctx context.Context, userID string, periodName string, logs []model.TrainingSessionLog) error {
	// Assign userID and periodName to all logs to ensure consistency
	for i := range logs {
		logs[i].UserID = userID
		logs[i].PeriodName = periodName
	}
	return s.repo.UpsertMany(ctx, logs)
}
