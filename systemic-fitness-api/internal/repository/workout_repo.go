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

type WorkoutRepository struct {
	db *pgxpool.Pool
}

func NewWorkoutRepository(db *pgxpool.Pool) *WorkoutRepository {
	return &WorkoutRepository{db: db}
}

type Workout struct {
	ID                   string    `json:"id"`
	Name                 string    `json:"name"`
	Description          *string   `json:"description,omitempty"`
	Type                 string    `json:"type"`
	EstimatedDurationMin *int      `json:"estimated_duration_min,omitempty"`
	CreatedBy            *string   `json:"created_by,omitempty"`
	IsTemplate           bool      `json:"is_template"`
	CreatedAt            time.Time `json:"created_at"`
	UpdatedAt            time.Time `json:"updated_at"`
}

type WorkoutExercise struct {
	ID            string   `json:"id"`
	WorkoutID     string   `json:"workout_id"`
	ExerciseID    string   `json:"exercise_id"`
	OrderIndex    int      `json:"order_index"`
	Sets          *int     `json:"sets,omitempty"`
	Reps          *string  `json:"reps,omitempty"`
	WeightKg      *float64 `json:"weight_kg,omitempty"`
	RestSeconds   *int     `json:"rest_seconds,omitempty"`
	Notes         *string  `json:"notes,omitempty"`
	SupersetGroup *int     `json:"superset_group,omitempty"`
	// Populated by join in GetDetail
	ExerciseName *string `json:"exercise_name,omitempty"`
}

// WorkoutDetail is workout + its exercises, returned by GetDetail.
type WorkoutDetail struct {
	Workout
	Exercises []WorkoutExercise `json:"exercises"`
}

const workoutCols = `id, name, description, type, estimated_duration_min,
	created_by, is_template, created_at, updated_at`

func scanWorkout(row pgx.Row) (*Workout, error) {
	w := &Workout{}
	err := row.Scan(
		&w.ID, &w.Name, &w.Description, &w.Type, &w.EstimatedDurationMin,
		&w.CreatedBy, &w.IsTemplate, &w.CreatedAt, &w.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return w, err
}

func (r *WorkoutRepository) Create(ctx context.Context, w *Workout) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO workouts (name, description, type, estimated_duration_min, created_by, is_template)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at, updated_at`,
		w.Name, w.Description, w.Type, w.EstimatedDurationMin,
		w.CreatedBy, w.IsTemplate,
	).Scan(&w.ID, &w.CreatedAt, &w.UpdatedAt)
}

func (r *WorkoutRepository) GetByID(ctx context.Context, id string) (*Workout, error) {
	return scanWorkout(r.db.QueryRow(ctx,
		`SELECT `+workoutCols+` FROM workouts WHERE id = $1`, id))
}

// GetDetail returns workout + exercises with exercise names joined.
func (r *WorkoutRepository) GetDetail(ctx context.Context, id string) (*WorkoutDetail, error) {
	w, err := r.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT we.id, we.workout_id, we.exercise_id, we.order_index,
		       we.sets, we.reps, we.weight_kg, we.rest_seconds,
		       we.notes, we.superset_group, e.name
		FROM workout_exercises we
		JOIN exercises e ON e.id = we.exercise_id
		WHERE we.workout_id = $1
		ORDER BY we.order_index`, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	exercises := make([]WorkoutExercise, 0)
	for rows.Next() {
		var we WorkoutExercise
		if err := rows.Scan(
			&we.ID, &we.WorkoutID, &we.ExerciseID, &we.OrderIndex,
			&we.Sets, &we.Reps, &we.WeightKg, &we.RestSeconds,
			&we.Notes, &we.SupersetGroup, &we.ExerciseName,
		); err != nil {
			return nil, err
		}
		exercises = append(exercises, we)
	}

	return &WorkoutDetail{Workout: *w, Exercises: exercises}, rows.Err()
}

func (r *WorkoutRepository) Update(ctx context.Context, w *Workout) error {
	err := r.db.QueryRow(ctx, `
		UPDATE workouts SET name=$2, description=$3, type=$4, estimated_duration_min=$5, is_template=$6
		WHERE id = $1 RETURNING updated_at`,
		w.ID, w.Name, w.Description, w.Type, w.EstimatedDurationMin, w.IsTemplate,
	).Scan(&w.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *WorkoutRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM workouts WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type WorkoutListFilter struct {
	Type       *string
	CreatedBy  *string
	IsTemplate *bool
	Search     string
}

func (r *WorkoutRepository) List(ctx context.Context, params model.PaginationParams, f WorkoutListFilter) ([]Workout, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Type != nil {
		where += fmt.Sprintf(" AND type = $%d", idx)
		args = append(args, *f.Type)
		idx++
	}
	if f.CreatedBy != nil {
		where += fmt.Sprintf(" AND created_by = $%d", idx)
		args = append(args, *f.CreatedBy)
		idx++
	}
	if f.IsTemplate != nil {
		where += fmt.Sprintf(" AND is_template = $%d", idx)
		args = append(args, *f.IsTemplate)
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND name ILIKE $%d", idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM workouts "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM workouts %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		workoutCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	workouts := make([]Workout, 0)
	for rows.Next() {
		var w Workout
		if err := rows.Scan(
			&w.ID, &w.Name, &w.Description, &w.Type, &w.EstimatedDurationMin,
			&w.CreatedBy, &w.IsTemplate, &w.CreatedAt, &w.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		workouts = append(workouts, w)
	}
	return workouts, total, rows.Err()
}

// ── Workout Exercises (batch operations) ────────────────────────

// ReplaceExercises deletes all exercises for a workout and inserts new ones in a transaction.
func (r *WorkoutRepository) ReplaceExercises(ctx context.Context, workoutID string, exercises []WorkoutExercise) ([]WorkoutExercise, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)

	if _, err := tx.Exec(ctx, `DELETE FROM workout_exercises WHERE workout_id = $1`, workoutID); err != nil {
		return nil, fmt.Errorf("clearing exercises: %w", err)
	}

	result := make([]WorkoutExercise, len(exercises))
	for i, we := range exercises {
		we.WorkoutID = workoutID
		err := tx.QueryRow(ctx, `
			INSERT INTO workout_exercises
				(workout_id, exercise_id, order_index, sets, reps, weight_kg, rest_seconds, notes, superset_group)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
			RETURNING id`,
			we.WorkoutID, we.ExerciseID, we.OrderIndex,
			we.Sets, we.Reps, we.WeightKg, we.RestSeconds,
			we.Notes, we.SupersetGroup,
		).Scan(&we.ID)
		if err != nil {
			return nil, fmt.Errorf("inserting exercise %d: %w", i, err)
		}
		result[i] = we
	}

	return result, tx.Commit(ctx)
}

func (r *WorkoutRepository) GetExercises(ctx context.Context, workoutID string) ([]WorkoutExercise, error) {
	rows, err := r.db.Query(ctx, `
		SELECT we.id, we.workout_id, we.exercise_id, we.order_index,
		       we.sets, we.reps, we.weight_kg, we.rest_seconds,
		       we.notes, we.superset_group, e.name
		FROM workout_exercises we
		JOIN exercises e ON e.id = we.exercise_id
		WHERE we.workout_id = $1
		ORDER BY we.order_index`, workoutID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	exercises := make([]WorkoutExercise, 0)
	for rows.Next() {
		var we WorkoutExercise
		if err := rows.Scan(
			&we.ID, &we.WorkoutID, &we.ExerciseID, &we.OrderIndex,
			&we.Sets, &we.Reps, &we.WeightKg, &we.RestSeconds,
			&we.Notes, &we.SupersetGroup, &we.ExerciseName,
		); err != nil {
			return nil, err
		}
		exercises = append(exercises, we)
	}
	return exercises, rows.Err()
}

// Duplicate deep-copies a workout including all workout_exercises.
func (r *WorkoutRepository) Duplicate(ctx context.Context, id, createdBy string) (*WorkoutDetail, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)

	var w Workout
	err = tx.QueryRow(ctx, `
		INSERT INTO workouts (name, description, type, estimated_duration_min, created_by, is_template)
		SELECT name || ' (Copy)', description, type, estimated_duration_min, $2, FALSE
		FROM workouts WHERE id = $1
		RETURNING `+workoutCols, id, createdBy,
	).Scan(&w.ID, &w.Name, &w.Description, &w.Type, &w.EstimatedDurationMin,
		&w.CreatedBy, &w.IsTemplate, &w.CreatedAt, &w.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("duplicating workout: %w", err)
	}

	_, err = tx.Exec(ctx, `
		INSERT INTO workout_exercises
			(workout_id, exercise_id, order_index, sets, reps, weight_kg, rest_seconds, notes, superset_group)
		SELECT $2, exercise_id, order_index, sets, reps, weight_kg, rest_seconds, notes, superset_group
		FROM workout_exercises WHERE workout_id = $1`, id, w.ID)
	if err != nil {
		return nil, fmt.Errorf("duplicating exercises: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}

	// Re-read to get full detail with exercise names
	return r.GetDetail(ctx, w.ID)
}
