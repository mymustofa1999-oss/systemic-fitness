package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type ChallengeService struct {
	challengeRepo *repository.ChallengeRepository
	logger        *slog.Logger
}

func NewChallengeService(cr *repository.ChallengeRepository, logger *slog.Logger) *ChallengeService {
	return &ChallengeService{challengeRepo: cr, logger: logger}
}

func (s *ChallengeService) Create(ctx context.Context, c *repository.Challenge) error {
	if err := s.challengeRepo.Create(ctx, c); err != nil {
		s.logger.Error("create challenge", "name", c.Name, "error", err)
		return fmt.Errorf("creating challenge: %w", err)
	}
	return nil
}

func (s *ChallengeService) GetByID(ctx context.Context, id string) (*repository.Challenge, error) {
	c, err := s.challengeRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get challenge", "id", id, "error", err)
		}
		return nil, err
	}
	return c, nil
}

func (s *ChallengeService) Update(ctx context.Context, c *repository.Challenge) error {
	if err := s.challengeRepo.Update(ctx, c); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update challenge", "id", c.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *ChallengeService) Delete(ctx context.Context, id string) error {
	if err := s.challengeRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete challenge", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *ChallengeService) List(ctx context.Context, params model.PaginationParams, f repository.ChallengeListFilter) ([]repository.Challenge, model.PaginationMeta, error) {
	challenges, total, err := s.challengeRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list challenges", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return challenges, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *ChallengeService) Join(ctx context.Context, cp *repository.ChallengeParticipant) error {
	if err := s.challengeRepo.JoinChallenge(ctx, cp); err != nil {
		s.logger.Error("join challenge", "challenge_id", cp.ChallengeID, "user_id", cp.UserID, "error", err)
		return fmt.Errorf("joining challenge: %w", err)
	}
	return nil
}

func (s *ChallengeService) Leave(ctx context.Context, challengeID, userID string) error {
	return s.challengeRepo.LeaveChallenge(ctx, challengeID, userID)
}

func (s *ChallengeService) UpdateProgress(ctx context.Context, challengeID, userID string, value float64) error {
	return s.challengeRepo.UpdateProgress(ctx, challengeID, userID, value)
}

func (s *ChallengeService) ListParticipants(ctx context.Context, challengeID string) ([]repository.ChallengeParticipant, error) {
	p, err := s.challengeRepo.ListParticipants(ctx, challengeID)
	if err != nil {
		s.logger.Error("list challenge participants", "challenge_id", challengeID, "error", err)
		return nil, err
	}
	return p, nil
}
