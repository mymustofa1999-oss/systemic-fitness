package service

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/repository"
)

type DailyJournalService struct {
	repo   *repository.DailyJournalRepository
	logger *slog.Logger
}

func NewDailyJournalService(r *repository.DailyJournalRepository, logger *slog.Logger) *DailyJournalService {
	return &DailyJournalService{repo: r, logger: logger}
}

func (s *DailyJournalService) ListByMonth(ctx context.Context, customerID, monthYear string) ([]repository.JournalSession, error) {
	sessions, err := s.repo.ListByMonth(ctx, customerID, monthYear)
	if err != nil {
		s.logger.Error("list journal sessions", "customer_id", customerID, "month", monthYear, "error", err)
		return nil, fmt.Errorf("listing sessions: %w", err)
	}
	return sessions, nil
}

func (s *DailyJournalService) UpsertSession(ctx context.Context, session *repository.JournalSession) error {
	if err := s.repo.UpsertSession(ctx, session); err != nil {
		s.logger.Error("upsert journal session", "customer_id", session.CustomerID, "error", err)
		return fmt.Errorf("upserting session: %w", err)
	}
	s.logger.Info("journal session saved", "id", session.ID, "session_number", session.SessionNumber)
	return nil
}

func (s *DailyJournalService) DeleteSession(ctx context.Context, sessionID string) error {
	return s.repo.DeleteSession(ctx, sessionID)
}

func (s *DailyJournalService) GetSession(ctx context.Context, sessionID string) (*repository.JournalSession, error) {
	return s.repo.GetSession(ctx, sessionID)
}

func (s *DailyJournalService) ListMonths(ctx context.Context, customerID string) ([]string, error) {
	return s.repo.ListMonths(ctx, customerID)
}
