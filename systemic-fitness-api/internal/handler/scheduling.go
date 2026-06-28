package handler

import (
	"errors"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type SchedulingHandler struct {
	schedulingService *service.SchedulingService
}

func NewSchedulingHandler(ss *service.SchedulingService) *SchedulingHandler {
	return &SchedulingHandler{schedulingService: ss}
}

// ─── Event Types ───────────────────────────────────────────────────

// GET /api/scheduling/event-types
func (h *SchedulingHandler) ListEventTypes(w http.ResponseWriter, r *http.Request) {
	types, err := h.schedulingService.ListEventTypes(r.Context())
	if err != nil {
		slog.Error("[Scheduling.ListEventTypes] failed", "error", err)
		response.InternalError(w, "Failed to fetch event types")
		return
	}
	response.OK(w, types)
}

// POST /api/scheduling/event-types
func (h *SchedulingHandler) CreateEventType(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name        string  `json:"name"         validate:"required,min=1,max=100"`
		Description *string `json:"description,omitempty"`
		Category    string  `json:"category"     validate:"required,oneof=one_on_one group_class personal"`
		DurationMin int     `json:"duration_min"  validate:"required,gt=0"`
		Color       *string `json:"color,omitempty"`
		IsActive    bool    `json:"is_active"`
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
	et := &repository.EventType{
		Name: input.Name, Description: input.Description, Category: input.Category,
		DurationMin: input.DurationMin, Color: input.Color, IsActive: input.IsActive,
		CreatedBy: &userID,
	}
	if err := h.schedulingService.CreateEventType(r.Context(), et); err != nil {
		slog.Error("[Scheduling.CreateEventType] failed", "error", err)
		response.InternalError(w, "Failed to create event type")
		return
	}
	response.Created(w, et)
}

// PUT /api/scheduling/event-types/{id}
func (h *SchedulingHandler) UpdateEventType(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Name        string  `json:"name"         validate:"required,min=1,max=100"`
		Description *string `json:"description,omitempty"`
		Category    string  `json:"category"     validate:"required,oneof=one_on_one group_class personal"`
		DurationMin int     `json:"duration_min"  validate:"required,gt=0"`
		Color       *string `json:"color,omitempty"`
		IsActive    bool    `json:"is_active"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	et := &repository.EventType{
		ID: id, Name: input.Name, Description: input.Description, Category: input.Category,
		DurationMin: input.DurationMin, Color: input.Color, IsActive: input.IsActive,
	}
	if err := h.schedulingService.UpdateEventType(r.Context(), et); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Event type not found")
			return
		}
		response.InternalError(w, "Failed to update event type")
		return
	}
	response.OK(w, et)
}

// DELETE /api/scheduling/event-types/{id}
func (h *SchedulingHandler) DeleteEventType(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.schedulingService.DeleteEventType(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Event type not found")
			return
		}
		response.InternalError(w, "Failed to delete event type")
		return
	}
	response.SuccessMessage(w, "Event type deleted")
}

// ─── Calendar Events ───────────────────────────────────────────────

// GET /api/scheduling/events
func (h *SchedulingHandler) ListEvents(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.EventListFilter{
		Category:  queryString(r, "category"),
		Status:    queryString(r, "status"),
		StartFrom: queryString(r, "start_from"),
		StartTo:   queryString(r, "start_to"),
		CreatedBy: queryString(r, "created_by"),
	}

	// Auto-scope: clients only see events they participate in
	if middleware.GetRole(r.Context()) == model.RoleClient {
		callerID := middleware.GetUserID(r.Context())
		f.ParticipantID = &callerID
	}

	events, meta, err := h.schedulingService.ListEvents(r.Context(), params, f)
	if err != nil {
		slog.Error("[Scheduling.ListEvents] failed", "error", err)
		response.InternalError(w, "Failed to fetch events")
		return
	}
	response.OKPaginated(w, events, meta)
}

// POST /api/scheduling/events
func (h *SchedulingHandler) CreateEvent(w http.ResponseWriter, r *http.Request) {
	var input struct {
		EventTypeID     *string `json:"event_type_id,omitempty"`
		Title           string  `json:"title"         validate:"required,min=1,max=200"`
		Description     *string `json:"description,omitempty"`
		Category        string  `json:"category"      validate:"required,oneof=one_on_one group_class personal"`
		StartAt         string  `json:"start_at"      validate:"required"`
		EndAt           string  `json:"end_at"        validate:"required"`
		Location        *string `json:"location,omitempty"`
		MaxParticipants *int    `json:"max_participants,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	startAt, err := time.Parse(time.RFC3339, input.StartAt)
	if err != nil {
		response.BadRequest(w, "Invalid start_at format, use RFC3339")
		return
	}
	endAt, err := time.Parse(time.RFC3339, input.EndAt)
	if err != nil {
		response.BadRequest(w, "Invalid end_at format, use RFC3339")
		return
	}

	userID := middleware.GetUserID(r.Context())
	event := &repository.CalendarEvent{
		EventTypeID: input.EventTypeID, Title: input.Title, Description: input.Description,
		Category: input.Category, Status: "scheduled", StartAt: startAt, EndAt: endAt,
		Location: input.Location, MaxParticipants: input.MaxParticipants, CreatedBy: userID,
	}
	if err := h.schedulingService.CreateEvent(r.Context(), event); err != nil {
		slog.Error("[Scheduling.CreateEvent] failed", "error", err)
		response.InternalError(w, "Failed to create event")
		return
	}
	response.Created(w, event)
}

// GET /api/scheduling/events/{id}
func (h *SchedulingHandler) GetEvent(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	event, err := h.schedulingService.GetEvent(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Event not found")
			return
		}
		response.InternalError(w, "Failed to fetch event")
		return
	}
	response.OK(w, event)
}

// PUT /api/scheduling/events/{id}
func (h *SchedulingHandler) UpdateEvent(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		EventTypeID     *string `json:"event_type_id,omitempty"`
		Title           string  `json:"title"         validate:"required,min=1,max=200"`
		Description     *string `json:"description,omitempty"`
		Category        string  `json:"category"      validate:"required,oneof=one_on_one group_class personal"`
		Status          string  `json:"status"        validate:"required,oneof=scheduled cancelled completed"`
		StartAt         string  `json:"start_at"      validate:"required"`
		EndAt           string  `json:"end_at"        validate:"required"`
		Location        *string `json:"location,omitempty"`
		MaxParticipants *int    `json:"max_participants,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	startAt, err := time.Parse(time.RFC3339, input.StartAt)
	if err != nil {
		response.BadRequest(w, "Invalid start_at format")
		return
	}
	endAt, err := time.Parse(time.RFC3339, input.EndAt)
	if err != nil {
		response.BadRequest(w, "Invalid end_at format")
		return
	}

	event := &repository.CalendarEvent{
		ID: id, EventTypeID: input.EventTypeID, Title: input.Title, Description: input.Description,
		Category: input.Category, Status: input.Status, StartAt: startAt, EndAt: endAt,
		Location: input.Location, MaxParticipants: input.MaxParticipants,
	}
	if err := h.schedulingService.UpdateEvent(r.Context(), event); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Event not found")
			return
		}
		response.InternalError(w, "Failed to update event")
		return
	}
	response.OK(w, event)
}

// DELETE /api/scheduling/events/{id}
func (h *SchedulingHandler) DeleteEvent(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.schedulingService.DeleteEvent(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Event not found")
			return
		}
		response.InternalError(w, "Failed to delete event")
		return
	}
	response.SuccessMessage(w, "Event deleted")
}

// ─── Event Participants ────────────────────────────────────────────

// POST /api/scheduling/events/{id}/participants
func (h *SchedulingHandler) AddParticipant(w http.ResponseWriter, r *http.Request) {
	eventID := chi.URLParam(r, "id")
	var input struct {
		UserID     string `json:"user_id"      validate:"required"`
		RSVPStatus string `json:"rsvp_status"  validate:"required,oneof=pending accepted declined"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	ep := &repository.EventParticipant{EventID: eventID, UserID: input.UserID, RSVPStatus: input.RSVPStatus}
	if err := h.schedulingService.AddParticipant(r.Context(), ep); err != nil {
		response.InternalError(w, "Failed to add participant")
		return
	}
	response.Created(w, ep)
}

// GET /api/scheduling/events/{id}/participants
func (h *SchedulingHandler) ListParticipants(w http.ResponseWriter, r *http.Request) {
	eventID := chi.URLParam(r, "id")
	participants, err := h.schedulingService.ListParticipants(r.Context(), eventID)
	if err != nil {
		response.InternalError(w, "Failed to fetch participants")
		return
	}
	response.OK(w, participants)
}

// ─── Availability ──────────────────────────────────────────────────

// GET /api/scheduling/availability/{trainerId}
func (h *SchedulingHandler) ListAvailability(w http.ResponseWriter, r *http.Request) {
	trainerID := chi.URLParam(r, "trainerId")
	slots, err := h.schedulingService.ListAvailability(r.Context(), trainerID)
	if err != nil {
		response.InternalError(w, "Failed to fetch availability")
		return
	}
	response.OK(w, slots)
}

// POST /api/scheduling/availability
func (h *SchedulingHandler) SetAvailability(w http.ResponseWriter, r *http.Request) {
	var input struct {
		DayOfWeek int    `json:"day_of_week" validate:"min=0,max=6"`
		StartTime string `json:"start_time"  validate:"required"`
		EndTime   string `json:"end_time"    validate:"required"`
		IsActive  bool   `json:"is_active"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	trainerID := middleware.GetUserID(r.Context())
	a := &repository.TrainerAvailability{
		TrainerID: trainerID, DayOfWeek: input.DayOfWeek,
		StartTime: input.StartTime, EndTime: input.EndTime, IsActive: input.IsActive,
	}
	if err := h.schedulingService.SetAvailability(r.Context(), a); err != nil {
		response.InternalError(w, "Failed to set availability")
		return
	}
	response.Created(w, a)
}

// DELETE /api/scheduling/availability/{id}
func (h *SchedulingHandler) DeleteAvailability(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.schedulingService.DeleteAvailability(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Availability slot not found")
			return
		}
		response.InternalError(w, "Failed to delete availability")
		return
	}
	response.SuccessMessage(w, "Availability slot deleted")
}
