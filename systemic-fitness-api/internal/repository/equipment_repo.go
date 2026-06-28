package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type EquipmentRepository struct {
	db *pgxpool.Pool
}

func NewEquipmentRepository(db *pgxpool.Pool) *EquipmentRepository {
	return &EquipmentRepository{db: db}
}

type Equipment struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Category    string    `json:"category"`
	Description *string   `json:"description,omitempty"`
	IsActive    bool      `json:"is_active"`
	SortOrder   int       `json:"sort_order"`
	CreatedBy   *string   `json:"created_by,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

const equipmentCols = `id, name, category, description, is_active, sort_order, created_by, created_at, updated_at`

func scanEquipment(row pgx.Row) (*Equipment, error) {
	e := &Equipment{}
	err := row.Scan(
		&e.ID, &e.Name, &e.Category, &e.Description,
		&e.IsActive, &e.SortOrder, &e.CreatedBy, &e.CreatedAt, &e.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return e, err
}

func (r *EquipmentRepository) Create(ctx context.Context, e *Equipment) error {
	query := `
		INSERT INTO equipments (name, category, description, is_active, sort_order, created_by)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		e.Name, e.Category, e.Description, e.IsActive, e.SortOrder, e.CreatedBy,
	).Scan(&e.ID, &e.CreatedAt, &e.UpdatedAt)
}

func (r *EquipmentRepository) GetByID(ctx context.Context, id string) (*Equipment, error) {
	return scanEquipment(r.db.QueryRow(ctx, `SELECT `+equipmentCols+` FROM equipments WHERE id = $1`, id))
}

func (r *EquipmentRepository) Update(ctx context.Context, e *Equipment) error {
	query := `
		UPDATE equipments SET
			name = $2, category = $3, description = $4,
			is_active = $5, sort_order = $6
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		e.ID, e.Name, e.Category, e.Description, e.IsActive, e.SortOrder,
	).Scan(&e.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *EquipmentRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM equipments WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type EquipmentListFilter struct {
	Search   string
	Category string
}

func (r *EquipmentRepository) List(ctx context.Context, params model.PaginationParams, f EquipmentListFilter) ([]Equipment, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Search != "" {
		where += fmt.Sprintf(" AND (name ILIKE $%d OR description ILIKE $%d)", idx, idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}
	if f.Category != "" {
		where += fmt.Sprintf(" AND category = $%d", idx)
		args = append(args, f.Category)
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM equipments "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM equipments %s ORDER BY category ASC, sort_order ASC, name ASC LIMIT $%d OFFSET $%d",
		equipmentCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	equipments := make([]Equipment, 0)
	for rows.Next() {
		var e Equipment
		if err := rows.Scan(
			&e.ID, &e.Name, &e.Category, &e.Description,
			&e.IsActive, &e.SortOrder, &e.CreatedBy, &e.CreatedAt, &e.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		equipments = append(equipments, e)
	}
	return equipments, total, rows.Err()
}
