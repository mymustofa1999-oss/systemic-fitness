package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type HabitService struct {
	habitRepo *repository.HabitRepository
	logger    *slog.Logger
}

func NewHabitService(hr *repository.HabitRepository, logger *slog.Logger) *HabitService {
	return &HabitService{habitRepo: hr, logger: logger}
}

// ─── Folders ───────────────────────────────────────────────────────

func (s *HabitService) CreateFolder(ctx context.Context, f *repository.HabitFolder) error {
	if err := s.habitRepo.CreateFolder(ctx, f); err != nil {
		s.logger.Error("create habit folder", "name", f.Name, "error", err)
		return fmt.Errorf("creating habit folder: %w", err)
	}
	return nil
}

func (s *HabitService) ListFolders(ctx context.Context) ([]repository.HabitFolder, error) {
	folders, err := s.habitRepo.ListFolders(ctx)
	if err != nil {
		s.logger.Error("list habit folders", "error", err)
		return nil, err
	}
	return folders, nil
}

func (s *HabitService) UpdateFolder(ctx context.Context, f *repository.HabitFolder) error {
	if err := s.habitRepo.UpdateFolder(ctx, f); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update habit folder", "id", f.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *HabitService) DeleteFolder(ctx context.Context, id string) error {
	if err := s.habitRepo.DeleteFolder(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete habit folder", "id", id, "error", err)
		}
		return err
	}
	return nil
}

// ─── Habits ────────────────────────────────────────────────────────

func (s *HabitService) Create(ctx context.Context, h *repository.Habit) error {
	if err := s.habitRepo.Create(ctx, h); err != nil {
		s.logger.Error("create habit", "name", h.Name, "error", err)
		return fmt.Errorf("creating habit: %w", err)
	}
	return nil
}

func (s *HabitService) GetByID(ctx context.Context, id string) (*repository.Habit, error) {
	h, err := s.habitRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get habit", "id", id, "error", err)
		}
		return nil, err
	}
	return h, nil
}

func (s *HabitService) Update(ctx context.Context, h *repository.Habit) error {
	if err := s.habitRepo.Update(ctx, h); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update habit", "id", h.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *HabitService) Delete(ctx context.Context, id string) error {
	if err := s.habitRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete habit", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *HabitService) List(ctx context.Context, params model.PaginationParams, f repository.HabitListFilter) ([]repository.Habit, model.PaginationMeta, error) {
	habits, total, err := s.habitRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list habits", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return habits, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ─── Habit Logs ────────────────────────────────────────────────────

func (s *HabitService) LogHabit(ctx context.Context, log *repository.HabitLog) error {
	if err := s.habitRepo.LogHabit(ctx, log); err != nil {
		s.logger.Error("log habit", "user_id", log.UserID, "habit_id", log.HabitID, "error", err)
		return fmt.Errorf("logging habit: %w", err)
	}
	return nil
}

func (s *HabitService) GetUserHabitLogs(ctx context.Context, userID, startDate, endDate string) ([]repository.HabitLog, error) {
	logs, err := s.habitRepo.GetUserHabitLogs(ctx, userID, startDate, endDate)
	if err != nil {
		s.logger.Error("get user habit logs", "user_id", userID, "error", err)
		return nil, err
	}
	return logs, nil
}
