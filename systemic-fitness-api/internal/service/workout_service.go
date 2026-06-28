package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type WorkoutService struct {
	workoutRepo  *repository.WorkoutRepository
	exerciseRepo *repository.ExerciseRepository
	logger       *slog.Logger
}

func NewWorkoutService(wr *repository.WorkoutRepository, er *repository.ExerciseRepository, logger *slog.Logger) *WorkoutService {
	return &WorkoutService{workoutRepo: wr, exerciseRepo: er, logger: logger}
}

// ═══════════════════════════════════════════════════════════════
//  Exercise CRUD
// ═══════════════════════════════════════════════════════════════

func (s *WorkoutService) ListExercises(ctx context.Context, params model.PaginationParams, f repository.ExerciseListFilter) ([]repository.Exercise, model.PaginationMeta, error) {
	exercises, total, err := s.exerciseRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list exercises", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return exercises, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *WorkoutService) GetExercise(ctx context.Context, id string) (*repository.Exercise, error) {
	ex, err := s.exerciseRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get exercise", "id", id, "error", err)
		}
		return nil, err
	}
	return ex, nil
}

func (s *WorkoutService) CreateExercise(ctx context.Context, ex *repository.Exercise) error {
	if err := s.exerciseRepo.Create(ctx, ex); err != nil {
		s.logger.Error("create exercise", "name", ex.Name, "error", err)
		return fmt.Errorf("creating exercise: %w", err)
	}
	s.logger.Info("exercise created", "id", ex.ID, "name", ex.Name)
	return nil
}

func (s *WorkoutService) UpdateExercise(ctx context.Context, ex *repository.Exercise, callerRole model.Role) error {
	existing, err := s.exerciseRepo.GetByID(ctx, ex.ID)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update exercise: fetch", "id", ex.ID, "error", err)
		}
		return err
	}
	if existing.IsSystem && callerRole != model.RoleOwner {
		s.logger.Warn("update exercise: system exercise edit denied", "id", ex.ID, "caller_role", callerRole)
		return fmt.Errorf("system exercises can only be edited by the owner")
	}

	// Preserve immutable fields
	ex.IsSystem = existing.IsSystem
	ex.CreatedBy = existing.CreatedBy

	if err := s.exerciseRepo.Update(ctx, ex); err != nil {
		s.logger.Error("update exercise: save", "id", ex.ID, "error", err)
		return err
	}
	s.logger.Info("exercise updated", "id", ex.ID)
	return nil
}

func (s *WorkoutService) DeleteExercise(ctx context.Context, id string, callerRole model.Role) error {
	existing, err := s.exerciseRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete exercise: fetch", "id", id, "error", err)
		}
		return err
	}
	if existing.IsSystem && callerRole != model.RoleOwner {
		s.logger.Warn("delete exercise: system exercise delete denied", "id", id, "caller_role", callerRole)
		return fmt.Errorf("system exercises can only be deleted by the owner")
	}

	if err := s.exerciseRepo.Delete(ctx, id); err != nil {
		s.logger.Error("delete exercise", "id", id, "error", err)
		return err
	}
	s.logger.Info("exercise deleted", "id", id)
	return nil
}

// ═══════════════════════════════════════════════════════════════
//  Workout CRUD
// ═══════════════════════════════════════════════════════════════

func (s *WorkoutService) ListWorkouts(ctx context.Context, params model.PaginationParams, f repository.WorkoutListFilter) ([]repository.Workout, model.PaginationMeta, error) {
	workouts, total, err := s.workoutRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list workouts", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return workouts, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *WorkoutService) GetWorkoutDetail(ctx context.Context, id string) (*repository.WorkoutDetail, error) {
	detail, err := s.workoutRepo.GetDetail(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get workout detail", "id", id, "error", err)
		}
		return nil, err
	}
	return detail, nil
}

type CreateWorkoutInput struct {
	Name                 string                     `json:"name"      validate:"required,min=1,max=100"`
	Description          *string                    `json:"description,omitempty"`
	Type                 string                     `json:"type"      validate:"required,oneof=strength cardio hiit flexibility custom"`
	EstimatedDurationMin *int                       `json:"estimated_duration_min,omitempty" validate:"omitempty,min=1"`
	IsTemplate           bool                       `json:"is_template"`
	Exercises            []WorkoutExerciseInput      `json:"exercises" validate:"required,min=1,dive"`
}

type WorkoutExerciseInput struct {
	ExerciseID    string   `json:"exercise_id"  validate:"required"`
	OrderIndex    int      `json:"order_index"  validate:"min=0"`
	Sets          *int     `json:"sets,omitempty"          validate:"omitempty,min=1"`
	Reps          *string  `json:"reps,omitempty"`
	WeightKg      *float64 `json:"weight_kg,omitempty"     validate:"omitempty,min=0"`
	RestSeconds   *int     `json:"rest_seconds,omitempty"  validate:"omitempty,min=0"`
	Notes         *string  `json:"notes,omitempty"`
	SupersetGroup *int     `json:"superset_group,omitempty"`
}

func (s *WorkoutService) CreateWorkout(ctx context.Context, input *CreateWorkoutInput, createdBy string) (*repository.WorkoutDetail, error) {
	// 1. Create workout row
	w := &repository.Workout{
		Name:                 input.Name,
		Description:          input.Description,
		Type:                 input.Type,
		EstimatedDurationMin: input.EstimatedDurationMin,
		CreatedBy:            &createdBy,
		IsTemplate:           input.IsTemplate,
	}
	if err := s.workoutRepo.Create(ctx, w); err != nil {
		s.logger.Error("create workout", "name", input.Name, "error", err)
		return nil, fmt.Errorf("creating workout: %w", err)
	}

	// 2. Batch insert exercises
	wes := make([]repository.WorkoutExercise, len(input.Exercises))
	for i, e := range input.Exercises {
		wes[i] = repository.WorkoutExercise{
			ExerciseID:    e.ExerciseID,
			OrderIndex:    e.OrderIndex,
			Sets:          e.Sets,
			Reps:          e.Reps,
			WeightKg:      e.WeightKg,
			RestSeconds:   e.RestSeconds,
			Notes:         e.Notes,
			SupersetGroup: e.SupersetGroup,
		}
	}

	if _, err := s.workoutRepo.ReplaceExercises(ctx, w.ID, wes); err != nil {
		s.logger.Error("create workout: insert exercises", "workout_id", w.ID, "error", err)
		return nil, fmt.Errorf("inserting exercises: %w", err)
	}

	s.logger.Info("workout created", "id", w.ID, "name", w.Name, "exercises", len(wes))

	return s.workoutRepo.GetDetail(ctx, w.ID)
}

type UpdateWorkoutInput struct {
	Name                 *string                `json:"name,omitempty"     validate:"omitempty,min=1,max=100"`
	Description          *string                `json:"description,omitempty"`
	Type                 *string                `json:"type,omitempty"     validate:"omitempty,oneof=strength cardio hiit flexibility custom"`
	EstimatedDurationMin *int                   `json:"estimated_duration_min,omitempty" validate:"omitempty,min=1"`
	IsTemplate           *bool                  `json:"is_template,omitempty"`
	Exercises            []WorkoutExerciseInput `json:"exercises,omitempty" validate:"omitempty,min=1,dive"`
}

func (s *WorkoutService) UpdateWorkout(ctx context.Context, id string, input *UpdateWorkoutInput) (*repository.WorkoutDetail, error) {
	existing, err := s.workoutRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update workout: fetch", "id", id, "error", err)
		}
		return nil, err
	}

	// Apply partial updates
	if input.Name != nil {
		existing.Name = *input.Name
	}
	if input.Description != nil {
		existing.Description = input.Description
	}
	if input.Type != nil {
		existing.Type = *input.Type
	}
	if input.EstimatedDurationMin != nil {
		existing.EstimatedDurationMin = input.EstimatedDurationMin
	}
	if input.IsTemplate != nil {
		existing.IsTemplate = *input.IsTemplate
	}

	if err := s.workoutRepo.Update(ctx, existing); err != nil {
		s.logger.Error("update workout: save", "id", id, "error", err)
		return nil, err
	}

	// Replace exercises if provided
	if input.Exercises != nil {
		wes := make([]repository.WorkoutExercise, len(input.Exercises))
		for i, e := range input.Exercises {
			wes[i] = repository.WorkoutExercise{
				ExerciseID:    e.ExerciseID,
				OrderIndex:    e.OrderIndex,
				Sets:          e.Sets,
				Reps:          e.Reps,
				WeightKg:      e.WeightKg,
				RestSeconds:   e.RestSeconds,
				Notes:         e.Notes,
				SupersetGroup: e.SupersetGroup,
			}
		}
		if _, err := s.workoutRepo.ReplaceExercises(ctx, id, wes); err != nil {
			s.logger.Error("update workout: replace exercises", "id", id, "error", err)
			return nil, fmt.Errorf("replacing exercises: %w", err)
		}
	}

	s.logger.Info("workout updated", "id", id)
	return s.workoutRepo.GetDetail(ctx, id)
}

func (s *WorkoutService) DuplicateWorkout(ctx context.Context, id, userID string) (*repository.WorkoutDetail, error) {
	detail, err := s.workoutRepo.Duplicate(ctx, id, userID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, err
		}
		s.logger.Error("duplicate workout", "id", id, "error", err)
		return nil, fmt.Errorf("duplicating workout: %w", err)
	}
	s.logger.Info("workout duplicated", "original_id", id, "new_id", detail.ID)
	return detail, nil
}
