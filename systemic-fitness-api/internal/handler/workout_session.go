package handler

import (
	"log/slog"
	"net/http"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type WorkoutSessionHandler struct {
	service *service.WorkoutSessionService
}

func NewWorkoutSessionHandler(svc *service.WorkoutSessionService) *WorkoutSessionHandler {
	return &WorkoutSessionHandler{service: svc}
}

// ────────────────────────────────────────────────────────────────
//  POST /api/v2/workout-sessions
// ────────────────────────────────────────────────────────────────

func (h *WorkoutSessionHandler) Log(w http.ResponseWriter, r *http.Request) {
	var input service.LogWorkoutSessionInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	log, err := h.service.Log(r.Context(), userID, input)
	if err != nil {
		slog.Error("[WorkoutSession.Log] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to log workout session")
		return
	}
	slog.Info("[WorkoutSession.Log] success", "user_id", userID, "type", input.SessionType)
	response.Created(w, log)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/v2/workout-sessions?session_type=&page=&limit=
// ────────────────────────────────────────────────────────────────

func (h *WorkoutSessionHandler) ListMine(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	params := paginationFromQuery(r)
	f := repository.WorkoutSessionFilter{SessionType: queryString(r, "session_type")}

	logs, meta, err := h.service.ListMine(r.Context(), userID, params, f)
	if err != nil {
		slog.Error("[WorkoutSession.ListMine] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch workout sessions")
		return
	}
	response.OKPaginated(w, logs, meta)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/v2/workout-sessions/stats
// ────────────────────────────────────────────────────────────────

func (h *WorkoutSessionHandler) Stats(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	stats, err := h.service.MyStats(r.Context(), userID)
	if err != nil {
		slog.Error("[WorkoutSession.Stats] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch workout session stats")
		return
	}
	response.OK(w, stats)
}
