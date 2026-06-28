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

type FoodRepository struct {
	db *pgxpool.Pool
}

func NewFoodRepository(db *pgxpool.Pool) *FoodRepository {
	return &FoodRepository{db: db}
}

type Food struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description *string   `json:"description,omitempty"`
	ImageURL    *string   `json:"image_url,omitempty"`
	MealTypes   []string  `json:"meal_types"`
	Calories    *int      `json:"calories,omitempty"`
	ProteinG    *float64  `json:"protein_g,omitempty"`
	CarbsG      *float64  `json:"carbs_g,omitempty"`
	FatG        *float64  `json:"fat_g,omitempty"`
	FiberG      *float64  `json:"fiber_g,omitempty"`
	ServingSize *string   `json:"serving_size,omitempty"`
	ServingUnit *string   `json:"serving_unit,omitempty"`
	IsSystem    bool      `json:"is_system"`
	CreatedBy   *string   `json:"created_by,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

const foodCols = `id, name, description, image_url, meal_types, calories, protein_g, carbs_g,
	fat_g, fiber_g, serving_size, serving_unit, is_system, created_by, created_at, updated_at`

func scanFood(row pgx.Row) (*Food, error) {
	f := &Food{}
	err := row.Scan(
		&f.ID, &f.Name, &f.Description, &f.ImageURL, &f.MealTypes,
		&f.Calories, &f.ProteinG, &f.CarbsG, &f.FatG, &f.FiberG,
		&f.ServingSize, &f.ServingUnit, &f.IsSystem, &f.CreatedBy,
		&f.CreatedAt, &f.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return f, err
}

func (r *FoodRepository) Create(ctx context.Context, f *Food) error {
	query := `
		INSERT INTO foods (name, description, image_url, meal_types, calories, protein_g, carbs_g,
			fat_g, fiber_g, serving_size, serving_unit, is_system, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		f.Name, f.Description, f.ImageURL, f.MealTypes, f.Calories,
		f.ProteinG, f.CarbsG, f.FatG, f.FiberG, f.ServingSize,
		f.ServingUnit, f.IsSystem, f.CreatedBy,
	).Scan(&f.ID, &f.CreatedAt, &f.UpdatedAt)
}

func (r *FoodRepository) GetByID(ctx context.Context, id string) (*Food, error) {
	return scanFood(r.db.QueryRow(ctx, `SELECT `+foodCols+` FROM foods WHERE id = $1`, id))
}

func (r *FoodRepository) Update(ctx context.Context, f *Food) error {
	query := `
		UPDATE foods SET
			name = $2, description = $3, image_url = $4, meal_types = $5, calories = $6,
			protein_g = $7, carbs_g = $8, fat_g = $9, fiber_g = $10,
			serving_size = $11, serving_unit = $12
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		f.ID, f.Name, f.Description, f.ImageURL, f.MealTypes, f.Calories,
		f.ProteinG, f.CarbsG, f.FatG, f.FiberG, f.ServingSize, f.ServingUnit,
	).Scan(&f.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *FoodRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM foods WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type FoodListFilter struct {
	MealType *string
	Search   string
}

func (r *FoodRepository) List(ctx context.Context, params model.PaginationParams, f FoodListFilter) ([]Food, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.MealType != nil {
		where += fmt.Sprintf(" AND meal_types @> ARRAY[$%d]::meal_type[]", idx)
		args = append(args, *f.MealType)
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND name ILIKE $%d", idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM foods "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM foods %s ORDER BY updated_at DESC LIMIT $%d OFFSET $%d",
		foodCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	foods := make([]Food, 0)
	for rows.Next() {
		var fd Food
		if err := rows.Scan(
			&fd.ID, &fd.Name, &fd.Description, &fd.ImageURL, &fd.MealTypes,
			&fd.Calories, &fd.ProteinG, &fd.CarbsG, &fd.FatG, &fd.FiberG,
			&fd.ServingSize, &fd.ServingUnit, &fd.IsSystem, &fd.CreatedBy,
			&fd.CreatedAt, &fd.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		foods = append(foods, fd)
	}
	return foods, total, rows.Err()
}
