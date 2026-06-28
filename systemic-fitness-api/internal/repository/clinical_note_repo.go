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

// ClinicalNote — SF Phase 7b.
// Catatan klinis dari Health Consultant. Bisa attached ke 1 asesmen v2
// (assessment_id) atau stand-alone untuk klien tertentu (assessment_id NULL).
type ClinicalNote struct {
	ID                string          `json:"id"`
	AssessmentID      *string         `json:"assessment_id,omitempty"`
	ClientID          string          `json:"client_id"`
	ConsultantID      string          `json:"consultant_id"`
	Title             string          `json:"title"`
	Content           string          `json:"content"`
	Attachments       json.RawMessage `json:"attachments"`
	IsVisibleToClient bool            `json:"is_visible_to_client"`
	CreatedAt         time.Time       `json:"created_at"`
	UpdatedAt         time.Time       `json:"updated_at"`

	// Joined display fields (read-only)
	ClientName     *string `json:"client_name,omitempty"`
	ClientEmail    *string `json:"client_email,omitempty"`
	ConsultantName *string `json:"consultant_name,omitempty"`
}

type ClinicalNoteRepository struct {
	db *pgxpool.Pool
}

func NewClinicalNoteRepository(db *pgxpool.Pool) *ClinicalNoteRepository {
	return &ClinicalNoteRepository{db: db}
}

const clinicalNoteCols = `cn.id, cn.assessment_id, cn.client_id, cn.consultant_id,
	cn.title, cn.content, cn.attachments, cn.is_visible_to_client,
	cn.created_at, cn.updated_at,
	uc.full_name AS client_name, uc.email AS client_email,
	uw.full_name AS consultant_name`

func scanClinicalNote(row pgx.Row) (*ClinicalNote, error) {
	n := &ClinicalNote{}
	err := row.Scan(
		&n.ID, &n.AssessmentID, &n.ClientID, &n.ConsultantID,
		&n.Title, &n.Content, &n.Attachments, &n.IsVisibleToClient,
		&n.CreatedAt, &n.UpdatedAt,
		&n.ClientName, &n.ClientEmail, &n.ConsultantName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return n, err
}

func (r *ClinicalNoteRepository) Create(ctx context.Context, n *ClinicalNote) error {
	if len(n.Attachments) == 0 {
		n.Attachments = json.RawMessage(`[]`)
	}
	const q = `
		INSERT INTO clinical_notes
			(assessment_id, client_id, consultant_id, title, content, attachments, is_visible_to_client)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, q,
		n.AssessmentID, n.ClientID, n.ConsultantID,
		n.Title, n.Content, n.Attachments, n.IsVisibleToClient,
	).Scan(&n.ID, &n.CreatedAt, &n.UpdatedAt)
}

func (r *ClinicalNoteRepository) GetByID(ctx context.Context, id string) (*ClinicalNote, error) {
	q := `SELECT ` + clinicalNoteCols + `
		FROM clinical_notes cn
		LEFT JOIN users uc ON uc.id = cn.client_id
		LEFT JOIN users uw ON uw.id = cn.consultant_id
		WHERE cn.id = $1 AND cn.deleted_at IS NULL`
	return scanClinicalNote(r.db.QueryRow(ctx, q, id))
}

type ClinicalNoteFilter struct {
	ConsultantID  *string
	ClientID      *string
	AssessmentID  *string
	OnlyPublished *bool // if true → is_visible_to_client = TRUE
}

func (r *ClinicalNoteRepository) List(ctx context.Context, f ClinicalNoteFilter) ([]ClinicalNote, error) {
	where := "WHERE cn.deleted_at IS NULL"
	args := []any{}
	idx := 1
	if f.ConsultantID != nil {
		where += fmt.Sprintf(" AND cn.consultant_id = $%d", idx)
		args = append(args, *f.ConsultantID)
		idx++
	}
	if f.ClientID != nil {
		where += fmt.Sprintf(" AND cn.client_id = $%d", idx)
		args = append(args, *f.ClientID)
		idx++
	}
	if f.AssessmentID != nil {
		where += fmt.Sprintf(" AND cn.assessment_id = $%d", idx)
		args = append(args, *f.AssessmentID)
		idx++
	}
	if f.OnlyPublished != nil && *f.OnlyPublished {
		where += " AND cn.is_visible_to_client = TRUE"
	}
	q := fmt.Sprintf(`SELECT %s
		FROM clinical_notes cn
		LEFT JOIN users uc ON uc.id = cn.client_id
		LEFT JOIN users uw ON uw.id = cn.consultant_id
		%s
		ORDER BY cn.created_at DESC
		LIMIT 200`, clinicalNoteCols, where)
	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]ClinicalNote, 0)
	for rows.Next() {
		var n ClinicalNote
		if err := rows.Scan(
			&n.ID, &n.AssessmentID, &n.ClientID, &n.ConsultantID,
			&n.Title, &n.Content, &n.Attachments, &n.IsVisibleToClient,
			&n.CreatedAt, &n.UpdatedAt,
			&n.ClientName, &n.ClientEmail, &n.ConsultantName,
		); err != nil {
			return nil, err
		}
		out = append(out, n)
	}
	return out, rows.Err()
}

// Update replaces editable fields (title, content, attachments, is_visible_to_client).
// Author identity & FKs are immutable.
func (r *ClinicalNoteRepository) Update(ctx context.Context, n *ClinicalNote) error {
	if len(n.Attachments) == 0 {
		n.Attachments = json.RawMessage(`[]`)
	}
	const q = `
		UPDATE clinical_notes SET
			title = $2,
			content = $3,
			attachments = $4,
			is_visible_to_client = $5
		WHERE id = $1 AND deleted_at IS NULL
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, q,
		n.ID, n.Title, n.Content, n.Attachments, n.IsVisibleToClient,
	).Scan(&n.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

// SoftDelete sets deleted_at (does not actually remove the row).
func (r *ClinicalNoteRepository) SoftDelete(ctx context.Context, id string) error {
	const q = `
		UPDATE clinical_notes SET deleted_at = NOW()
		WHERE id = $1 AND deleted_at IS NULL
		RETURNING id`
	var out string
	err := r.db.QueryRow(ctx, q, id).Scan(&out)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

// ─── Aggregations for Consultant Dashboard ─────────────────────────

// ConsultantClient — distinct client referenced by either a clinical_note
// authored by `consultantID`, or a lab_consultation assigned to that
// consultant. Used by GET /api/v2/consultant/clients.
type ConsultantClient struct {
	ClientID         string     `json:"client_id"`
	ClientName       *string    `json:"client_name,omitempty"`
	ClientEmail      *string    `json:"client_email,omitempty"`
	NoteCount        int        `json:"note_count"`
	LabCount         int        `json:"lab_count"`
	LastInteraction  *time.Time `json:"last_interaction,omitempty"`
}

// ListClientsForConsultant returns distinct clients touched by this
// consultant via clinical_notes OR lab_consultations.
func (r *ClinicalNoteRepository) ListClientsForConsultant(
	ctx context.Context, consultantID string,
) ([]ConsultantClient, error) {
	const q = `
		WITH note_clients AS (
			SELECT client_id,
			       COUNT(*) AS note_count,
			       MAX(created_at) AS last_at
			FROM clinical_notes
			WHERE consultant_id = $1 AND deleted_at IS NULL
			GROUP BY client_id
		),
		lab_clients AS (
			SELECT user_id AS client_id,
			       COUNT(*) AS lab_count,
			       MAX(created_at) AS last_at
			FROM lab_consultations
			WHERE consultant_id = $1
			GROUP BY user_id
		),
		merged AS (
			SELECT
				COALESCE(n.client_id, l.client_id) AS client_id,
				COALESCE(n.note_count, 0)          AS note_count,
				COALESCE(l.lab_count, 0)           AS lab_count,
				GREATEST(
					COALESCE(n.last_at, 'epoch'::timestamptz),
					COALESCE(l.last_at, 'epoch'::timestamptz)
				) AS last_interaction
			FROM note_clients n
			FULL OUTER JOIN lab_clients l ON l.client_id = n.client_id
		)
		SELECT m.client_id, u.full_name, u.email,
		       m.note_count, m.lab_count, m.last_interaction
		FROM merged m
		LEFT JOIN users u ON u.id = m.client_id
		ORDER BY m.last_interaction DESC
		LIMIT 500`
	rows, err := r.db.Query(ctx, q, consultantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]ConsultantClient, 0)
	for rows.Next() {
		var c ConsultantClient
		if err := rows.Scan(
			&c.ClientID, &c.ClientName, &c.ClientEmail,
			&c.NoteCount, &c.LabCount, &c.LastInteraction,
		); err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}
