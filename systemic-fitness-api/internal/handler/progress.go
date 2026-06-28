package handler

import (
	"encoding/json"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type ProgressHandler struct {
	progressService *service.ProgressService
}

func NewProgressHandler(ps *service.ProgressService) *ProgressHandler {
	return &ProgressHandler{progressService: ps}
}

// ────────────────────────────────────────────────────────────────
//  POST /api/progress/log
// ────────────────────────────────────────────────────────────────

func (h *ProgressHandler) LogProgress(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ExerciseID string          `json:"exercise_id" validate:"required"`
		WorkoutID  *string         `json:"workout_id,omitempty"`
		Sets       json.RawMessage `json:"sets"        validate:"required"`
		Notes      *string         `json:"notes,omitempty"`
		Mood       *string         `json:"mood,omitempty" validate:"omitempty,oneof=great good okay tired bad"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Progress.Log] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Progress.Log] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	// Validate that sets is a non-empty JSON array
	var setsArray []json.RawMessage
	if err := json.Unmarshal(input.Sets, &setsArray); err != nil || len(setsArray) == 0 {
		slog.Warn("[Progress.Log] invalid sets format", "exercise_id", input.ExerciseID)
		response.ValidationError(w, []string{"sets must be a non-empty JSON array"})
		return
	}

	userID := middleware.GetUserID(r.Context())
	log := &repository.ProgressLog{
		UserID:     userID,
		ExerciseID: input.ExerciseID,
		WorkoutID:  input.WorkoutID,
		Sets:       input.Sets,
		Notes:      input.Notes,
		Mood:       input.Mood,
	}

	if err := h.progressService.LogProgress(r.Context(), log); err != nil {
		slog.Error("[Progress.Log] failed", "user_id", userID, "exercise_id", input.ExerciseID, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Progress.Log] success", "user_id", userID, "exercise_id", input.ExerciseID, "sets", len(setsArray))
	response.Created(w, log)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/progress/user/{id}?exercise_id=&workout_id=&date_from=&date_to=&page=&limit=
// ────────────────────────────────────────────────────────────────

func (h *ProgressHandler) GetHistory(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "id")
	params := paginationFromQuery(r)
	f := repository.ProgressHistoryFilter{
		ExerciseID: queryString(r, "exercise_id"),
		WorkoutID:  queryString(r, "workout_id"),
		DateFrom:   queryString(r, "date_from"),
		DateTo:     queryString(r, "date_to"),
	}

	logs, meta, err := h.progressService.GetHistory(r.Context(), userID, params, f)
	if err != nil {
		slog.Error("[Progress.GetHistory] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch progress history")
		return
	}
	slog.Debug("[Progress.GetHistory] success", "user_id", userID, "total", meta.Total)
	response.OKPaginated(w, logs, meta)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/progress/user/{id}/charts?exercise_id=&date_from=&date_to=
// ────────────────────────────────────────────────────────────────

func (h *ProgressHandler) GetCharts(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "id")
	exerciseID := queryString(r, "exercise_id")
	dateFrom := queryString(r, "date_from")
	dateTo := queryString(r, "date_to")

	charts, err := h.progressService.GetChartData(r.Context(), userID, exerciseID, dateFrom, dateTo)
	if err != nil {
		slog.Error("[Progress.GetCharts] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch chart data")
		return
	}
	slog.Debug("[Progress.GetCharts] success", "user_id", userID, "exercises", len(charts))
	response.OK(w, map[string]any{
		"user_id":   userID,
		"exercises": charts,
	})
}

// ────────────────────────────────────────────────────────────────
//  POST /api/progress/body-metric
// ────────────────────────────────────────────────────────────────

func (h *ProgressHandler) LogBodyMetric(w http.ResponseWriter, r *http.Request) {
	var input struct {
		WeightKg     *float64 `json:"weight_kg,omitempty"      validate:"omitempty,gt=0,lt=500"`
		BodyFatPct   *float64 `json:"body_fat_pct,omitempty"   validate:"omitempty,gte=0,lte=100"`
		MuscleMassKg *float64 `json:"muscle_mass_kg,omitempty" validate:"omitempty,gte=0"`
		PhotoURLs    []string `json:"photo_urls,omitempty"     validate:"omitempty,max=5,dive,url"`
		Notes        *string  `json:"notes,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Progress.LogBodyMetric] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Progress.LogBodyMetric] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	// At least one measurement required
	if input.WeightKg == nil && input.BodyFatPct == nil && input.MuscleMassKg == nil && len(input.PhotoURLs) == 0 {
		slog.Warn("[Progress.LogBodyMetric] no measurement provided")
		response.ValidationError(w, []string{"at least one measurement (weight, body fat, muscle mass, or photo) is required"})
		return
	}

	userID := middleware.GetUserID(r.Context())
	bm := &repository.BodyMetric{
		UserID:       userID,
		WeightKg:     input.WeightKg,
		BodyFatPct:   input.BodyFatPct,
		MuscleMassKg: input.MuscleMassKg,
		PhotoURLs:    input.PhotoURLs,
		Notes:        input.Notes,
	}

	if err := h.progressService.LogBodyMetric(r.Context(), bm); err != nil {
		slog.Error("[Progress.LogBodyMetric] failed", "user_id", userID, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Progress.LogBodyMetric] success", "user_id", userID, "id", bm.ID)
	response.Created(w, bm)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/progress/user/{id}/body-metrics?page=&limit=
// ────────────────────────────────────────────────────────────────

func (h *ProgressHandler) GetBodyMetrics(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "id")
	params := paginationFromQuery(r)

	metrics, meta, err := h.progressService.GetBodyMetrics(r.Context(), userID, params)
	if err != nil {
		slog.Error("[Progress.GetBodyMetrics] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch body metrics")
		return
	}
	slog.Debug("[Progress.GetBodyMetrics] success", "user_id", userID, "total", meta.Total)
	response.OKPaginated(w, metrics, meta)
}
