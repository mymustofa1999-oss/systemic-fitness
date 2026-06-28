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

type FormRepository struct {
	db *pgxpool.Pool
}

func NewFormRepository(db *pgxpool.Pool) *FormRepository {
	return &FormRepository{db: db}
}

// ─── Forms ─────────────────────────────────────────────────────────

type Form struct {
	ID          string      `json:"id"`
	Name        string      `json:"name"`
	Description *string     `json:"description,omitempty"`
	Status      string      `json:"status"`
	IsSystem    bool        `json:"is_system"`
	CreatedBy   *string     `json:"created_by,omitempty"`
	CreatedAt   time.Time   `json:"created_at"`
	UpdatedAt   time.Time   `json:"updated_at"`
	Fields      []FormField `json:"fields,omitempty"`
}

type FormField struct {
	ID        string           `json:"id"`
	FormID    string           `json:"form_id"`
	Label     string           `json:"label"`
	FieldType string           `json:"field_type"`
	Required  bool             `json:"required"`
	Options   *json.RawMessage `json:"options,omitempty"`
	SortOrder int              `json:"sort_order"`
}

type FormResponse struct {
	ID          string           `json:"id"`
	FormID      string           `json:"form_id"`
	UserID      string           `json:"user_id"`
	Answers     *json.RawMessage `json:"answers"`
	SubmittedAt time.Time        `json:"submitted_at"`
}

const formCols = `id, name, description, status, is_system, created_by, created_at, updated_at`

func scanForm(row pgx.Row) (*Form, error) {
	f := &Form{}
	err := row.Scan(&f.ID, &f.Name, &f.Description, &f.Status, &f.IsSystem,
		&f.CreatedBy, &f.CreatedAt, &f.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return f, err
}

func (r *FormRepository) Create(ctx context.Context, f *Form) error {
	query := `
		INSERT INTO forms (name, description, status, is_system, created_by)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		f.Name, f.Description, f.Status, f.IsSystem, f.CreatedBy,
	).Scan(&f.ID, &f.CreatedAt, &f.UpdatedAt)
}

func (r *FormRepository) GetByID(ctx context.Context, id string) (*Form, error) {
	form, err := scanForm(r.db.QueryRow(ctx, `SELECT `+formCols+` FROM forms WHERE id = $1`, id))
	if err != nil {
		return nil, err
	}

	// Load fields
	rows, err := r.db.Query(ctx, `
		SELECT id, form_id, label, field_type, required, options, sort_order
		FROM form_fields WHERE form_id = $1 ORDER BY sort_order`, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var ff FormField
		if err := rows.Scan(&ff.ID, &ff.FormID, &ff.Label, &ff.FieldType, &ff.Required,
			&ff.Options, &ff.SortOrder); err != nil {
			return nil, err
		}
		form.Fields = append(form.Fields, ff)
	}
	return form, rows.Err()
}

func (r *FormRepository) Update(ctx context.Context, f *Form) error {
	query := `
		UPDATE forms SET name = $2, description = $3, status = $4
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query, f.ID, f.Name, f.Description, f.Status).Scan(&f.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *FormRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM forms WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type FormListFilter struct {
	Status *string
	Search string
}

func (r *FormRepository) List(ctx context.Context, params model.PaginationParams, f FormListFilter) ([]Form, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Status != nil {
		where += fmt.Sprintf(" AND status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND name ILIKE $%d", idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM forms "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM forms %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		formCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	forms := make([]Form, 0)
	for rows.Next() {
		var fm Form
		if err := rows.Scan(&fm.ID, &fm.Name, &fm.Description, &fm.Status, &fm.IsSystem,
			&fm.CreatedBy, &fm.CreatedAt, &fm.UpdatedAt); err != nil {
			return nil, 0, err
		}
		forms = append(forms, fm)
	}
	return forms, total, rows.Err()
}

// ─── Form Fields ───────────────────────────────────────────────────

func (r *FormRepository) CreateField(ctx context.Context, ff *FormField) error {
	query := `
		INSERT INTO form_fields (form_id, label, field_type, required, options, sort_order)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id`
	return r.db.QueryRow(ctx, query,
		ff.FormID, ff.Label, ff.FieldType, ff.Required, ff.Options, ff.SortOrder,
	).Scan(&ff.ID)
}

func (r *FormRepository) DeleteFieldsByForm(ctx context.Context, formID string) error {
	_, err := r.db.Exec(ctx, `DELETE FROM form_fields WHERE form_id = $1`, formID)
	return err
}

// ─── Form Responses ────────────────────────────────────────────────

func (r *FormRepository) SubmitResponse(ctx context.Context, resp *FormResponse) error {
	query := `
		INSERT INTO form_responses (form_id, user_id, answers)
		VALUES ($1, $2, $3)
		RETURNING id, submitted_at`
	return r.db.QueryRow(ctx, query, resp.FormID, resp.UserID, resp.Answers).
		Scan(&resp.ID, &resp.SubmittedAt)
}

func (r *FormRepository) ListResponses(ctx context.Context, formID string, params model.PaginationParams) ([]FormResponse, int, error) {
	var total int
	if err := r.db.QueryRow(ctx, `SELECT COUNT(*) FROM form_responses WHERE form_id = $1`, formID).Scan(&total); err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT id, form_id, user_id, answers, submitted_at
		FROM form_responses WHERE form_id = $1
		ORDER BY submitted_at DESC LIMIT $2 OFFSET $3`,
		formID, params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var responses []FormResponse
	for rows.Next() {
		var resp FormResponse
		if err := rows.Scan(&resp.ID, &resp.FormID, &resp.UserID, &resp.Answers, &resp.SubmittedAt); err != nil {
			return nil, 0, err
		}
		responses = append(responses, resp)
	}
	return responses, total, rows.Err()
}
