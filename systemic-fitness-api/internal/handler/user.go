package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type UserHandler struct {
	userService *service.UserService
}

func NewUserHandler(us *service.UserService) *UserHandler {
	return &UserHandler{userService: us}
}

// ────────────────────────────────────────────────────────────────
//  GET /api/users?page=1&limit=20&role=client&status=active&search=john&sort_by=created_at&sort_order=desc
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	callerRole := middleware.GetRole(r.Context())
	callerID := middleware.GetUserID(r.Context())

	input := &service.ListUsersInput{
		Pagination: params,
		CallerRole: callerRole,
		CallerID:   callerID,
	}

	// Parse optional role filter
	if roleStr := r.URL.Query().Get("role"); roleStr != "" {
		role := model.Role(roleStr)
		if !role.IsValid() {
			slog.Warn("[User.List] invalid role filter", "role", roleStr, "caller_id", callerID)
			response.BadRequest(w, "Invalid role filter. Must be one of: owner, admin, finance, trainer, client")
			return
		}
		input.Role = &role
	}

	// Parse optional status filter
	if statusStr := r.URL.Query().Get("status"); statusStr != "" {
		status := model.UserStatus(statusStr)
		if !status.IsValid() {
			slog.Warn("[User.List] invalid status filter", "status", statusStr, "caller_id", callerID)
			response.BadRequest(w, "Invalid status filter. Must be one of: active, inactive, suspended, pending")
			return
		}
		input.Status = &status
	}

	users, meta, err := h.userService.List(r.Context(), input)
	if err != nil {
		slog.Error("[User.List] failed", "caller_id", callerID, "error", err)
		response.InternalError(w, "Failed to fetch users")
		return
	}

	slog.Debug("[User.List] success", "caller_id", callerID, "total", meta.Total)
	response.OKPaginated(w, users, meta)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/users/{id}
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	targetID := chi.URLParam(r, "id")
	callerRole := middleware.GetRole(r.Context())
	callerID := middleware.GetUserID(r.Context())

	result, err := h.userService.GetByID(r.Context(), targetID, callerRole, callerID)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrUserNotFound):
			slog.Warn("[User.GetByID] not found", "target_id", targetID, "caller_id", callerID)
			response.NotFound(w, "User not found")
		default:
			slog.Warn("[User.GetByID] access denied or error", "target_id", targetID, "caller_id", callerID, "error", err)
			response.Forbidden(w, err.Error())
		}
		return
	}

	slog.Debug("[User.GetByID] success", "target_id", targetID, "caller_id", callerID)
	response.OK(w, result)
}

// ────────────────────────────────────────────────────────────────
//  PUT /api/users/{id}
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) Update(w http.ResponseWriter, r *http.Request) {
	targetID := chi.URLParam(r, "id")
	callerRole := middleware.GetRole(r.Context())
	callerID := middleware.GetUserID(r.Context())

	var input service.UpdateUserInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[User.Update] invalid request body", "target_id", targetID, "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[User.Update] validation failed", "target_id", targetID, "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	result, err := h.userService.Update(r.Context(), targetID, &input, callerRole, callerID)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrUserNotFound):
			slog.Warn("[User.Update] user not found", "target_id", targetID)
			response.NotFound(w, "User not found")
		default:
			slog.Error("[User.Update] failed", "target_id", targetID, "caller_id", callerID, "error", err)
			response.BadRequest(w, err.Error())
		}
		return
	}

	slog.Info("[User.Update] success", "target_id", targetID, "caller_id", callerID)
	response.OKWithMessage(w, result, "User updated successfully")
}

// ────────────────────────────────────────────────────────────────
//  POST /api/users/invite
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) Invite(w http.ResponseWriter, r *http.Request) {
	callerRole := middleware.GetRole(r.Context())
	callerID := middleware.GetUserID(r.Context())

	var input service.InviteUserInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[User.Invite] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[User.Invite] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	result, err := h.userService.Invite(r.Context(), &input, callerRole)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrEmailTaken):
			slog.Warn("[User.Invite] email already registered", "email", input.Email)
			response.Conflict(w, "Email is already registered")
		default:
			slog.Error("[User.Invite] failed", "email", input.Email, "role", input.Role, "caller_id", callerID, "error", err)
			response.BadRequest(w, err.Error())
		}
		return
	}

	slog.Info("[User.Invite] success", "email", input.Email, "role", input.Role, "caller_id", callerID)
	response.CreatedWithMessage(w, result, "Invitation sent successfully")
}

// ────────────────────────────────────────────────────────────────
//  DELETE /api/users/{id}
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) Delete(w http.ResponseWriter, r *http.Request) {
	targetID := chi.URLParam(r, "id")
	callerID := middleware.GetUserID(r.Context())

	err := h.userService.SoftDelete(r.Context(), targetID, callerID)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrUserNotFound):
			slog.Warn("[User.Delete] user not found", "target_id", targetID)
			response.NotFound(w, "User not found")
		default:
			slog.Error("[User.Delete] failed", "target_id", targetID, "caller_id", callerID, "error", err)
			response.BadRequest(w, err.Error())
		}
		return
	}

	slog.Info("[User.Delete] success", "target_id", targetID, "caller_id", callerID)
	response.SuccessMessage(w, "User deleted successfully")
}

// ────────────────────────────────────────────────────────────────
//  GET /api/users/{id}/stats
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) Stats(w http.ResponseWriter, r *http.Request) {
	targetID := chi.URLParam(r, "id")
	callerRole := middleware.GetRole(r.Context())
	callerID := middleware.GetUserID(r.Context())

	stats, err := h.userService.GetStats(r.Context(), targetID, callerRole, callerID)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrUserNotFound):
			slog.Warn("[User.Stats] user not found", "target_id", targetID)
			response.NotFound(w, "User not found")
		default:
			slog.Warn("[User.Stats] access denied or error", "target_id", targetID, "caller_id", callerID, "error", err)
			response.Forbidden(w, err.Error())
		}
		return
	}

	slog.Debug("[User.Stats] success", "target_id", targetID)
	response.OK(w, stats)
}

// ────────────────────────────────────────────────────────────────
//  POST /api/clients/assign
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) AssignClient(w http.ResponseWriter, r *http.Request) {
	var input struct {
		TrainerID string `json:"trainer_id" validate:"required"`
		ClientID  string `json:"client_id"  validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	if err := h.userService.AssignClient(r.Context(), input.TrainerID, input.ClientID); err != nil {
		slog.Error("[Client.Assign] failed", "error", err)
		response.InternalError(w, "Failed to assign client")
		return
	}
	response.SuccessMessage(w, "Client assigned to trainer")
}

// ────────────────────────────────────────────────────────────────
//  POST /api/clients/unassign
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) UnassignClient(w http.ResponseWriter, r *http.Request) {
	var input struct {
		TrainerID string `json:"trainer_id" validate:"required"`
		ClientID  string `json:"client_id"  validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	if err := h.userService.UnassignClient(r.Context(), input.TrainerID, input.ClientID); err != nil {
		if errors.Is(err, service.ErrUserNotFound) {
			response.NotFound(w, "Assignment not found")
			return
		}
		slog.Error("[Client.Unassign] failed", "error", err)
		response.InternalError(w, "Failed to unassign client")
		return
	}
	response.SuccessMessage(w, "Client unassigned from trainer")
}

// ────────────────────────────────────────────────────────────────
//  GET /api/clients (trainer's own clients)
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) ListClients(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	callerRole := middleware.GetRole(r.Context())
	callerID := middleware.GetUserID(r.Context())

	clientRole := model.RoleClient
	input := &service.ListUsersInput{
		Pagination: params,
		Role:       &clientRole,
		CallerRole: callerRole,
		CallerID:   callerID,
	}

	users, meta, err := h.userService.List(r.Context(), input)
	if err != nil {
		slog.Error("[Client.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch clients")
		return
	}
	response.OKPaginated(w, users, meta)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/team
// ────────────────────────────────────────────────────────────────

func (h *UserHandler) ListTeam(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)

	users, meta, err := h.userService.ListTeamMembers(r.Context(), params)
	if err != nil {
		slog.Error("[Team.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch team members")
		return
	}
	response.OKPaginated(w, users, meta)
}

