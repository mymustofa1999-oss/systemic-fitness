package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type PaymentService struct {
	paymentRepo        *repository.PaymentRepository
	trainerCardService *TrainerCardService
	notifier           *NotificationService // optional — nil disables push
	logger             *slog.Logger
}

func NewPaymentService(
	pr *repository.PaymentRepository,
	tcs *TrainerCardService,
	notifier *NotificationService,
	logger *slog.Logger,
) *PaymentService {
	return &PaymentService{
		paymentRepo:        pr,
		trainerCardService: tcs,
		notifier:           notifier,
		logger:             logger,
	}
}

// ═══════════════════════════════════════════════════════════════
//  Plans
// ═══════════════════════════════════════════════════════════════

func (s *PaymentService) ListPlans(ctx context.Context, activeOnly bool) ([]repository.PaymentPlan, error) {
	plans, err := s.paymentRepo.ListPlans(ctx, activeOnly)
	if err != nil {
		s.logger.Error("list plans", "active_only", activeOnly, "error", err)
		return nil, err
	}
	return plans, nil
}

func (s *PaymentService) GetPlan(ctx context.Context, id string) (*repository.PaymentPlan, error) {
	plan, err := s.paymentRepo.GetPlanByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get plan", "id", id, "error", err)
		}
		return nil, err
	}
	return plan, nil
}

func (s *PaymentService) CreatePlan(ctx context.Context, p *repository.PaymentPlan) error {
	if err := s.paymentRepo.CreatePlan(ctx, p); err != nil {
		s.logger.Error("create plan", "name", p.Name, "error", err)
		return fmt.Errorf("creating plan: %w", err)
	}
	s.logger.Info("payment plan created", "id", p.ID, "name", p.Name, "price", p.Price)
	return nil
}

func (s *PaymentService) UpdatePlan(ctx context.Context, p *repository.PaymentPlan) error {
	if err := s.paymentRepo.UpdatePlan(ctx, p); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return err
		}
		s.logger.Error("update plan", "id", p.ID, "error", err)
		return fmt.Errorf("updating plan: %w", err)
	}
	s.logger.Info("payment plan updated", "id", p.ID)
	return nil
}

// ═══════════════════════════════════════════════════════════════
//  Subscriptions
// ═══════════════════════════════════════════════════════════════

func (s *PaymentService) ListSubscriptions(ctx context.Context, params model.PaginationParams, f repository.SubscriptionListFilter) ([]repository.Subscription, model.PaginationMeta, error) {
	subs, total, err := s.paymentRepo.ListSubscriptions(ctx, params, f)
	if err != nil {
		s.logger.Error("list subscriptions", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return subs, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

func (s *PaymentService) UpdateSubscriptionAttachment(ctx context.Context, id string, attachmentURL *string) error {
	if err := s.paymentRepo.UpdateSubscriptionAttachment(ctx, id, attachmentURL); err != nil {
		s.logger.Error("update subscription attachment", "id", id, "error", err)
		return err
	}
	s.logger.Info("subscription attachment updated", "id", id)
	return nil
}

// ═══════════════════════════════════════════════════════════════
//  Payment Records
// ═══════════════════════════════════════════════════════════════

func (s *PaymentService) ListPayments(ctx context.Context, params model.PaginationParams, f repository.PaymentListFilter) ([]repository.PaymentRecord, model.PaginationMeta, error) {
	records, total, err := s.paymentRepo.ListPayments(ctx, params, f)
	if err != nil {
		s.logger.Error("list payments", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return records, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

var validPaymentStatuses = map[string]bool{
	"pending": true, "completed": true, "failed": true, "refunded": true,
}

// UpdatePaymentStatus changes a payment record's status. When set to
// "completed" the related subscription is also activated and extended.
// Every change is recorded in payment_status_logs.
func (s *PaymentService) UpdatePaymentStatus(
	ctx context.Context,
	paymentID, newStatus, actorID string,
	reason *string,
) (*repository.PaymentRecord, *repository.PaymentStatusLog, error) {
	if !validPaymentStatuses[newStatus] {
		return nil, nil, fmt.Errorf("invalid status: %s", newStatus)
	}
	if actorID == "" {
		return nil, nil, errors.New("actor required")
	}

	rec, log, err := s.paymentRepo.UpdatePaymentStatus(ctx, paymentID, newStatus, actorID, reason)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update payment status",
				"payment_id", paymentID, "new_status", newStatus, "actor", actorID, "error", err)
		}
		return nil, nil, err
	}
	s.logger.Info("payment status updated",
		"payment_id", paymentID, "new_status", newStatus, "actor", actorID)

	if newStatus == "completed" && s.trainerCardService != nil {
		if tcErr := s.trainerCardService.AutoCreateDefaultCard(ctx, rec.UserID); tcErr != nil {
			s.logger.Error("failed to auto-create training card during manual payment completion", "user_id", rec.UserID, "error", tcErr)
		}
	}

	// Dispatch push + in-app notification to the customer whose payment
	// was just updated (terminal states only — pending is a no-op).
	// Best-effort — failures are logged but not propagated so the admin
	// action succeeds even if FCM is down.
	if s.notifier != nil && (newStatus == "completed" || newStatus == "failed" || newStatus == "refunded") {
		var title, body, notifType string
		switch newStatus {
		case "completed":
			title = "Pembayaran Berhasil Diverifikasi 🎉"
			body = "Langganan kamu sudah aktif. Selamat menikmati semua fitur premium!"
			notifType = "payment_completed"
		case "failed":
			title = "Pembayaran Ditolak"
			body = "Pembayaran kamu tidak berhasil diverifikasi oleh admin. Silakan coba lagi atau hubungi support."
			notifType = "payment_failed"
		case "refunded":
			title = "Pembayaran Dikembalikan"
			body = "Pembayaran kamu telah direfund."
			notifType = "payment_refunded"
		}
		data := map[string]string{
			"payment_id": rec.ID,
			"status":     newStatus,
			"deep_link":  "/profile/payments",
		}
		if err := s.notifier.SendToUser(ctx, rec.UserID, title, body, notifType, data); err != nil {
			s.logger.Warn("send payment status notification",
				"payment_id", rec.ID, "user_id", rec.UserID, "status", newStatus, "error", err)
		}
	}

	return rec, log, nil
}

func (s *PaymentService) ListPaymentLogs(ctx context.Context, paymentID string) ([]repository.PaymentStatusLog, error) {
	logs, err := s.paymentRepo.ListPaymentLogs(ctx, paymentID)
	if err != nil {
		s.logger.Error("list payment logs", "payment_id", paymentID, "error", err)
		return nil, err
	}
	return logs, nil
}

// ═══════════════════════════════════════════════════════════════
//  Financial Report
// ═══════════════════════════════════════════════════════════════

func (s *PaymentService) GetFinancialReport(ctx context.Context, periodStart, periodEnd string) (*repository.FinancialReport, error) {
	report, err := s.paymentRepo.GetFinancialReport(ctx, periodStart, periodEnd)
	if err != nil {
		s.logger.Error("get financial report", "period_start", periodStart, "period_end", periodEnd, "error", err)
		return nil, err
	}
	s.logger.Info("financial report generated", "period_start", periodStart, "period_end", periodEnd)
	return report, nil
}

// CreateManualSubscription creates an active subscription manually for a client and triggers default training card generation.
func (s *PaymentService) CreateManualSubscription(
	ctx context.Context,
	userID, planID string,
) (*repository.Subscription, error) {
	sub, rec, err := s.paymentRepo.CreateManualSubscription(ctx, userID, planID)
	if err != nil {
		s.logger.Error("create manual subscription failed", "user_id", userID, "plan_id", planID, "error", err)
		return nil, err
	}
	s.logger.Info("manual subscription created", "user_id", userID, "subscription_id", sub.ID)

	if s.trainerCardService != nil {
		if tcErr := s.trainerCardService.AutoCreateDefaultCard(ctx, rec.UserID); tcErr != nil {
			s.logger.Error("failed to auto-create training card during manual subscription assignment", "user_id", rec.UserID, "error", tcErr)
		}
	}

	return sub, nil
}

