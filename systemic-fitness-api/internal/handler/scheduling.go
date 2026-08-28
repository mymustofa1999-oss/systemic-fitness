package handler

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
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

	// FETCH existing
	existing, err := h.schedulingService.GetEventType(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Event type not found")
			return
		}
		response.InternalError(w, "Failed to fetch event type")
		return
	}

	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		response.BadRequest(w, "Invalid request body")
		return
	}
	r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	var raw map[string]any
	if err := json.Unmarshal(bodyBytes, &raw); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	var input struct {
		Name        string  `json:"name"         validate:"omitempty,min=1,max=100"`
		Description *string `json:"description,omitempty"`
		Category    string  `json:"category"     validate:"omitempty,oneof=one_on_one group_class personal"`
		DurationMin int     `json:"duration_min" validate:"omitempty,gt=0"`
		Color       *string `json:"color,omitempty"`
		IsActive    *bool   `json:"is_active,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	// MERGE
	if _, ok := raw["name"]; ok {
		existing.Name = input.Name
	}
	if v, ok := raw["description"]; ok {
		if v == nil {
			existing.Description = nil
		} else {
			existing.Description = input.Description
		}
	}
	if _, ok := raw["category"]; ok {
		existing.Category = input.Category
	}
	if _, ok := raw["duration_min"]; ok {
		existing.DurationMin = input.DurationMin
	}
	if v, ok := raw["color"]; ok {
		if v == nil {
			existing.Color = nil
		} else {
			existing.Color = input.Color
		}
	}
	if _, ok := raw["is_active"]; ok {
		existing.IsActive = *input.IsActive
	}

	// SAVE
	if err := h.schedulingService.UpdateEventType(r.Context(), existing); err != nil {
		response.InternalError(w, "Failed to update event type")
		return
	}
	response.OK(w, existing)
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

	// FETCH existing
	existing, err := h.schedulingService.GetEvent(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Event not found")
			return
		}
		response.InternalError(w, "Failed to fetch event")
		return
	}

	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		response.BadRequest(w, "Invalid request body")
		return
	}
	r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	var raw map[string]any
	if err := json.Unmarshal(bodyBytes, &raw); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	var input struct {
		EventTypeID     *string `json:"event_type_id,omitempty"`
		Title           string  `json:"title"         validate:"omitempty,min=1,max=200"`
		Description     *string `json:"description,omitempty"`
		Category        string  `json:"category"      validate:"omitempty,oneof=one_on_one group_class personal"`
		Status          string  `json:"status"        validate:"omitempty,oneof=scheduled cancelled completed"`
		StartAt         string  `json:"start_at"      validate:"omitempty"`
		EndAt           string  `json:"end_at"        validate:"omitempty"`
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

	// MERGE
	if v, ok := raw["event_type_id"]; ok {
		if v == nil {
			existing.EventTypeID = nil
		} else {
			existing.EventTypeID = input.EventTypeID
		}
	}
	if _, ok := raw["title"]; ok {
		existing.Title = input.Title
	}
	if v, ok := raw["description"]; ok {
		if v == nil {
			existing.Description = nil
		} else {
			existing.Description = input.Description
		}
	}
	if _, ok := raw["category"]; ok {
		existing.Category = input.Category
	}
	if _, ok := raw["status"]; ok {
		existing.Status = input.Status
	}
	if _, ok := raw["start_at"]; ok {
		startAt, err := time.Parse(time.RFC3339, input.StartAt)
		if err != nil {
			response.BadRequest(w, "Invalid start_at format")
			return
		}
		existing.StartAt = startAt
	}
	if _, ok := raw["end_at"]; ok {
		endAt, err := time.Parse(time.RFC3339, input.EndAt)
		if err != nil {
			response.BadRequest(w, "Invalid end_at format")
			return
		}
		existing.EndAt = endAt
	}
	if v, ok := raw["location"]; ok {
		if v == nil {
			existing.Location = nil
		} else {
			existing.Location = input.Location
		}
	}
	if v, ok := raw["max_participants"]; ok {
		if v == nil {
			existing.MaxParticipants = nil
		} else {
			existing.MaxParticipants = input.MaxParticipants
		}
	}

	// SAVE
	if err := h.schedulingService.UpdateEvent(r.Context(), existing); err != nil {
		response.InternalError(w, "Failed to update event")
		return
	}
	response.OK(w, existing)
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

// GET /api/scheduling/availability/all
func (h *SchedulingHandler) ListAllAvailability(w http.ResponseWriter, r *http.Request) {
	slots, err := h.schedulingService.ListAllAvailability(r.Context())
	if err != nil {
		response.InternalError(w, "Failed to fetch all availability")
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

// PUT /api/scheduling/availability
func (h *SchedulingHandler) ReplaceAvailability(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Slots []struct {
			DayOfWeek int    `json:"day_of_week" validate:"min=0,max=6"`
			StartTime string `json:"start_time"  validate:"required"`
			EndTime   string `json:"end_time"    validate:"required"`
			IsActive  bool   `json:"is_active"`
		} `json:"slots" validate:"dive"`
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
	var slots []repository.TrainerAvailability
	for _, s := range input.Slots {
		slots = append(slots, repository.TrainerAvailability{
			TrainerID: trainerID, DayOfWeek: s.DayOfWeek,
			StartTime: s.StartTime, EndTime: s.EndTime, IsActive: s.IsActive,
		})
	}

	if err := h.schedulingService.ReplaceAvailability(r.Context(), trainerID, slots); err != nil {
		response.InternalError(w, "Failed to replace availability")
		return
	}
	response.SuccessMessage(w, "Availability replaced successfully")
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
