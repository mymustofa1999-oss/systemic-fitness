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

type MedicineRepository struct {
	db *pgxpool.Pool
}

func NewMedicineRepository(db *pgxpool.Pool) *MedicineRepository {
	return &MedicineRepository{db: db}
}

type Medicine struct {
	ID           string    `json:"id"`
	Name         string    `json:"name"`
	Category     *string   `json:"category,omitempty"`
	MainFunction *string   `json:"main_function,omitempty"`
	SideEffects  *string   `json:"side_effects,omitempty"`
	DetailURL    *string   `json:"detail_url,omitempty"`
	ImageURL     *string   `json:"image_url,omitempty"`
	IsSystem             bool      `json:"is_system"`
	IsActive             bool      `json:"is_active"`
	CreatedBy            *string   `json:"created_by,omitempty"`
	ActiveIngredient     *string   `json:"active_ingredient,omitempty"`
	ExerciseImplications *string   `json:"exercise_implications,omitempty"`
	ExerciseAdjustments  *string   `json:"exercise_adjustments,omitempty"`
	FlagLevel            *string   `json:"flag_level,omitempty"`
	CreatedAt            time.Time `json:"created_at"`
	UpdatedAt            time.Time `json:"updated_at"`
}

const medicineCols = `id, name, category, main_function, side_effects, detail_url,
	image_url, is_system, is_active, created_by, active_ingredient, exercise_implications,
	exercise_adjustments, flag_level, created_at, updated_at`

func scanMedicine(row pgx.Row) (*Medicine, error) {
	m := &Medicine{}
	err := row.Scan(
		&m.ID, &m.Name, &m.Category, &m.MainFunction, &m.SideEffects,
		&m.DetailURL, &m.ImageURL, &m.IsSystem, &m.IsActive, &m.CreatedBy,
		&m.ActiveIngredient, &m.ExerciseImplications, &m.ExerciseAdjustments, &m.FlagLevel,
		&m.CreatedAt, &m.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return m, err
}

func (r *MedicineRepository) Create(ctx context.Context, m *Medicine) error {
	query := `
		INSERT INTO medicines (name, category, main_function, side_effects, detail_url, image_url, is_system, is_active, created_by, active_ingredient, exercise_implications, exercise_adjustments, flag_level)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		m.Name, m.Category, m.MainFunction, m.SideEffects,
		m.DetailURL, m.ImageURL, m.IsSystem, m.IsActive, m.CreatedBy,
		m.ActiveIngredient, m.ExerciseImplications, m.ExerciseAdjustments, m.FlagLevel,
	).Scan(&m.ID, &m.CreatedAt, &m.UpdatedAt)
}

func (r *MedicineRepository) GetByID(ctx context.Context, id string) (*Medicine, error) {
	return scanMedicine(r.db.QueryRow(ctx, `SELECT `+medicineCols+` FROM medicines WHERE id = $1`, id))
}

func (r *MedicineRepository) Update(ctx context.Context, m *Medicine) error {
	query := `
		UPDATE medicines SET
			name = $2, category = $3, main_function = $4,
			side_effects = $5, detail_url = $6, image_url = $7,
			active_ingredient = $8, exercise_implications = $9,
			exercise_adjustments = $10, flag_level = $11,
			is_active = $12
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		m.ID, m.Name, m.Category, m.MainFunction,
		m.SideEffects, m.DetailURL, m.ImageURL,
		m.ActiveIngredient, m.ExerciseImplications, m.ExerciseAdjustments, m.FlagLevel,
		m.IsActive,
	).Scan(&m.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *MedicineRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM medicines WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type MedicineListFilter struct {
	Category *string
	Search   string
	IsActive *bool
}

func (r *MedicineRepository) List(ctx context.Context, params model.PaginationParams, f MedicineListFilter) ([]Medicine, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Category != nil {
		where += fmt.Sprintf(" AND category ILIKE $%d", idx)
		args = append(args, "%"+*f.Category+"%")
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND (name ILIKE $%d OR category ILIKE $%d OR main_function ILIKE $%d)", idx, idx, idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}
	if f.IsActive != nil {
		where += fmt.Sprintf(" AND is_active = $%d", idx)
		args = append(args, *f.IsActive)
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM medicines "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM medicines %s ORDER BY name ASC LIMIT $%d OFFSET $%d",
		medicineCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	medicines := make([]Medicine, 0)
	for rows.Next() {
		var m Medicine
		if err := rows.Scan(
			&m.ID, &m.Name, &m.Category, &m.MainFunction, &m.SideEffects,
			&m.DetailURL, &m.ImageURL, &m.IsSystem, &m.IsActive, &m.CreatedBy,
			&m.ActiveIngredient, &m.ExerciseImplications, &m.ExerciseAdjustments, &m.FlagLevel,
			&m.CreatedAt, &m.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		medicines = append(medicines, m)
	}
	return medicines, total, rows.Err()
}
