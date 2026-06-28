package repository

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// LabConsultation domain — Phase 6.
type LabConsultation struct {
	ID             string          `json:"id"`
	UserID         string          `json:"user_id"`
	ConsultantID   *string         `json:"consultant_id,omitempty"`
	AssessmentID   *string         `json:"assessment_id,omitempty"`
	PaymentID      *string         `json:"payment_id,omitempty"`
	Status         string          `json:"status"`
	FeeAmount      float64         `json:"fee_amount"`
	BookingNote    *string         `json:"booking_note,omitempty"`
	PreferredAt    *time.Time      `json:"preferred_at,omitempty"`
	ScheduledAt    *time.Time      `json:"scheduled_at,omitempty"`
	CompletedAt    *time.Time      `json:"completed_at,omitempty"`
	ResultSummary  *string         `json:"result_summary,omitempty"`
	ResultPayload  json.RawMessage `json:"result_payload"`
	CreatedAt      time.Time       `json:"created_at"`
	UpdatedAt      time.Time       `json:"updated_at"`
	UserName       *string         `json:"user_name,omitempty"`
	UserEmail      *string         `json:"user_email,omitempty"`
	ConsultantName *string         `json:"consultant_name,omitempty"`
}

type LabConsultationRepository struct {
	db *pgxpool.Pool
}

func NewLabConsultationRepository(db *pgxpool.Pool) *LabConsultationRepository {
	return &LabConsultationRepository{db: db}
}

const labCols = `lc.id, lc.user_id, lc.consultant_id, lc.assessment_id, lc.payment_id,
	lc.status, lc.fee_amount, lc.booking_note, lc.preferred_at, lc.scheduled_at,
	lc.completed_at, lc.result_summary, lc.result_payload,
	lc.created_at, lc.updated_at,
	u.full_name AS user_name, u.email AS user_email,
	c.full_name AS consultant_name`

func scanLab(row pgx.Row) (*LabConsultation, error) {
	l := &LabConsultation{}
	err := row.Scan(
		&l.ID, &l.UserID, &l.ConsultantID, &l.AssessmentID, &l.PaymentID,
		&l.Status, &l.FeeAmount, &l.BookingNote, &l.PreferredAt, &l.ScheduledAt,
		&l.CompletedAt, &l.ResultSummary, &l.ResultPayload,
		&l.CreatedAt, &l.UpdatedAt,
		&l.UserName, &l.UserEmail, &l.ConsultantName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return l, err
}

func (r *LabConsultationRepository) Create(ctx context.Context, l *LabConsultation) error {
	if len(l.ResultPayload) == 0 {
		l.ResultPayload = json.RawMessage(`{}`)
	}
	if l.Status == "" {
		l.Status = "pending"
	}
	if l.FeeAmount == 0 {
		l.FeeAmount = 350000
	}
	const q = `
		INSERT INTO lab_consultations
			(user_id, consultant_id, assessment_id, payment_id,
			 status, fee_amount, booking_note, preferred_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, q,
		l.UserID, l.ConsultantID, l.AssessmentID, l.PaymentID,
		l.Status, l.FeeAmount, l.BookingNote, l.PreferredAt,
	).Scan(&l.ID, &l.CreatedAt, &l.UpdatedAt)
}

func (r *LabConsultationRepository) GetByID(ctx context.Context, id string) (*LabConsultation, error) {
	q := `SELECT ` + labCols + `
		FROM lab_consultations lc
		LEFT JOIN users u ON u.id = lc.user_id
		LEFT JOIN users c ON c.id = lc.consultant_id
		WHERE lc.id = $1`
	return scanLab(r.db.QueryRow(ctx, q, id))
}

type LabConsultationFilter struct {
	UserID *string
	Status *string
}

func (r *LabConsultationRepository) List(ctx context.Context, f LabConsultationFilter) ([]LabConsultation, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1
	if f.UserID != nil {
		where += fmt.Sprintf(" AND lc.user_id = $%d", idx)
		args = append(args, *f.UserID)
		idx++
	}
	if f.Status != nil {
		where += fmt.Sprintf(" AND lc.status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	q := fmt.Sprintf(`SELECT %s
		FROM lab_consultations lc
		LEFT JOIN users u ON u.id = lc.user_id
		LEFT JOIN users c ON c.id = lc.consultant_id
		%s
		ORDER BY lc.created_at DESC
		LIMIT 200`, labCols, where)
	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]LabConsultation, 0)
	for rows.Next() {
		var l LabConsultation
		if err := rows.Scan(
			&l.ID, &l.UserID, &l.ConsultantID, &l.AssessmentID, &l.PaymentID,
			&l.Status, &l.FeeAmount, &l.BookingNote, &l.PreferredAt, &l.ScheduledAt,
			&l.CompletedAt, &l.ResultSummary, &l.ResultPayload,
			&l.CreatedAt, &l.UpdatedAt,
			&l.UserName, &l.UserEmail, &l.ConsultantName,
		); err != nil {
			return nil, err
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

// AssignConsultant assigns a consultant to a lab consultation without
// touching other fields. Idempotent — re-assigning ke consultant yang
// sama tidak error. Status di-bump ke 'scheduled' kalau sebelumnya
// 'pending', supaya alur antrian admin tetap konsisten.
func (r *LabConsultationRepository) AssignConsultant(
	ctx context.Context, id, consultantID string,
) error {
	const q = `
		UPDATE lab_consultations SET
			consultant_id = $2,
			status = CASE WHEN status = 'pending' THEN 'scheduled' ELSE status END
		WHERE id = $1
		RETURNING id`
	var out string
	err := r.db.QueryRow(ctx, q, id, consultantID).Scan(&out)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

// Update modifies all editable fields (assignment, schedule, completion).
func (r *LabConsultationRepository) Update(ctx context.Context, l *LabConsultation) error {
	if len(l.ResultPayload) == 0 {
		l.ResultPayload = json.RawMessage(`{}`)
	}
	const q = `
		UPDATE lab_consultations SET
			consultant_id = $2, status = $3,
			scheduled_at = $4, completed_at = $5,
			result_summary = $6, result_payload = $7
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, q,
		l.ID, l.ConsultantID, l.Status,
		l.ScheduledAt, l.CompletedAt, l.ResultSummary, l.ResultPayload,
	).Scan(&l.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}
