package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

// AssessmentV2Handler exposes the SF v2 assessment endpoints (Phase 2).
//
//   POST   /api/v2/assessments                  (auth: client)
//   GET    /api/v2/assessments/latest           (auth: client)
//   GET    /api/v2/assessments/{id}             (auth: any role; client must own)
//   GET    /api/v2/assessments/score-weights    (auth)
//   PATCH  /api/v2/assessments/score-weights    (owner only)
type AssessmentV2Handler struct {
	service *service.AssessmentV2Service
}

func NewAssessmentV2Handler(s *service.AssessmentV2Service) *AssessmentV2Handler {
	return &AssessmentV2Handler{service: s}
}

// POST /api/v2/assessments
func (h *AssessmentV2Handler) Submit(w http.ResponseWriter, r *http.Request) {
	var in service.SubmitV2Input
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Unauthorized(w, "Authentication required")
		return
	}

	callerRole := middleware.GetRole(r.Context())
	a, err := h.service.Submit(r.Context(), userID, &in, callerRole)
	if err != nil {
		slog.Error("[AssessmentV2.Submit] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to submit assessment")
		return
	}
	response.Created(w, a)
}

// POST /api/v2/assessments/user/{userId} — admin/trainer only.
func (h *AssessmentV2Handler) SubmitForUser(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "userId")
	if userID == "" {
		response.BadRequest(w, "Missing userId")
		return
	}

	var in service.SubmitV2Input
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	callerRole := middleware.GetRole(r.Context())
	a, err := h.service.Submit(r.Context(), userID, &in, callerRole)
	if err != nil {
		slog.Error("[AssessmentV2.SubmitForUser] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to submit assessment")
		return
	}
	response.Created(w, a)
}

// GET /api/v2/assessments/latest
func (h *AssessmentV2Handler) Latest(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Unauthorized(w, "Authentication required")
		return
	}
	a, err := h.service.Latest(r.Context(), userID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "No v2 assessment found")
			return
		}
		response.InternalError(w, "Failed to fetch latest v2 assessment")
		return
	}
	response.OK(w, a)
}

// GET /api/v2/assessments/user/{userId}/latest — admin/owner/trainer only.
// Used by the web admin viewer to read a specific client's most recent v2.
func (h *AssessmentV2Handler) LatestForUser(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "userId")
	if userID == "" {
		response.BadRequest(w, "Missing userId")
		return
	}
	a, err := h.service.Latest(r.Context(), userID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "No v2 assessment for this user")
			return
		}
		response.InternalError(w, "Failed to fetch latest v2 assessment")
		return
	}
	response.OK(w, a)
}

// GET /api/v2/assessments/{id}
func (h *AssessmentV2Handler) Get(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	a, err := h.service.Get(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Assessment not found")
			return
		}
		response.InternalError(w, "Failed to fetch assessment")
		return
	}
	// Ownership check: client may only read their own row.
	role := middleware.GetRole(r.Context())
	userID := middleware.GetUserID(r.Context())
	if role == model.RoleClient && (a.UserID == nil || *a.UserID != userID) {
		response.Forbidden(w, "Forbidden")
		return
	}
	response.OK(w, a)
}

// GET /api/v2/assessments/score-weights
func (h *AssessmentV2Handler) GetWeights(w http.ResponseWriter, r *http.Request) {
	wts, err := h.service.GetActiveWeights(r.Context())
	if err != nil {
		response.InternalError(w, "Failed to fetch weights")
		return
	}
	response.OK(w, wts)
}

// PATCH /api/v2/assessments/score-weights
func (h *AssessmentV2Handler) UpdateWeights(w http.ResponseWriter, r *http.Request) {
	var in service.UpdateWeightsInput
	if err := response.DecodeJSON(r, &in); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&in); errs != nil {
		response.ValidationError(w, errs)
		return
	}
	if in.MovementPct+in.NutritionPct+in.RestPct != 100 {
		response.BadRequest(w, "movement_pct + nutrition_pct + rest_pct must equal 100")
		return
	}
	userID := middleware.GetUserID(r.Context())
	out, err := h.service.UpdateWeights(r.Context(), in, userID)
	if err != nil {
		response.InternalError(w, err.Error())
		return
	}
	response.OK(w, out)
}

// GET /api/v2/assessments/training-card
func (h *AssessmentV2Handler) GetTrainingCard(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Unauthorized(w, "Authentication required")
		return
	}
	tc, err := h.service.GetTrainingCard(r.Context(), userID)
	if err != nil {
		if errors.Is(err, service.ErrSubscriptionRequired) {
			response.PaymentRequired(w, "Active subscription required to access training card")
			return
		}
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "No assessment data available to generate training card")
			return
		}
		slog.Error("[AssessmentV2Handler.GetTrainingCard] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to generate training card")
		return
	}
	response.OK(w, tc)
}

// GET /api/v2/assessments/user/{userId}/training-card — admin/owner/trainer only.
func (h *AssessmentV2Handler) GetTrainingCardForUser(w http.ResponseWriter, r *http.Request) {
	userID := chi.URLParam(r, "userId")
	if userID == "" {
		response.BadRequest(w, "Missing userId")
		return
	}
	
	tc, err := h.service.GetTrainingCard(r.Context(), userID)
	if err != nil {
		if errors.Is(err, service.ErrSubscriptionRequired) {
			response.PaymentRequired(w, "User has no active subscription")
			return
		}
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "No assessment data available to generate training card")
			return
		}
		slog.Error("[AssessmentV2Handler.GetTrainingCardForUser] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to generate training card")
		return
	}
	response.OK(w, tc)
}
