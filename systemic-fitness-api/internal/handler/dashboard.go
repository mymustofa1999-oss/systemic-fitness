package handler

import (
	"log/slog"
	"net/http"
	"strconv"

	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type DashboardHandler struct {
	dashboardService *service.DashboardService
}

func NewDashboardHandler(ds *service.DashboardService) *DashboardHandler {
	return &DashboardHandler{dashboardService: ds}
}

// GET /api/dashboard/overview
func (h *DashboardHandler) Overview(w http.ResponseWriter, r *http.Request) {
	overview, err := h.dashboardService.GetOverview(r.Context())
	if err != nil {
		slog.Error("[Dashboard.Overview] failed", "error", err)
		response.InternalError(w, "Failed to fetch dashboard overview")
		return
	}
	slog.Debug("[Dashboard.Overview] success", "total_users", overview.TotalUsers)
	response.OK(w, overview)
}

// GET /api/dashboard/revenue?months=12
func (h *DashboardHandler) Revenue(w http.ResponseWriter, r *http.Request) {
	months := 12
	if v := r.URL.Query().Get("months"); v != "" {
		if m, err := strconv.Atoi(v); err == nil && m > 0 {
			months = m
		}
	}

	data, err := h.dashboardService.GetRevenueChart(r.Context(), months)
	if err != nil {
		slog.Error("[Dashboard.Revenue] failed", "months", months, "error", err)
		response.InternalError(w, "Failed to fetch revenue data")
		return
	}
	slog.Debug("[Dashboard.Revenue] success", "months", months, "data_points", len(data))
	response.OK(w, map[string]any{
		"months": months,
		"data":   data,
	})
}

// GET /api/dashboard/engagement
func (h *DashboardHandler) Engagement(w http.ResponseWriter, r *http.Request) {
	data, err := h.dashboardService.GetEngagement(r.Context())
	if err != nil {
		slog.Error("[Dashboard.Engagement] failed", "error", err)
		response.InternalError(w, "Failed to fetch engagement data")
		return
	}
	slog.Debug("[Dashboard.Engagement] success")
	response.OK(w, data)
}

// GET /api/dashboard/trainers
func (h *DashboardHandler) TrainerPerformance(w http.ResponseWriter, r *http.Request) {
	data, err := h.dashboardService.GetTrainerPerformance(r.Context())
	if err != nil {
		slog.Error("[Dashboard.TrainerPerformance] failed", "error", err)
		response.InternalError(w, "Failed to fetch trainer performance")
		return
	}
	slog.Debug("[Dashboard.TrainerPerformance] success", "trainers", len(data))
	response.OK(w, data)
}
