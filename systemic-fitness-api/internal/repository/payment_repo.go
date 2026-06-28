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

type PaymentRepository struct {
	db *pgxpool.Pool
}

func NewPaymentRepository(db *pgxpool.Pool) *PaymentRepository {
	return &PaymentRepository{db: db}
}

// ── Structs ─────────────────────────────────────────────────────

type PaymentPlan struct {
	ID             string          `json:"id"`
	Name           string          `json:"name"`
	Description    *string         `json:"description,omitempty"`
	Price          float64         `json:"price"`
	Currency       string          `json:"currency"`
	DurationMonths int             `json:"duration_months"`
	Features       json.RawMessage `json:"features"`
	MaxClients     *int            `json:"max_clients,omitempty"`
	IsActive       bool            `json:"is_active"`
	Tier           *string         `json:"tier,omitempty"`
	BillingPeriod  *string         `json:"billing_period,omitempty"`
	CreatedAt      time.Time       `json:"created_at"`
	UpdatedAt      time.Time       `json:"updated_at"`
}

type Subscription struct {
	ID            string     `json:"id"`
	UserID        string     `json:"user_id"`
	UserName      *string    `json:"user_name,omitempty"`
	UserEmail     *string    `json:"user_email,omitempty"`
	PlanID        string     `json:"plan_id"`
	PlanName      *string    `json:"plan_name,omitempty"`
	Status        string     `json:"status"`
	StartedAt     time.Time  `json:"started_at"`
	ExpiresAt     time.Time  `json:"expires_at"`
	CancelledAt   *time.Time `json:"cancelled_at,omitempty"`
	PaymentMethod *string    `json:"payment_method,omitempty"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
}

type PaymentRecord struct {
	ID              string          `json:"id"`
	SubscriptionID  string          `json:"subscription_id"`
	UserID          string          `json:"user_id"`
	UserName        *string         `json:"user_name,omitempty"`
	UserEmail       *string         `json:"user_email,omitempty"`
	Amount          float64         `json:"amount"`
	Currency        string          `json:"currency"`
	Status          string          `json:"status"`
	PaymentMethod   *string         `json:"payment_method,omitempty"`
	PaymentType     *string         `json:"payment_type,omitempty"`
	BankAccountID   *string         `json:"bank_account_id,omitempty"`
	BankName        *string         `json:"bank_name,omitempty"`
	ProofImageURL   *string         `json:"proof_image_url,omitempty"`
	ProofUploadedAt *time.Time      `json:"proof_uploaded_at,omitempty"`
	SnapToken       *string         `json:"snap_token,omitempty"`
	SnapRedirectURL *string         `json:"snap_redirect_url,omitempty"`
	GatewayStatus   *string         `json:"gateway_status,omitempty"`
	ExternalID      *string         `json:"external_id,omitempty"`
	PaidAt          *time.Time      `json:"paid_at,omitempty"`
	Metadata        json.RawMessage `json:"metadata,omitempty"`
	CreatedAt       time.Time       `json:"created_at"`
	UpdatedAt       time.Time       `json:"updated_at"`
}

// ── Payment Plans ───────────────────────────────────────────────

func (r *PaymentRepository) CreatePlan(ctx context.Context, p *PaymentPlan) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO payment_plans (name, description, price, currency, duration_months, features, max_clients, is_active, tier, billing_period)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at, updated_at`,
		p.Name, p.Description, p.Price, p.Currency, p.DurationMonths,
		p.Features, p.MaxClients, p.IsActive, p.Tier, p.BillingPeriod,
	).Scan(&p.ID, &p.CreatedAt, &p.UpdatedAt)
}

func (r *PaymentRepository) UpdatePlan(ctx context.Context, p *PaymentPlan) error {
	err := r.db.QueryRow(ctx, `
		UPDATE payment_plans SET name=$2, description=$3, price=$4, currency=$5,
			duration_months=$6, features=$7, max_clients=$8, is_active=$9, tier=$10, billing_period=$11
		WHERE id=$1 RETURNING updated_at`,
		p.ID, p.Name, p.Description, p.Price, p.Currency,
		p.DurationMonths, p.Features, p.MaxClients, p.IsActive, p.Tier, p.BillingPeriod,
	).Scan(&p.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *PaymentRepository) GetPlanByID(ctx context.Context, id string) (*PaymentPlan, error) {
	p := &PaymentPlan{}
	err := r.db.QueryRow(ctx, `
		SELECT id, name, description, price, currency, duration_months,
		       features, max_clients, is_active, tier, billing_period, created_at, updated_at
		FROM payment_plans WHERE id = $1`, id,
	).Scan(&p.ID, &p.Name, &p.Description, &p.Price, &p.Currency,
		&p.DurationMonths, &p.Features, &p.MaxClients, &p.IsActive, &p.Tier, &p.BillingPeriod,
		&p.CreatedAt, &p.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return p, err
}

func (r *PaymentRepository) ListPlans(ctx context.Context, activeOnly bool) ([]PaymentPlan, error) {
	q := `SELECT id, name, description, price, currency, duration_months,
	      features, max_clients, is_active, tier, billing_period, created_at, updated_at FROM payment_plans`
	if activeOnly {
		q += ` WHERE is_active = TRUE`
	}
	q += ` ORDER BY price`

	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	plans := make([]PaymentPlan, 0)
	for rows.Next() {
		var p PaymentPlan
		if err := rows.Scan(&p.ID, &p.Name, &p.Description, &p.Price, &p.Currency,
			&p.DurationMonths, &p.Features, &p.MaxClients, &p.IsActive, &p.Tier, &p.BillingPeriod,
			&p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, err
		}
		plans = append(plans, p)
	}
	return plans, rows.Err()
}

// ── Subscriptions ───────────────────────────────────────────────

type SubscriptionListFilter struct {
	Status *string
	PlanID *string
	UserID *string
}

func (r *PaymentRepository) ListSubscriptions(ctx context.Context, params model.PaginationParams, f SubscriptionListFilter) ([]Subscription, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Status != nil {
		where += fmt.Sprintf(" AND s.status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	if f.PlanID != nil {
		where += fmt.Sprintf(" AND s.plan_id = $%d", idx)
		args = append(args, *f.PlanID)
		idx++
	}
	if f.UserID != nil {
		where += fmt.Sprintf(" AND s.user_id = $%d", idx)
		args = append(args, *f.UserID)
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM subscriptions s "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(`
		SELECT s.id, s.user_id, u.full_name, u.email, s.plan_id, pp.name,
		       s.status, s.started_at, s.expires_at, s.cancelled_at,
		       s.payment_method, s.created_at, s.updated_at
		FROM subscriptions s
		JOIN users u ON u.id = s.user_id
		JOIN payment_plans pp ON pp.id = s.plan_id
		%s ORDER BY s.created_at DESC LIMIT $%d OFFSET $%d`,
		where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	subs := make([]Subscription, 0)
	for rows.Next() {
		var s Subscription
		if err := rows.Scan(
			&s.ID, &s.UserID, &s.UserName, &s.UserEmail, &s.PlanID, &s.PlanName,
			&s.Status, &s.StartedAt, &s.ExpiresAt, &s.CancelledAt,
			&s.PaymentMethod, &s.CreatedAt, &s.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		subs = append(subs, s)
	}
	return subs, total, rows.Err()
}

// ── Payment Records ─────────────────────────────────────────────

type PaymentListFilter struct {
	Status   *string
	DateFrom *string
	DateTo   *string
	UserID   *string
}

func (r *PaymentRepository) ListPayments(ctx context.Context, params model.PaginationParams, f PaymentListFilter) ([]PaymentRecord, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Status != nil {
		where += fmt.Sprintf(" AND pr.status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	if f.DateFrom != nil {
		where += fmt.Sprintf(" AND pr.created_at >= $%d::DATE", idx)
		args = append(args, *f.DateFrom)
		idx++
	}
	if f.DateTo != nil {
		where += fmt.Sprintf(" AND pr.created_at < ($%d::DATE + INTERVAL '1 day')", idx)
		args = append(args, *f.DateTo)
		idx++
	}
	if f.UserID != nil {
		where += fmt.Sprintf(" AND pr.user_id = $%d", idx)
		args = append(args, *f.UserID)
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM payment_records pr "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(`
		SELECT pr.id, pr.subscription_id, pr.user_id, u.full_name, u.email,
		       pr.amount, pr.currency, pr.status, pr.payment_method,
		       pr.payment_type, pr.bank_account_id, ba.bank_name,
		       pr.proof_image_url, pr.proof_uploaded_at,
		       pr.snap_token, pr.snap_redirect_url, pr.gateway_status,
		       pr.external_id, pr.paid_at, pr.metadata, pr.created_at, pr.updated_at
		FROM payment_records pr
		JOIN users u ON u.id = pr.user_id
		LEFT JOIN bank_accounts ba ON ba.id = pr.bank_account_id
		%s ORDER BY pr.created_at DESC LIMIT $%d OFFSET $%d`,
		where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	records := make([]PaymentRecord, 0)
	for rows.Next() {
		var pr PaymentRecord
		if err := rows.Scan(
			&pr.ID, &pr.SubscriptionID, &pr.UserID, &pr.UserName, &pr.UserEmail,
			&pr.Amount, &pr.Currency, &pr.Status, &pr.PaymentMethod,
			&pr.PaymentType, &pr.BankAccountID, &pr.BankName,
			&pr.ProofImageURL, &pr.ProofUploadedAt,
			&pr.SnapToken, &pr.SnapRedirectURL, &pr.GatewayStatus,
			&pr.ExternalID, &pr.PaidAt, &pr.Metadata, &pr.CreatedAt, &pr.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		records = append(records, pr)
	}
	return records, total, rows.Err()
}

// ── Payment Status Logs ─────────────────────────────────────────

type PaymentStatusLog struct {
	ID             string          `json:"id"`
	PaymentID      string          `json:"payment_id"`
	UserID         string          `json:"user_id"`
	UserName       *string         `json:"user_name,omitempty"`
	OldStatus      *string         `json:"old_status,omitempty"`
	NewStatus      string          `json:"new_status"`
	ChangedBy      string          `json:"changed_by"`
	ChangedByName  *string         `json:"changed_by_name,omitempty"`
	Reason         *string         `json:"reason,omitempty"`
	SubscriptionID *string         `json:"subscription_id,omitempty"`
	Metadata       json.RawMessage `json:"metadata,omitempty"`
	CreatedAt      time.Time       `json:"created_at"`
}

func (r *PaymentRepository) GetPaymentByID(ctx context.Context, id string) (*PaymentRecord, error) {
	pr := &PaymentRecord{}
	err := r.db.QueryRow(ctx, `
		SELECT pr.id, pr.subscription_id, pr.user_id, u.full_name, u.email,
		       pr.amount, pr.currency, pr.status, pr.payment_method,
		       pr.payment_type, pr.bank_account_id, ba.bank_name,
		       pr.proof_image_url, pr.proof_uploaded_at,
		       pr.snap_token, pr.snap_redirect_url, pr.gateway_status,
		       pr.external_id, pr.paid_at, pr.metadata, pr.created_at, pr.updated_at
		FROM payment_records pr
		JOIN users u ON u.id = pr.user_id
		LEFT JOIN bank_accounts ba ON ba.id = pr.bank_account_id
		WHERE pr.id = $1`, id,
	).Scan(&pr.ID, &pr.SubscriptionID, &pr.UserID, &pr.UserName, &pr.UserEmail,
		&pr.Amount, &pr.Currency, &pr.Status, &pr.PaymentMethod,
		&pr.PaymentType, &pr.BankAccountID, &pr.BankName,
		&pr.ProofImageURL, &pr.ProofUploadedAt,
		&pr.SnapToken, &pr.SnapRedirectURL, &pr.GatewayStatus,
		&pr.ExternalID, &pr.PaidAt, &pr.Metadata, &pr.CreatedAt, &pr.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return pr, err
}

// UpdatePaymentStatus updates a payment record's status and writes an audit
// log row in a single transaction. When the new status is "completed", the
// related subscription is also activated and its expiration date is extended
// based on the plan's duration_months.
func (r *PaymentRepository) UpdatePaymentStatus(
	ctx context.Context,
	paymentID, newStatus, actorID string,
	reason *string,
) (*PaymentRecord, *PaymentStatusLog, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return nil, nil, err
	}
	defer tx.Rollback(ctx)

	// Lock the payment row and read current state.
	var (
		oldStatus      string
		subscriptionID string
	)
	err = tx.QueryRow(ctx, `
		SELECT status, subscription_id
		FROM payment_records
		WHERE id = $1
		FOR UPDATE`, paymentID,
	).Scan(&oldStatus, &subscriptionID)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil, ErrNotFound
	}
	if err != nil {
		return nil, nil, err
	}

	// Update the payment record. Set paid_at on completion, failed_at on
	// failure, refunded_at on refund — but only if not already set.
	if _, err := tx.Exec(ctx, `
		UPDATE payment_records SET
			status      = $2::payment_status,
			paid_at     = CASE WHEN $2 = 'completed' AND paid_at     IS NULL THEN NOW() ELSE paid_at     END,
			failed_at   = CASE WHEN $2 = 'failed'    AND failed_at   IS NULL THEN NOW() ELSE failed_at   END,
			refunded_at = CASE WHEN $2 = 'refunded'  AND refunded_at IS NULL THEN NOW() ELSE refunded_at END,
			updated_at  = NOW()
		WHERE id = $1`, paymentID, newStatus,
	); err != nil {
		return nil, nil, fmt.Errorf("update payment: %w", err)
	}

	// On completion, activate the subscription. Two cases:
	//
	//   1. status='pending' (strict gating, fresh subscribe):
	//      reset started_at = NOW(), expires_at = NOW() + duration.
	//      The pending sub was created with placeholder dates that
	//      should NOT be added to — otherwise the customer would get
	//      double the duration.
	//
	//   2. status='active' (renewal / extension flow):
	//      keep started_at, extend expires_at = GREATEST(expires_at, NOW()) + duration.
	if newStatus == "completed" {
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
			return nil, nil, fmt.Errorf("activate subscription: %w", err)
		}
	}

	// Insert audit log row.
	log := &PaymentStatusLog{}
	err = tx.QueryRow(ctx, `
		INSERT INTO payment_status_logs (
			payment_id, user_id, old_status, new_status, changed_by,
			changed_by_name, reason, subscription_id
		)
		SELECT pr.id, pr.user_id, $2::payment_status, $3::payment_status, $4, u.full_name, $5, pr.subscription_id
		FROM payment_records pr
		JOIN users u ON u.id = $4
		WHERE pr.id = $1
		RETURNING id, payment_id, user_id, old_status, new_status, changed_by,
		          changed_by_name, reason, subscription_id, metadata, created_at`,
		paymentID, oldStatus, newStatus, actorID, reason,
	).Scan(&log.ID, &log.PaymentID, &log.UserID, &log.OldStatus, &log.NewStatus,
		&log.ChangedBy, &log.ChangedByName, &log.Reason, &log.SubscriptionID,
		&log.Metadata, &log.CreatedAt)
	if err != nil {
		return nil, nil, fmt.Errorf("insert status log: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, nil, err
	}

	updated, err := r.GetPaymentByID(ctx, paymentID)
	if err != nil {
		return nil, nil, err
	}
	return updated, log, nil
}

func (r *PaymentRepository) ListPaymentLogs(ctx context.Context, paymentID string) ([]PaymentStatusLog, error) {
	rows, err := r.db.Query(ctx, `
		SELECT l.id, l.payment_id, l.user_id, u.full_name, l.old_status, l.new_status,
		       l.changed_by, l.changed_by_name, l.reason, l.subscription_id,
		       l.metadata, l.created_at
		FROM payment_status_logs l
		JOIN users u ON u.id = l.user_id
		WHERE l.payment_id = $1
		ORDER BY l.created_at DESC`, paymentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	logs := make([]PaymentStatusLog, 0)
	for rows.Next() {
		var l PaymentStatusLog
		if err := rows.Scan(&l.ID, &l.PaymentID, &l.UserID, &l.UserName,
			&l.OldStatus, &l.NewStatus, &l.ChangedBy, &l.ChangedByName,
			&l.Reason, &l.SubscriptionID, &l.Metadata, &l.CreatedAt); err != nil {
			return nil, err
		}
		logs = append(logs, l)
	}
	return logs, rows.Err()
}

// ── Dashboard / Reports ─────────────────────────────────────────

func (r *PaymentRepository) GetDashboardRevenue(ctx context.Context) (float64, int, error) {
	var revenue float64
	var count int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(SUM(amount), 0), COUNT(*)
		FROM payment_records
		WHERE status = 'completed' AND paid_at >= NOW() - INTERVAL '30 days'`).Scan(&revenue, &count)
	return revenue, count, err
}

type MonthlyRevenue struct {
	Month   string  `json:"month"` // YYYY-MM
	Revenue float64 `json:"revenue"`
	Count   int     `json:"count"`
}

func (r *PaymentRepository) GetMonthlyRevenue(ctx context.Context, months int) ([]MonthlyRevenue, error) {
	rows, err := r.db.Query(ctx, `
		SELECT TO_CHAR(paid_at, 'YYYY-MM') AS month,
		       COALESCE(SUM(amount), 0) AS revenue,
		       COUNT(*) AS count
		FROM payment_records
		WHERE status = 'completed'
		  AND paid_at >= NOW() - make_interval(months => $1)
		GROUP BY month
		ORDER BY month`, months)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	data := make([]MonthlyRevenue, 0)
	for rows.Next() {
		var m MonthlyRevenue
		if err := rows.Scan(&m.Month, &m.Revenue, &m.Count); err != nil {
			return nil, err
		}
		data = append(data, m)
	}
	return data, rows.Err()
}

type RevenueByPlan struct {
	PlanName string  `json:"plan_name"`
	Revenue  float64 `json:"revenue"`
	Count    int     `json:"count"`
}

type RevenueByMethod struct {
	Method  string  `json:"method"`
	Revenue float64 `json:"revenue"`
	Count   int     `json:"count"`
}

type FinancialReport struct {
	PeriodStart         string            `json:"period_start"`
	PeriodEnd           string            `json:"period_end"`
	TotalRevenue        float64           `json:"total_revenue"`
	TotalTransactions   int               `json:"total_transactions"`
	SuccessfulPayments  int               `json:"successful_payments"`
	FailedPayments      int               `json:"failed_payments"`
	RefundedPayments    int               `json:"refunded_payments"`
	RefundAmount        float64           `json:"refund_amount"`
	NetRevenue          float64           `json:"net_revenue"`
	ActiveSubscriptions int               `json:"active_subscriptions"`
	RevenueByPlan       []RevenueByPlan   `json:"revenue_by_plan"`
	RevenueByMethod     []RevenueByMethod `json:"revenue_by_method"`
}

func (r *PaymentRepository) GetFinancialReport(ctx context.Context, periodStart, periodEnd string) (*FinancialReport, error) {
	rpt := &FinancialReport{PeriodStart: periodStart, PeriodEnd: periodEnd}

	// Aggregates
	err := r.db.QueryRow(ctx, `
		SELECT
			COALESCE(SUM(CASE WHEN status='completed' THEN amount END), 0),
			COUNT(*),
			COUNT(*) FILTER (WHERE status='completed'),
			COUNT(*) FILTER (WHERE status='failed'),
			COUNT(*) FILTER (WHERE status='refunded'),
			COALESCE(SUM(CASE WHEN status='refunded' THEN amount END), 0)
		FROM payment_records
		WHERE created_at >= $1::DATE AND created_at < ($2::DATE + INTERVAL '1 day')`,
		periodStart, periodEnd,
	).Scan(&rpt.TotalRevenue, &rpt.TotalTransactions, &rpt.SuccessfulPayments,
		&rpt.FailedPayments, &rpt.RefundedPayments, &rpt.RefundAmount)
	if err != nil {
		return nil, err
	}
	rpt.NetRevenue = rpt.TotalRevenue - rpt.RefundAmount

	// Active subscriptions
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM subscriptions WHERE status = 'active'`,
	).Scan(&rpt.ActiveSubscriptions); err != nil {
		return nil, err
	}

	// Revenue by plan
	planRows, err := r.db.Query(ctx, `
		SELECT pp.name, COALESCE(SUM(pr.amount), 0), COUNT(*)
		FROM payment_records pr
		JOIN subscriptions s ON s.id = pr.subscription_id
		JOIN payment_plans pp ON pp.id = s.plan_id
		WHERE pr.status = 'completed'
		  AND pr.created_at >= $1::DATE AND pr.created_at < ($2::DATE + INTERVAL '1 day')
		GROUP BY pp.name ORDER BY SUM(pr.amount) DESC`,
		periodStart, periodEnd)
	if err != nil {
		return nil, err
	}
	defer planRows.Close()
	for planRows.Next() {
		var bp RevenueByPlan
		if err := planRows.Scan(&bp.PlanName, &bp.Revenue, &bp.Count); err != nil {
			return nil, err
		}
		rpt.RevenueByPlan = append(rpt.RevenueByPlan, bp)
	}

	// Revenue by payment method
	methodRows, err := r.db.Query(ctx, `
		SELECT COALESCE(payment_method, 'unknown'), COALESCE(SUM(amount), 0), COUNT(*)
		FROM payment_records
		WHERE status = 'completed'
		  AND created_at >= $1::DATE AND created_at < ($2::DATE + INTERVAL '1 day')
		GROUP BY payment_method ORDER BY SUM(amount) DESC`,
		periodStart, periodEnd)
	if err != nil {
		return nil, err
	}
	defer methodRows.Close()
	for methodRows.Next() {
		var bm RevenueByMethod
		if err := methodRows.Scan(&bm.Method, &bm.Revenue, &bm.Count); err != nil {
			return nil, err
		}
		rpt.RevenueByMethod = append(rpt.RevenueByMethod, bm)
	}

	return rpt, nil
}

// CreateManualSubscription creates an active subscription and a completed payment record for the specified user and plan.
func (r *PaymentRepository) CreateManualSubscription(
	ctx context.Context,
	userID, planID string,
) (*Subscription, *PaymentRecord, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return nil, nil, err
	}
	defer tx.Rollback(ctx)

	// 1. Fetch user role to verify user exists
	var userRole string
	err = tx.QueryRow(ctx, `SELECT role FROM users WHERE id = $1`, userID).Scan(&userRole)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil, fmt.Errorf("user not found")
		}
		return nil, nil, err
	}

	// 2. Fetch the plan details
	plan := &PaymentPlan{}
	err = tx.QueryRow(ctx, `
		SELECT id, name, price, currency, duration_months
		FROM payment_plans WHERE id = $1 AND is_active = TRUE`, planID,
	).Scan(&plan.ID, &plan.Name, &plan.Price, &plan.Currency, &plan.DurationMonths)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil, fmt.Errorf("active payment plan not found")
		}
		return nil, nil, err
	}

	// 3. Create active subscription
	now := time.Now()
	expiresAt := now.AddDate(0, plan.DurationMonths, 0)
	
	var subID string
	err = tx.QueryRow(ctx, `
		INSERT INTO subscriptions (user_id, plan_id, status, started_at, expires_at, payment_method, created_at, updated_at)
		VALUES ($1, $2, 'active', $3, $4, 'manual_admin', $3, $3)
		RETURNING id`,
		userID, plan.ID, now, expiresAt,
	).Scan(&subID)
	if err != nil {
		return nil, nil, fmt.Errorf("creating subscription: %w", err)
	}

	// 4. Create completed payment record
	var paymentID string
	err = tx.QueryRow(ctx, `
		INSERT INTO payment_records (
			subscription_id, user_id, amount, currency, status,
			payment_method, payment_type, paid_at, external_id, metadata, created_at, updated_at
		)
		VALUES ($1, $2, $3, $4, 'completed', 'manual_admin', 'manual_admin', $5, $6, $7, $5, $5)
		RETURNING id`,
		subID, userID, plan.Price, plan.Currency, now, "manual-"+subID[:8], `{"reason": "Manually assigned by owner/admin"}`,
	).Scan(&paymentID)
	if err != nil {
		return nil, nil, fmt.Errorf("creating payment record: %w", err)
	}

	// 5. Insert audit log row
	_, err = tx.Exec(ctx, `
		INSERT INTO payment_status_logs (
			payment_id, user_id, old_status, new_status, changed_by,
			changed_by_name, reason, subscription_id, created_at
		)
		VALUES ($1, $2, 'pending', 'completed', $2, 'Admin', 'Manually assigned by owner/admin', $3, $4)`,
		paymentID, userID, subID, now,
	)
	if err != nil {
		return nil, nil, fmt.Errorf("creating payment status log: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, nil, err
	}

	// Fetch subscription details to return
	sub := &Subscription{}
	err = r.db.QueryRow(ctx, `
		SELECT s.id, s.user_id, u.full_name, u.email, s.plan_id, pp.name,
		       s.status, s.started_at, s.expires_at, s.cancelled_at,
		       s.payment_method, s.created_at, s.updated_at
		FROM subscriptions s
		JOIN users u ON u.id = s.user_id
		JOIN payment_plans pp ON pp.id = s.plan_id
		WHERE s.id = $1`, subID,
	).Scan(
		&sub.ID, &sub.UserID, &sub.UserName, &sub.UserEmail, &sub.PlanID, &sub.PlanName,
		&sub.Status, &sub.StartedAt, &sub.ExpiresAt, &sub.CancelledAt,
		&sub.PaymentMethod, &sub.CreatedAt, &sub.UpdatedAt,
	)
	if err != nil {
		return nil, nil, err
	}

	payRec, err := r.GetPaymentByID(ctx, paymentID)
	if err != nil {
		return nil, nil, err
	}

	return sub, payRec, nil
}

