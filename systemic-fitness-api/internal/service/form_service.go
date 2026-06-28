package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type FormService struct {
	formRepo *repository.FormRepository
	logger   *slog.Logger
}

func NewFormService(fr *repository.FormRepository, logger *slog.Logger) *FormService {
	return &FormService{formRepo: fr, logger: logger}
}

func (s *FormService) Create(ctx context.Context, f *repository.Form) error {
	if err := s.formRepo.Create(ctx, f); err != nil {
		s.logger.Error("create form", "name", f.Name, "error", err)
		return fmt.Errorf("creating form: %w", err)
	}
	s.logger.Info("form created", "id", f.ID, "name", f.Name)
	return nil
}

func (s *FormService) GetByID(ctx context.Context, id string) (*repository.Form, error) {
	f, err := s.formRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get form", "id", id, "error", err)
		}
		return nil, err
	}
	return f, nil
}

func (s *FormService) Update(ctx context.Context, f *repository.Form) error {
	if err := s.formRepo.Update(ctx, f); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update form", "id", f.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *FormService) Delete(ctx context.Context, id string) error {
	if err := s.formRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete form", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *FormService) List(ctx context.Context, params model.PaginationParams, f repository.FormListFilter) ([]repository.Form, model.PaginationMeta, error) {
	forms, total, err := s.formRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list forms", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return forms, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *FormService) SaveFields(ctx context.Context, formID string, fields []repository.FormField) error {
	if err := s.formRepo.DeleteFieldsByForm(ctx, formID); err != nil {
		s.logger.Error("delete form fields", "form_id", formID, "error", err)
		return err
	}
	for i := range fields {
		fields[i].FormID = formID
		fields[i].SortOrder = i
		if err := s.formRepo.CreateField(ctx, &fields[i]); err != nil {
			s.logger.Error("create form field", "form_id", formID, "label", fields[i].Label, "error", err)
			return fmt.Errorf("creating form field: %w", err)
		}
	}
	return nil
}

func (s *FormService) SubmitResponse(ctx context.Context, resp *repository.FormResponse) error {
	if err := s.formRepo.SubmitResponse(ctx, resp); err != nil {
		s.logger.Error("submit form response", "form_id", resp.FormID, "user_id", resp.UserID, "error", err)
		return fmt.Errorf("submitting form response: %w", err)
	}
	return nil
}

func (s *FormService) ListResponses(ctx context.Context, formID string, params model.PaginationParams) ([]repository.FormResponse, model.PaginationMeta, error) {
	responses, total, err := s.formRepo.ListResponses(ctx, formID, params)
	if err != nil {
		s.logger.Error("list form responses", "form_id", formID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return responses, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}
