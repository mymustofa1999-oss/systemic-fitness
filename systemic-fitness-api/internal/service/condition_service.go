package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/repository"
)

// ConditionService orchestrates SF master tables:
// condition_classifications, specific_conditions, physical_status_levels.
type ConditionService struct {
	repo   *repository.ConditionRepository
	logger *slog.Logger
}

func NewConditionService(repo *repository.ConditionRepository, logger *slog.Logger) *ConditionService {
	return &ConditionService{repo: repo, logger: logger}
}

// ─── Classifications ───────────────────────────────────────────────────

func (s *ConditionService) ListClassifications(ctx context.Context, includeInactive bool) ([]repository.ConditionClassification, error) {
	out, err := s.repo.ListClassifications(ctx, includeInactive)
	if err != nil {
		s.logger.Error("list condition classifications", "error", err)
		return nil, err
	}
	return out, nil
}

func (s *ConditionService) GetClassification(ctx context.Context, id string) (*repository.ConditionClassification, error) {
	c, err := s.repo.GetClassificationByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get classification", "id", id, "error", err)
		}
		return nil, err
	}
	return c, nil
}

func (s *ConditionService) CreateClassification(ctx context.Context, c *repository.ConditionClassification) error {
	if err := s.repo.CreateClassification(ctx, c); err != nil {
		s.logger.Error("create classification", "slug", c.Slug, "error", err)
		return fmt.Errorf("creating classification: %w", err)
	}
	s.logger.Info("classification created", "id", c.ID, "slug", c.Slug)
	return nil
}

func (s *ConditionService) UpdateClassification(ctx context.Context, c *repository.ConditionClassification) error {
	if err := s.repo.UpdateClassification(ctx, c); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update classification", "id", c.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *ConditionService) DeleteClassification(ctx context.Context, id string) error {
	if err := s.repo.DeleteClassification(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete classification", "id", id, "error", err)
		}
		return err
	}
	return nil
}

// ─── Specific Conditions ───────────────────────────────────────────────

func (s *ConditionService) ListSpecificConditions(ctx context.Context, f repository.SpecificConditionFilter) ([]repository.SpecificCondition, error) {
	out, err := s.repo.ListSpecificConditions(ctx, f)
	if err != nil {
		s.logger.Error("list specific conditions", "error", err)
		return nil, err
	}
	return out, nil
}

func (s *ConditionService) GetSpecific(ctx context.Context, id string) (*repository.SpecificCondition, error) {
	sc, err := s.repo.GetSpecificByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get specific condition", "id", id, "error", err)
		}
		return nil, err
	}
	return sc, nil
}

func (s *ConditionService) CreateSpecific(ctx context.Context, sc *repository.SpecificCondition) error {
	if err := s.repo.CreateSpecific(ctx, sc); err != nil {
		s.logger.Error("create specific", "slug", sc.Slug, "error", err)
		return fmt.Errorf("creating specific condition: %w", err)
	}
	s.logger.Info("specific condition created", "id", sc.ID, "slug", sc.Slug)
	return nil
}

func (s *ConditionService) UpdateSpecific(ctx context.Context, sc *repository.SpecificCondition) error {
	if err := s.repo.UpdateSpecific(ctx, sc); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update specific", "id", sc.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *ConditionService) DeleteSpecific(ctx context.Context, id string) error {
	if err := s.repo.DeleteSpecific(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete specific", "id", id, "error", err)
		}
		return err
	}
	return nil
}

// ─── Physical Status Levels (read-only for now) ────────────────────────

func (s *ConditionService) ListPhysicalStatusLevels(ctx context.Context, includeInactive bool) ([]repository.PhysicalStatusLevel, error) {
	out, err := s.repo.ListPhysicalStatusLevels(ctx, includeInactive)
	if err != nil {
		s.logger.Error("list physical status levels", "error", err)
		return nil, err
	}
	return out, nil
}
