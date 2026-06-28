package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/repository"
)

type TrainerCardTemplateService struct {
	repo   *repository.TrainerCardTemplateRepository
	logger *slog.Logger
}

func NewTrainerCardTemplateService(repo *repository.TrainerCardTemplateRepository, logger *slog.Logger) *TrainerCardTemplateService {
	return &TrainerCardTemplateService{repo: repo, logger: logger}
}

func (s *TrainerCardTemplateService) List(ctx context.Context) ([]repository.TrainerCardTemplate, error) {
	return s.repo.List(ctx)
}

func (s *TrainerCardTemplateService) GetByLevel(ctx context.Context, level string) (*repository.TrainerCardTemplate, error) {
	tmpl, err := s.repo.GetByLevel(ctx, level)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, repository.ErrNotFound
		}
		slog.Error("[TemplateService.GetByLevel] failed", "level", level, "error", err)
		return nil, err
	}
	return tmpl, nil
}

func (s *TrainerCardTemplateService) UpsertTemplate(ctx context.Context, tmpl *repository.TrainerCardTemplate) error {
	if err := s.repo.UpsertTemplate(ctx, tmpl); err != nil {
		slog.Error("[TemplateService.UpsertTemplate] failed", "level", tmpl.Level, "error", err)
		return fmt.Errorf("upserting template: %w", err)
	}
	return nil
}

func (s *TrainerCardTemplateService) DeleteTemplate(ctx context.Context, level string) error {
	if err := s.repo.DeleteTemplate(ctx, level); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return repository.ErrNotFound
		}
		slog.Error("[TemplateService.DeleteTemplate] failed", "level", level, "error", err)
		return fmt.Errorf("deleting template: %w", err)
	}
	return nil
}
