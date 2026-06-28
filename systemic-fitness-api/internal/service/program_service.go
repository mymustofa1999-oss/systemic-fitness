package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type ProgramService struct {
	programRepo *repository.ProgramRepository
	logger      *slog.Logger
}

func NewProgramService(pr *repository.ProgramRepository, logger *slog.Logger) *ProgramService {
	return &ProgramService{programRepo: pr, logger: logger}
}

// ═══════════════════════════════════════════════════════════════
//  List / Get
// ═══════════════════════════════════════════════════════════════

func (s *ProgramService) List(ctx context.Context, params model.PaginationParams, f repository.ProgramListFilter) ([]repository.Program, model.PaginationMeta, error) {
	programs, total, err := s.programRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list programs", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return programs, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *ProgramService) GetDetail(ctx context.Context, id string) (*repository.ProgramDetail, error) {
	detail, err := s.programRepo.GetDetail(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get program detail", "id", id, "error", err)
		}
		return nil, err
	}
	return detail, nil
}

func (s *ProgramService) ListTemplates(ctx context.Context) ([]repository.Program, error) {
	templates, err := s.programRepo.ListTemplates(ctx)
	if err != nil {
		s.logger.Error("list templates", "error", err)
		return nil, err
	}
	return templates, nil
}

// ═══════════════════════════════════════════════════════════════
//  Create
// ═══════════════════════════════════════════════════════════════

type ProgramDayInput struct {
	WeekNumber int     `json:"week_number" validate:"required,min=1"`
	DayOfWeek  int     `json:"day_of_week" validate:"min=0,max=6"`
	WorkoutID  *string `json:"workout_id,omitempty"`
	IsRestDay  bool    `json:"is_rest_day"`
}

type CreateProgramInput struct {
	Name          string            `json:"name"           validate:"required,min=1,max=100"`
	Description   *string           `json:"description,omitempty"`
	DurationWeeks int               `json:"duration_weeks" validate:"required,min=1,max=52"`
	Difficulty    string            `json:"difficulty"     validate:"required,oneof=beginner intermediate advanced"`
	Goal          string            `json:"goal"           validate:"required,oneof=lose_weight gain_muscle maintain general_fitness"`
	IsTemplate    bool              `json:"is_template"`
	Days          []ProgramDayInput `json:"days"           validate:"required,min=1,dive"`
}

func (s *ProgramService) Create(ctx context.Context, input *CreateProgramInput, createdBy string) (*repository.ProgramDetail, error) {
	p := &repository.Program{
		Name:          input.Name,
		Description:   input.Description,
		DurationWeeks: input.DurationWeeks,
		Difficulty:    input.Difficulty,
		Goal:          input.Goal,
		CreatedBy:     &createdBy,
		IsTemplate:    input.IsTemplate,
	}
	if err := s.programRepo.Create(ctx, p); err != nil {
		s.logger.Error("create program", "name", input.Name, "error", err)
		return nil, fmt.Errorf("creating program: %w", err)
	}

	// Convert and insert days
	days := make([]repository.ProgramDayInput, len(input.Days))
	for i, d := range input.Days {
		days[i] = repository.ProgramDayInput{
			WeekNumber: d.WeekNumber,
			DayOfWeek:  d.DayOfWeek,
			WorkoutID:  d.WorkoutID,
			IsRestDay:  d.IsRestDay,
		}
	}
	if err := s.programRepo.ReplaceDays(ctx, p.ID, days); err != nil {
		s.logger.Error("create program: insert days", "program_id", p.ID, "error", err)
		return nil, fmt.Errorf("inserting schedule: %w", err)
	}

	s.logger.Info("program created", "id", p.ID, "name", p.Name, "days", len(days))
	return s.programRepo.GetDetail(ctx, p.ID)
}

// ═══════════════════════════════════════════════════════════════
//  Update
// ═══════════════════════════════════════════════════════════════

type UpdateProgramInput struct {
	Name          *string           `json:"name,omitempty"           validate:"omitempty,min=1,max=100"`
	Description   *string           `json:"description,omitempty"`
	DurationWeeks *int              `json:"duration_weeks,omitempty" validate:"omitempty,min=1,max=52"`
	Difficulty    *string           `json:"difficulty,omitempty"     validate:"omitempty,oneof=beginner intermediate advanced"`
	Goal          *string           `json:"goal,omitempty"           validate:"omitempty,oneof=lose_weight gain_muscle maintain general_fitness"`
	Days          []ProgramDayInput `json:"days,omitempty"           validate:"omitempty,min=1,dive"`
}

func (s *ProgramService) Update(ctx context.Context, id string, input *UpdateProgramInput) (*repository.ProgramDetail, error) {
	existing, err := s.programRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update program: fetch", "id", id, "error", err)
		}
		return nil, err
	}

	if input.Name != nil {
		existing.Name = *input.Name
	}
	if input.Description != nil {
		existing.Description = input.Description
	}
	if input.DurationWeeks != nil {
		existing.DurationWeeks = *input.DurationWeeks
	}
	if input.Difficulty != nil {
		existing.Difficulty = *input.Difficulty
	}
	if input.Goal != nil {
		existing.Goal = *input.Goal
	}

	if err := s.programRepo.Update(ctx, existing); err != nil {
		s.logger.Error("update program: save", "id", id, "error", err)
		return nil, err
	}

	// Replace schedule if provided
	if input.Days != nil {
		days := make([]repository.ProgramDayInput, len(input.Days))
		for i, d := range input.Days {
			days[i] = repository.ProgramDayInput{
				WeekNumber: d.WeekNumber,
				DayOfWeek:  d.DayOfWeek,
				WorkoutID:  d.WorkoutID,
				IsRestDay:  d.IsRestDay,
			}
		}
		if err := s.programRepo.ReplaceDays(ctx, id, days); err != nil {
			s.logger.Error("update program: replace days", "id", id, "error", err)
			return nil, fmt.Errorf("replacing schedule: %w", err)
		}
	}

	s.logger.Info("program updated", "id", id)
	return s.programRepo.GetDetail(ctx, id)
}

// ═══════════════════════════════════════════════════════════════
//  Assign to Clients (bulk)
// ═══════════════════════════════════════════════════════════════

type AssignProgramInput struct {
	ClientIDs []string `json:"client_ids" validate:"required,min=1"`
	StartDate string   `json:"start_date" validate:"required"` // YYYY-MM-DD
}

type AssignResult struct {
	Assigned int      `json:"assigned"`
	Failed   []string `json:"failed,omitempty"`
}

func (s *ProgramService) Assign(ctx context.Context, programID string, input *AssignProgramInput, assignedBy string) (*AssignResult, error) {
	// Verify program exists and get duration to calculate end date
	p, err := s.programRepo.GetByID(ctx, programID)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("assign program: fetch", "program_id", programID, "error", err)
		}
		return nil, err
	}

	startDate, err := time.Parse("2006-01-02", input.StartDate)
	if err != nil {
		s.logger.Warn("assign program: invalid date", "start_date", input.StartDate)
		return nil, fmt.Errorf("invalid start_date format, use YYYY-MM-DD")
	}
	endDate := startDate.AddDate(0, 0, p.DurationWeeks*7).Format("2006-01-02")

	result := &AssignResult{}
	for _, clientID := range input.ClientIDs {
		up := &repository.UserProgram{
			UserID:    clientID,
			ProgramID: programID,
			AssignedBy: &assignedBy,
			StartDate: input.StartDate,
			EndDate:   &endDate,
			Status:    "active",
		}
		if err := s.programRepo.AssignToUser(ctx, up); err != nil {
			s.logger.Warn("assign failed", "program_id", programID, "client_id", clientID, "error", err)
			result.Failed = append(result.Failed, clientID)
			continue
		}
		result.Assigned++
	}

	s.logger.Info("program assigned",
		"program_id", programID,
		"assigned", result.Assigned,
		"failed", len(result.Failed),
	)
	return result, nil
}
