package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type WorkoutReminderHandler struct {
	service *service.WorkoutReminderService
}

func NewWorkoutReminderHandler(svc *service.WorkoutReminderService) *WorkoutReminderHandler {
	return &WorkoutReminderHandler{service: svc}
}

// ────────────────────────────────────────────────────────────────
//  GET /api/v2/workout-reminders/me
// ────────────────────────────────────────────────────────────────

func (h *WorkoutReminderHandler) GetMine(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	wr, err := h.service.GetMine(r.Context(), userID)
	if err != nil {
		slog.Error("[WorkoutReminder.GetMine] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch reminder settings")
		return
	}
	response.OK(w, wr)
}

// ────────────────────────────────────────────────────────────────
//  PUT /api/v2/workout-reminders/me
// ────────────────────────────────────────────────────────────────

func (h *WorkoutReminderHandler) SetMine(w http.ResponseWriter, r *http.Request) {
	var input service.SetWorkoutReminderInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	wr, err := h.service.SetMine(r.Context(), userID, input)
	if err != nil {
		if errors.Is(err, service.ErrInvalidReminderTime) {
			response.ValidationError(w, []string{"remind_at must be in HH:MM format"})
			return
		}
		slog.Error("[WorkoutReminder.SetMine] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to save reminder settings")
		return
	}
	slog.Info("[WorkoutReminder.SetMine] success", "user_id", userID, "enabled", input.Enabled)
	response.OK(w, wr)
}
