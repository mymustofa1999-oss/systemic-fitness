package service

import (
	"context"
	"fmt"
	"log/slog"
	"time"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type ProgressService struct {
	progressRepo *repository.ProgressRepository
	programRepo  *repository.ProgramRepository
	logger       *slog.Logger
}

func NewProgressService(pr *repository.ProgressRepository, pgr *repository.ProgramRepository, logger *slog.Logger) *ProgressService {
	return &ProgressService{progressRepo: pr, programRepo: pgr, logger: logger}
}

// ═══════════════════════════════════════════════════════════════
//  Log Progress
// ═══════════════════════════════════════════════════════════════

func (s *ProgressService) LogProgress(ctx context.Context, log *repository.ProgressLog) error {
	if err := s.progressRepo.LogProgress(ctx, log); err != nil {
		s.logger.Error("log progress", "user_id", log.UserID, "exercise_id", log.ExerciseID, "error", err)
		return fmt.Errorf("logging progress: %w", err)
	}

	s.logger.Info("progress logged",
		"user_id", log.UserID,
		"exercise_id", log.ExerciseID,
		"workout_id", log.WorkoutID,
	)

	// Check if user completed all workouts for the current week → auto-advance
	go s.checkWeekCompletion(log.UserID)

	return nil
}

// checkWeekCompletion runs asynchronously after logging progress.
// If the user has completed all non-rest days for the current week
// in their active program, advance to the next week (or complete).
func (s *ProgressService) checkWeekCompletion(userID string) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// 1. Get active program
	up, err := s.programRepo.GetActiveUserProgram(ctx, userID)
	if err != nil || up == nil {
		return // no active program
	}

	// 2. Get program schedule for current week
	days, err := s.programRepo.GetDays(ctx, up.ProgramID)
	if err != nil {
		return
	}

	// Count non-rest-day workouts in current week
	requiredWorkouts := 0
	for _, d := range days {
		if d.WeekNumber == up.CurrentWeek && !d.IsRestDay && d.WorkoutID != nil {
			requiredWorkouts++
		}
	}
	if requiredWorkouts == 0 {
		return
	}

	// 3. Count how many workouts user has logged this week
	startDate, err := time.Parse("2006-01-02", up.StartDate)
	if err != nil {
		return
	}
	weekStart := startDate.AddDate(0, 0, (up.CurrentWeek-1)*7)
	weekEnd := weekStart.AddDate(0, 0, 7)

	logged, err := s.progressRepo.CountWorkoutsLoggedInWeek(ctx,
		userID,
		weekStart.Format("2006-01-02"),
		weekEnd.Format("2006-01-02"),
	)
	if err != nil {
		s.logger.Warn("week completion check failed", "user_id", userID, "error", err)
		return
	}

	if logged < requiredWorkouts {
		return // week not yet complete
	}

	// 4. Get program details to check if this was the last week
	program, err := s.programRepo.GetByID(ctx, up.ProgramID)
	if err != nil {
		return
	}

	if up.CurrentWeek >= program.DurationWeeks {
		// Program complete!
		if err := s.programRepo.CompleteUserProgram(ctx, up.ID); err != nil {
			s.logger.Error("failed to complete program", "user_program_id", up.ID, "error", err)
			return
		}
		s.logger.Info("program completed",
			"user_id", userID,
			"program_id", up.ProgramID,
			"user_program_id", up.ID,
		)
		// TODO: trigger on_program_complete automation
	} else {
		// Advance to next week
		nextWeek := up.CurrentWeek + 1
		if err := s.programRepo.AdvanceWeek(ctx, up.ID, nextWeek); err != nil {
			s.logger.Error("failed to advance week", "user_program_id", up.ID, "error", err)
			return
		}
		s.logger.Info("week advanced",
			"user_id", userID,
			"program_id", up.ProgramID,
			"new_week", nextWeek,
		)
	}
}

// ═══════════════════════════════════════════════════════════════
//  History
// ═══════════════════════════════════════════════════════════════

func (s *ProgressService) GetHistory(ctx context.Context, userID string, params model.PaginationParams, f repository.ProgressHistoryFilter) ([]repository.ProgressLog, model.PaginationMeta, error) {
	logs, total, err := s.progressRepo.GetHistory(ctx, userID, params, f)
	if err != nil {
		s.logger.Error("get progress history", "user_id", userID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return logs, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ═══════════════════════════════════════════════════════════════
//  Chart Data
// ═══════════════════════════════════════════════════════════════

func (s *ProgressService) GetChartData(ctx context.Context, userID string, exerciseID, dateFrom, dateTo *string) ([]repository.ExerciseChartData, error) {
	data, err := s.progressRepo.GetChartData(ctx, userID, exerciseID, dateFrom, dateTo)
	if err != nil {
		s.logger.Error("get chart data", "user_id", userID, "error", err)
		return nil, err
	}
	return data, nil
}

// ═══════════════════════════════════════════════════════════════
//  Body Metrics
// ═══════════════════════════════════════════════════════════════

func (s *ProgressService) LogBodyMetric(ctx context.Context, bm *repository.BodyMetric) error {
	if err := s.progressRepo.LogBodyMetric(ctx, bm); err != nil {
		s.logger.Error("log body metric", "user_id", bm.UserID, "error", err)
		return fmt.Errorf("logging body metric: %w", err)
	}
	s.logger.Info("body metric logged", "user_id", bm.UserID, "id", bm.ID)
	return nil
}

func (s *ProgressService) GetBodyMetrics(ctx context.Context, userID string, params model.PaginationParams) ([]repository.BodyMetric, model.PaginationMeta, error) {
	metrics, total, err := s.progressRepo.GetBodyMetrics(ctx, userID, params)
	if err != nil {
		s.logger.Error("get body metrics", "user_id", userID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return metrics, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}
