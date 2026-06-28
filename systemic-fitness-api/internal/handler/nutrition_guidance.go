package handler

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type NutritionGuidanceHandler struct {
	svc *service.NutritionGuidanceService
}

func NewNutritionGuidanceHandler(svc *service.NutritionGuidanceService) *NutritionGuidanceHandler {
	return &NutritionGuidanceHandler{svc: svc}
}

// POST /api/v1/nutrition-guidance/profile
func (h *NutritionGuidanceHandler) UpsertProfile(w http.ResponseWriter, r *http.Request) {
	var input model.UpsertNutritionProfileInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	profile, err := h.svc.UpsertProfile(r.Context(), userID, &input)
	if err != nil {
		slog.Error("[NutritionGuidance.UpsertProfile] failed", "error", err)
		response.InternalError(w, "Failed to save nutrition profile")
		return
	}
	response.Created(w, profile)
}

// GET /api/v1/nutrition-guidance/plan
func (h *NutritionGuidanceHandler) GetPlan(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	plan, err := h.svc.GetPlan(r.Context(), userID)
	if err != nil {
		if errors.Is(err, service.ErrNutritionProfileNotFound) {
			response.NotFound(w, "Nutrition profile not set. Please complete your health profile first.")
			return
		}
		slog.Error("[NutritionGuidance.GetPlan] failed", "error", err)
		response.InternalError(w, "Failed to load nutrition plan")
		return
	}
	response.OK(w, plan)
}

// POST /api/v1/nutrition-guidance/daily/log
func (h *NutritionGuidanceHandler) SubmitDailyLog(w http.ResponseWriter, r *http.Request) {
	var input model.NutritionDailyLogInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	userID := middleware.GetUserID(r.Context())
	res, err := h.svc.SubmitDailyLog(r.Context(), userID, &input)
	if err != nil {
		slog.Error("[NutritionGuidance.SubmitDailyLog] failed", "error", err)
		response.InternalError(w, "Failed to save daily log")
		return
	}
	response.Created(w, res)
}

// GET /api/v1/nutrition-guidance/daily/result?date=YYYY-MM-DD
func (h *NutritionGuidanceHandler) GetDailyResult(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	date := r.URL.Query().Get("date")
	res, err := h.svc.GetDailyResult(r.Context(), userID, date)
	if err != nil {
		slog.Error("[NutritionGuidance.GetDailyResult] failed", "error", err)
		response.InternalError(w, "Failed to load daily result")
		return
	}
	response.OK(w, res)
}

// GET /api/v1/nutrition-guidance/daily/logs?limit=30
// Returns the authenticated user's most recent daily logs, newest first.
func (h *NutritionGuidanceHandler) ListMyLogs(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	limit := 30
	if v := r.URL.Query().Get("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 && n <= 365 {
			limit = n
		}
	}
	logs, err := h.svc.ListMyLogs(r.Context(), userID, limit)
	if err != nil {
		slog.Error("[NutritionGuidance.ListMyLogs] failed", "error", err)
		response.InternalError(w, "Failed to load logs")
		return
	}
	response.OK(w, logs)
}

// ─── Admin / Trainer endpoints ──────────────────────────────────────

// GET /api/v1/admin/nutrition-guidance/users/{id}/profile
func (h *NutritionGuidanceHandler) AdminGetProfile(w http.ResponseWriter, r *http.Request) {
	targetID := chi.URLParam(r, "id")
	profile, err := h.svc.AdminGetProfile(r.Context(), targetID)
	if err != nil {
		if errors.Is(err, service.ErrNutritionProfileNotFound) {
			response.NotFound(w, "Nutrition profile not set for this user.")
			return
		}
		slog.Error("[NutritionGuidance.AdminGetProfile] failed", "error", err)
		response.InternalError(w, "Failed to load profile")
		return
	}
	response.OK(w, profile)
}

// PUT /api/v1/admin/nutrition-guidance/users/{id}/profile
func (h *NutritionGuidanceHandler) AdminUpsertProfile(w http.ResponseWriter, r *http.Request) {
	targetID := chi.URLParam(r, "id")
	var input model.UpsertNutritionProfileInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	profile, err := h.svc.AdminUpsertProfile(r.Context(), targetID, &input)
	if err != nil {
		slog.Error("[NutritionGuidance.AdminUpsertProfile] failed", "error", err)
		response.InternalError(w, "Failed to save nutrition profile")
		return
	}
	response.OK(w, profile)
}

// GET /api/v1/admin/nutrition-guidance/users/{id}/plan
func (h *NutritionGuidanceHandler) AdminGetPlan(w http.ResponseWriter, r *http.Request) {
	targetID := chi.URLParam(r, "id")
	plan, err := h.svc.AdminGetPlan(r.Context(), targetID)
	if err != nil {
		if errors.Is(err, service.ErrNutritionProfileNotFound) {
			response.NotFound(w, "Nutrition profile not set for this user.")
			return
		}
		slog.Error("[NutritionGuidance.AdminGetPlan] failed", "error", err)
		response.InternalError(w, "Failed to load plan")
		return
	}
	response.OK(w, plan)
}

// GET /api/v1/admin/nutrition-guidance/users/{id}/logs?limit=30
func (h *NutritionGuidanceHandler) AdminListLogs(w http.ResponseWriter, r *http.Request) {
	targetID := chi.URLParam(r, "id")
	limit := 30
	if v := r.URL.Query().Get("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 && n <= 365 {
			limit = n
		}
	}
	logs, err := h.svc.AdminListLogs(r.Context(), targetID, limit)
	if err != nil {
		slog.Error("[NutritionGuidance.AdminListLogs] failed", "error", err)
		response.InternalError(w, "Failed to load logs")
		return
	}
	response.OK(w, logs)
}

