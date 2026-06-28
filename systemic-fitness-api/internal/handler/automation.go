package handler

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type AutomationHandler struct {
	automationService *service.AutomationService
}

func NewAutomationHandler(as *service.AutomationService) *AutomationHandler {
	return &AutomationHandler{automationService: as}
}

// GET /api/automations?trigger_type=scheduled&is_active=true&search=welcome&page=1&limit=20
func (h *AutomationHandler) List(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.AutomationListFilter{
		TriggerType: queryString(r, "trigger_type"),
		Search:      params.Search,
	}
	if v := r.URL.Query().Get("is_active"); v == "true" {
		t := true
		f.IsActive = &t
	} else if v == "false" {
		t := false
		f.IsActive = &t
	}

	automations, meta, err := h.automationService.List(r.Context(), params, f)
	if err != nil {
		slog.Error("[Automation.List] failed", "error", err)
		response.InternalError(w, "Failed to fetch automations")
		return
	}
	slog.Debug("[Automation.List] success", "total", meta.Total)
	response.OKPaginated(w, automations, meta)
}

// GET /api/automations/{id}
func (h *AutomationHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	a, err := h.automationService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Automation.GetByID] not found", "id", id)
			response.NotFound(w, "Automation not found")
			return
		}
		slog.Error("[Automation.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch automation")
		return
	}
	slog.Debug("[Automation.GetByID] success", "id", id)
	response.OK(w, a)
}

// POST /api/automations
func (h *AutomationHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name          string          `json:"name"           validate:"required,min=1,max=100"`
		Description   *string         `json:"description,omitempty"`
		TriggerType   string          `json:"trigger_type"   validate:"required,oneof=on_signup on_program_complete on_inactive_days scheduled on_milestone"`
		TriggerConfig json.RawMessage `json:"trigger_config" validate:"required"`
		ActionType    string          `json:"action_type"    validate:"required,oneof=send_message assign_program send_reminder send_notification send_email"`
		ActionConfig  json.RawMessage `json:"action_config"  validate:"required"`
		IsActive      bool            `json:"is_active"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Automation.Create] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Automation.Create] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	callerID := middleware.GetUserID(r.Context())
	a := &repository.Automation{
		Name:          input.Name,
		Description:   input.Description,
		TriggerType:   input.TriggerType,
		TriggerConfig: input.TriggerConfig,
		ActionType:    input.ActionType,
		ActionConfig:  input.ActionConfig,
		IsActive:      input.IsActive,
		CreatedBy:     &callerID,
	}

	if err := h.automationService.Create(r.Context(), a); err != nil {
		slog.Error("[Automation.Create] failed", "name", input.Name, "caller_id", callerID, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Automation.Create] success", "id", a.ID, "name", a.Name, "trigger", a.TriggerType, "caller_id", callerID)
	response.Created(w, a)
}

// PUT /api/automations/{id}
func (h *AutomationHandler) Update(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	body, err := readBody(r)
	if err != nil {
		slog.Warn("[Automation.Update] invalid request body", "id", id, "error", err)
		response.BadRequest(w, "Invalid request body")
		return
	}

	a, err := h.automationService.Update(r.Context(), id, body)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Automation.Update] not found", "id", id)
			response.NotFound(w, "Automation not found")
			return
		}
		slog.Error("[Automation.Update] failed", "id", id, "error", err)
		response.BadRequest(w, err.Error())
		return
	}
	slog.Info("[Automation.Update] success", "id", id, "name", a.Name)
	response.OK(w, a)
}

// DELETE /api/automations/{id}
func (h *AutomationHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.automationService.Delete(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Automation.Delete] not found", "id", id)
			response.NotFound(w, "Automation not found")
			return
		}
		slog.Error("[Automation.Delete] failed", "id", id, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Automation.Delete] success", "id", id)
	response.SuccessMessage(w, "Automation deleted")
}

// GET /api/automations/{id}/logs?page=1&limit=20
func (h *AutomationHandler) GetLogs(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	params := paginationFromQuery(r)

	logs, meta, err := h.automationService.GetLogs(r.Context(), id, params)
	if err != nil {
		slog.Error("[Automation.GetLogs] failed", "automation_id", id, "error", err)
		response.InternalError(w, "Failed to fetch automation logs")
		return
	}
	slog.Debug("[Automation.GetLogs] success", "automation_id", id, "total", meta.Total)
	response.OKPaginated(w, logs, meta)
}

// readBody reads request body as raw JSON.
func readBody(r *http.Request) (json.RawMessage, error) {
	var body json.RawMessage
	return body, json.NewDecoder(r.Body).Decode(&body)
}
