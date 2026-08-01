package service

import (
	"context"

	"github.com/google/uuid"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type SystemicSessionLogService interface {
	CreateLog(ctx context.Context, log *model.SystemicSessionLog) error
	GetLogsByUserID(ctx context.Context, userID uuid.UUID) ([]model.SystemicSessionLog, error)
}

type systemicSessionLogService struct {
	repo repository.SystemicSessionLogRepository
}

func NewSystemicSessionLogService(repo repository.SystemicSessionLogRepository) SystemicSessionLogService {
	return &systemicSessionLogService{repo: repo}
}

func (s *systemicSessionLogService) CreateLog(ctx context.Context, log *model.SystemicSessionLog) error {
	log.ID = uuid.New()
	return s.repo.Create(ctx, log)
}

func (s *systemicSessionLogService) GetLogsByUserID(ctx context.Context, userID uuid.UUID) ([]model.SystemicSessionLog, error) {
	return s.repo.GetByUserID(ctx, userID)
}
