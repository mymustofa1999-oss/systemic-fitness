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

type PaymentHandler struct {
	paymentService *service.PaymentService
}

func NewPaymentHandler(ps *service.PaymentService) *PaymentHandler {
	return &PaymentHandler{paymentService: ps}
}

// ── Plans ───────────────────────────────────────────────────────

// GET /api/payments/plans?active_only=true
func (h *PaymentHandler) ListPlans(w http.ResponseWriter, r *http.Request) {
	activeOnly := r.URL.Query().Get("active_only") != "false"
	plans, err := h.paymentService.ListPlans(r.Context(), activeOnly)
	if err != nil {
		slog.Error("[Payment.ListPlans] failed", "active_only", activeOnly, "error", err)
		response.InternalError(w, "Failed to fetch plans")
		return
	}
	slog.Debug("[Payment.ListPlans] success", "count", len(plans), "active_only", activeOnly)
	response.OK(w, plans)
}

// GET /api/payments/plans/{id}
func (h *PaymentHandler) GetPlan(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	plan, err := h.paymentService.GetPlan(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Payment.GetPlan] not found", "id", id)
			response.NotFound(w, "Plan not found")
			return
		}
		slog.Error("[Payment.GetPlan] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch plan")
		return
	}
	slog.Debug("[Payment.GetPlan] success", "id", id)
	response.OK(w, plan)
}

// POST /api/payments/plans
func (h *PaymentHandler) CreatePlan(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name           string          `json:"name"            validate:"required,min=1,max=100"`
		Description    *string         `json:"description,omitempty"`
		Price          float64         `json:"price"           validate:"required,min=0"`
		Currency       string          `json:"currency"        validate:"required,len=3"`
		DurationMonths int             `json:"duration_months" validate:"required,min=1"`
		Features       json.RawMessage `json:"features"        validate:"required"`
		MaxClients     *int            `json:"max_clients,omitempty" validate:"omitempty,min=1"`
		Tier           *string         `json:"tier,omitempty"`
		BillingPeriod  *string         `json:"billing_period,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Payment.CreatePlan] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Payment.CreatePlan] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	plan := &repository.PaymentPlan{
		Name:           input.Name,
		Description:    input.Description,
		Price:          input.Price,
		Currency:       input.Currency,
		DurationMonths: input.DurationMonths,
		Features:       input.Features,
		MaxClients:     input.MaxClients,
		IsActive:       true,
		Tier:           input.Tier,
		BillingPeriod:  input.BillingPeriod,
	}

	if err := h.paymentService.CreatePlan(r.Context(), plan); err != nil {
		slog.Error("[Payment.CreatePlan] failed", "name", input.Name, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Payment.CreatePlan] success", "id", plan.ID, "name", plan.Name, "price", plan.Price)
	response.Created(w, plan)
}

// PUT /api/payments/plans/{id}
func (h *PaymentHandler) UpdatePlan(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	existing, err := h.paymentService.GetPlan(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			slog.Warn("[Payment.UpdatePlan] not found", "id", id)
			response.NotFound(w, "Plan not found")
			return
		}
		slog.Error("[Payment.UpdatePlan] failed to fetch plan", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch plan")
		return
	}

	if err := response.DecodeJSON(r, existing); err != nil {
		slog.Warn("[Payment.UpdatePlan] invalid request body", "id", id, "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	existing.ID = id

	if err := h.paymentService.UpdatePlan(r.Context(), existing); err != nil {
		slog.Error("[Payment.UpdatePlan] failed", "id", id, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Payment.UpdatePlan] success", "id", id, "name", existing.Name)
	response.OK(w, existing)
}

// ── Subscriptions ───────────────────────────────────────────────

// PUT /api/payments/subscriptions/{id}/attachment
func (h *PaymentHandler) UpdateSubscriptionAttachment(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if id == "" {
		response.BadRequest(w, "Missing subscription ID")
		return
	}
	var req struct {
		AttachmentURL *string `json:"attachment_url"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, "Invalid payload")
		return
	}
	if err := h.paymentService.UpdateSubscriptionAttachment(r.Context(), id, req.AttachmentURL); err != nil {
		slog.Error("[Payment.UpdateSubscriptionAttachment] failed", "error", err)
		response.InternalError(w, "Failed to update attachment")
		return
	}
	response.SuccessMessage(w, "Attachment updated")
}

// GET /api/payments/subscriptions?status=active&plan_id=uuid&page=1&limit=20
func (h *PaymentHandler) ListSubscriptions(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.SubscriptionListFilter{
		Status: queryString(r, "status"),
		PlanID: queryString(r, "plan_id"),
		UserID: queryString(r, "user_id"),
	}

	subs, meta, err := h.paymentService.ListSubscriptions(r.Context(), params, f)
	if err != nil {
		slog.Error("[Payment.ListSubscriptions] failed", "error", err)
		response.InternalError(w, "Failed to fetch subscriptions")
		return
	}
	slog.Debug("[Payment.ListSubscriptions] success", "total", meta.Total)
	response.OKPaginated(w, subs, meta)
}

// ── Payment Records ─────────────────────────────────────────────

// GET /api/payments?status=completed&date_from=2024-01-01&date_to=2024-12-31&page=1&limit=20
func (h *PaymentHandler) ListPayments(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.PaymentListFilter{
		Status:   queryString(r, "status"),
		DateFrom: queryString(r, "date_from"),
		DateTo:   queryString(r, "date_to"),
		UserID:   queryString(r, "user_id"),
	}

	records, meta, err := h.paymentService.ListPayments(r.Context(), params, f)
	if err != nil {
		slog.Error("[Payment.ListPayments] failed", "error", err)
		response.InternalError(w, "Failed to fetch payments")
		return
	}
	slog.Debug("[Payment.ListPayments] success", "total", meta.Total)
	response.OKPaginated(w, records, meta)
}

// ── Payment Status Updates ──────────────────────────────────────

// PATCH /api/payments/{id}/status
func (h *PaymentHandler) UpdatePaymentStatus(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	var input struct {
		Status string  `json:"status" validate:"required,oneof=pending completed failed refunded"`
		Reason *string `json:"reason,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Payment.UpdateStatus] invalid request body", "id", id, "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Payment.UpdateStatus] validation failed", "id", id, "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	actorID := middleware.GetUserID(r.Context())
	rec, _, err := h.paymentService.UpdatePaymentStatus(r.Context(), id, input.Status, actorID, input.Reason)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Payment not found")
			return
		}
		slog.Error("[Payment.UpdateStatus] failed", "id", id, "status", input.Status, "error", err)
		response.InternalError(w, "Failed to update payment status")
		return
	}
	slog.Info("[Payment.UpdateStatus] success", "id", id, "status", input.Status, "actor", actorID)
	response.OKWithMessage(w, rec, "Payment status updated")
}

// GET /api/payments/{id}/logs
func (h *PaymentHandler) ListPaymentLogs(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	logs, err := h.paymentService.ListPaymentLogs(r.Context(), id)
	if err != nil {
		slog.Error("[Payment.ListLogs] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch payment logs")
		return
	}
	response.OK(w, logs)
}

// ── Financial Report ────────────────────────────────────────────

// GET /api/payments/reports?period_start=2024-01-01&period_end=2024-12-31
func (h *PaymentHandler) FinancialReport(w http.ResponseWriter, r *http.Request) {
	periodStart := r.URL.Query().Get("period_start")
	periodEnd := r.URL.Query().Get("period_end")

	if periodStart == "" || periodEnd == "" {
		slog.Warn("[Payment.FinancialReport] missing period params")
		response.BadRequest(w, "period_start and period_end are required (YYYY-MM-DD)")
		return
	}

	report, err := h.paymentService.GetFinancialReport(r.Context(), periodStart, periodEnd)
	if err != nil {
		slog.Error("[Payment.FinancialReport] failed", "period_start", periodStart, "period_end", periodEnd, "error", err)
		response.InternalError(w, "Failed to generate financial report")
		return
	}
	slog.Info("[Payment.FinancialReport] success", "period_start", periodStart, "period_end", periodEnd)
	response.OK(w, report)
}

// POST /api/payments/subscriptions
func (h *PaymentHandler) CreateManualSubscription(w http.ResponseWriter, r *http.Request) {
	var input struct {
		UserID string `json:"user_id" validate:"required,uuid4"`
		PlanID string `json:"plan_id" validate:"required,uuid4"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Payment.CreateManualSubscription] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Payment.CreateManualSubscription] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	sub, err := h.paymentService.CreateManualSubscription(r.Context(), input.UserID, input.PlanID)
	if err != nil {
		slog.Error("[Payment.CreateManualSubscription] failed", "user_id", input.UserID, "plan_id", input.PlanID, "error", err)
		response.InternalError(w, "Failed to create manual subscription: "+err.Error())
		return
	}

	slog.Info("[Payment.CreateManualSubscription] success", "user_id", input.UserID, "plan_id", input.PlanID)
	response.Created(w, sub)
}

