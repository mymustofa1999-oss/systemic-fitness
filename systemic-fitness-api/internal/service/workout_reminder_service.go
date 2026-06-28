package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/fitcoach/api/internal/repository"
)

// ErrInvalidReminderTime is returned when remind_at is not HH:MM.
var ErrInvalidReminderTime = errors.New("remind_at must be in HH:MM format")

type WorkoutReminderService struct {
	repo   *repository.WorkoutReminderRepository
	logger *slog.Logger
}

func NewWorkoutReminderService(repo *repository.WorkoutReminderRepository, logger *slog.Logger) *WorkoutReminderService {
	return &WorkoutReminderService{repo: repo, logger: logger}
}

// SetWorkoutReminderInput is the body for saving a reminder config.
type SetWorkoutReminderInput struct {
	Enabled    bool   `json:"enabled"`
	DaysOfWeek []int  `json:"days_of_week" validate:"dive,min=0,max=6"`
	RemindAt   string `json:"remind_at"    validate:"required"`
	Timezone   string `json:"timezone"`
}

// GetMine returns the user's config, or a disabled default when none is set.
func (s *WorkoutReminderService) GetMine(ctx context.Context, userID string) (*repository.WorkoutReminder, error) {
	wr, err := s.repo.GetByUser(ctx, userID)
	if err != nil {
		s.logger.Error("get workout reminder", "user_id", userID, "error", err)
		return nil, err
	}
	if wr == nil {
		return &repository.WorkoutReminder{
			UserID:     userID,
			Enabled:    false,
			DaysOfWeek: []int{},
			RemindAt:   "07:00",
			Timezone:   "Asia/Jakarta",
		}, nil
	}
	return wr, nil
}

// SetMine validates and upserts the user's reminder config.
func (s *WorkoutReminderService) SetMine(ctx context.Context, userID string, in SetWorkoutReminderInput) (*repository.WorkoutReminder, error) {
	if _, err := time.Parse("15:04", in.RemindAt); err != nil {
		return nil, ErrInvalidReminderTime
	}

	tz := in.Timezone
	if tz == "" {
		tz = "Asia/Jakarta"
	}
	if _, err := time.LoadLocation(tz); err != nil {
		tz = "Asia/Jakarta" // fall back on an unknown timezone rather than reject
	}

	wr := &repository.WorkoutReminder{
		UserID:     userID,
		Enabled:    in.Enabled,
		DaysOfWeek: in.DaysOfWeek,
		RemindAt:   in.RemindAt,
		Timezone:   tz,
	}
	if err := s.repo.Upsert(ctx, wr); err != nil {
		s.logger.Error("save workout reminder", "user_id", userID, "error", err)
		return nil, fmt.Errorf("saving reminder: %w", err)
	}
	s.logger.Info("workout reminder saved",
		"user_id", userID, "enabled", in.Enabled, "days", in.DaysOfWeek, "at", in.RemindAt)
	return wr, nil
}
