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

type MedicineHandler struct {
	medicineService *service.MedicineService
	images          *imageResolver
}

func NewMedicineHandler(ms *service.MedicineService, us *service.UploadService) *MedicineHandler {
	return &MedicineHandler{medicineService: ms, images: &imageResolver{uploadService: us}}
}

// GET /api/medicines
func (h *MedicineHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.MedicineListFilter{
		Category: queryString(r, "category"),
		Search:   params.Search,
	}

	medicines, meta, err := h.medicineService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Medicine.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch medicines")
		return
	}
	response.OKPaginated(w, medicines, meta)
}

// GET /api/medicines/{id}
func (h *MedicineHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	m, err := h.medicineService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Medicine not found")
			return
		}
		slog.Error("[Medicine.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch medicine")
		return
	}
	response.OK(w, m)
}

// POST /api/medicines
func (h *MedicineHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name         string  `json:"name"          validate:"required,min=1,max=200"`
		Category     *string `json:"category,omitempty"`
		MainFunction *string `json:"main_function,omitempty"`
		SideEffects  *string `json:"side_effects,omitempty"`
		DetailURL    *string `json:"detail_url,omitempty"`
		ImageID      string  `json:"image_id,omitempty"`
		ImageURL     *string `json:"image_url,omitempty"`
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
	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "medicine", "")

	m := &repository.Medicine{
		Name:         input.Name,
		Category:     input.Category,
		MainFunction: input.MainFunction,
		SideEffects:  input.SideEffects,
		DetailURL:    input.DetailURL,
		ImageURL:     imgURL,
		CreatedBy:    &userID,
	}

	if err := h.medicineService.Create(r.Context(), m); err != nil {
		slog.Error("[Medicine.Create] failed", "name", input.Name, "error", err)
		response.InternalError(w, "Failed to create medicine")
		return
	}

	if input.ImageID != "" {
		h.images.resolve(r.Context(), input.ImageID, nil, "medicine", m.ID)
	}

	slog.Info("[Medicine.Create] success", "id", m.ID, "name", m.Name)
	response.Created(w, m)
}

// PUT /api/medicines/{id}
func (h *MedicineHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name         string  `json:"name"          validate:"required,min=1,max=200"`
		Category     *string `json:"category,omitempty"`
		MainFunction *string `json:"main_function,omitempty"`
		SideEffects  *string `json:"side_effects,omitempty"`
		DetailURL    *string `json:"detail_url,omitempty"`
		ImageID      string  `json:"image_id,omitempty"`
		ImageURL     *string `json:"image_url,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "medicine", id)

	m := &repository.Medicine{
		ID:           id,
		Name:         input.Name,
		Category:     input.Category,
		MainFunction: input.MainFunction,
		SideEffects:  input.SideEffects,
		DetailURL:    input.DetailURL,
		ImageURL:     imgURL,
	}

	if err := h.medicineService.Update(r.Context(), m); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Medicine not found")
			return
		}
		slog.Error("[Medicine.Update] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update medicine")
		return
	}
	response.OK(w, m)
}

// DELETE /api/medicines/{id}
func (h *MedicineHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.medicineService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Medicine not found")
			return
		}
		slog.Error("[Medicine.Delete] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete medicine")
		return
	}
	response.SuccessMessage(w, "Medicine deleted")
}
