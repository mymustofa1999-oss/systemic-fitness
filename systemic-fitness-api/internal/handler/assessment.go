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

type AssessmentHandler struct {
	svc *service.AssessmentService
}

func NewAssessmentHandler(svc *service.AssessmentService) *AssessmentHandler {
	return &AssessmentHandler{svc: svc}
}

// ────────────────────────────────────────────────────────────────
//  POST /api/assessments/free
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) SubmitFree(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Unauthorized(w, "Not authenticated")
		return
	}

	var input service.SubmitFreeInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Assessment.SubmitFree] invalid body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Assessment.SubmitFree] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	result, err := h.svc.SubmitFree(r.Context(), userID, &input)
	if err != nil {
		slog.Error("[Assessment.SubmitFree] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to submit assessment")
		return
	}
	slog.Info("[Assessment.SubmitFree] success", "assessment_id", result.ID, "user_id", userID)
	response.CreatedWithMessage(w, result, "Free assessment submitted")
}

// ────────────────────────────────────────────────────────────────
//  POST /api/assessments/paid
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) SubmitPaid(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Unauthorized(w, "Not authenticated")
		return
	}

	var input service.SubmitPaidInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Assessment.SubmitPaid] invalid body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Assessment.SubmitPaid] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	result, err := h.svc.SubmitPaid(r.Context(), userID, &input)
	if err != nil {
		slog.Error("[Assessment.SubmitPaid] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to submit assessment")
		return
	}
	slog.Info("[Assessment.SubmitPaid] success", "assessment_id", result.ID, "user_id", userID)
	response.CreatedWithMessage(w, result, "Paid assessment submitted — pending trainer review")
}

// ────────────────────────────────────────────────────────────────
//  GET /api/assessments  — my history
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) ListMine(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Unauthorized(w, "Not authenticated")
		return
	}

	params := paginationFromQuery(r)
	items, total, err := h.svc.ListMine(r.Context(), userID, params)
	if err != nil {
		slog.Error("[Assessment.ListMine] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch assessments")
		return
	}

	meta := model.NewPaginationMeta(params.Page, params.Limit, total)
	response.OKPaginated(w, items, meta)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/users/{id}/assessments  — trainer+
//  Returns history for a specific user (trainer review use case).
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) ListByUser(w http.ResponseWriter, r *http.Request) {
	targetUserID := chi.URLParam(r, "id")
	if targetUserID == "" {
		response.BadRequest(w, "Missing user id")
		return
	}

	params := paginationFromQuery(r)
	items, total, err := h.svc.ListMine(r.Context(), targetUserID, params)
	if err != nil {
		slog.Error("[Assessment.ListByUser] failed", "user_id", targetUserID, "error", err)
		response.InternalError(w, "Failed to fetch assessments")
		return
	}

	meta := model.NewPaginationMeta(params.Page, params.Limit, total)
	response.OKPaginated(w, items, meta)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/assessments/latest?tier=free|paid
//
//  Returns the caller's most recent assessment, optionally filtered
//  by tier. Used by the mobile paid wizard to pre-fill Sleep + Movement
//  inputs from the user's last free assessment so they only need to
//  enter the metabolic lab values during upgrade.
//  Returns 404 if the user has no matching assessment yet.
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) GetLatest(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		response.Unauthorized(w, "Not authenticated")
		return
	}

	tier := r.URL.Query().Get("tier")
	if tier != "" && tier != "free" && tier != "paid" {
		response.BadRequest(w, "tier must be 'free' or 'paid'")
		return
	}

	result, err := h.svc.GetLatest(r.Context(), userID, tier)
	if err != nil {
		if errors.Is(err, service.ErrAssessmentNotFound) {
			response.NotFound(w, "No assessment found")
			return
		}
		slog.Error("[Assessment.GetLatest] failed", "user_id", userID, "tier", tier, "error", err)
		response.InternalError(w, "Failed to fetch latest assessment")
		return
	}
	response.OK(w, result)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/assessments/{id}
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	role := middleware.GetRole(r.Context())
	id := chi.URLParam(r, "id")
	if id == "" {
		response.BadRequest(w, "Missing assessment id")
		return
	}

	result, err := h.svc.GetByID(r.Context(), id, userID, role)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrAssessmentNotFound):
			response.NotFound(w, "Assessment not found")
		case errors.Is(err, service.ErrAssessmentForbidden):
			response.Forbidden(w, "You do not have access to this assessment")
		default:
			slog.Error("[Assessment.GetByID] failed", "id", id, "error", err)
			response.InternalError(w, "Failed to fetch assessment")
		}
		return
	}
	response.OK(w, result)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/assessments/{id}/previous
//
//  Returns the assessment created immediately before {id} for the
//  same user. Used by the mobile result page to compute deltas
//  ("Sleep: 65 → 78 +13") so users can see progress over time.
//  Returns 404 when {id} is the user's first assessment.
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) GetPrevious(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	role := middleware.GetRole(r.Context())
	id := chi.URLParam(r, "id")
	if id == "" {
		response.BadRequest(w, "Missing assessment id")
		return
	}

	result, err := h.svc.GetPrevious(r.Context(), id, userID, role)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrAssessmentNotFound):
			response.NotFound(w, "No previous assessment")
		case errors.Is(err, service.ErrAssessmentForbidden):
			response.Forbidden(w, "You do not have access to this assessment")
		default:
			slog.Error("[Assessment.GetPrevious] failed", "id", id, "error", err)
			response.InternalError(w, "Failed to fetch previous assessment")
		}
		return
	}
	response.OK(w, result)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/assessments/pending-review  — trainer only
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) ListPendingReview(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	items, total, err := h.svc.ListPendingReview(r.Context(), params)
	if err != nil {
		slog.Error("[Assessment.ListPendingReview] failed", "error", err)
		response.InternalError(w, "Failed to fetch pending assessments")
		return
	}

	meta := model.NewPaginationMeta(params.Page, params.Limit, total)
	response.OKPaginated(w, items, meta)
}

// ────────────────────────────────────────────────────────────────
//  GET /api/assessments/all  — admin/owner only
//
//  Query params (all optional):
//    tier=free|paid
//    status=submitted|verified|revised
//    user_id=<uuid>
//    page, limit
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) ListAll(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	filter := repository.AssessmentListFilter{
		Tier:   queryString(r, "tier"),
		Status: queryString(r, "status"),
		UserID: queryString(r, "user_id"),
	}

	items, total, err := h.svc.ListAll(r.Context(), params, filter)
	if err != nil {
		slog.Error("[Assessment.ListAll] failed", "error", err)
		response.InternalError(w, "Failed to fetch assessments")
		return
	}

	meta := model.NewPaginationMeta(params.Page, params.Limit, total)
	response.OKPaginated(w, items, meta)
}

// ────────────────────────────────────────────────────────────────
//  PATCH /api/assessments/{id}/review  — trainer only
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) Review(w http.ResponseWriter, r *http.Request) {
	reviewerID := middleware.GetUserID(r.Context())
	if reviewerID == "" {
		response.Unauthorized(w, "Not authenticated")
		return
	}
	id := chi.URLParam(r, "id")
	if id == "" {
		response.BadRequest(w, "Missing assessment id")
		return
	}

	var input service.ReviewInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Assessment.Review] invalid body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Assessment.Review] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	result, err := h.svc.Review(r.Context(), id, reviewerID, &input)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrAssessmentNotFound):
			response.NotFound(w, "Assessment not found")
		case errors.Is(err, service.ErrPaidOnly):
			response.BadRequest(w, "Only paid assessments can be reviewed")
		case errors.Is(err, service.ErrInvalidReviewStatus):
			response.BadRequest(w, err.Error())
		default:
			slog.Error("[Assessment.Review] failed", "id", id, "reviewer_id", reviewerID, "error", err)
			response.InternalError(w, "Failed to apply review")
		}
		return
	}
	slog.Info("[Assessment.Review] success", "assessment_id", id, "reviewer_id", reviewerID, "status", input.Status)
	response.OKWithMessage(w, result, "Review applied")
}
