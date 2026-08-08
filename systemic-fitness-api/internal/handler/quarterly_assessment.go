package handler

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/pkg/response"
)

type QuarterlyAssessmentHandler struct {
	repo repository.QuarterlyAssessmentRepository
}

func NewQuarterlyAssessmentHandler(repo repository.QuarterlyAssessmentRepository) *QuarterlyAssessmentHandler {
	return &QuarterlyAssessmentHandler{repo: repo}
}

func (h *QuarterlyAssessmentHandler) Create(w http.ResponseWriter, r *http.Request) {
	var input model.QuarterlyAssessment
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		response.BadRequest(w, "Invalid JSON payload")
		return
	}

	if err := h.repo.Create(r.Context(), &input); err != nil {
		response.InternalError(w, "Failed to create quarterly assessment")
		return
	}

	response.Created(w, input)
}

func (h *QuarterlyAssessmentHandler) ListByClient(w http.ResponseWriter, r *http.Request) {
	clientIDStr := chi.URLParam(r, "id")
	clientID, err := uuid.Parse(clientIDStr)
	if err != nil {
		response.BadRequest(w, "Invalid client ID")
		return
	}

	assessments, err := h.repo.GetByClientID(r.Context(), clientID)
	if err != nil {
		response.InternalError(w, "Failed to fetch quarterly assessments")
		return
	}

	if assessments == nil {
		assessments = []model.QuarterlyAssessment{}
	}

	response.OK(w, assessments)
}
