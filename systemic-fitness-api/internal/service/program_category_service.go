package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type ProgramCategoryService struct {
	programCategoryRepo *repository.ProgramCategoryRepository
	logger              *slog.Logger
}

func NewProgramCategoryService(pcr *repository.ProgramCategoryRepository, logger *slog.Logger) *ProgramCategoryService {
	return &ProgramCategoryService{programCategoryRepo: pcr, logger: logger}
}

func (s *ProgramCategoryService) Create(ctx context.Context, pc *repository.ProgramCategory) error {
	if err := s.programCategoryRepo.Create(ctx, pc); err != nil {
		s.logger.Error("create program category", "name", pc.Name, "error", err)
		return fmt.Errorf("creating program category: %w", err)
	}
	s.logger.Info("program category created", "id", pc.ID, "name", pc.Name)
	return nil
}

func (s *ProgramCategoryService) GetByID(ctx context.Context, id string) (*repository.ProgramCategory, error) {
	pc, err := s.programCategoryRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get program category", "id", id, "error", err)
		}
		return nil, err
	}
	return pc, nil
}

func (s *ProgramCategoryService) Update(ctx context.Context, pc *repository.ProgramCategory) error {
	if err := s.programCategoryRepo.Update(ctx, pc); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update program category", "id", pc.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *ProgramCategoryService) Delete(ctx context.Context, id string) error {
	if err := s.programCategoryRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete program category", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *ProgramCategoryService) List(ctx context.Context, params model.PaginationParams, f repository.ProgramCategoryListFilter) ([]repository.ProgramCategory, model.PaginationMeta, error) {
	categories, total, err := s.programCategoryRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list program categories", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return categories, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}
