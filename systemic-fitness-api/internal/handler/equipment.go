package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type EquipmentHandler struct {
	equipmentService *service.EquipmentService
}

func NewEquipmentHandler(es *service.EquipmentService) *EquipmentHandler {
	return &EquipmentHandler{equipmentService: es}
}

// GET /api/equipments
func (h *EquipmentHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.EquipmentListFilter{
		Search:   params.Search,
		Category: r.URL.Query().Get("category"),
	}

	equipments, meta, err := h.equipmentService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Equipment.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch equipments")
		return
	}
	response.OKPaginated(w, equipments, meta)
}

// GET /api/equipments/{id}
func (h *EquipmentHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	e, err := h.equipmentService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Equipment not found")
			return
		}
		slog.Error("[Equipment.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch equipment")
		return
	}
	response.OK(w, e)
}

// POST /api/equipments
func (h *EquipmentHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name        string  `json:"name"        validate:"required,min=1,max=100"`
		Category    string  `json:"category"    validate:"required,oneof=upper lower"`
		Description *string `json:"description,omitempty"`
		SortOrder   int     `json:"sort_order"`
		IsActive    *bool   `json:"is_active,omitempty"`
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

	e := &repository.Equipment{
		Name:        input.Name,
		Category:    input.Category,
		Description: input.Description,
		IsActive:    isActive,
		SortOrder:   input.SortOrder,
		CreatedBy:   &userID,
	}

	if err := h.equipmentService.Create(r.Context(), e); err != nil {
		slog.Error("[Equipment.Create] failed", "name", input.Name, "error", err)
		response.InternalError(w, "Failed to create equipment")
		return
	}

	slog.Info("[Equipment.Create] success", "id", e.ID, "name", e.Name)
	response.Created(w, e)
}

// PUT /api/equipments/{id}
func (h *EquipmentHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name        string  `json:"name"        validate:"required,min=1,max=100"`
		Category    string  `json:"category"    validate:"required,oneof=upper lower"`
		Description *string `json:"description,omitempty"`
		SortOrder   int     `json:"sort_order"`
		IsActive    *bool   `json:"is_active,omitempty"`
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

	e := &repository.Equipment{
		ID:          id,
		Name:        input.Name,
		Category:    input.Category,
		Description: input.Description,
		IsActive:    isActive,
		SortOrder:   input.SortOrder,
	}

	if err := h.equipmentService.Update(r.Context(), e); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Equipment not found")
			return
		}
		slog.Error("[Equipment.Update] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update equipment")
		return
	}
	response.OK(w, e)
}

// DELETE /api/equipments/{id}
func (h *EquipmentHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.equipmentService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Equipment not found")
			return
		}
		slog.Error("[Equipment.Delete] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete equipment")
		return
	}
	response.SuccessMessage(w, "Equipment deleted")
}
