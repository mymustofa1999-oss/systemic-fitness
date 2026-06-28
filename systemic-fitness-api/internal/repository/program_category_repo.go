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

type ProgramCategoryRepository struct {
	db *pgxpool.Pool
}

func NewProgramCategoryRepository(db *pgxpool.Pool) *ProgramCategoryRepository {
	return &ProgramCategoryRepository{db: db}
}

type ProgramCategory struct {
	ID                string          `json:"id"`
	Name              string          `json:"name"`
	Code              string          `json:"code"`
	Description       *string         `json:"description,omitempty"`
	ParameterTemplate json.RawMessage `json:"parameter_template"`
	DisplayOrder      int             `json:"display_order"`
	IsActive          bool            `json:"is_active"`
	IsSystem          bool            `json:"is_system"`
	CreatedBy         *string         `json:"created_by,omitempty"`
	CreatedAt         time.Time       `json:"created_at"`
	UpdatedAt         time.Time       `json:"updated_at"`
}

const programCategoryCols = `id, name, code, description, parameter_template,
	display_order, is_active, is_system, created_by, created_at, updated_at`

func scanProgramCategory(row pgx.Row) (*ProgramCategory, error) {
	pc := &ProgramCategory{}
	err := row.Scan(
		&pc.ID, &pc.Name, &pc.Code, &pc.Description, &pc.ParameterTemplate,
		&pc.DisplayOrder, &pc.IsActive, &pc.IsSystem, &pc.CreatedBy, &pc.CreatedAt, &pc.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return pc, err
}

func (r *ProgramCategoryRepository) Create(ctx context.Context, pc *ProgramCategory) error {
	query := `
		INSERT INTO program_categories (name, code, description, parameter_template, display_order, is_active, is_system, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		pc.Name, pc.Code, pc.Description, pc.ParameterTemplate,
		pc.DisplayOrder, pc.IsActive, pc.IsSystem, pc.CreatedBy,
	).Scan(&pc.ID, &pc.CreatedAt, &pc.UpdatedAt)
}

func (r *ProgramCategoryRepository) GetByID(ctx context.Context, id string) (*ProgramCategory, error) {
	return scanProgramCategory(r.db.QueryRow(ctx, `SELECT `+programCategoryCols+` FROM program_categories WHERE id = $1`, id))
}

func (r *ProgramCategoryRepository) Update(ctx context.Context, pc *ProgramCategory) error {
	query := `
		UPDATE program_categories SET
			name = $2, code = $3, description = $4, parameter_template = $5,
			display_order = $6, is_active = $7
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		pc.ID, pc.Name, pc.Code, pc.Description, pc.ParameterTemplate,
		pc.DisplayOrder, pc.IsActive,
	).Scan(&pc.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *ProgramCategoryRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM program_categories WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type ProgramCategoryListFilter struct {
	Search string
}

func (r *ProgramCategoryRepository) List(ctx context.Context, params model.PaginationParams, f ProgramCategoryListFilter) ([]ProgramCategory, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Search != "" {
		where += fmt.Sprintf(" AND (name ILIKE $%d OR code ILIKE $%d OR description ILIKE $%d)", idx, idx, idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM program_categories "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM program_categories %s ORDER BY display_order ASC, name ASC LIMIT $%d OFFSET $%d",
		programCategoryCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	categories := make([]ProgramCategory, 0)
	for rows.Next() {
		var pc ProgramCategory
		if err := rows.Scan(
			&pc.ID, &pc.Name, &pc.Code, &pc.Description, &pc.ParameterTemplate,
			&pc.DisplayOrder, &pc.IsActive, &pc.IsSystem, &pc.CreatedBy, &pc.CreatedAt, &pc.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		categories = append(categories, pc)
	}
	return categories, total, rows.Err()
}
