package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type EquipmentService struct {
	equipmentRepo *repository.EquipmentRepository
	logger        *slog.Logger
}

func NewEquipmentService(er *repository.EquipmentRepository, logger *slog.Logger) *EquipmentService {
	return &EquipmentService{equipmentRepo: er, logger: logger}
}

func (s *EquipmentService) Create(ctx context.Context, e *repository.Equipment) error {
	if err := s.equipmentRepo.Create(ctx, e); err != nil {
		s.logger.Error("create equipment", "name", e.Name, "error", err)
		return fmt.Errorf("creating equipment: %w", err)
	}
	s.logger.Info("equipment created", "id", e.ID, "name", e.Name)
	return nil
}

func (s *EquipmentService) GetByID(ctx context.Context, id string) (*repository.Equipment, error) {
	e, err := s.equipmentRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get equipment", "id", id, "error", err)
		}
		return nil, err
	}
	return e, nil
}

func (s *EquipmentService) Update(ctx context.Context, e *repository.Equipment) error {
	if err := s.equipmentRepo.Update(ctx, e); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update equipment", "id", e.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *EquipmentService) Delete(ctx context.Context, id string) error {
	if err := s.equipmentRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete equipment", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *EquipmentService) List(ctx context.Context, params model.PaginationParams, f repository.EquipmentListFilter) ([]repository.Equipment, model.PaginationMeta, error) {
	equipments, total, err := s.equipmentRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list equipments", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return equipments, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}
