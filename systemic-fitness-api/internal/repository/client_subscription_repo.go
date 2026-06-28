package repository

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

// ════════════════════════════════════════════════════════════════
//  Client Subscription Repository
//  Client-facing queries for subscription plans & management
// ════════════════════════════════════════════════════════════════

type ClientSubscriptionRepository struct {
	db *pgxpool.Pool
}

func NewClientSubscriptionRepository(db *pgxpool.Pool) *ClientSubscriptionRepository {
	return &ClientSubscriptionRepository{db: db}
}

// ── Structs ─────────────────────────────────────────────────────

type ClientPlan struct {
	ID             string          `json:"id"`
	Name           string          `json:"name"`
	Description    *string         `json:"description,omitempty"`
	Tier           string          `json:"tier"`
	BillingPeriod  string          `json:"billing_period"`
	Price          float64         `json:"price"`
	OriginalPrice  *float64        `json:"original_price,omitempty"`
	Currency       string          `json:"currency"`
	DurationMonths int             `json:"duration_months"`
	DiscountPct    int             `json:"discount_pct"`
	Features       json.RawMessage `json:"features"`
	IsPopular      bool            `json:"is_popular"`
	SortOrder      int             `json:"sort_order"`
}

type ClientSubscription struct {
	ID            string     `json:"id"`
	PlanID        string     `json:"plan_id"`
	PlanName      string     `json:"plan_name"`
	Tier          string     `json:"tier"`
	BillingPeriod string     `json:"billing_period"`
	Status        string     `json:"status"`
	StartedAt     time.Time  `json:"started_at"`
	ExpiresAt     time.Time  `json:"expires_at"`
	CancelledAt   *time.Time `json:"cancelled_at,omitempty"`
	PaymentMethod *string    `json:"payment_method,omitempty"`
	CreatedAt     time.Time  `json:"created_at"`
}

type ClientPaymentRecord struct {
	ID              string          `json:"id"`
	SubscriptionID  string          `json:"subscription_id"`
	Amount          float64         `json:"amount"`
	Currency        string          `json:"currency"`
	Status          string          `json:"status"`
	PaymentMethod   *string         `json:"payment_method,omitempty"`
	PaymentType     *string         `json:"payment_type,omitempty"`
	BankAccountID   *string         `json:"bank_account_id,omitempty"`
	ProofImageURL   *string         `json:"proof_image_url,omitempty"`
	ProofUploadedAt *time.Time      `json:"proof_uploaded_at,omitempty"`
	SnapToken       *string         `json:"snap_token,omitempty"`
	SnapRedirectURL *string         `json:"snap_redirect_url,omitempty"`
	GatewayStatus   *string         `json:"gateway_status,omitempty"`
	GatewayResponse json.RawMessage `json:"gateway_response,omitempty"`
	ExternalID      *string         `json:"external_id,omitempty"`
	PaidAt          *time.Time      `json:"paid_at,omitempty"`
	Metadata        json.RawMessage `json:"metadata,omitempty"`
	CreatedAt       time.Time       `json:"created_at"`
}

const clientPaymentColumns = `id, subscription_id, amount, currency, status, payment_method,
	payment_type, bank_account_id, proof_image_url, proof_uploaded_at,
	snap_token, snap_redirect_url, gateway_status, gateway_response,
	external_id, paid_at, metadata, created_at`

func scanClientPaymentRecord(row pgx.Row) (*ClientPaymentRecord, error) {
	pr := &ClientPaymentRecord{}
	err := row.Scan(&pr.ID, &pr.SubscriptionID, &pr.Amount, &pr.Currency, &pr.Status,
		&pr.PaymentMethod, &pr.PaymentType, &pr.BankAccountID,
		&pr.ProofImageURL, &pr.ProofUploadedAt,
		&pr.SnapToken, &pr.SnapRedirectURL, &pr.GatewayStatus, &pr.GatewayResponse,
		&pr.ExternalID, &pr.PaidAt, &pr.Metadata, &pr.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return pr, err
}

// ── Plans ───────────────────────────────────────────────────────

const clientPlanColumns = `id, name, description, tier, billing_period, price, original_price,
	currency, duration_months, discount_pct, features, is_popular, sort_order`

func scanClientPlan(row pgx.Row) (*ClientPlan, error) {
	p := &ClientPlan{}
	err := row.Scan(&p.ID, &p.Name, &p.Description, &p.Tier, &p.BillingPeriod,
		&p.Price, &p.OriginalPrice, &p.Currency, &p.DurationMonths,
		&p.DiscountPct, &p.Features, &p.IsPopular, &p.SortOrder)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return p, err
}

func (r *ClientSubscriptionRepository) ListPlans(ctx context.Context) ([]ClientPlan, error) {
	rows, err := r.db.Query(ctx, fmt.Sprintf(`
		SELECT %s FROM payment_plans
		WHERE is_active = TRUE AND tier IS NOT NULL
		ORDER BY sort_order, price`, clientPlanColumns))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	plans := make([]ClientPlan, 0)
	for rows.Next() {
		var p ClientPlan
		if err := rows.Scan(&p.ID, &p.Name, &p.Description, &p.Tier, &p.BillingPeriod,
			&p.Price, &p.OriginalPrice, &p.Currency, &p.DurationMonths,
			&p.DiscountPct, &p.Features, &p.IsPopular, &p.SortOrder); err != nil {
			return nil, err
		}
		plans = append(plans, p)
	}
	return plans, rows.Err()
}

func (r *ClientSubscriptionRepository) GetPlanByID(ctx context.Context, id string) (*ClientPlan, error) {
	return scanClientPlan(r.db.QueryRow(ctx, fmt.Sprintf(`
		SELECT %s FROM payment_plans
		WHERE id = $1 AND is_active = TRUE AND tier IS NOT NULL`, clientPlanColumns), id))
}

// ── Active Subscription ─────────────────────────────────────────

const clientSubColumns = `s.id, s.plan_id, pp.name, pp.tier, pp.billing_period,
	s.status, s.started_at, s.expires_at, s.cancelled_at, s.payment_method, s.created_at`

func scanClientSubscription(row pgx.Row) (*ClientSubscription, error) {
	s := &ClientSubscription{}
	err := row.Scan(&s.ID, &s.PlanID, &s.PlanName, &s.Tier, &s.BillingPeriod,
		&s.Status, &s.StartedAt, &s.ExpiresAt, &s.CancelledAt, &s.PaymentMethod, &s.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return s, err
}

func (r *ClientSubscriptionRepository) GetActiveSubscription(ctx context.Context, userID string) (*ClientSubscription, error) {
	return scanClientSubscription(r.db.QueryRow(ctx, fmt.Sprintf(`
		SELECT %s
		FROM subscriptions s
		JOIN payment_plans pp ON pp.id = s.plan_id
		WHERE s.user_id = $1 AND s.status = 'active'
		ORDER BY s.created_at DESC
		LIMIT 1`, clientSubColumns), userID))
}

func (r *ClientSubscriptionRepository) GetSubscriptionByID(ctx context.Context, id, userID string) (*ClientSubscription, error) {
	return scanClientSubscription(r.db.QueryRow(ctx, fmt.Sprintf(`
		SELECT %s
		FROM subscriptions s
		JOIN payment_plans pp ON pp.id = s.plan_id
		WHERE s.id = $1 AND s.user_id = $2`, clientSubColumns), id, userID))
}

// ── Subscribe ───────────────────────────────────────────────────

// CreateSubscription inserts a subscription with status='pending'.
//
// The subscription will be flipped to 'active' only after the related
// payment_record reaches 'completed' — either by an admin verifying a
// manual transfer (PaymentRepository.UpdatePaymentStatus) or by the
// Midtrans webhook (ApplyMidtransNotification).
//
// startedAt/expiresAt are placeholder values written so the row passes
// the chk_subscriptions_dates CHECK (expires_at > started_at). On
// activation, both columns are recomputed from NOW() so the customer
// gets the full plan duration starting from the verified payment time,
// not from the subscribe call.
func (r *ClientSubscriptionRepository) CreateSubscription(ctx context.Context, userID, planID, paymentMethod string, startedAt, expiresAt time.Time) (*ClientSubscription, error) {
	var subID string
	err := r.db.QueryRow(ctx, `
		INSERT INTO subscriptions (user_id, plan_id, status, started_at, expires_at, payment_method)
		VALUES ($1, $2, 'pending', $3, $4, $5)
		RETURNING id`,
		userID, planID, startedAt, expiresAt, paymentMethod,
	).Scan(&subID)
	if err != nil {
		return nil, fmt.Errorf("creating subscription: %w", err)
	}

	return r.GetSubscriptionByID(ctx, subID, userID)
}

// ActivatePendingSubscription flips a 'pending' subscription to 'active'
// and resets started_at / expires_at so the customer gets the full plan
// duration starting from NOW() (the moment the payment was verified).
//
// Idempotent: if the subscription is already 'active' (e.g. duplicate
// webhook), the existing started_at is preserved and expires_at is only
// EXTENDED — matching the renewal behaviour in payment_repo.UpdatePaymentStatus.
func (r *ClientSubscriptionRepository) ActivatePendingSubscription(ctx context.Context, subscriptionID string) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE subscriptions s SET
			status       = 'active',
			cancelled_at = NULL,
			started_at   = CASE
				WHEN s.status = 'pending' THEN NOW()
				ELSE s.started_at
			END,
			expires_at   = CASE
				WHEN s.status = 'pending'
					THEN NOW() + make_interval(months => pp.duration_months)
				ELSE GREATEST(s.expires_at, NOW())
					+ make_interval(months => pp.duration_months)
			END,
			updated_at   = NOW()
		FROM payment_plans pp
		WHERE s.id = $1 AND pp.id = s.plan_id`,
		subscriptionID,
	)
	if err != nil {
		return fmt.Errorf("activating subscription: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ── Cancel ──────────────────────────────────────────────────────

// CancelSubscription cancels an active OR pending subscription.
//
// When cancelling a 'pending' sub (not yet paid), any associated
// pending payment_record is also marked 'failed' — this releases the
// customer so they can start a fresh subscribe flow.
//
// When cancelling an 'active' sub (paid customer), the payment_records
// are untouched and the customer keeps access until expires_at.
//
// Both actions happen in a single transaction. Returns ErrNotFound if
// no matching subscription exists for the (id, userID) pair.
func (r *ClientSubscriptionRepository) CancelSubscription(ctx context.Context, id, userID string) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	// Lock + read the subscription's current status to decide whether
	// payment records should also be marked failed.
	var currentStatus string
	err = tx.QueryRow(ctx, `
		SELECT status FROM subscriptions
		WHERE id = $1 AND user_id = $2
		FOR UPDATE`, id, userID,
	).Scan(&currentStatus)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if err != nil {
		return fmt.Errorf("locking subscription: %w", err)
	}

	if currentStatus != "active" && currentStatus != "pending" {
		// Already cancelled / expired / etc — treat as a no-op error so
		// the handler can return a user-friendly message.
		return ErrNotFound
	}

	// Flip subscription → cancelled.
	if _, err := tx.Exec(ctx, `
		UPDATE subscriptions
		SET status = 'cancelled', cancelled_at = NOW()
		WHERE id = $1`, id,
	); err != nil {
		return fmt.Errorf("cancelling subscription: %w", err)
	}

	// For pending subs, also abandon any pending payments so the
	// customer can subscribe again without the "already subscribed"
	// block kicking in.
	if currentStatus == "pending" {
		if _, err := tx.Exec(ctx, `
			UPDATE payment_records
			SET status     = 'failed',
			    failed_at  = COALESCE(failed_at, NOW()),
			    updated_at = NOW()
			WHERE subscription_id = $1 AND status = 'pending'`, id,
		); err != nil {
			return fmt.Errorf("failing pending payments: %w", err)
		}
	}

	return tx.Commit(ctx)
}

// ── History ─────────────────────────────────────────────────────

func (r *ClientSubscriptionRepository) ListSubscriptionHistory(ctx context.Context, userID string, params model.PaginationParams) ([]ClientSubscription, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM subscriptions WHERE user_id = $1`, userID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, fmt.Sprintf(`
		SELECT %s
		FROM subscriptions s
		JOIN payment_plans pp ON pp.id = s.plan_id
		WHERE s.user_id = $1
		ORDER BY s.created_at DESC
		LIMIT $2 OFFSET $3`, clientSubColumns),
		userID, params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	subs := make([]ClientSubscription, 0)
	for rows.Next() {
		var s ClientSubscription
		if err := rows.Scan(&s.ID, &s.PlanID, &s.PlanName, &s.Tier, &s.BillingPeriod,
			&s.Status, &s.StartedAt, &s.ExpiresAt, &s.CancelledAt, &s.PaymentMethod, &s.CreatedAt); err != nil {
			return nil, 0, err
		}
		subs = append(subs, s)
	}
	return subs, total, rows.Err()
}

// ── Payment Records ─────────────────────────────────────────────

// CreatePaymentRecordInput is a struct because the parameter list grew
// after gateway support was added (payment_type, bank_account_id, etc.).
type CreatePaymentRecordInput struct {
	SubscriptionID string
	UserID         string
	Amount         float64
	Currency       string
	PaymentMethod  string
	PaymentType    string  // manual_transfer | midtrans_snap | …
	BankAccountID  *string // only for manual_transfer
}

func (r *ClientSubscriptionRepository) CreatePaymentRecord(ctx context.Context, in CreatePaymentRecordInput) (*ClientPaymentRecord, error) {
	pr := &ClientPaymentRecord{}
	err := r.db.QueryRow(ctx, fmt.Sprintf(`
		INSERT INTO payment_records (
			subscription_id, user_id, amount, currency, status,
			payment_method, payment_type, bank_account_id
		)
		VALUES ($1, $2, $3, $4, 'pending', $5, $6, $7)
		RETURNING %s`, clientPaymentColumns),
		in.SubscriptionID, in.UserID, in.Amount, in.Currency,
		in.PaymentMethod, in.PaymentType, in.BankAccountID,
	).Scan(&pr.ID, &pr.SubscriptionID, &pr.Amount, &pr.Currency, &pr.Status,
		&pr.PaymentMethod, &pr.PaymentType, &pr.BankAccountID,
		&pr.ProofImageURL, &pr.ProofUploadedAt,
		&pr.SnapToken, &pr.SnapRedirectURL, &pr.GatewayStatus, &pr.GatewayResponse,
		&pr.ExternalID, &pr.PaidAt, &pr.Metadata, &pr.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("creating payment record: %w", err)
	}
	return pr, nil
}

func (r *ClientSubscriptionRepository) GetPaymentByID(ctx context.Context, id, userID string) (*ClientPaymentRecord, error) {
	return scanClientPaymentRecord(r.db.QueryRow(ctx, fmt.Sprintf(`
		SELECT %s FROM payment_records
		WHERE id = $1 AND user_id = $2`, clientPaymentColumns), id, userID))
}

// GetPaymentByExternalID looks up a payment by Midtrans order_id.
// Used by the webhook handler to find the matching record.
func (r *ClientSubscriptionRepository) GetPaymentByExternalID(ctx context.Context, externalID string) (*ClientPaymentRecord, error) {
	return scanClientPaymentRecord(r.db.QueryRow(ctx, fmt.Sprintf(`
		SELECT %s FROM payment_records
		WHERE external_id = $1
		ORDER BY created_at DESC LIMIT 1`, clientPaymentColumns), externalID))
}

// GetLatestPendingPaymentBySubscription returns the most recent 'pending'
// payment_record for a subscription, or ErrNotFound if there is none. Used
// by Subscribe() to decide whether an in-progress Midtrans Snap checkout
// can be resumed instead of starting a brand-new transaction.
func (r *ClientSubscriptionRepository) GetLatestPendingPaymentBySubscription(ctx context.Context, subscriptionID string) (*ClientPaymentRecord, error) {
	return scanClientPaymentRecord(r.db.QueryRow(ctx, fmt.Sprintf(`
		SELECT %s FROM payment_records
		WHERE subscription_id = $1 AND status = 'pending'
		ORDER BY created_at DESC LIMIT 1`, clientPaymentColumns), subscriptionID))
}

// UpdateSnapDetails persists snap_token, snap_redirect_url and external_id
// after a successful Midtrans Snap transaction creation.
func (r *ClientSubscriptionRepository) UpdateSnapDetails(ctx context.Context, paymentID, snapToken, snapRedirectURL, orderID string) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE payment_records
		SET snap_token = $1, snap_redirect_url = $2, external_id = $3
		WHERE id = $4`,
		snapToken, snapRedirectURL, orderID, paymentID)
	if err != nil {
		return fmt.Errorf("updating snap details: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// UpdatePaymentProof attaches a transfer-receipt image to the payment.
// Status stays 'pending' — admin still needs to verify before flipping
// it to 'completed'.
func (r *ClientSubscriptionRepository) UpdatePaymentProof(ctx context.Context, paymentID, userID, imageURL string) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE payment_records
		SET proof_image_url = $1, proof_uploaded_at = NOW()
		WHERE id = $2 AND user_id = $3`,
		imageURL, paymentID, userID)
	if err != nil {
		return fmt.Errorf("updating payment proof: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ApplyMidtransNotification updates a payment record from a Midtrans
// webhook callback in a single transaction:
//
//   1. Find the matching payment by external_id
//   2. Update its status, gateway_status, gateway_response, paid_at
//   3. If the new internal status is 'completed', also flip the parent
//      subscription from 'pending' → 'active' (or extend if already active)
//
// Idempotent: a duplicate webhook with the same payload is safe — the
// update is a no-op semantically.
func (r *ClientSubscriptionRepository) ApplyMidtransNotification(
	ctx context.Context,
	externalID, internalStatus, gatewayStatus string,
	rawPayload []byte,
) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	// Find the payment + lock it; capture subscription_id so we can
	// activate the sub if status becomes 'completed'.
	var subscriptionID string
	err = tx.QueryRow(ctx, `
		SELECT subscription_id FROM payment_records
		WHERE external_id = $1 FOR UPDATE`, externalID,
	).Scan(&subscriptionID)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if err != nil {
		return fmt.Errorf("locking payment: %w", err)
	}

	// Update the payment row.
	if _, err := tx.Exec(ctx, `
		UPDATE payment_records
		SET status            = $1::payment_status,
		    gateway_status    = $2,
		    gateway_response  = $3,
		    paid_at           = CASE WHEN $1 = 'completed' AND paid_at IS NULL THEN NOW() ELSE paid_at END,
		    failed_at         = CASE WHEN $1 = 'failed'    AND failed_at IS NULL THEN NOW() ELSE failed_at END,
		    refunded_at       = CASE WHEN $1 = 'refunded'  AND refunded_at IS NULL THEN NOW() ELSE refunded_at END,
		    updated_at        = NOW()
		WHERE external_id = $4`,
		internalStatus, gatewayStatus, rawPayload, externalID,
	); err != nil {
		return fmt.Errorf("updating payment: %w", err)
	}

	// On completion, activate the subscription. Same SQL as the admin
	// flow in payment_repo.UpdatePaymentStatus — keeps both code paths
	// (admin verification vs Midtrans webhook) consistent.
	if internalStatus == "completed" {
		if _, err := tx.Exec(ctx, `
			UPDATE subscriptions s SET
				status       = 'active',
				cancelled_at = NULL,
				started_at   = CASE
					WHEN s.status = 'pending' THEN NOW()
					ELSE s.started_at
				END,
				expires_at   = CASE
					WHEN s.status = 'pending'
						THEN NOW() + make_interval(months => pp.duration_months)
					ELSE GREATEST(s.expires_at, NOW())
						+ make_interval(months => pp.duration_months)
				END,
				updated_at   = NOW()
			FROM payment_plans pp
			WHERE s.id = $1 AND pp.id = s.plan_id`, subscriptionID,
		); err != nil {
			return fmt.Errorf("activating subscription: %w", err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit tx: %w", err)
	}
	return nil
}

func (r *ClientSubscriptionRepository) ListMyPayments(ctx context.Context, userID string, params model.PaginationParams) ([]ClientPaymentRecord, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM payment_records WHERE user_id = $1`, userID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, fmt.Sprintf(`
		SELECT %s
		FROM payment_records
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`, clientPaymentColumns),
		userID, params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	records := make([]ClientPaymentRecord, 0)
	for rows.Next() {
		var pr ClientPaymentRecord
		if err := rows.Scan(&pr.ID, &pr.SubscriptionID, &pr.Amount, &pr.Currency, &pr.Status,
			&pr.PaymentMethod, &pr.PaymentType, &pr.BankAccountID,
			&pr.ProofImageURL, &pr.ProofUploadedAt,
			&pr.SnapToken, &pr.SnapRedirectURL, &pr.GatewayStatus, &pr.GatewayResponse,
			&pr.ExternalID, &pr.PaidAt, &pr.Metadata, &pr.CreatedAt); err != nil {
			return nil, 0, err
		}
		records = append(records, pr)
	}
	return records, total, rows.Err()
}

// ── Helpers ─────────────────────────────────────────────────────

// HasActiveSubscription returns true if the user has an 'active'
// subscription. Used by access-gate checks.
func (r *ClientSubscriptionRepository) HasActiveSubscription(ctx context.Context, userID string) (bool, error) {
	var count int
	err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM subscriptions WHERE user_id = $1 AND status = 'active'`,
		userID,
	).Scan(&count)
	return count > 0, err
}

// GetSubscriptionByIDInternal looks up a subscription by id WITHOUT the
// user_id ownership check. Used by service layer for cross-user lookups
// (e.g. during Midtrans webhook processing where the sub was created by
// the customer but the handler has no user context).
func (r *ClientSubscriptionRepository) GetSubscriptionByIDInternal(ctx context.Context, id string) (*ClientSubscription, error) {
	return scanClientSubscription(r.db.QueryRow(ctx, fmt.Sprintf(`
		SELECT %s
		FROM subscriptions s
		JOIN payment_plans pp ON pp.id = s.plan_id
		WHERE s.id = $1`, clientSubColumns), id))
}

// GetPaymentOwnerUserID returns the user_id for a given payment record.
// Used by notification dispatch so we can push to the right customer
// without having to JOIN users in every query.
func (r *ClientSubscriptionRepository) GetPaymentOwnerUserID(ctx context.Context, paymentID string) (string, error) {
	var userID string
	err := r.db.QueryRow(ctx,
		`SELECT user_id FROM payment_records WHERE id = $1`, paymentID,
	).Scan(&userID)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", ErrNotFound
	}
	return userID, err
}

// GetCurrentSubscription returns the latest active OR pending subscription
// for the user, preferring 'active' over 'pending'. Used by GetMySubscription
// so the mobile app can surface the in-progress state to the customer
// (e.g. "Pembayaran sedang diverifikasi").
func (r *ClientSubscriptionRepository) GetCurrentSubscription(ctx context.Context, userID string) (*ClientSubscription, error) {
	return scanClientSubscription(r.db.QueryRow(ctx, fmt.Sprintf(`
		SELECT %s
		FROM subscriptions s
		JOIN payment_plans pp ON pp.id = s.plan_id
		WHERE s.user_id = $1 AND s.status IN ('active', 'pending')
		ORDER BY
			CASE s.status WHEN 'active' THEN 0 WHEN 'pending' THEN 1 ELSE 2 END,
			s.created_at DESC
		LIMIT 1`, clientSubColumns), userID))
}
