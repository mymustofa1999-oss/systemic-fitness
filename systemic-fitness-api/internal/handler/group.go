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

type GroupHandler struct {
	groupService *service.GroupService
	images       *imageResolver
}

func NewGroupHandler(gs *service.GroupService, us *service.UploadService) *GroupHandler {
	return &GroupHandler{groupService: gs, images: &imageResolver{uploadService: us}}
}

// GET /api/groups
func (h *GroupHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	groups, meta, err := h.groupService.List(r.Context(), params, params.Search)
	if err != nil {
		slog.Error("[Group.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch groups")
		return
	}
	response.OKPaginated(w, groups, meta)
}

// GET /api/groups/{id}
func (h *GroupHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	g, err := h.groupService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Group not found")
			return
		}
		response.InternalError(w, "Failed to fetch group")
		return
	}
	response.OK(w, g)
}

// POST /api/groups
func (h *GroupHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name        string  `json:"name"        validate:"required,min=1,max=100"`
		Description *string `json:"description,omitempty"`
		ImageID     string  `json:"image_id,omitempty"`
		ImageURL    *string `json:"image_url,omitempty"`
		MaxMembers  *int    `json:"max_members,omitempty"`
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
	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "group", "")

	g := &repository.Group{
		Name: input.Name, Description: input.Description,
		ImageURL: imgURL, MaxMembers: input.MaxMembers, CreatedBy: userID,
	}
	if err := h.groupService.Create(r.Context(), g); err != nil {
		slog.Error("[Group.Create] failed", "error", err)
		response.InternalError(w, "Failed to create group")
		return
	}
	if input.ImageID != "" {
		h.images.resolve(r.Context(), input.ImageID, nil, "group", g.ID)
	}
	response.Created(w, g)
}

// PUT /api/groups/{id}
func (h *GroupHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name        string  `json:"name"        validate:"required,min=1,max=100"`
		Description *string `json:"description,omitempty"`
		ImageID     string  `json:"image_id,omitempty"`
		ImageURL    *string `json:"image_url,omitempty"`
		MaxMembers  *int    `json:"max_members,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	imgURL := h.images.resolve(r.Context(), input.ImageID, input.ImageURL, "group", id)

	g := &repository.Group{
		ID: id, Name: input.Name, Description: input.Description,
		ImageURL: imgURL, MaxMembers: input.MaxMembers,
	}
	if err := h.groupService.Update(r.Context(), g); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Group not found")
			return
		}
		response.InternalError(w, "Failed to update group")
		return
	}
	response.OK(w, g)
}

// DELETE /api/groups/{id}
func (h *GroupHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.groupService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Group not found")
			return
		}
		response.InternalError(w, "Failed to delete group")
		return
	}
	response.SuccessMessage(w, "Group deleted")
}

// ─── Members ───────────────────────────────────────────────────────

// POST /api/groups/{id}/members
func (h *GroupHandler) AddMember(w http.ResponseWriter, r *http.Request) {
	groupID := chi.URLParam(r, "id")
	var input struct {
		UserID string `json:"user_id" validate:"required"`
		Role   string `json:"role"    validate:"required,oneof=admin member"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	gm := &repository.GroupMember{GroupID: groupID, UserID: input.UserID, Role: input.Role}
	if err := h.groupService.AddMember(r.Context(), gm); err != nil {
		response.InternalError(w, "Failed to add member")
		return
	}
	response.Created(w, gm)
}

// GET /api/groups/{id}/members
func (h *GroupHandler) ListMembers(w http.ResponseWriter, r *http.Request) {
	groupID := chi.URLParam(r, "id")
	members, err := h.groupService.ListMembers(r.Context(), groupID)
	if err != nil {
		response.InternalError(w, "Failed to fetch members")
		return
	}
	response.OK(w, members)
}

// DELETE /api/groups/{id}/members/{userId}
func (h *GroupHandler) RemoveMember(w http.ResponseWriter, r *http.Request) {
	groupID := chi.URLParam(r, "id")
	userID := chi.URLParam(r, "userId")
	if err := h.groupService.RemoveMember(r.Context(), groupID, userID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Member not found")
			return
		}
		response.InternalError(w, "Failed to remove member")
		return
	}
	response.SuccessMessage(w, "Member removed")
}
