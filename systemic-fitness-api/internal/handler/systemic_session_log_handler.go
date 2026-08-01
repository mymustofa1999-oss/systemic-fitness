package handler

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type SystemicSessionLogHandler struct {
	svc service.SystemicSessionLogService
}

func NewSystemicSessionLogHandler(svc service.SystemicSessionLogService) *SystemicSessionLogHandler {
	return &SystemicSessionLogHandler{svc: svc}
}

func (h *SystemicSessionLogHandler) GetLogs(w http.ResponseWriter, r *http.Request) {
	userIDStr := chi.URLParam(r, "id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		response.BadRequest(w, "invalid user ID")
		return
	}

	logs, err := h.svc.GetLogsByUserID(r.Context(), userID)
	if err != nil {
		response.InternalError(w, err.Error())
		return
	}

	response.OKWithMessage(w, logs, "Logs fetched successfully")
}

func (h *SystemicSessionLogHandler) CreateLog(w http.ResponseWriter, r *http.Request) {
	userIDStr := chi.URLParam(r, "id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		response.BadRequest(w, "invalid user ID")
		return
	}

	var req model.SystemicSessionLog
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, "invalid request body")
		return
	}

	// Override user ID from URL
	req.UserID = userID

	if err := h.svc.CreateLog(r.Context(), &req); err != nil {
		response.InternalError(w, err.Error())
		return
	}

	response.SuccessMessage(w, "Log saved successfully")
}
