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

type PromotionHandler struct {
	promotionService *service.PromotionService
	images           *imageResolver
}

func NewPromotionHandler(ps *service.PromotionService, us *service.UploadService) *PromotionHandler {
	return &PromotionHandler{promotionService: ps, images: &imageResolver{uploadService: us}}
}

// GET /api/promotions (admin: paginated list)
func (h *PromotionHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.PromotionListFilter{
		Status: queryString(r, "status"),
		Search: params.Search,
	}

	promotions, meta, err := h.promotionService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Promotion.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch promotions")
		return
	}
	response.OKPaginated(w, promotions, meta)
}

// GET /api/promotions/active (client: active promos for carousel)
func (h *PromotionHandler) ListActive(w http.ResponseWriter, r *http.Request) {
	promotions, err := h.promotionService.ListActive(r.Context())
	if err != nil {
		slog.Error("[Promotion.ListActive] failed", "error", err)
		response.InternalError(w, "Failed to fetch active promotions")
		return
	}
	response.OK(w, promotions)
}

// GET /api/promotions/{id}
func (h *PromotionHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	p, err := h.promotionService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Promotion not found")
			return
		}
		response.InternalError(w, "Failed to fetch promotion")
		return
	}
	response.OK(w, p)
}

// POST /api/promotions
func (h *PromotionHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title       string  `json:"title"       validate:"required,min=1,max=200"`
		Description string  `json:"description"`
		ImageID     string  `json:"image_id,omitempty"`
		ImageURL    *string `json:"image_url,omitempty"`
		Badge       string  `json:"badge"       validate:"required,max=50"`
		Route       string  `json:"route"       validate:"required,max=200"`
		Status      string  `json:"status"      validate:"required,oneof=draft active ended"`
		StartDate   string  `json:"start_date"  validate:"required"`
		EndDate     string  `json:"end_date"    validate:"required"`
		SortOrder   int     `json:"sort_order"`
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
	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "promotion", "")

	var desc *string
	if input.Description != "" {
		desc = &input.Description
	}

	p := &repository.Promotion{
		Title: input.Title, Description: desc, ImageURL: imgURL,
		Badge: input.Badge, Route: input.Route, Status: input.Status,
		StartDate: input.StartDate, EndDate: input.EndDate,
		SortOrder: input.SortOrder, CreatedBy: &userID,
	}
	if err := h.promotionService.Create(r.Context(), p); err != nil {
		slog.Error("[Promotion.Create] failed", "error", err)
		response.InternalError(w, "Failed to create promotion")
		return
	}
	if input.ImageID != "" {
		h.images.resolve(r.Context(), input.ImageID, nil, "promotion", p.ID)
	}
	response.Created(w, p)
}

// PUT /api/promotions/{id}
func (h *PromotionHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Title       string  `json:"title"       validate:"required,min=1,max=200"`
		Description string  `json:"description"`
		ImageID     string  `json:"image_id,omitempty"`
		ImageURL    *string `json:"image_url,omitempty"`
		Badge       string  `json:"badge"       validate:"required,max=50"`
		Route       string  `json:"route"       validate:"required,max=200"`
		Status      string  `json:"status"      validate:"required,oneof=draft active ended"`
		StartDate   string  `json:"start_date"  validate:"required"`
		EndDate     string  `json:"end_date"    validate:"required"`
		SortOrder   int     `json:"sort_order"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "promotion", id)

	var desc *string
	if input.Description != "" {
		desc = &input.Description
	}

	p := &repository.Promotion{
		ID: id, Title: input.Title, Description: desc, ImageURL: imgURL,
		Badge: input.Badge, Route: input.Route, Status: input.Status,
		StartDate: input.StartDate, EndDate: input.EndDate, SortOrder: input.SortOrder,
	}
	if err := h.promotionService.Update(r.Context(), p); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Promotion not found")
			return
		}
		response.InternalError(w, "Failed to update promotion")
		return
	}
	response.OK(w, p)
}

// DELETE /api/promotions/{id}
func (h *PromotionHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.promotionService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Promotion not found")
			return
		}
		response.InternalError(w, "Failed to delete promotion")
		return
	}
	response.SuccessMessage(w, "Promotion deleted")
}
