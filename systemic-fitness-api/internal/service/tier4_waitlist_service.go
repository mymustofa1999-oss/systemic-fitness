package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/repository"
)

type Tier4WaitlistService struct {
	repo   *repository.Tier4WaitlistRepository
	logger *slog.Logger
}

func NewTier4WaitlistService(
	repo *repository.Tier4WaitlistRepository, logger *slog.Logger,
) *Tier4WaitlistService {
	return &Tier4WaitlistService{repo: repo, logger: logger}
}

func (s *Tier4WaitlistService) Create(ctx context.Context, e *repository.Tier4WaitlistEntry) error {
	if err := s.repo.Create(ctx, e); err != nil {
		s.logger.Error("create tier4 waitlist", "email", e.Email, "error", err)
		return fmt.Errorf("creating waitlist: %w", err)
	}
	s.logger.Info("tier4 waitlist created",
		"id", e.ID, "email", e.Email, "source", e.Source)
	return nil
}

func (s *Tier4WaitlistService) Get(ctx context.Context, id string) (*repository.Tier4WaitlistEntry, error) {
	e, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get tier4 waitlist", "id", id, "error", err)
		}
		return nil, err
	}
	return e, nil
}

func (s *Tier4WaitlistService) List(ctx context.Context, f repository.Tier4WaitlistFilter) ([]repository.Tier4WaitlistEntry, error) {
	out, err := s.repo.List(ctx, f)
	if err != nil {
		s.logger.Error("list tier4 waitlist", "error", err)
		return nil, err
	}
	return out, nil
}

func (s *Tier4WaitlistService) UpdateStatus(
	ctx context.Context, id, status string, adminNote *string,
) error {
	if err := s.repo.UpdateStatus(ctx, id, status, adminNote); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update tier4 status", "id", id, "error", err)
		}
		return err
	}
	return nil
}
