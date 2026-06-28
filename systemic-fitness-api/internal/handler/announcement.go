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

type AnnouncementHandler struct {
	announcementService *service.AnnouncementService
	images              *imageResolver
}

func NewAnnouncementHandler(as *service.AnnouncementService, us *service.UploadService) *AnnouncementHandler {
	return &AnnouncementHandler{announcementService: as, images: &imageResolver{uploadService: us}}
}

// GET /api/announcements (admin: all; others: published only)
func (h *AnnouncementHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.AnnouncementListFilter{
		Status: queryString(r, "status"),
		Search: params.Search,
	}

	announcements, meta, err := h.announcementService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Announcement.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch announcements")
		return
	}
	response.OKPaginated(w, announcements, meta)
}

// GET /api/announcements/feed (published, role-filtered)
func (h *AnnouncementHandler) Feed(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	role := string(middleware.GetRole(r.Context()))

	announcements, meta, err := h.announcementService.ListPublished(r.Context(), role, params)
	if err != nil {
		slog.Error("[Announcement.Feed] failed", "error", err)
		response.InternalError(w, "Failed to fetch announcements")
		return
	}
	response.OKPaginated(w, announcements, meta)
}

// GET /api/announcements/{id}
func (h *AnnouncementHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	a, err := h.announcementService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Announcement not found")
			return
		}
		response.InternalError(w, "Failed to fetch announcement")
		return
	}
	response.OK(w, a)
}

// POST /api/announcements
func (h *AnnouncementHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title       string   `json:"title"        validate:"required,min=1,max=200"`
		Body        string   `json:"body"         validate:"required,min=1"`
		ImageID     string   `json:"image_id,omitempty"`
		ImageURL    *string  `json:"image_url,omitempty"`
		Status      string   `json:"status"       validate:"required,oneof=draft published archived"`
		TargetRoles []string `json:"target_roles"`
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
	if input.TargetRoles == nil {
		input.TargetRoles = []string{}
	}
	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "announcement", "")

	a := &repository.Announcement{
		Title: input.Title, Body: input.Body, ImageURL: imgURL,
		Status: input.Status, TargetRoles: input.TargetRoles, CreatedBy: userID,
	}
	if err := h.announcementService.Create(r.Context(), a); err != nil {
		slog.Error("[Announcement.Create] failed", "error", err)
		response.InternalError(w, "Failed to create announcement")
		return
	}
	if input.ImageID != "" {
		h.images.resolve(r.Context(), input.ImageID, nil, "announcement", a.ID)
	}
	response.Created(w, a)
}

// PUT /api/announcements/{id}
func (h *AnnouncementHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Title       string   `json:"title"        validate:"required,min=1,max=200"`
		Body        string   `json:"body"         validate:"required,min=1"`
		ImageID     string   `json:"image_id,omitempty"`
		ImageURL    *string  `json:"image_url,omitempty"`
		Status      string   `json:"status"       validate:"required,oneof=draft published archived"`
		TargetRoles []string `json:"target_roles"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	if input.TargetRoles == nil {
		input.TargetRoles = []string{}
	}
	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "announcement", id)

	a := &repository.Announcement{
		ID: id, Title: input.Title, Body: input.Body, ImageURL: imgURL,
		Status: input.Status, TargetRoles: input.TargetRoles,
	}
	if err := h.announcementService.Update(r.Context(), a); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Announcement not found")
			return
		}
		response.InternalError(w, "Failed to update announcement")
		return
	}
	response.OK(w, a)
}

// DELETE /api/announcements/{id}
func (h *AnnouncementHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.announcementService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Announcement not found")
			return
		}
		response.InternalError(w, "Failed to delete announcement")
		return
	}
	response.SuccessMessage(w, "Announcement deleted")
}

// POST /api/announcements/{id}/read
func (h *AnnouncementHandler) MarkAsRead(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	userID := middleware.GetUserID(r.Context())
	if err := h.announcementService.MarkAsRead(r.Context(), id, userID); err != nil {
		response.InternalError(w, "Failed to mark as read")
		return
	}
	response.SuccessMessage(w, "Marked as read")
}
