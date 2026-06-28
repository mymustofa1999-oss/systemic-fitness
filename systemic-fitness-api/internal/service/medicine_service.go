package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type MedicineService struct {
	medicineRepo *repository.MedicineRepository
	logger       *slog.Logger
}

func NewMedicineService(mr *repository.MedicineRepository, logger *slog.Logger) *MedicineService {
	return &MedicineService{medicineRepo: mr, logger: logger}
}

func (s *MedicineService) Create(ctx context.Context, m *repository.Medicine) error {
	if err := s.medicineRepo.Create(ctx, m); err != nil {
		s.logger.Error("create medicine", "name", m.Name, "error", err)
		return fmt.Errorf("creating medicine: %w", err)
	}
	s.logger.Info("medicine created", "id", m.ID, "name", m.Name)
	return nil
}

func (s *MedicineService) GetByID(ctx context.Context, id string) (*repository.Medicine, error) {
	m, err := s.medicineRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get medicine", "id", id, "error", err)
		}
		return nil, err
	}
	return m, nil
}

func (s *MedicineService) Update(ctx context.Context, m *repository.Medicine) error {
	if err := s.medicineRepo.Update(ctx, m); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update medicine", "id", m.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *MedicineService) Delete(ctx context.Context, id string) error {
	if err := s.medicineRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete medicine", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *MedicineService) List(ctx context.Context, params model.PaginationParams, f repository.MedicineListFilter) ([]repository.Medicine, model.PaginationMeta, error) {
	medicines, total, err := s.medicineRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list medicines", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return medicines, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}
