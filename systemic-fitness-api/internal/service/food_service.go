package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type FoodService struct {
	foodRepo *repository.FoodRepository
	logger   *slog.Logger
}

func NewFoodService(fr *repository.FoodRepository, logger *slog.Logger) *FoodService {
	return &FoodService{foodRepo: fr, logger: logger}
}

func (s *FoodService) Create(ctx context.Context, f *repository.Food) error {
	if err := s.foodRepo.Create(ctx, f); err != nil {
		s.logger.Error("create food", "name", f.Name, "error", err)
		return fmt.Errorf("creating food: %w", err)
	}
	s.logger.Info("food created", "id", f.ID, "name", f.Name)
	return nil
}

func (s *FoodService) GetByID(ctx context.Context, id string) (*repository.Food, error) {
	f, err := s.foodRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get food", "id", id, "error", err)
		}
		return nil, err
	}
	return f, nil
}

func (s *FoodService) Update(ctx context.Context, f *repository.Food) error {
	if err := s.foodRepo.Update(ctx, f); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update food", "id", f.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *FoodService) Delete(ctx context.Context, id string) error {
	if err := s.foodRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete food", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *FoodService) List(ctx context.Context, params model.PaginationParams, f repository.FoodListFilter) ([]repository.Food, model.PaginationMeta, error) {
	foods, total, err := s.foodRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list foods", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return foods, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}
