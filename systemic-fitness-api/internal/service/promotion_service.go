package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type PromotionService struct {
	promotionRepo *repository.PromotionRepository
	logger        *slog.Logger
}

func NewPromotionService(pr *repository.PromotionRepository, logger *slog.Logger) *PromotionService {
	return &PromotionService{promotionRepo: pr, logger: logger}
}

func (s *PromotionService) Create(ctx context.Context, p *repository.Promotion) error {
	if err := s.promotionRepo.Create(ctx, p); err != nil {
		s.logger.Error("create promotion", "title", p.Title, "error", err)
		return fmt.Errorf("creating promotion: %w", err)
	}
	return nil
}

func (s *PromotionService) GetByID(ctx context.Context, id string) (*repository.Promotion, error) {
	p, err := s.promotionRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get promotion", "id", id, "error", err)
		}
		return nil, err
	}
	return p, nil
}

func (s *PromotionService) Update(ctx context.Context, p *repository.Promotion) error {
	if err := s.promotionRepo.Update(ctx, p); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update promotion", "id", p.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *PromotionService) Delete(ctx context.Context, id string) error {
	if err := s.promotionRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete promotion", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *PromotionService) List(ctx context.Context, params model.PaginationParams, f repository.PromotionListFilter) ([]repository.Promotion, model.PaginationMeta, error) {
	promotions, total, err := s.promotionRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list promotions", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return promotions, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *PromotionService) ListActive(ctx context.Context) ([]repository.Promotion, error) {
	promotions, err := s.promotionRepo.ListActive(ctx)
	if err != nil {
		s.logger.Error("list active promotions", "error", err)
		return nil, err
	}
	return promotions, nil
}
