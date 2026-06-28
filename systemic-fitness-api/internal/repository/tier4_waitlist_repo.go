package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Tier4WaitlistEntry — Phase 6.
// Dipakai untuk:
//   1. Tier 4 (System Elite, Trainer on-site) yang belum dibuka.
//   2. Level 0–3 mobility waitlist (program belum tersedia).
type Tier4WaitlistEntry struct {
	ID            string     `json:"id"`
	UserID        *string    `json:"user_id,omitempty"`
	FullName      string     `json:"full_name"`
	Email         string     `json:"email"`
	Phone         *string    `json:"phone,omitempty"`
	City          *string    `json:"city,omitempty"`
	Source        string     `json:"source"`
	AssessmentID  *string    `json:"assessment_id,omitempty"`
	Note          *string    `json:"note,omitempty"`
	Status        string     `json:"status"`
	AdminNote     *string    `json:"admin_note,omitempty"`
	ContactedAt   *time.Time `json:"contacted_at,omitempty"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
}

type Tier4WaitlistRepository struct {
	db *pgxpool.Pool
}

func NewTier4WaitlistRepository(db *pgxpool.Pool) *Tier4WaitlistRepository {
	return &Tier4WaitlistRepository{db: db}
}

const tier4Cols = `id, user_id, full_name, email, phone, city, source,
	assessment_id, note, status, admin_note, contacted_at,
	created_at, updated_at`

func scanTier4(row pgx.Row) (*Tier4WaitlistEntry, error) {
	e := &Tier4WaitlistEntry{}
	err := row.Scan(
		&e.ID, &e.UserID, &e.FullName, &e.Email, &e.Phone, &e.City, &e.Source,
		&e.AssessmentID, &e.Note, &e.Status, &e.AdminNote, &e.ContactedAt,
		&e.CreatedAt, &e.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return e, err
}

func (r *Tier4WaitlistRepository) Create(ctx context.Context, e *Tier4WaitlistEntry) error {
	if e.Source == "" {
		e.Source = "tier4"
	}
	if e.Status == "" {
		e.Status = "new"
	}
	const q = `
		INSERT INTO tier4_waitlist_entries
			(user_id, full_name, email, phone, city, source, assessment_id, note, status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, q,
		e.UserID, e.FullName, e.Email, e.Phone, e.City,
		e.Source, e.AssessmentID, e.Note, e.Status,
	).Scan(&e.ID, &e.CreatedAt, &e.UpdatedAt)
}

func (r *Tier4WaitlistRepository) GetByID(ctx context.Context, id string) (*Tier4WaitlistEntry, error) {
	q := `SELECT ` + tier4Cols + ` FROM tier4_waitlist_entries WHERE id = $1`
	return scanTier4(r.db.QueryRow(ctx, q, id))
}

type Tier4WaitlistFilter struct {
	Status *string
	Source *string
}

func (r *Tier4WaitlistRepository) List(ctx context.Context, f Tier4WaitlistFilter) ([]Tier4WaitlistEntry, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1
	if f.Status != nil {
		where += fmt.Sprintf(" AND status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	if f.Source != nil {
		where += fmt.Sprintf(" AND source = $%d", idx)
		args = append(args, *f.Source)
		idx++
	}
	q := fmt.Sprintf("SELECT %s FROM tier4_waitlist_entries %s ORDER BY created_at DESC LIMIT 500",
		tier4Cols, where)
	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]Tier4WaitlistEntry, 0)
	for rows.Next() {
		var e Tier4WaitlistEntry
		if err := rows.Scan(
			&e.ID, &e.UserID, &e.FullName, &e.Email, &e.Phone, &e.City, &e.Source,
			&e.AssessmentID, &e.Note, &e.Status, &e.AdminNote, &e.ContactedAt,
			&e.CreatedAt, &e.UpdatedAt,
		); err != nil {
			return nil, err
		}
		out = append(out, e)
	}
	return out, rows.Err()
}

// UpdateStatus dipakai admin untuk mark contacted/converted/closed + admin_note.
func (r *Tier4WaitlistRepository) UpdateStatus(
	ctx context.Context, id, status string, adminNote *string,
) error {
	const q = `
		UPDATE tier4_waitlist_entries SET
			status = $2,
			admin_note = COALESCE($3, admin_note),
			contacted_at = CASE WHEN $2 = 'contacted' THEN NOW() ELSE contacted_at END
		WHERE id = $1
		RETURNING id`
	var out string
	err := r.db.QueryRow(ctx, q, id, status, adminNote).Scan(&out)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}
