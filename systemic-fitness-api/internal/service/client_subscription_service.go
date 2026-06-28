package service

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

// ════════════════════════════════════════════════════════════════
//  Client Subscription Service
//  Business logic for client-facing subscription management
// ════════════════════════════════════════════════════════════════

var (
	ErrAlreadySubscribed    = errors.New("you already have an active subscription")
	ErrPlanNotFound         = errors.New("subscription plan not found")
	ErrSubscriptionNotFound = errors.New("subscription not found")
	ErrCannotCancel         = errors.New("no active subscription to cancel")
	ErrPaymentNotFound      = errors.New("payment not found")
	ErrInvalidPaymentType   = errors.New("invalid payment type")
	ErrNoBankAccount        = errors.New("no bank account is configured")
)

// Supported payment_type values for the Subscribe endpoint.
// "midtrans_*" variants are placeholders so we can plug in non-Snap
// flows later (VA, QRIS, e-wallet) without changing this enum again.
const (
	PaymentTypeManualTransfer = "manual_transfer"
	PaymentTypeMidtransSnap   = "midtrans_snap"

	// snapExpiryHours bounds how long a Midtrans Snap checkout stays valid.
	// It is sent to the gateway as the transaction `expiry` so abandoned
	// sessions auto-expire, and reused as snapSessionTTL — the window within
	// which an unfinished pending checkout can still be resumed (see
	// resumePendingCheckout) instead of being recreated.
	snapExpiryHours = 24
	snapSessionTTL  = snapExpiryHours * time.Hour
)

type ClientSubscriptionService struct {
	repo               *repository.ClientSubscriptionRepository
	bankRepo           *repository.BankAccountRepository
	midtransService    *MidtransService
	trainerCardService *TrainerCardService
	notifier           *NotificationService // optional — nil disables push
	logger             *slog.Logger
}

func NewClientSubscriptionService(
	repo *repository.ClientSubscriptionRepository,
	bankRepo *repository.BankAccountRepository,
	midtransService *MidtransService,
	tcs *TrainerCardService,
	notifier *NotificationService,
	logger *slog.Logger,
) *ClientSubscriptionService {
	return &ClientSubscriptionService{
		repo:               repo,
		bankRepo:           bankRepo,
		midtransService:    midtransService,
		trainerCardService: tcs,
		notifier:           notifier,
		logger:             logger,
	}
}

// notifyPaymentStatus dispatches a push + in-app notification for a
// payment state change. Best-effort — failures are logged but not
// propagated, since payment state has already been persisted.
func (s *ClientSubscriptionService) notifyPaymentStatus(ctx context.Context, userID, status, planName, paymentID string) {
	if s.notifier == nil {
		return
	}
	var title, body, notifType string
	switch status {
	case "completed":
		title = "Pembayaran Berhasil Diverifikasi 🎉"
		body = "Langganan " + planName + " kamu sudah aktif. Selamat menikmati semua fitur premium!"
		notifType = "payment_completed"
	case "failed":
		title = "Pembayaran Ditolak"
		body = "Pembayaran untuk " + planName + " tidak berhasil diverifikasi. Silakan coba lagi atau hubungi admin."
		notifType = "payment_failed"
	case "refunded":
		title = "Pembayaran Dikembalikan"
		body = "Pembayaran untuk " + planName + " telah direfund."
		notifType = "payment_refunded"
	default:
		return
	}
	data := map[string]string{
		"payment_id": paymentID,
		"status":     status,
		"deep_link":  "/profile/payments",
	}
	if err := s.notifier.SendToUser(ctx, userID, title, body, notifType, data); err != nil {
		s.logger.Warn("send payment notification",
			"user_id", userID,
			"payment_id", paymentID,
			"status", status,
			"error", err,
		)
	}
}

// ── Plans ───────────────────────────────────────────────────────

type PlanGroup struct {
	Tier     string                    `json:"tier"`
	Monthly  *repository.ClientPlan    `json:"monthly"`
	Annual   *repository.ClientPlan    `json:"annual,omitempty"`
}

func (s *ClientSubscriptionService) ListPlans(ctx context.Context) ([]PlanGroup, error) {
	plans, err := s.repo.ListPlans(ctx)
	if err != nil {
		s.logger.Error("list client plans", "error", err)
		return nil, fmt.Errorf("listing plans: %w", err)
	}

	tierMap := make(map[string]*PlanGroup)
	tierOrder := []string{}

	for i := range plans {
		p := &plans[i]
		group, ok := tierMap[p.Tier]
		if !ok {
			group = &PlanGroup{Tier: p.Tier}
			tierMap[p.Tier] = group
			tierOrder = append(tierOrder, p.Tier)
		}
		switch p.BillingPeriod {
		case "monthly":
			group.Monthly = p
		case "annual":
			group.Annual = p
		}
	}

	result := make([]PlanGroup, 0, len(tierOrder))
	for _, tier := range tierOrder {
		result = append(result, *tierMap[tier])
	}
	return result, nil
}

func (s *ClientSubscriptionService) GetPlan(ctx context.Context, id string) (*repository.ClientPlan, error) {
	plan, err := s.repo.GetPlanByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrPlanNotFound
		}
		s.logger.Error("get client plan", "id", id, "error", err)
		return nil, err
	}
	return plan, nil
}

// ── Subscribe ───────────────────────────────────────────────────

type SubscribeInput struct {
	PlanID        string `json:"plan_id"        validate:"required,uuid"`
	PaymentMethod string `json:"payment_method" validate:"required,max=50"`
	// PaymentType selects the flow:
	//   - "manual_transfer" : returns bank account instructions
	//   - "midtrans_snap"   : creates Snap transaction, returns snap_token + redirect_url
	// If empty, defaults to manual_transfer for backward compatibility.
	PaymentType string `json:"payment_type,omitempty" validate:"omitempty,oneof=manual_transfer midtrans_snap"`
	// Optional customer details forwarded to Midtrans (Snap UX).
	CustomerName  string `json:"customer_name,omitempty"  validate:"omitempty,max=100"`
	CustomerEmail string `json:"customer_email,omitempty" validate:"omitempty,email"`
	CustomerPhone string `json:"customer_phone,omitempty" validate:"omitempty,max=30"`
}

type SubscribeResult struct {
	Subscription *repository.ClientSubscription  `json:"subscription"`
	Payment      *repository.ClientPaymentRecord `json:"payment"`
	// BankAccount is populated for the manual_transfer flow.
	BankAccount *repository.BankAccount `json:"bank_account,omitempty"`
	// SnapToken/SnapRedirectURL are populated for the midtrans_snap flow.
	SnapToken       string `json:"snap_token,omitempty"`
	SnapRedirectURL string `json:"snap_redirect_url,omitempty"`
}

func (s *ClientSubscriptionService) Subscribe(ctx context.Context, userID string, input *SubscribeInput) (*SubscribeResult, error) {
	// Default to manual transfer if not specified
	paymentType := input.PaymentType
	if paymentType == "" {
		paymentType = PaymentTypeManualTransfer
	}

	// Inspect any in-flight subscription instead of blanket-blocking:
	//   - active  → genuinely subscribed; block with ErrAlreadySubscribed.
	//   - pending → an unfinished checkout. If it is a Midtrans Snap session
	//               still inside snapSessionTTL, resume it (hand back the same
	//               redirect URL). Otherwise it is abandoned/stale, so we
	//               cancel it and let the customer start fresh below.
	// This removes the dead-end where an abandoned 'pending' subscription
	// permanently blocked the customer from ever paying again.
	existing, err := s.repo.GetCurrentSubscription(ctx, userID)
	if err != nil && !errors.Is(err, repository.ErrNotFound) {
		s.logger.Error("check existing subscription", "user_id", userID, "error", err)
		return nil, fmt.Errorf("checking subscription: %w", err)
	}
	if existing != nil {
		if existing.Status == "active" {
			return nil, ErrAlreadySubscribed
		}
		// existing.Status == "pending"
		resumed, err := s.resumePendingCheckout(ctx, userID, existing, paymentType)
		if err != nil {
			return nil, err
		}
		if resumed != nil {
			return resumed, nil
		}
		// Stale pending was released — fall through to a fresh subscribe.
	}

	// Validate plan exists
	plan, err := s.repo.GetPlanByID(ctx, input.PlanID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrPlanNotFound
		}
		s.logger.Error("get plan for subscribe", "plan_id", input.PlanID, "error", err)
		return nil, err
	}

	// Calculate subscription period
	now := time.Now()
	expiresAt := now.AddDate(0, plan.DurationMonths, 0)

	// Create subscription (status='active' but payment is still pending —
	// access gating should rely on the payment record's status if you want
	// strict pay-before-access. We keep the existing semantics for now.)
	sub, err := s.repo.CreateSubscription(ctx, userID, plan.ID, input.PaymentMethod, now, expiresAt)
	if err != nil {
		s.logger.Error("create subscription", "user_id", userID, "plan_id", plan.ID, "error", err)
		return nil, fmt.Errorf("creating subscription: %w", err)
	}

	// Branch: build the payment record + flow-specific extras
	switch paymentType {
	case PaymentTypeManualTransfer:
		return s.subscribeManualTransfer(ctx, userID, sub, plan, input.PaymentMethod)
	case PaymentTypeMidtransSnap:
		return s.subscribeMidtransSnap(ctx, userID, sub, plan, input)
	default:
		return nil, ErrInvalidPaymentType
	}
}

// subscribeManualTransfer picks an active bank account and returns it
// alongside the pending payment_record so the mobile app can render
// the transfer instructions screen.
func (s *ClientSubscriptionService) subscribeManualTransfer(
	ctx context.Context,
	userID string,
	sub *repository.ClientSubscription,
	plan *repository.ClientPlan,
	paymentMethod string,
) (*SubscribeResult, error) {
	bank, err := s.bankRepo.GetFirstActive(ctx)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrNoBankAccount
		}
		s.logger.Error("get first active bank", "error", err)
		return nil, fmt.Errorf("loading bank account: %w", err)
	}

	payment, err := s.repo.CreatePaymentRecord(ctx, repository.CreatePaymentRecordInput{
		SubscriptionID: sub.ID,
		UserID:         userID,
		Amount:         plan.Price,
		Currency:       plan.Currency,
		PaymentMethod:  paymentMethod,
		PaymentType:    PaymentTypeManualTransfer,
		BankAccountID:  &bank.ID,
	})
	if err != nil {
		s.logger.Error("create payment record (manual)", "subscription_id", sub.ID, "error", err)
		return nil, fmt.Errorf("creating payment record: %w", err)
	}

	s.logger.Info("client subscribed (manual transfer)",
		"user_id", userID,
		"plan_id", plan.ID,
		"plan_name", plan.Name,
		"amount", plan.Price,
		"bank_id", bank.ID,
	)

	return &SubscribeResult{
		Subscription: sub,
		Payment:      payment,
		BankAccount:  bank,
	}, nil
}

// resumePendingCheckout decides what to do when the customer already has
// a 'pending' subscription. If they are re-requesting Midtrans and it is
// backed by a Snap session still inside snapSessionTTL, the same checkout
// is returned so they can finish paying (no duplicate transaction).
// Otherwise the stale pending subscription is cancelled — which also marks
// its pending payment 'failed' — and (nil, nil) is returned so the caller
// starts a fresh flow (e.g. when the customer switches payment method).
func (s *ClientSubscriptionService) resumePendingCheckout(
	ctx context.Context,
	userID string,
	sub *repository.ClientSubscription,
	requestedType string,
) (*SubscribeResult, error) {
	pay, err := s.repo.GetLatestPendingPaymentBySubscription(ctx, sub.ID)
	if err != nil && !errors.Is(err, repository.ErrNotFound) {
		s.logger.Error("load pending payment", "subscription_id", sub.ID, "error", err)
		return nil, fmt.Errorf("loading pending payment: %w", err)
	}

	if requestedType == PaymentTypeMidtransSnap && isResumableSnap(pay) {
		s.logger.Info("resuming midtrans snap checkout",
			"user_id", userID,
			"subscription_id", sub.ID,
			"payment_id", pay.ID,
		)
		return &SubscribeResult{
			Subscription:    sub,
			Payment:         pay,
			SnapToken:       strVal(pay.SnapToken),
			SnapRedirectURL: strVal(pay.SnapRedirectURL),
		}, nil
	}

	// Abandoned / expired / non-resumable → release the customer so they
	// can subscribe again. CancelSubscription also flips the lingering
	// pending payment to 'failed'.
	if err := s.repo.CancelSubscription(ctx, sub.ID, userID); err != nil &&
		!errors.Is(err, repository.ErrNotFound) {
		s.logger.Error("cancel stale pending subscription", "subscription_id", sub.ID, "error", err)
		return nil, fmt.Errorf("releasing stale subscription: %w", err)
	}
	s.logger.Info("released stale pending subscription",
		"user_id", userID, "subscription_id", sub.ID)
	return nil, nil
}

// isResumableSnap reports whether a pending payment is a Midtrans Snap
// session still within snapSessionTTL and therefore safe to hand back to
// the customer instead of creating a brand-new transaction.
func isResumableSnap(pay *repository.ClientPaymentRecord) bool {
	return pay != nil &&
		pay.PaymentType != nil && *pay.PaymentType == PaymentTypeMidtransSnap &&
		pay.SnapRedirectURL != nil && *pay.SnapRedirectURL != "" &&
		time.Since(pay.CreatedAt) < snapSessionTTL
}

func strVal(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}

// subscribeMidtransSnap creates a Snap transaction and persists the
// resulting snap_token + redirect_url. Returns ErrMidtransNotConfigured
// if the gateway isn't enabled — caller should fall back to manual.
func (s *ClientSubscriptionService) subscribeMidtransSnap(
	ctx context.Context,
	userID string,
	sub *repository.ClientSubscription,
	plan *repository.ClientPlan,
	input *SubscribeInput,
) (*SubscribeResult, error) {
	if s.midtransService == nil || !s.midtransService.IsConfigured() {
		return nil, ErrMidtransNotConfigured
	}

	// Create the payment record first (status='pending') so we have a UUID
	// that we can also use as the Midtrans order_id. This makes webhook
	// reconciliation simple — order_id ↔ payment_records.id ↔ external_id.
	payment, err := s.repo.CreatePaymentRecord(ctx, repository.CreatePaymentRecordInput{
		SubscriptionID: sub.ID,
		UserID:         userID,
		Amount:         plan.Price,
		Currency:       plan.Currency,
		PaymentMethod:  input.PaymentMethod,
		PaymentType:    PaymentTypeMidtransSnap,
	})
	if err != nil {
		s.logger.Error("create payment record (midtrans)", "subscription_id", sub.ID, "error", err)
		return nil, fmt.Errorf("creating payment record: %w", err)
	}

	orderID := fmt.Sprintf("FC-%s", payment.ID)

	snapReq := &SnapTransactionRequest{
		TransactionDetails: SnapTransactionDetails{
			OrderID:     orderID,
			GrossAmount: plan.Price,
		},
		ItemDetails: []SnapItemDetails{
			{
				ID:       plan.ID,
				Price:    plan.Price,
				Quantity: 1,
				Name:     plan.Name,
				Category: "subscription",
			},
		},
		CustomerDetails: &SnapCustomerDetails{
			FirstName: input.CustomerName,
			Email:     input.CustomerEmail,
			Phone:     input.CustomerPhone,
		},
		Callbacks: &SnapCallbacks{
			Finish: "https://systemicfitnesshealth.com/payment/finish",
		},
		// Bound the session lifetime so abandoned checkouts auto-expire on
		// the gateway. start_time is omitted, so Midtrans counts from the
		// transaction creation time. Kept in sync with snapSessionTTL.
		Expiry: &SnapExpiry{
			Unit:     "hours",
			Duration: snapExpiryHours,
		},
	}

	snapResp, err := s.midtransService.CreateSnapTransaction(ctx, snapReq)
	if err != nil {
		s.logger.Error("midtrans snap create", "order_id", orderID, "error", err)
		return nil, fmt.Errorf("creating snap transaction: %w", err)
	}

	if err := s.repo.UpdateSnapDetails(ctx, payment.ID, snapResp.Token, snapResp.RedirectURL, orderID); err != nil {
		s.logger.Error("persist snap details", "payment_id", payment.ID, "error", err)
		return nil, fmt.Errorf("persisting snap details: %w", err)
	}

	// Reflect the new fields in the returned payment for convenience.
	payment.SnapToken = &snapResp.Token
	payment.SnapRedirectURL = &snapResp.RedirectURL
	payment.ExternalID = &orderID

	s.logger.Info("client subscribed (midtrans snap)",
		"user_id", userID,
		"plan_id", plan.ID,
		"plan_name", plan.Name,
		"amount", plan.Price,
		"order_id", orderID,
	)

	return &SubscribeResult{
		Subscription:    sub,
		Payment:         payment,
		SnapToken:       snapResp.Token,
		SnapRedirectURL: snapResp.RedirectURL,
	}, nil
}

// ── Upload Payment Proof (manual transfer flow) ─────────────────

func (s *ClientSubscriptionService) UploadPaymentProof(ctx context.Context, paymentID, userID, imageURL string) (*repository.ClientPaymentRecord, error) {
	// Verify the payment belongs to the user
	pr, err := s.repo.GetPaymentByID(ctx, paymentID, userID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrPaymentNotFound
		}
		s.logger.Error("get payment for proof upload", "payment_id", paymentID, "error", err)
		return nil, fmt.Errorf("getting payment: %w", err)
	}

	if err := s.repo.UpdatePaymentProof(ctx, paymentID, userID, imageURL); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrPaymentNotFound
		}
		s.logger.Error("update payment proof", "payment_id", paymentID, "error", err)
		return nil, fmt.Errorf("updating payment proof: %w", err)
	}

	pr.ProofImageURL = &imageURL
	now := time.Now()
	pr.ProofUploadedAt = &now

	s.logger.Info("payment proof uploaded",
		"payment_id", paymentID,
		"user_id", userID,
	)

	// Notify customer that the proof was received and is being verified.
	if s.notifier != nil {
		_ = s.notifier.SendToUser(
			ctx, userID,
			"Bukti Pembayaran Diterima",
			"Bukti transfer kamu sudah kami terima. Admin akan memverifikasi dalam maksimal 1x24 jam.",
			"payment_proof_received",
			map[string]string{
				"payment_id": paymentID,
				"deep_link":  "/profile/payments",
			},
		)
	}
	return pr, nil
}

// ── Process Midtrans Webhook ────────────────────────────────────

// ProcessMidtransNotification verifies the signature, looks up the
// matching payment record, and updates its status atomically.
//
// Status mapping:
//   settlement / capture  →  completed
//   pending               →  pending (no-op)
//   deny / cancel / expire → failed
//   refund / chargeback   →  refunded
func (s *ClientSubscriptionService) ProcessMidtransNotification(
	ctx context.Context,
	notif *MidtransNotification,
	rawBody []byte,
) error {
	if s.midtransService == nil || !s.midtransService.IsConfigured() {
		return ErrMidtransNotConfigured
	}

	if err := s.midtransService.VerifySignature(notif); err != nil {
		return err
	}

	internalStatus := MapTransactionStatus(notif.TransactionStatus)

	// Persist raw payload for audit/debug
	rawJSON := json.RawMessage(rawBody)
	if !json.Valid(rawJSON) {
		// Should never happen — webhook handler decodes JSON before
		// reaching here — but be defensive.
		rawJSON = json.RawMessage(`{}`)
	}

	if err := s.repo.ApplyMidtransNotification(
		ctx,
		notif.OrderID,
		internalStatus,
		notif.TransactionStatus,
		rawJSON,
	); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return ErrPaymentNotFound
		}
		s.logger.Error("apply midtrans notification",
			"order_id", notif.OrderID,
			"status", notif.TransactionStatus,
			"error", err,
		)
		return fmt.Errorf("applying notification: %w", err)
	}

	s.logger.Info("midtrans notification applied",
		"order_id", notif.OrderID,
		"midtrans_status", notif.TransactionStatus,
		"internal_status", internalStatus,
	)

	// Dispatch push notification for terminal states. Best-effort —
	// we re-read the payment to grab user_id + plan name. Skip on
	// 'pending' since it isn't actionable for the customer.
	if internalStatus == "completed" || internalStatus == "failed" || internalStatus == "refunded" {
		pr, err := s.repo.GetPaymentByExternalID(ctx, notif.OrderID)
		if err == nil && pr != nil {
			// Plan name lookup via the subscription → best-effort.
			planName := "langganan"
			if sub, err := s.repo.GetSubscriptionByIDInternal(ctx, pr.SubscriptionID); err == nil && sub != nil {
				planName = sub.PlanName
			}
			// GetPaymentByExternalID does not fetch user_id directly
			// from the client struct — grab it via a dedicated lookup.
			userID, err := s.repo.GetPaymentOwnerUserID(ctx, pr.ID)
			if err == nil && userID != "" {
				if internalStatus == "completed" && s.trainerCardService != nil {
					if tcErr := s.trainerCardService.AutoCreateDefaultCard(ctx, userID); tcErr != nil {
						s.logger.Error("failed to auto-create training card during Midtrans webhook", "user_id", userID, "error", tcErr)
					}
				}
				s.notifyPaymentStatus(ctx, userID, internalStatus, planName, pr.ID)
			}
		}
	}

	return nil
}

// ── My Subscription ─────────────────────────────────────────────

type MySubscriptionResult struct {
	HasSubscription bool                            `json:"has_subscription"`
	Subscription    *repository.ClientSubscription  `json:"subscription,omitempty"`
	DaysRemaining   *int                            `json:"days_remaining,omitempty"`
}

func (s *ClientSubscriptionService) GetMySubscription(ctx context.Context, userID string) (*MySubscriptionResult, error) {
	// Returns the latest active OR pending subscription, preferring active.
	// We surface pending here so the mobile client can show "menunggu
	// pembayaran" state, while paid-feature gates continue to use
	// isPaidActive (which only counts status='active').
	sub, err := s.repo.GetCurrentSubscription(ctx, userID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return &MySubscriptionResult{HasSubscription: false}, nil
		}
		s.logger.Error("get my subscription", "user_id", userID, "error", err)
		return nil, err
	}

	// days_remaining only meaningful for active subscriptions — for
	// pending ones expires_at is just a placeholder.
	var daysRemaining *int
	if sub.Status == "active" {
		d := int(time.Until(sub.ExpiresAt).Hours() / 24)
		daysRemaining = &d
	}

	return &MySubscriptionResult{
		HasSubscription: true,
		Subscription:    sub,
		DaysRemaining:   daysRemaining,
	}, nil
}

// ── Cancel ──────────────────────────────────────────────────────

func (s *ClientSubscriptionService) CancelSubscription(ctx context.Context, userID, subscriptionID string) error {
	// Look up the sub first so we know its status (pending vs active)
	// and plan name for the notification body. Best-effort — if the
	// lookup fails we still attempt the cancel.
	sub, _ := s.repo.GetSubscriptionByID(ctx, subscriptionID, userID)

	if err := s.repo.CancelSubscription(ctx, subscriptionID, userID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return ErrCannotCancel
		}
		s.logger.Error("cancel subscription", "user_id", userID, "subscription_id", subscriptionID, "error", err)
		return fmt.Errorf("cancelling subscription: %w", err)
	}

	s.logger.Info("subscription cancelled",
		"user_id", userID,
		"subscription_id", subscriptionID,
	)

	// Notify customer (in-app + push). Customer initiated the cancel,
	// so this is mostly a confirmation receipt.
	if s.notifier != nil {
		planName := "Langganan"
		if sub != nil {
			planName = sub.PlanName
		}
		data := map[string]string{
			"subscription_id": subscriptionID,
			"deep_link":       "/profile/subscription",
		}
		_ = s.notifier.SendToUser(
			ctx, userID,
			"Langganan Dibatalkan",
			planName+" telah dibatalkan. Kamu bisa subscribe ulang kapan saja.",
			"subscription_cancelled",
			data,
		)
	}
	return nil
}

// ── History ─────────────────────────────────────────────────────

func (s *ClientSubscriptionService) GetHistory(ctx context.Context, userID string, params model.PaginationParams) ([]repository.ClientSubscription, model.PaginationMeta, error) {
	subs, total, err := s.repo.ListSubscriptionHistory(ctx, userID, params)
	if err != nil {
		s.logger.Error("list subscription history", "user_id", userID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return subs, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ── My Payments ─────────────────────────────────────────────────

func (s *ClientSubscriptionService) GetMyPayments(ctx context.Context, userID string, params model.PaginationParams) ([]repository.ClientPaymentRecord, model.PaginationMeta, error) {
	records, total, err := s.repo.ListMyPayments(ctx, userID, params)
	if err != nil {
		s.logger.Error("list my payments", "user_id", userID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return records, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}
