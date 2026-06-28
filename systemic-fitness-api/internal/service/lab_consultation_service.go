package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/repository"
)

type LabConsultationService struct {
	repo   *repository.LabConsultationRepository
	logger *slog.Logger
}

func NewLabConsultationService(
	repo *repository.LabConsultationRepository, logger *slog.Logger,
) *LabConsultationService {
	return &LabConsultationService{repo: repo, logger: logger}
}

func (s *LabConsultationService) Book(ctx context.Context, l *repository.LabConsultation) error {
	if err := s.repo.Create(ctx, l); err != nil {
		s.logger.Error("book lab consultation", "user_id", l.UserID, "error", err)
		return fmt.Errorf("booking lab consultation: %w", err)
	}
	s.logger.Info("lab consultation booked", "id", l.ID, "user_id", l.UserID)
	return nil
}

func (s *LabConsultationService) Get(ctx context.Context, id string) (*repository.LabConsultation, error) {
	l, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get lab consultation", "id", id, "error", err)
		}
		return nil, err
	}
	return l, nil
}

func (s *LabConsultationService) List(ctx context.Context, f repository.LabConsultationFilter) ([]repository.LabConsultation, error) {
	out, err := s.repo.List(ctx, f)
	if err != nil {
		s.logger.Error("list lab consultations", "error", err)
		return nil, err
	}
	return out, nil
}

func (s *LabConsultationService) Update(ctx context.Context, l *repository.LabConsultation) error {
	if err := s.repo.Update(ctx, l); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update lab consultation", "id", l.ID, "error", err)
		}
		return err
	}
	return nil
}

// AssignConsultant — SF Phase 7b. Dipakai admin/owner untuk meng-assign
// consultant tanpa harus mengirim semua field Update.
func (s *LabConsultationService) AssignConsultant(
	ctx context.Context, id, consultantID string,
) error {
	if err := s.repo.AssignConsultant(ctx, id, consultantID); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("assign consultant", "lab_id", id, "consultant_id", consultantID, "error", err)
		}
		return err
	}
	s.logger.Info("lab consultation assigned", "lab_id", id, "consultant_id", consultantID)
	return nil
}
