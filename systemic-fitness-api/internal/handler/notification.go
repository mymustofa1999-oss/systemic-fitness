package handler

import (
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type NotificationHandler struct {
	svc *service.NotificationService
}

func NewNotificationHandler(svc *service.NotificationService) *NotificationHandler {
	return &NotificationHandler{svc: svc}
}

// ── POST /api/notifications/device-token ────────────────────────
// Register FCM device token (called on app launch / login).
func (h *NotificationHandler) RegisterToken(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var input struct {
		Token      string `json:"token" validate:"required"`
		Platform   string `json:"platform" validate:"required,oneof=android ios web"`
		DeviceName string `json:"device_name"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Notification.RegisterToken] invalid request body", "user_id", userID, "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Notification.RegisterToken] validation failed", "user_id", userID, "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	if err := h.svc.RegisterToken(r.Context(), userID, input.Token, input.Platform, input.DeviceName); err != nil {
		slog.Error("[Notification.RegisterToken] failed", "user_id", userID, "platform", input.Platform, "error", err)
		response.InternalError(w, "Failed to register device token")
		return
	}

	slog.Info("[Notification.RegisterToken] success", "user_id", userID, "platform", input.Platform)
	response.OK(w, map[string]string{"status": "registered"})
}

// ── DELETE /api/notifications/device-token ───────────────────────
// Unregister FCM device token (called on logout).
func (h *NotificationHandler) UnregisterToken(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var input struct {
		Token string `json:"token" validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Notification.UnregisterToken] invalid request body", "user_id", userID, "error", err)
		response.BadRequest(w, "Invalid request body")
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Notification.UnregisterToken] validation failed", "user_id", userID, "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	if err := h.svc.UnregisterToken(r.Context(), userID, input.Token); err != nil {
		slog.Error("[Notification.UnregisterToken] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to unregister token")
		return
	}

	slog.Info("[Notification.UnregisterToken] success", "user_id", userID)
	response.NoContent(w)
}

// ── GET /api/notifications ──────────────────────────────────────
// List user's notifications (in-app notification center).
func (h *NotificationHandler) List(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	p := paginationFromQuery(r)

	notifications, meta, err := h.svc.GetNotifications(r.Context(), userID, p)
	if err != nil {
		slog.Error("[Notification.List] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch notifications")
		return
	}

	slog.Debug("[Notification.List] success", "user_id", userID, "total", meta.Total)
	response.OKPaginated(w, notifications, meta)
}

// ── GET /api/notifications/unread-count ─────────────────────────
// Get count of unread notifications.
func (h *NotificationHandler) UnreadCount(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	count, err := h.svc.GetUnreadCount(r.Context(), userID)
	if err != nil {
		slog.Error("[Notification.UnreadCount] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to get unread count")
		return
	}

	slog.Debug("[Notification.UnreadCount] success", "user_id", userID, "count", count)
	response.OK(w, map[string]int{"unread_count": count})
}

// ── POST /api/notifications/{id}/read ───────────────────────────
// Mark a single notification as read.
func (h *NotificationHandler) MarkAsRead(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	notifID := chi.URLParam(r, "id")

	if err := h.svc.MarkAsRead(r.Context(), userID, notifID); err != nil {
		slog.Warn("[Notification.MarkAsRead] failed", "user_id", userID, "notification_id", notifID, "error", err)
		response.NotFound(w, "Notification not found")
		return
	}

	slog.Debug("[Notification.MarkAsRead] success", "user_id", userID, "notification_id", notifID)
	response.OK(w, map[string]string{"status": "read"})
}

// ── POST /api/notifications/read-all ────────────────────────────
// Mark all notifications as read.
func (h *NotificationHandler) MarkAllAsRead(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	if err := h.svc.MarkAllAsRead(r.Context(), userID); err != nil {
		slog.Error("[Notification.MarkAllAsRead] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to mark all as read")
		return
	}

	slog.Info("[Notification.MarkAllAsRead] success", "user_id", userID)
	response.OK(w, map[string]string{"status": "all_read"})
}

// ── POST /api/notifications/broadcast (admin) ───────────────────
// Send broadcast/promo notification to all or specific roles.
func (h *NotificationHandler) Broadcast(w http.ResponseWriter, r *http.Request) {
	createdBy := middleware.GetUserID(r.Context())

	var input struct {
		Title       string            `json:"title" validate:"required,min=2,max=200"`
		Body        string            `json:"body" validate:"required,min=2"`
		Type        string            `json:"type" validate:"required,oneof=promo announcement maintenance general"`
		Data        map[string]string `json:"data"`
		TargetRoles []string          `json:"target_roles"` // empty = all users
		ImageURL    string            `json:"image_url"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Notification.Broadcast] invalid request body", "created_by", createdBy, "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Notification.Broadcast] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	if err := h.svc.Broadcast(r.Context(), input.Title, input.Body, input.Type, input.Data, input.TargetRoles, input.ImageURL, createdBy); err != nil {
		slog.Error("[Notification.Broadcast] failed", "title", input.Title, "created_by", createdBy, "error", err)
		response.InternalError(w, "Failed to send broadcast")
		return
	}

	slog.Info("[Notification.Broadcast] success", "title", input.Title, "type", input.Type, "target_roles", input.TargetRoles, "created_by", createdBy)
	response.CreatedWithMessage(w, map[string]string{"status": "broadcast_sent"}, "Broadcast sent successfully")
}

// ── GET /api/notifications/broadcasts (admin) ───────────────────
// List broadcast history.
func (h *NotificationHandler) ListBroadcasts(w http.ResponseWriter, r *http.Request) {
	p := paginationFromQuery(r)

	broadcasts, meta, err := h.svc.ListBroadcasts(r.Context(), p)
	if err != nil {
		slog.Error("[Notification.ListBroadcasts] failed", "error", err)
		response.InternalError(w, "Failed to fetch broadcasts")
		return
	}

	slog.Debug("[Notification.ListBroadcasts] success", "total", meta.Total)
	response.OKPaginated(w, broadcasts, meta)
}
