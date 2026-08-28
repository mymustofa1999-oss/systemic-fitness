package handler

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type TrainingScheduleHandler struct {
	scheduleService *service.TrainingScheduleService
}

func NewTrainingScheduleHandler(svc *service.TrainingScheduleService) *TrainingScheduleHandler {
	return &TrainingScheduleHandler{scheduleService: svc}
}

// ════════════════════════════════════════════════════════════════════
//  Schedules (recurring templates)
// ════════════════════════════════════════════════════════════════════

// GET /api/training-schedules
func (h *TrainingScheduleHandler) ListSchedules(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.ScheduleListFilter{
		ClientID:   queryString(r, "client_id"),
		TrainerID:  queryString(r, "trainer_id"),
		ActiveOnly: r.URL.Query().Get("active") == "true",
	}
	// Trainers may only see their own schedules — server-side enforcement
	// in case the frontend forgets the trainer_id filter.
	if middleware.GetRole(r.Context()) == model.RoleTrainer {
		callerID := middleware.GetUserID(r.Context())
		f.TrainerID = &callerID
	}
	if dow := r.URL.Query().Get("day_of_week"); dow != "" {
		if v, err := strconv.Atoi(dow); err == nil {
			f.DayOfWeek = &v
		}
	}

	schedules, meta, err := h.scheduleService.ListSchedules(r.Context(), params, f)
	if err != nil {
		slog.Error("[TrainingSchedule.ListSchedules] failed", "error", err)
		response.InternalError(w, "Failed to fetch schedules")
		return
	}
	response.OKPaginated(w, schedules, meta)
}

// GET /api/training-schedules/{id}
func (h *TrainingScheduleHandler) GetSchedule(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	callerID := middleware.GetUserID(r.Context())
	callerRole := middleware.GetRole(r.Context())
	
	sch, err := h.scheduleService.GetSchedule(r.Context(), id, callerID, callerRole)
	if err != nil {
		if err.Error() == "unauthorized" {
			response.Forbidden(w, "Insufficient permissions to view this schedule")
			return
		}
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Schedule not found")
			return
		}
		slog.Error("[TrainingSchedule.GetSchedule] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch schedule")
		return
	}
	response.OK(w, sch)
}

// POST /api/training-schedules
func (h *TrainingScheduleHandler) CreateSchedule(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ClientID  string  `json:"client_id"   validate:"required"`
		TrainerID string  `json:"trainer_id"   validate:"required"`
		DayOfWeek int     `json:"day_of_week"  validate:"min=0,max=6"`
		StartTime string  `json:"start_time"   validate:"required"`
		EndTime   string  `json:"end_time"     validate:"required"`
		Location  *string `json:"location,omitempty"`
		Notes     *string `json:"notes,omitempty"`
		IsActive  *bool   `json:"is_active,omitempty"`
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
	isActive := true
	if input.IsActive != nil {
		isActive = *input.IsActive
	}

	sch := &repository.TrainingSchedule{
		ClientID:  input.ClientID,
		TrainerID: input.TrainerID,
		DayOfWeek: input.DayOfWeek,
		StartTime: input.StartTime,
		EndTime:   input.EndTime,
		Location:  input.Location,
		Notes:     input.Notes,
		IsActive:  isActive,
		CreatedBy: userID,
	}

	if err := h.scheduleService.CreateSchedule(r.Context(), sch); err != nil {
		slog.Error("[TrainingSchedule.CreateSchedule] failed", "error", err)
		response.InternalError(w, "Failed to create schedule")
		return
	}
	response.Created(w, sch)
}

// PUT /api/training-schedules/{id}
func (h *TrainingScheduleHandler) UpdateSchedule(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		ClientID  string  `json:"client_id"   validate:"required"`
		TrainerID string  `json:"trainer_id"   validate:"required"`
		DayOfWeek int     `json:"day_of_week"  validate:"min=0,max=6"`
		StartTime string  `json:"start_time"   validate:"required"`
		EndTime   string  `json:"end_time"     validate:"required"`
		Location  *string `json:"location,omitempty"`
		Notes     *string `json:"notes,omitempty"`
		IsActive  *bool   `json:"is_active,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	isActive := true
	if input.IsActive != nil {
		isActive = *input.IsActive
	}

	sch := &repository.TrainingSchedule{
		ID:        id,
		ClientID:  input.ClientID,
		TrainerID: input.TrainerID,
		DayOfWeek: input.DayOfWeek,
		StartTime: input.StartTime,
		EndTime:   input.EndTime,
		Location:  input.Location,
		Notes:     input.Notes,
		IsActive:  isActive,
	}

	if err := h.scheduleService.UpdateSchedule(r.Context(), sch); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Schedule not found")
			return
		}
		slog.Error("[TrainingSchedule.UpdateSchedule] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update schedule")
		return
	}
	response.OK(w, sch)
}

// DELETE /api/training-schedules/{id}
func (h *TrainingScheduleHandler) DeleteSchedule(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.scheduleService.DeleteSchedule(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Schedule not found")
			return
		}
		slog.Error("[TrainingSchedule.DeleteSchedule] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete schedule")
		return
	}
	response.SuccessMessage(w, "Schedule deleted")
}

// ════════════════════════════════════════════════════════════════════
//  Sessions (individual dated instances)
// ════════════════════════════════════════════════════════════════════

// GET /api/training-schedules/sessions
func (h *TrainingScheduleHandler) ListSessions(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.SessionListFilter{
		ClientID:   queryString(r, "client_id"),
		TrainerID:  queryString(r, "trainer_id"),
		DateFrom:   queryString(r, "date_from"),
		DateTo:     queryString(r, "date_to"),
		Status:     queryString(r, "status"),
		ScheduleID: queryString(r, "schedule_id"),
	}
	// Trainers may only see their own sessions — server-side enforcement
	// in case the frontend forgets the trainer_id filter.
	if middleware.GetRole(r.Context()) == model.RoleTrainer {
		callerID := middleware.GetUserID(r.Context())
		f.TrainerID = &callerID
	}

	sessions, meta, err := h.scheduleService.ListSessions(r.Context(), params, f)
	if err != nil {
		slog.Error("[TrainingSchedule.ListSessions] failed", "error", err)
		response.InternalError(w, "Failed to fetch sessions")
		return
	}
	response.OKPaginated(w, sessions, meta)
}

// GET /api/training-schedules/sessions/{id}
func (h *TrainingScheduleHandler) GetSession(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	sess, err := h.scheduleService.GetSession(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Session not found")
			return
		}
		slog.Error("[TrainingSchedule.GetSession] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch session")
		return
	}
	response.OK(w, sess)
}

// POST /api/training-schedules/sessions
func (h *TrainingScheduleHandler) CreateSession(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ScheduleID  *string `json:"schedule_id,omitempty"`
		ClientID    string  `json:"client_id"    validate:"required"`
		TrainerID   string  `json:"trainer_id"    validate:"required"`
		SessionDate string  `json:"session_date"  validate:"required"`
		StartTime   string  `json:"start_time"    validate:"required"`
		EndTime     string  `json:"end_time"      validate:"required"`
		Status      *string `json:"status,omitempty"`
		Location    *string `json:"location,omitempty"`
		Notes       *string `json:"notes,omitempty"`
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
	status := "scheduled"
	if input.Status != nil {
		status = *input.Status
	}

	sess := &repository.TrainingSession{
		ScheduleID:  input.ScheduleID,
		ClientID:    input.ClientID,
		TrainerID:   input.TrainerID,
		SessionDate: input.SessionDate,
		StartTime:   input.StartTime,
		EndTime:     input.EndTime,
		Status:      status,
		Location:    input.Location,
		Notes:       input.Notes,
		CreatedBy:   userID,
	}

	if err := h.scheduleService.CreateSession(r.Context(), sess); err != nil {
		slog.Error("[TrainingSchedule.CreateSession] failed", "error", err)
		response.InternalError(w, "Failed to create session")
		return
	}
	response.Created(w, sess)
}

// PUT /api/training-schedules/sessions/{id}
func (h *TrainingScheduleHandler) UpdateSession(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		TrainerID   string  `json:"trainer_id"    validate:"required"`
		SessionDate string  `json:"session_date"  validate:"required"`
		StartTime   string  `json:"start_time"    validate:"required"`
		EndTime     string  `json:"end_time"      validate:"required"`
		Status      string  `json:"status"        validate:"required,oneof=scheduled completed cancelled substituted"`
		Location    *string `json:"location,omitempty"`
		Notes       *string `json:"notes,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	sess := &repository.TrainingSession{
		ID:          id,
		TrainerID:   input.TrainerID,
		SessionDate: input.SessionDate,
		StartTime:   input.StartTime,
		EndTime:     input.EndTime,
		Status:      input.Status,
		Location:    input.Location,
		Notes:       input.Notes,
	}

	if err := h.scheduleService.UpdateSession(r.Context(), sess); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Session not found")
			return
		}
		slog.Error("[TrainingSchedule.UpdateSession] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update session")
		return
	}
	response.OK(w, sess)
}

// DELETE /api/training-schedules/sessions/{id}
func (h *TrainingScheduleHandler) DeleteSession(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.scheduleService.DeleteSession(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Session not found")
			return
		}
		slog.Error("[TrainingSchedule.DeleteSession] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete session")
		return
	}
	response.SuccessMessage(w, "Session deleted")
}

// POST /api/training-schedules/sessions/{id}/substitute
func (h *TrainingScheduleHandler) SubstituteTrainer(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	callerID := middleware.GetUserID(r.Context())
	var input struct {
		SubstituteTrainerID string `json:"substitute_trainer_id" validate:"required"`
		Reason              string `json:"reason"                validate:"required,min=1"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	if err := h.scheduleService.SubstituteTrainer(r.Context(), id, input.SubstituteTrainerID, input.Reason, callerID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Session not found or already substituted")
			return
		}
		slog.Error("[TrainingSchedule.SubstituteTrainer] failed", "session_id", id, "error", err)
		response.InternalError(w, "Failed to substitute trainer")
		return
	}

	// Return the updated session
	sess, _ := h.scheduleService.GetSession(r.Context(), id)
	response.OK(w, sess)
}

// POST /api/training-schedules/sessions/bulk-substitute
//
// Reassigns ALL active sessions + recurring schedule occurrences for a
// trainer within a date range to another trainer. Used when a trainer
// is sick / on leave / unavailable for several days. Konsultan-only.
func (h *TrainingScheduleHandler) BulkSubstitute(w http.ResponseWriter, r *http.Request) {
	callerID := middleware.GetUserID(r.Context())
	var input service.BulkSubstituteInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	result, err := h.scheduleService.BulkSubstitute(r.Context(), input, callerID)
	if err != nil {
		slog.Error("[TrainingSchedule.BulkSubstitute] failed",
			"original_trainer_id", input.OriginalTrainerID,
			"substitute_trainer_id", input.SubstituteTrainerID,
			"error", err)
		response.BadRequest(w, err.Error())
		return
	}
	slog.Info("[TrainingSchedule.BulkSubstitute] success",
		"original_trainer_id", input.OriginalTrainerID,
		"substitute_trainer_id", input.SubstituteTrainerID,
		"materialized", result.MaterializedSessions,
		"substituted", result.SubstitutedSessions,
	)
	response.OK(w, result)
}
