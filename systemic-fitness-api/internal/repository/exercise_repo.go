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

type ExerciseRepository struct {
	db *pgxpool.Pool
}

func NewExerciseRepository(db *pgxpool.Pool) *ExerciseRepository {
	return &ExerciseRepository{db: db}
}

type Exercise struct {
	ID           string    `json:"id"`
	Name         string    `json:"name"`
	Description  *string   `json:"description,omitempty"`
	MuscleGroup  []string  `json:"muscle_group"`
	Equipment    *string   `json:"equipment,omitempty"`
	Difficulty   string    `json:"difficulty"`
	VideoURL     *string   `json:"video_url,omitempty"`
	ThumbnailURL *string   `json:"thumbnail_url,omitempty"`
	Instructions []string  `json:"instructions,omitempty"`
	CreatedBy    *string   `json:"created_by,omitempty"`
	IsSystem     bool      `json:"is_system"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

const exerciseCols = `id, name, description, muscle_group, equipment, difficulty,
	video_url, thumbnail_url, instructions, created_by, is_system, created_at, updated_at`

func scanExercise(row pgx.Row) (*Exercise, error) {
	ex := &Exercise{}
	err := row.Scan(
		&ex.ID, &ex.Name, &ex.Description, &ex.MuscleGroup, &ex.Equipment,
		&ex.Difficulty, &ex.VideoURL, &ex.ThumbnailURL, &ex.Instructions,
		&ex.CreatedBy, &ex.IsSystem, &ex.CreatedAt, &ex.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return ex, err
}

func (r *ExerciseRepository) Create(ctx context.Context, ex *Exercise) error {
	query := `
		INSERT INTO exercises (name, description, muscle_group, equipment, difficulty,
		    video_url, thumbnail_url, instructions, created_by, is_system)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		ex.Name, ex.Description, ex.MuscleGroup, ex.Equipment,
		ex.Difficulty, ex.VideoURL, ex.ThumbnailURL, ex.Instructions,
		ex.CreatedBy, ex.IsSystem,
	).Scan(&ex.ID, &ex.CreatedAt, &ex.UpdatedAt)
}

func (r *ExerciseRepository) GetByID(ctx context.Context, id string) (*Exercise, error) {
	return scanExercise(r.db.QueryRow(ctx,
		`SELECT `+exerciseCols+` FROM exercises WHERE id = $1`, id))
}

func (r *ExerciseRepository) Update(ctx context.Context, ex *Exercise) error {
	query := `
		UPDATE exercises SET
			name = $2, description = $3, muscle_group = $4, equipment = $5,
			difficulty = $6, video_url = $7, thumbnail_url = $8, instructions = $9
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		ex.ID, ex.Name, ex.Description, ex.MuscleGroup, ex.Equipment,
		ex.Difficulty, ex.VideoURL, ex.ThumbnailURL, ex.Instructions,
	).Scan(&ex.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *ExerciseRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM exercises WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type ExerciseListFilter struct {
	MuscleGroup *string
	Equipment   *string
	Difficulty  *string
	Search      string
}

func (r *ExerciseRepository) List(ctx context.Context, params model.PaginationParams, f ExerciseListFilter) ([]Exercise, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.MuscleGroup != nil {
		where += fmt.Sprintf(" AND muscle_group @> ARRAY[$%d]::VARCHAR[]", idx)
		args = append(args, *f.MuscleGroup)
		idx++
	}
	if f.Equipment != nil {
		where += fmt.Sprintf(" AND equipment = $%d", idx)
		args = append(args, *f.Equipment)
		idx++
	}
	if f.Difficulty != nil {
		where += fmt.Sprintf(" AND difficulty = $%d", idx)
		args = append(args, *f.Difficulty)
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND name ILIKE $%d", idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM exercises "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM exercises %s ORDER BY is_system DESC, name ASC LIMIT $%d OFFSET $%d",
		exerciseCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	exercises := make([]Exercise, 0)
	for rows.Next() {
		var ex Exercise
		if err := rows.Scan(
			&ex.ID, &ex.Name, &ex.Description, &ex.MuscleGroup, &ex.Equipment,
			&ex.Difficulty, &ex.VideoURL, &ex.ThumbnailURL, &ex.Instructions,
			&ex.CreatedBy, &ex.IsSystem, &ex.CreatedAt, &ex.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		exercises = append(exercises, ex)
	}
	return exercises, total, rows.Err()
}
