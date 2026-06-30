package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type DigitalLibraryService struct {
	dlRepo *repository.DigitalLibraryRepository
	logger *slog.Logger
}

func NewDigitalLibraryService(dlRepo *repository.DigitalLibraryRepository, logger *slog.Logger) *DigitalLibraryService {
	return &DigitalLibraryService{dlRepo: dlRepo, logger: logger}
}

// ─── Categories ─────────────────────────────────────────────────

func (s *DigitalLibraryService) ListCategories(ctx context.Context) ([]repository.DLCategory, error) {
	cats, err := s.dlRepo.ListCategories(ctx)
	if err != nil {
		s.logger.Error("list dl categories", "error", err)
		return nil, err
	}
	return cats, nil
}

// ─── Levels ─────────────────────────────────────────────────────

func (s *DigitalLibraryService) ListLevels(ctx context.Context) ([]repository.DLLevel, error) {
	levels, err := s.dlRepo.ListLevels(ctx)
	if err != nil {
		s.logger.Error("list dl levels", "error", err)
		return nil, err
	}
	return levels, nil
}

// ─── Movements ──────────────────────────────────────────────────

func (s *DigitalLibraryService) ListMovements(ctx context.Context, params model.PaginationParams, f repository.DLMovementFilter) ([]repository.DLMovement, model.PaginationMeta, error) {
	movements, total, err := s.dlRepo.ListMovements(ctx, params, f)
	if err != nil {
		s.logger.Error("list dl movements", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return movements, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *DigitalLibraryService) GetMovement(ctx context.Context, id string) (*repository.DLMovement, error) {
	m, err := s.dlRepo.GetMovementByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get dl movement", "id", id, "error", err)
		}
		return nil, err
	}
	return m, nil
}

type CreateMovementInput struct {
	Name           string   `json:"name"             validate:"required,min=1,max=150"`
	BodyPart       string   `json:"body_part"        validate:"required,oneof=upper lower core 'whole body'"`
	VideoURLMale   *string  `json:"video_url_male,omitempty"   validate:"omitempty,url"`
	VideoURLFemale *string  `json:"video_url_female,omitempty" validate:"omitempty,url"`
	ImageURL       *string  `json:"image_url,omitempty"     validate:"omitempty,url"`
	Instructions   []string `json:"instructions,omitempty"`
	Categories     []string `json:"categories"       validate:"required,min=1"`
	Type           *string  `json:"type,omitempty"         validate:"omitempty,oneof=sit stand mat"`
	Pattern        *string  `json:"pattern,omitempty"`
	Level          *int     `json:"level,omitempty"        validate:"omitempty,min=1,max=6"`
	NameEN         *string  `json:"name_en,omitempty"      validate:"omitempty,max=150"`
	InstructionsEN []string `json:"instructions_en,omitempty"`
	DescriptionEN  *string  `json:"description_en,omitempty"`
}

func (s *DigitalLibraryService) CreateMovement(ctx context.Context, input *CreateMovementInput) (*repository.DLMovement, error) {
	m := &repository.DLMovement{
		Name:           input.Name,
		BodyPart:       input.BodyPart,
		VideoURLMale:   input.VideoURLMale,
		VideoURLFemale: input.VideoURLFemale,
		ImageURL:       input.ImageURL,
		Instructions:   input.Instructions,
		Categories:     input.Categories,
		Type:           input.Type,
		Pattern:        input.Pattern,
		Level:          input.Level,
		NameEN:         input.NameEN,
		InstructionsEN: input.InstructionsEN,
		DescriptionEN:  input.DescriptionEN,
	}
	if err := s.dlRepo.CreateMovement(ctx, m); err != nil {
		s.logger.Error("create dl movement", "name", input.Name, "error", err)
		return nil, fmt.Errorf("creating movement: %w", err)
	}
	s.logger.Info("dl movement created", "id", m.ID, "name", m.Name)
	return m, nil
}

type UpdateMovementInput struct {
	Name           string   `json:"name"             validate:"required,min=1,max=150"`
	BodyPart       string   `json:"body_part"        validate:"required,oneof=upper lower core 'whole body'"`
	VideoURLMale   *string  `json:"video_url_male,omitempty"   validate:"omitempty,url"`
	VideoURLFemale *string  `json:"video_url_female,omitempty" validate:"omitempty,url"`
	ImageURL       *string  `json:"image_url,omitempty"     validate:"omitempty,url"`
	Instructions   []string `json:"instructions,omitempty"`
	Categories     []string `json:"categories"       validate:"required,min=1"`
	Type           *string  `json:"type,omitempty"         validate:"omitempty,oneof=sit stand mat"`
	Pattern        *string  `json:"pattern,omitempty"`
	Level          *int     `json:"level,omitempty"        validate:"omitempty,min=1,max=6"`
	NameEN         *string  `json:"name_en,omitempty"      validate:"omitempty,max=150"`
	InstructionsEN []string `json:"instructions_en,omitempty"`
	DescriptionEN  *string  `json:"description_en,omitempty"`
}

func (s *DigitalLibraryService) UpdateMovement(ctx context.Context, id string, input *UpdateMovementInput) (*repository.DLMovement, error) {
	if _, err := s.dlRepo.GetMovementByID(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update dl movement: fetch", "id", id, "error", err)
		}
		return nil, err
	}

	m := &repository.DLMovement{
		ID:             id,
		Name:           input.Name,
		BodyPart:       input.BodyPart,
		VideoURLMale:   input.VideoURLMale,
		VideoURLFemale: input.VideoURLFemale,
		ImageURL:       input.ImageURL,
		Instructions:   input.Instructions,
		Categories:     input.Categories,
		Type:           input.Type,
		Pattern:        input.Pattern,
		Level:          input.Level,
		NameEN:         input.NameEN,
		InstructionsEN: input.InstructionsEN,
		DescriptionEN:  input.DescriptionEN,
	}
	if err := s.dlRepo.UpdateMovement(ctx, m); err != nil {
		s.logger.Error("update dl movement: save", "id", id, "error", err)
		return nil, err
	}
	s.logger.Info("dl movement updated", "id", id)
	return m, nil
}

func (s *DigitalLibraryService) DeleteMovement(ctx context.Context, id string) error {
	if err := s.dlRepo.DeleteMovement(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete dl movement", "id", id, "error", err)
		}
		return err
	}
	s.logger.Info("dl movement deleted", "id", id)
	return nil
}

// ─── Menu Items ─────────────────────────────────────────────────

func (s *DigitalLibraryService) ListMenuItems(ctx context.Context, code string, levelNumber *int) ([]repository.DLMenuItem, error) {
	items, err := s.dlRepo.ListMenuItems(ctx, code, levelNumber)
	if err != nil {
		s.logger.Error("list dl menu items", "code", code, "error", err)
		return nil, err
	}
	return items, nil
}

func (s *DigitalLibraryService) AddModulCardItem(ctx context.Context, levelID string, movementID string) error {
	err := s.dlRepo.AddModulCardItem(ctx, levelID, movementID)
	if err != nil {
		s.logger.Error("add modul card item", "level_id", levelID, "movement_id", movementID, "error", err)
		return err
	}
	return nil
}

func (s *DigitalLibraryService) RemoveModulCardItem(ctx context.Context, levelID string, movementID string) error {
	err := s.dlRepo.RemoveModulCardItem(ctx, levelID, movementID)
	if err != nil {
		s.logger.Error("remove modul card item", "level_id", levelID, "movement_id", movementID, "error", err)
		return err
	}
	return nil
}

// ─── Isolate Items ──────────────────────────────────────────────

func (s *DigitalLibraryService) ListIsolateItems(ctx context.Context, categoryCode string, position *string) ([]repository.DLIsolateItem, error) {
	items, err := s.dlRepo.ListIsolateItems(ctx, categoryCode, position)
	if err != nil {
		s.logger.Error("list dl isolate items", "category", categoryCode, "error", err)
		return nil, err
	}
	return items, nil
}

// ─── Dynamic Items ──────────────────────────────────────────────

func (s *DigitalLibraryService) ListDynamicItems(ctx context.Context, categoryCode string) ([]repository.DLDynamicItem, error) {
	items, err := s.dlRepo.ListDynamicItems(ctx, categoryCode)
	if err != nil {
		s.logger.Error("list dl dynamic items", "category", categoryCode, "error", err)
		return nil, err
	}
	return items, nil
}

// ─── Program Overview ───────────────────────────────────────────

func (s *DigitalLibraryService) GetProgramOverview(ctx context.Context, categoryCode string) (*repository.DLProgramOverview, error) {
	cat, err := s.dlRepo.GetCategoryByCode(ctx, categoryCode)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get dl program overview: category", "code", categoryCode, "error", err)
		}
		return nil, err
	}

	levels, err := s.dlRepo.ListLevels(ctx)
	if err != nil {
		s.logger.Error("get dl program overview: levels", "error", err)
		return nil, err
	}

	menuItems, err := s.dlRepo.ListMenuItems(ctx, categoryCode, nil)
	if err != nil {
		s.logger.Error("get dl program overview: menu", "error", err)
		return nil, err
	}

	isolateItems, err := s.dlRepo.ListIsolateItems(ctx, categoryCode, nil)
	if err != nil {
		s.logger.Error("get dl program overview: isolate", "error", err)
		return nil, err
	}

	dynamicItems, err := s.dlRepo.ListDynamicItems(ctx, categoryCode)
	if err != nil {
		s.logger.Error("get dl program overview: dynamic", "error", err)
		return nil, err
	}

	return &repository.DLProgramOverview{
		Category:     *cat,
		Levels:       levels,
		MenuItems:    menuItems,
		IsolateItems: isolateItems,
		DynamicItems: dynamicItems,
	}, nil
}
