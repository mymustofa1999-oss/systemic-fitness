package handler

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
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
	if isActiveStr := r.URL.Query().Get("is_active"); isActiveStr != "" {
		v := isActiveStr == "true" || isActiveStr == "1"
		f.IsActive = &v
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
		Name                 string  `json:"name"          validate:"required,min=1,max=200"`
		Category             *string `json:"category,omitempty"`
		MainFunction         *string `json:"main_function,omitempty"`
		SideEffects          *string `json:"side_effects,omitempty"`
		DetailURL            *string `json:"detail_url,omitempty"`
		ImageID              string  `json:"image_id,omitempty"`
		ImageURL             *string `json:"image_url,omitempty"`
		IsActive             bool    `json:"is_active"`
		ActiveIngredient     *string `json:"active_ingredient,omitempty"`
		ExerciseImplications *string `json:"exercise_implications,omitempty"`
		ExerciseAdjustments  *string `json:"exercise_adjustments,omitempty"`
		FlagLevel            *string `json:"flag_level,omitempty"`
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
		Name:                 input.Name,
		Category:             input.Category,
		MainFunction:         input.MainFunction,
		SideEffects:          input.SideEffects,
		DetailURL:            input.DetailURL,
		ImageURL:             imgURL,
		CreatedBy:            &userID,
		IsActive:             input.IsActive,
		ActiveIngredient:     input.ActiveIngredient,
		ExerciseImplications: input.ExerciseImplications,
		ExerciseAdjustments:  input.ExerciseAdjustments,
		FlagLevel:            input.FlagLevel,
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

	// 1. Read raw body to extract explicit nulls
	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		response.BadRequest(w, "Invalid request body")
		return
	}
	r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	var raw map[string]any
	var explicitNulls []string
	if err := json.Unmarshal(bodyBytes, &raw); err == nil {
		for k, v := range raw {
			if v == nil {
				explicitNulls = append(explicitNulls, k)
			}
		}
	}

	// Helper to check if a JSON key was explicitly sent as null
	isNull := func(field string) bool {
		for _, v := range explicitNulls {
			if v == field {
				return true
			}
		}
		return false
	}

	var input struct {
		Name                 string  `json:"name"          validate:"required,min=1,max=200"`
		Category             *string `json:"category,omitempty"`
		MainFunction         *string `json:"main_function,omitempty"`
		SideEffects          *string `json:"side_effects,omitempty"`
		DetailURL            *string `json:"detail_url,omitempty"`
		ImageID              string  `json:"image_id,omitempty"`
		ImageURL             *string `json:"image_url,omitempty"`
		IsActive             bool    `json:"is_active"`
		ActiveIngredient     *string `json:"active_ingredient,omitempty"`
		ExerciseImplications *string `json:"exercise_implications,omitempty"`
		ExerciseAdjustments  *string `json:"exercise_adjustments,omitempty"`
		FlagLevel            *string `json:"flag_level,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	// 2. Fetch existing record
	existing, err := h.medicineService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Medicine not found")
			return
		}
		slog.Error("[Medicine.Update] get failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch existing medicine")
		return
	}

	// 3. Resolve image URL if new image was provided
	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "medicine", id)

	// 4. Merge values (Fetch -> Merge -> Save pattern)
	// Required fields are always updated
	existing.Name = input.Name
	existing.IsActive = input.IsActive

	// Only update optional fields if they are explicitly provided in the payload
	if input.Category != nil {
		existing.Category = input.Category
	} else if isNull("category") {
		existing.Category = nil
	}

	if input.MainFunction != nil {
		existing.MainFunction = input.MainFunction
	} else if isNull("main_function") {
		existing.MainFunction = nil
	}

	if input.SideEffects != nil {
		existing.SideEffects = input.SideEffects
	} else if isNull("side_effects") {
		existing.SideEffects = nil
	}

	if input.DetailURL != nil {
		existing.DetailURL = input.DetailURL
	} else if isNull("detail_url") {
		existing.DetailURL = nil
	}

	if imgURL != nil {
		existing.ImageURL = imgURL
	} else if isNull("image_url") && isNull("image_id") {
		existing.ImageURL = nil
	}

	if input.ActiveIngredient != nil {
		existing.ActiveIngredient = input.ActiveIngredient
	} else if isNull("active_ingredient") {
		existing.ActiveIngredient = nil
	}

	if input.ExerciseImplications != nil {
		existing.ExerciseImplications = input.ExerciseImplications
	} else if isNull("exercise_implications") {
		existing.ExerciseImplications = nil
	}

	if input.ExerciseAdjustments != nil {
		existing.ExerciseAdjustments = input.ExerciseAdjustments
	} else if isNull("exercise_adjustments") {
		existing.ExerciseAdjustments = nil
	}

	if input.FlagLevel != nil {
		existing.FlagLevel = input.FlagLevel
	} else if isNull("flag_level") {
		existing.FlagLevel = nil
	}

	// 5. Save merged record
	if err := h.medicineService.Update(r.Context(), existing); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Medicine not found")
			return
		}
		slog.Error("[Medicine.Update] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update medicine")
		return
	}

	slog.Info("[Medicine.Update] success", "id", existing.ID, "name", existing.Name)
	response.OK(w, existing)
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

// PATCH /api/medicines/{id}/toggle-active
func (h *MedicineHandler) ToggleActive(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	m, err := h.medicineService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Medicine not found")
			return
		}
		slog.Error("[Medicine.ToggleActive] get failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch medicine")
		return
	}
	m.IsActive = !m.IsActive
	if err := h.medicineService.Update(r.Context(), m); err != nil {
		slog.Error("[Medicine.ToggleActive] update failed", "id", id, "error", err)
		response.InternalError(w, "Failed to toggle medicine status")
		return
	}
	response.OK(w, m)
}
