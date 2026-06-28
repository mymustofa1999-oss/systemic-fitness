package handler

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type ProgramCategoryHandler struct {
	programCategoryService *service.ProgramCategoryService
}

func NewProgramCategoryHandler(pcs *service.ProgramCategoryService) *ProgramCategoryHandler {
	return &ProgramCategoryHandler{programCategoryService: pcs}
}

// GET /api/program-categories
func (h *ProgramCategoryHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.ProgramCategoryListFilter{
		Search: params.Search,
	}

	categories, meta, err := h.programCategoryService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[ProgramCategory.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch program categories")
		return
	}
	response.OKPaginated(w, categories, meta)
}

// GET /api/program-categories/{id}
func (h *ProgramCategoryHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	pc, err := h.programCategoryService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Program category not found")
			return
		}
		slog.Error("[ProgramCategory.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch program category")
		return
	}
	response.OK(w, pc)
}

// POST /api/program-categories
func (h *ProgramCategoryHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name              string          `json:"name"               validate:"required,min=1,max=200"`
		Code              string          `json:"code"               validate:"required,min=1,max=50"`
		Description       *string         `json:"description,omitempty"`
		ParameterTemplate json.RawMessage `json:"parameter_template,omitempty"`
		DisplayOrder      int             `json:"display_order"`
		IsActive          *bool           `json:"is_active,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())

	isActive := true
	if input.IsActive != nil {
		isActive = *input.IsActive
	}

	paramTemplate := json.RawMessage("{}")
	if len(input.ParameterTemplate) > 0 {
		paramTemplate = input.ParameterTemplate
	}

	pc := &repository.ProgramCategory{
		Name:              input.Name,
		Code:              input.Code,
		Description:       input.Description,
		ParameterTemplate: paramTemplate,
		DisplayOrder:      input.DisplayOrder,
		IsActive:          isActive,
		CreatedBy:         &userID,
	}

	if err := h.programCategoryService.Create(r.Context(), pc); err != nil {
		slog.Error("[ProgramCategory.Create] failed", "name", input.Name, "error", err)
		response.InternalError(w, "Failed to create program category")
		return
	}

	slog.Info("[ProgramCategory.Create] success", "id", pc.ID, "name", pc.Name)
	response.Created(w, pc)
}

// PUT /api/program-categories/{id}
func (h *ProgramCategoryHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name              string          `json:"name"               validate:"required,min=1,max=200"`
		Code              string          `json:"code"               validate:"required,min=1,max=50"`
		Description       *string         `json:"description,omitempty"`
		ParameterTemplate json.RawMessage `json:"parameter_template,omitempty"`
		DisplayOrder      int             `json:"display_order"`
		IsActive          *bool           `json:"is_active,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	isActive := true
	if input.IsActive != nil {
		isActive = *input.IsActive
	}

	paramTemplate := json.RawMessage("{}")
	if len(input.ParameterTemplate) > 0 {
		paramTemplate = input.ParameterTemplate
	}

	pc := &repository.ProgramCategory{
		ID:                id,
		Name:              input.Name,
		Code:              input.Code,
		Description:       input.Description,
		ParameterTemplate: paramTemplate,
		DisplayOrder:      input.DisplayOrder,
		IsActive:          isActive,
	}

	if err := h.programCategoryService.Update(r.Context(), pc); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Program category not found")
			return
		}
		slog.Error("[ProgramCategory.Update] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update program category")
		return
	}
	response.OK(w, pc)
}

// DELETE /api/program-categories/{id}
func (h *ProgramCategoryHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.programCategoryService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Program category not found")
			return
		}
		slog.Error("[ProgramCategory.Delete] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete program category")
		return
	}
	response.SuccessMessage(w, "Program category deleted")
}
