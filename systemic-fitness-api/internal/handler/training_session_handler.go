package handler

import (
	"encoding/json"
	"net/http"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
	"github.com/go-chi/chi/v5"
)

type TrainingSessionHandler struct {
	svc service.TrainingSessionService
}

func NewTrainingSessionHandler(svc service.TrainingSessionService) *TrainingSessionHandler {
	return &TrainingSessionHandler{svc: svc}
}

func (h *TrainingSessionHandler) GetLogs(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "id")
	periodName := r.URL.Query().Get("period")
	
	if periodName == "" {
		response.BadRequest(w, "period parameter is required")
		return
	}

	logs, err := h.svc.GetLogsByPeriod(r.Context(), userID, periodName)
	if err != nil {
		response.InternalError(w, err.Error())
		return
	}

	response.OKWithMessage(w, logs, "Logs fetched successfully")
}

type UpsertLogsRequest struct {
	PeriodName string                     `json:"period_name"`
	Logs       []model.TrainingSessionLog `json:"logs"`
}

func (h *TrainingSessionHandler) UpsertLogs(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "id")
	
	var req UpsertLogsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, "invalid request body")
		return
	}
	
	if req.PeriodName == "" {
		response.BadRequest(w, "period_name is required")
		return
	}

	if err := h.svc.UpsertLogs(r.Context(), userID, req.PeriodName, req.Logs); err != nil {
		response.InternalError(w, err.Error())
		return
	}

	response.SuccessMessage(w, "Logs saved successfully")
}
