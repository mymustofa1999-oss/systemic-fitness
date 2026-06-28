package handler

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

// ════════════════════════════════════════════════════════════════
//  Client Subscription Handler
//  Client-facing endpoints for subscription plans & management
// ════════════════════════════════════════════════════════════════

type ClientSubscriptionHandler struct {
	svc           *service.ClientSubscriptionService
	uploadService *service.UploadService
}

func NewClientSubscriptionHandler(
	svc *service.ClientSubscriptionService,
	uploadService *service.UploadService,
) *ClientSubscriptionHandler {
	return &ClientSubscriptionHandler{svc: svc, uploadService: uploadService}
}

// ── Plans ───────────────────────────────────────────────────────

// GET /api/subscription/plans
func (h *ClientSubscriptionHandler) ListPlans(w http.ResponseWriter, r *http.Request) {
	plans, err := h.svc.ListPlans(r.Context())
	if err != nil {
		slog.Error("[ClientSubscription.ListPlans] failed", "error", err)
		response.InternalError(w, "Failed to fetch subscription plans")
		return
	}
	response.OK(w, plans)
}

// GET /api/subscription/plans/{id}
func (h *ClientSubscriptionHandler) GetPlan(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	plan, err := h.svc.GetPlan(r.Context(), id)
	if err != nil {
		if errors.Is(err, service.ErrPlanNotFound) {
			response.NotFound(w, "Subscription plan not found")
			return
		}
		slog.Error("[ClientSubscription.GetPlan] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch plan")
		return
	}
	response.OK(w, plan)
}

// ── Subscribe ───────────────────────────────────────────────────

// POST /api/subscription/subscribe
func (h *ClientSubscriptionHandler) Subscribe(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	var input service.SubscribeInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	result, err := h.svc.Subscribe(r.Context(), userID, &input)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrAlreadySubscribed):
			response.Conflict(w, "Kamu sudah memiliki langganan aktif. Batalkan terlebih dahulu untuk beralih plan.")
		case errors.Is(err, service.ErrPlanNotFound):
			response.NotFound(w, "Plan langganan tidak ditemukan")
		default:
			slog.Error("[ClientSubscription.Subscribe] failed", "user_id", userID, "error", err)
			response.InternalError(w, "Gagal memproses langganan")
		}
		return
	}

	slog.Info("[ClientSubscription.Subscribe] success",
		"user_id", userID,
		"plan_id", input.PlanID,
		"subscription_id", result.Subscription.ID,
	)
	response.CreatedWithMessage(w, result, "Berhasil berlangganan! Silakan selesaikan pembayaran.")
}

// ── My Subscription ─────────────────────────────────────────────

// GET /api/subscription/me
func (h *ClientSubscriptionHandler) MySubscription(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())

	result, err := h.svc.GetMySubscription(r.Context(), userID)
	if err != nil {
		slog.Error("[ClientSubscription.MySubscription] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch subscription")
		return
	}
	response.OK(w, result)
}

// ── Cancel ──────────────────────────────────────────────────────

// POST /api/subscription/{id}/cancel
func (h *ClientSubscriptionHandler) Cancel(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	subID := chi.URLParam(r, "id")

	if err := h.svc.CancelSubscription(r.Context(), userID, subID); err != nil {
		switch {
		case errors.Is(err, service.ErrCannotCancel):
			response.NotFound(w, "Tidak ada langganan aktif yang bisa dibatalkan")
		default:
			slog.Error("[ClientSubscription.Cancel] failed", "user_id", userID, "subscription_id", subID, "error", err)
			response.InternalError(w, "Gagal membatalkan langganan")
		}
		return
	}

	slog.Info("[ClientSubscription.Cancel] success", "user_id", userID, "subscription_id", subID)
	response.SuccessMessage(w, "Langganan berhasil dibatalkan")
}

// ── History ─────────────────────────────────────────────────────

// GET /api/subscription/history?page=1&limit=20
func (h *ClientSubscriptionHandler) History(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	params := paginationFromQuery(r)

	subs, meta, err := h.svc.GetHistory(r.Context(), userID, params)
	if err != nil {
		slog.Error("[ClientSubscription.History] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch subscription history")
		return
	}
	response.OKPaginated(w, subs, meta)
}

// ── My Payments ─────────────────────────────────────────────────

// GET /api/subscription/payments?page=1&limit=20
func (h *ClientSubscriptionHandler) MyPayments(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	params := paginationFromQuery(r)

	records, meta, err := h.svc.GetMyPayments(r.Context(), userID, params)
	if err != nil {
		slog.Error("[ClientSubscription.MyPayments] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch payment history")
		return
	}
	response.OKPaginated(w, records, meta)
}

// ── Upload Payment Proof ────────────────────────────────────────

// POST /api/subscription/payments/{id}/proof
//
// multipart/form-data with field "file" — the transfer receipt image.
// On success, the payment_records row is updated with the uploaded URL
// and proof_uploaded_at is stamped. Status stays 'pending' until an
// admin verifies and flips it.
func (h *ClientSubscriptionHandler) UploadPaymentProof(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	paymentID := chi.URLParam(r, "id")

	// Parse multipart with a generous size cap; UploadService re-validates.
	if err := r.ParseMultipartForm(20 << 20); err != nil {
		response.BadRequest(w, "Failed to parse multipart form: "+err.Error())
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		response.BadRequest(w, "Missing file field 'file'")
		return
	}
	defer file.Close()

	mimeType := header.Header.Get("Content-Type")

	upload, err := h.uploadService.Upload(r.Context(), &service.UploadInput{
		File:       file,
		FileName:   header.Filename,
		FileSize:   header.Size,
		MimeType:   mimeType,
		UserID:     userID,
		EntityType: strPtr("payment_proof"),
		EntityID:   &paymentID,
	})
	if err != nil {
		switch {
		case errors.Is(err, service.ErrFileTooLarge):
			response.BadRequest(w, "File terlalu besar")
		case errors.Is(err, service.ErrUnsupportedFormat):
			response.BadRequest(w, "Format file tidak didukung. Gunakan JPG/PNG/WEBP")
		default:
			slog.Error("[ClientSubscription.UploadPaymentProof] upload failed",
				"user_id", userID, "payment_id", paymentID, "error", err)
			response.InternalError(w, "Gagal mengunggah bukti pembayaran")
		}
		return
	}

	pr, err := h.svc.UploadPaymentProof(r.Context(), paymentID, userID, upload.URL)
	if err != nil {
		if errors.Is(err, service.ErrPaymentNotFound) {
			response.NotFound(w, "Pembayaran tidak ditemukan")
			return
		}
		slog.Error("[ClientSubscription.UploadPaymentProof] persist failed",
			"user_id", userID, "payment_id", paymentID, "error", err)
		response.InternalError(w, "Gagal menyimpan bukti pembayaran")
		return
	}

	slog.Info("[ClientSubscription.UploadPaymentProof] success",
		"user_id", userID, "payment_id", paymentID, "url", upload.URL)
	response.OKWithMessage(w, pr, "Bukti pembayaran berhasil diunggah, menunggu verifikasi admin")
}

// ── Midtrans Webhook ────────────────────────────────────────────

// POST /api/payments/midtrans/webhook
//
// Public endpoint (no auth) — Midtrans posts notifications here when
// payment status changes. The handler verifies the signature, updates
// the payment_records row and logs the raw payload for audit.
//
// Always returns HTTP 200 OK to Midtrans on processed payloads, even
// if the payment isn't found, otherwise Midtrans will retry forever.
// 4xx is reserved for malformed payloads.
func (h *ClientSubscriptionHandler) MidtransWebhook(w http.ResponseWriter, r *http.Request) {
	rawBody, err := io.ReadAll(r.Body)
	if err != nil {
		response.BadRequest(w, "Failed to read body")
		return
	}
	defer r.Body.Close()

	var notif service.MidtransNotification
	if err := json.NewDecoder(bytes.NewReader(rawBody)).Decode(&notif); err != nil {
		slog.Warn("[Midtrans.Webhook] invalid json", "error", err)
		response.BadRequest(w, "Invalid JSON body")
		return
	}

	if err := h.svc.ProcessMidtransNotification(r.Context(), &notif, rawBody); err != nil {
		switch {
		case errors.Is(err, service.ErrMidtransInvalidSig):
			slog.Warn("[Midtrans.Webhook] invalid signature", "order_id", notif.OrderID)
			response.Unauthorized(w, "Invalid signature")
			return
		case errors.Is(err, service.ErrMidtransNotConfigured):
			slog.Warn("[Midtrans.Webhook] not configured", "order_id", notif.OrderID)
			response.InternalError(w, "Midtrans not configured")
			return
		case errors.Is(err, service.ErrPaymentNotFound):
			// Acknowledge so Midtrans stops retrying — log for follow-up.
			slog.Warn("[Midtrans.Webhook] payment not found, ack-ing anyway",
				"order_id", notif.OrderID)
			response.OKWithMessage(w, nil, "acknowledged (payment not found)")
			return
		default:
			slog.Error("[Midtrans.Webhook] processing failed",
				"order_id", notif.OrderID, "error", err)
			response.InternalError(w, "Failed to process notification")
			return
		}
	}

	response.OKWithMessage(w, nil, "ok")
}

func strPtr(s string) *string { return &s }
