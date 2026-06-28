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

type ExerciseHandler struct {
	workoutService *service.WorkoutService
}

func NewExerciseHandler(ws *service.WorkoutService) *ExerciseHandler {
	return &ExerciseHandler{workoutService: ws}
}

// GET /api/exercises?search=bench&muscle_group=chest&equipment=barbell&difficulty=intermediate&page=1&limit=20
func (h *ExerciseHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.ExerciseListFilter{
		MuscleGroup: queryString(r, "muscle_group"),
		Equipment:   queryString(r, "equipment"),
		Difficulty:  queryString(r, "difficulty"),
		Search:      params.Search,
	}

	exercises, meta, err := h.workoutService.ListExercises(r.Context(), params, f)
	if err != nil {
		slog.Error("[Exercise.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch exercises")
		return
	}
	slog.Debug("[Exercise.List] success", "total", meta.Total)
	response.OKPaginated(w, exercises, meta)
}

// GET /api/exercises/{id}
func (h *ExerciseHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	ex, err := h.workoutService.GetExercise(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Exercise.GetByID] not found", "id", id)
			response.NotFound(w, "Exercise not found")
			return
		}
		slog.Error("[Exercise.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch exercise")
		return
	}
	slog.Debug("[Exercise.GetByID] success", "id", id)
	response.OK(w, ex)
}

// POST /api/exercises
func (h *ExerciseHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name         string   `json:"name"         validate:"required,min=1,max=100"`
		Description  *string  `json:"description,omitempty"`
		MuscleGroup  []string `json:"muscle_group" validate:"required,min=1"`
		Equipment    *string  `json:"equipment,omitempty"`
		Difficulty   string   `json:"difficulty"   validate:"required,oneof=beginner intermediate advanced"`
		VideoURL     *string  `json:"video_url,omitempty"      validate:"omitempty,url"`
		ThumbnailURL *string  `json:"thumbnail_url,omitempty"  validate:"omitempty,url"`
		Instructions []string `json:"instructions,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Exercise.Create] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Exercise.Create] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	ex := &repository.Exercise{
		Name:         input.Name,
		Description:  input.Description,
		MuscleGroup:  input.MuscleGroup,
		Equipment:    input.Equipment,
		Difficulty:   input.Difficulty,
		VideoURL:     input.VideoURL,
		ThumbnailURL: input.ThumbnailURL,
		Instructions: input.Instructions,
		CreatedBy:    &userID,
		IsSystem:     false,
	}

	if err := h.workoutService.CreateExercise(r.Context(), ex); err != nil {
		slog.Error("[Exercise.Create] failed", "name", input.Name, "user_id", userID, "error", err)
		response.InternalError(w, "Failed to create exercise")
		return
	}
	slog.Info("[Exercise.Create] success", "id", ex.ID, "name", ex.Name, "user_id", userID)
	response.Created(w, ex)
}

// PUT /api/exercises/{id}
func (h *ExerciseHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name         string   `json:"name"         validate:"required,min=1,max=100"`
		Description  *string  `json:"description,omitempty"`
		MuscleGroup  []string `json:"muscle_group" validate:"required,min=1"`
		Equipment    *string  `json:"equipment,omitempty"`
		Difficulty   string   `json:"difficulty"   validate:"required,oneof=beginner intermediate advanced"`
		VideoURL     *string  `json:"video_url,omitempty"      validate:"omitempty,url"`
		ThumbnailURL *string  `json:"thumbnail_url,omitempty"  validate:"omitempty,url"`
		Instructions []string `json:"instructions,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Exercise.Update] invalid request body", "id", id, "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Exercise.Update] validation failed", "id", id, "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	callerRole := middleware.GetRole(r.Context())
	ex := &repository.Exercise{
		ID:           id,
		Name:         input.Name,
		Description:  input.Description,
		MuscleGroup:  input.MuscleGroup,
		Equipment:    input.Equipment,
		Difficulty:   input.Difficulty,
		VideoURL:     input.VideoURL,
		ThumbnailURL: input.ThumbnailURL,
		Instructions: input.Instructions,
	}

	if err := h.workoutService.UpdateExercise(r.Context(), ex, callerRole); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Exercise.Update] not found", "id", id)
			response.NotFound(w, "Exercise not found")
			return
		}
		slog.Error("[Exercise.Update] failed", "id", id, "error", err)
		response.Forbidden(w, err.Error())
		return
	}
	slog.Info("[Exercise.Update] success", "id", id, "name", input.Name)
	response.OK(w, ex)
}

// DELETE /api/exercises/{id}
func (h *ExerciseHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	callerRole := middleware.GetRole(r.Context())

	if err := h.workoutService.DeleteExercise(r.Context(), id, callerRole); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Exercise.Delete] not found", "id", id)
			response.NotFound(w, "Exercise not found")
			return
		}
		slog.Error("[Exercise.Delete] failed", "id", id, "error", err)
		response.Forbidden(w, err.Error())
		return
	}
	slog.Info("[Exercise.Delete] success", "id", id)
	response.SuccessMessage(w, "Exercise deleted")
}
