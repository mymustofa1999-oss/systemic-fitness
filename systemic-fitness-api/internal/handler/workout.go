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

type WorkoutHandler struct {
	workoutService *service.WorkoutService
}

func NewWorkoutHandler(ws *service.WorkoutService) *WorkoutHandler {
	return &WorkoutHandler{workoutService: ws}
}

// GET /api/workouts?search=leg&type=strength&created_by=uuid&is_template=true&page=1&limit=20
func (h *WorkoutHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.WorkoutListFilter{
		Type:      queryString(r, "type"),
		CreatedBy: queryString(r, "created_by"),
		Search:    params.Search,
	}
	if v := r.URL.Query().Get("is_template"); v == "true" {
		t := true
		f.IsTemplate = &t
	} else if v == "false" {
		t := false
		f.IsTemplate = &t
	}

	workouts, meta, err := h.workoutService.ListWorkouts(r.Context(), params, f)
	if err != nil {
		slog.Error("[Workout.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch workouts")
		return
	}
	slog.Debug("[Workout.List] success", "total", meta.Total)
	response.OKPaginated(w, workouts, meta)
}

// GET /api/workouts/{id}
func (h *WorkoutHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	detail, err := h.workoutService.GetWorkoutDetail(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Workout.GetByID] not found", "id", id)
			response.NotFound(w, "Workout not found")
			return
		}
		slog.Error("[Workout.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch workout")
		return
	}
	slog.Debug("[Workout.GetByID] success", "id", id)
	response.OK(w, detail)
}

// POST /api/workouts
func (h *WorkoutHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input service.CreateWorkoutInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Workout.Create] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Workout.Create] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	detail, err := h.workoutService.CreateWorkout(r.Context(), &input, userID)
	if err != nil {
		slog.Error("[Workout.Create] failed", "name", input.Name, "user_id", userID, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Workout.Create] success", "id", detail.ID, "name", input.Name, "user_id", userID)
	response.Created(w, detail)
}

// PUT /api/workouts/{id}
func (h *WorkoutHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input service.UpdateWorkoutInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Workout.Update] invalid request body", "id", id, "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Workout.Update] validation failed", "id", id, "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	detail, err := h.workoutService.UpdateWorkout(r.Context(), id, &input)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Workout.Update] not found", "id", id)
			response.NotFound(w, "Workout not found")
			return
		}
		slog.Error("[Workout.Update] failed", "id", id, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Workout.Update] success", "id", id)
	response.OK(w, detail)
}

// POST /api/workouts/{id}/duplicate
func (h *WorkoutHandler) Duplicate(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	userID := middleware.GetUserID(r.Context())

	detail, err := h.workoutService.DuplicateWorkout(r.Context(), id, userID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Workout.Duplicate] not found", "id", id)
			response.NotFound(w, "Workout not found")
			return
		}
		slog.Error("[Workout.Duplicate] failed", "id", id, "user_id", userID, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Workout.Duplicate] success", "original_id", id, "new_id", detail.ID, "user_id", userID)
	response.Created(w, detail)
}
