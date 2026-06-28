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

type FoodHandler struct {
	foodService *service.FoodService
	images      *imageResolver
}

func NewFoodHandler(fs *service.FoodService, us *service.UploadService) *FoodHandler {
	return &FoodHandler{foodService: fs, images: &imageResolver{uploadService: us}}
}

// GET /api/foods
func (h *FoodHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.FoodListFilter{
		MealType: queryString(r, "meal_type"),
		Search:   params.Search,
	}

	foods, meta, err := h.foodService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Food.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch foods")
		return
	}
	response.OKPaginated(w, foods, meta)
}

// GET /api/foods/{id}
func (h *FoodHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	f, err := h.foodService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Food not found")
			return
		}
		slog.Error("[Food.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch food")
		return
	}
	response.OK(w, f)
}

// POST /api/foods
func (h *FoodHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name        string   `json:"name"         validate:"required,min=1,max=150"`
		Description *string  `json:"description,omitempty"`
		ImageID     string   `json:"image_id,omitempty"`
		ImageURL    *string  `json:"image_url,omitempty"`
		MealTypes   []string `json:"meal_types"   validate:"required"`
		Calories    *int     `json:"calories,omitempty"`
		ProteinG    *float64 `json:"protein_g,omitempty"`
		CarbsG      *float64 `json:"carbs_g,omitempty"`
		FatG        *float64 `json:"fat_g,omitempty"`
		FiberG      *float64 `json:"fiber_g,omitempty"`
		ServingSize *string  `json:"serving_size,omitempty"`
		ServingUnit *string  `json:"serving_unit,omitempty"`
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

	// Resolve image: prefer image_id (upload) over image_url (direct link)
	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "food", "")

	f := &repository.Food{
		Name:        input.Name,
		Description: input.Description,
		ImageURL:    imgURL,
		MealTypes:   input.MealTypes,
		Calories:    input.Calories,
		ProteinG:    input.ProteinG,
		CarbsG:      input.CarbsG,
		FatG:        input.FatG,
		FiberG:      input.FiberG,
		ServingSize: input.ServingSize,
		ServingUnit: input.ServingUnit,
		CreatedBy:   &userID,
	}

	if err := h.foodService.Create(r.Context(), f); err != nil {
		slog.Error("[Food.Create] failed", "name", input.Name, "error", err)
		response.InternalError(w, "Failed to create food")
		return
	}

	// Link upload to newly created entity
	if input.ImageID != "" {
		h.images.resolve(r.Context(), input.ImageID, nil, "food", f.ID)
	}

	slog.Info("[Food.Create] success", "id", f.ID, "name", f.Name)
	response.Created(w, f)
}

// PUT /api/foods/{id}
func (h *FoodHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name        string   `json:"name"         validate:"required,min=1,max=150"`
		Description *string  `json:"description,omitempty"`
		ImageID     string   `json:"image_id,omitempty"`
		ImageURL    *string  `json:"image_url,omitempty"`
		MealTypes   []string `json:"meal_types"   validate:"required"`
		Calories    *int     `json:"calories,omitempty"`
		ProteinG    *float64 `json:"protein_g,omitempty"`
		CarbsG      *float64 `json:"carbs_g,omitempty"`
		FatG        *float64 `json:"fat_g,omitempty"`
		FiberG      *float64 `json:"fiber_g,omitempty"`
		ServingSize *string  `json:"serving_size,omitempty"`
		ServingUnit *string  `json:"serving_unit,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "food", id)

	f := &repository.Food{
		ID:          id,
		Name:        input.Name,
		Description: input.Description,
		ImageURL:    imgURL,
		MealTypes:   input.MealTypes,
		Calories:    input.Calories,
		ProteinG:    input.ProteinG,
		CarbsG:      input.CarbsG,
		FatG:        input.FatG,
		FiberG:      input.FiberG,
		ServingSize: input.ServingSize,
		ServingUnit: input.ServingUnit,
	}

	if err := h.foodService.Update(r.Context(), f); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Food not found")
			return
		}
		slog.Error("[Food.Update] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update food")
		return
	}
	response.OK(w, f)
}

// DELETE /api/foods/{id}
func (h *FoodHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.foodService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Food not found")
			return
		}
		slog.Error("[Food.Delete] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete food")
		return
	}
	response.SuccessMessage(w, "Food deleted")
}
