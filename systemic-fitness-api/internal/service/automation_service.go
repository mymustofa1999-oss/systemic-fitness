package service

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type AutomationService struct {
	automationRepo *repository.AutomationRepository
	logger         *slog.Logger
}

func NewAutomationService(ar *repository.AutomationRepository, logger *slog.Logger) *AutomationService {
	return &AutomationService{automationRepo: ar, logger: logger}
}

func (s *AutomationService) List(ctx context.Context, params model.PaginationParams, f repository.AutomationListFilter) ([]repository.Automation, model.PaginationMeta, error) {
	automations, total, err := s.automationRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list automations", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return automations, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *AutomationService) GetByID(ctx context.Context, id string) (*repository.Automation, error) {
	a, err := s.automationRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get automation", "id", id, "error", err)
		}
		return nil, err
	}
	return a, nil
}

func (s *AutomationService) Create(ctx context.Context, a *repository.Automation) error {
	if err := s.automationRepo.Create(ctx, a); err != nil {
		s.logger.Error("create automation", "name", a.Name, "error", err)
		return err
	}
	s.logger.Info("automation created", "id", a.ID, "name", a.Name, "trigger", a.TriggerType)
	return nil
}

func (s *AutomationService) Update(ctx context.Context, id string, input json.RawMessage) (*repository.Automation, error) {
	existing, err := s.automationRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update automation: fetch", "id", id, "error", err)
		}
		return nil, err
	}

	// Merge update into existing
	if err := json.Unmarshal(input, existing); err != nil {
		s.logger.Error("update automation: unmarshal", "id", id, "error", err)
		return nil, fmt.Errorf("invalid update payload: %w", err)
	}
	existing.ID = id

	if err := s.automationRepo.Update(ctx, existing); err != nil {
		s.logger.Error("update automation: save", "id", id, "error", err)
		return nil, err
	}
	s.logger.Info("automation updated", "id", id)
	return existing, nil
}

func (s *AutomationService) Delete(ctx context.Context, id string) error {
	if err := s.automationRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete automation", "id", id, "error", err)
		}
		return err
	}
	s.logger.Info("automation deleted", "id", id)
	return nil
}

func (s *AutomationService) GetLogs(ctx context.Context, automationID string, params model.PaginationParams) ([]repository.AutomationLog, model.PaginationMeta, error) {
	logs, total, err := s.automationRepo.GetLogs(ctx, automationID, params)
	if err != nil {
		s.logger.Error("get automation logs", "automation_id", automationID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return logs, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}
