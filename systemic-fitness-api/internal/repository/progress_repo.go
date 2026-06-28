package repository

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type ProgressRepository struct {
	db *pgxpool.Pool
}

func NewProgressRepository(db *pgxpool.Pool) *ProgressRepository {
	return &ProgressRepository{db: db}
}

type ProgressLog struct {
	ID           string          `json:"id"`
	UserID       string          `json:"user_id"`
	ExerciseID   string          `json:"exercise_id"`
	ExerciseName *string         `json:"exercise_name,omitempty"` // populated via join
	WorkoutID    *string         `json:"workout_id,omitempty"`
	LoggedAt     time.Time       `json:"logged_at"`
	Sets         json.RawMessage `json:"sets"`
	Notes        *string         `json:"notes,omitempty"`
	Mood         *string         `json:"mood,omitempty"`
}

type BodyMetric struct {
	ID           string    `json:"id"`
	UserID       string    `json:"user_id"`
	LoggedAt     time.Time `json:"logged_at"`
	WeightKg     *float64  `json:"weight_kg,omitempty"`
	BodyFatPct   *float64  `json:"body_fat_pct,omitempty"`
	MuscleMassKg *float64  `json:"muscle_mass_kg,omitempty"`
	PhotoURLs    []string  `json:"photo_urls,omitempty"`
	Notes        *string   `json:"notes,omitempty"`
}

// ChartPoint is one data point in a progress chart.
type ChartPoint struct {
	Date        string  `json:"date"`
	MaxWeight   float64 `json:"max_weight"`
	TotalVolume float64 `json:"total_volume"`
	AvgReps     float64 `json:"avg_reps"`
	SetCount    int     `json:"set_count"`
}

// ExerciseChartData is chart data for a single exercise.
type ExerciseChartData struct {
	ExerciseID   string       `json:"exercise_id"`
	ExerciseName string       `json:"exercise_name"`
	Data         []ChartPoint `json:"data"`
}

func (r *ProgressRepository) LogProgress(ctx context.Context, log *ProgressLog) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO progress_logs (user_id, exercise_id, workout_id, sets, notes, mood)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, logged_at`,
		log.UserID, log.ExerciseID, log.WorkoutID, log.Sets, log.Notes, log.Mood,
	).Scan(&log.ID, &log.LoggedAt)
}

type ProgressHistoryFilter struct {
	ExerciseID *string
	WorkoutID  *string
	DateFrom   *string // YYYY-MM-DD
	DateTo     *string // YYYY-MM-DD
}

func (r *ProgressRepository) GetHistory(ctx context.Context, userID string, params model.PaginationParams, f ProgressHistoryFilter) ([]ProgressLog, int, error) {
	where := "WHERE pl.user_id = $1"
	args := []any{userID}
	idx := 2

	if f.ExerciseID != nil {
		where += fmt.Sprintf(" AND pl.exercise_id = $%d", idx)
		args = append(args, *f.ExerciseID)
		idx++
	}
	if f.WorkoutID != nil {
		where += fmt.Sprintf(" AND pl.workout_id = $%d", idx)
		args = append(args, *f.WorkoutID)
		idx++
	}
	if f.DateFrom != nil {
		where += fmt.Sprintf(" AND pl.logged_at >= $%d::DATE", idx)
		args = append(args, *f.DateFrom)
		idx++
	}
	if f.DateTo != nil {
		where += fmt.Sprintf(" AND pl.logged_at < ($%d::DATE + INTERVAL '1 day')", idx)
		args = append(args, *f.DateTo)
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx,
		"SELECT COUNT(*) FROM progress_logs pl "+where, args...,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(`
		SELECT pl.id, pl.user_id, pl.exercise_id, e.name,
		       pl.workout_id, pl.logged_at, pl.sets, pl.notes, pl.mood
		FROM progress_logs pl
		JOIN exercises e ON e.id = pl.exercise_id
		%s ORDER BY pl.logged_at DESC
		LIMIT $%d OFFSET $%d`, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	logs := make([]ProgressLog, 0)
	for rows.Next() {
		var l ProgressLog
		if err := rows.Scan(
			&l.ID, &l.UserID, &l.ExerciseID, &l.ExerciseName,
			&l.WorkoutID, &l.LoggedAt, &l.Sets, &l.Notes, &l.Mood,
		); err != nil {
			return nil, 0, err
		}
		logs = append(logs, l)
	}
	return logs, total, rows.Err()
}

// GetChartData returns aggregated progress data per exercise per day.
// All aggregation happens in SQL — no raw data transferred to Go.
func (r *ProgressRepository) GetChartData(ctx context.Context, userID string, exerciseID, dateFrom, dateTo *string) ([]ExerciseChartData, error) {
	where := "WHERE pl.user_id = $1"
	args := []any{userID}
	idx := 2

	if exerciseID != nil {
		where += fmt.Sprintf(" AND pl.exercise_id = $%d", idx)
		args = append(args, *exerciseID)
		idx++
	}
	if dateFrom != nil {
		where += fmt.Sprintf(" AND pl.logged_at >= $%d::DATE", idx)
		args = append(args, *dateFrom)
		idx++
	}
	if dateTo != nil {
		where += fmt.Sprintf(" AND pl.logged_at < ($%d::DATE + INTERVAL '1 day')", idx)
		args = append(args, *dateTo)
		idx++
	}

	// Aggregate per exercise per day using JSONB set extraction.
	// Each set is: {"set_number":1, "reps":10, "weight_kg":80, "completed":true}
	query := fmt.Sprintf(`
		WITH expanded AS (
			SELECT
				pl.exercise_id,
				e.name AS exercise_name,
				DATE(pl.logged_at) AS log_date,
				(s->>'weight_kg')::NUMERIC AS weight,
				(s->>'reps')::NUMERIC AS reps
			FROM progress_logs pl
			JOIN exercises e ON e.id = pl.exercise_id,
			LATERAL jsonb_array_elements(pl.sets) AS s
			%s
			AND (s->>'completed')::BOOLEAN IS NOT FALSE
		)
		SELECT
			exercise_id,
			exercise_name,
			log_date::TEXT,
			COALESCE(MAX(weight), 0) AS max_weight,
			COALESCE(SUM(weight * reps), 0) AS total_volume,
			COALESCE(AVG(reps), 0) AS avg_reps,
			COUNT(*) AS set_count
		FROM expanded
		GROUP BY exercise_id, exercise_name, log_date
		ORDER BY exercise_id, log_date`, where)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("chart data query: %w", err)
	}
	defer rows.Close()

	// Group by exercise
	dataMap := make(map[string]*ExerciseChartData)
	var order []string

	for rows.Next() {
		var exID, exName string
		var pt ChartPoint
		if err := rows.Scan(&exID, &exName, &pt.Date, &pt.MaxWeight,
			&pt.TotalVolume, &pt.AvgReps, &pt.SetCount); err != nil {
			return nil, err
		}

		entry, exists := dataMap[exID]
		if !exists {
			entry = &ExerciseChartData{ExerciseID: exID, ExerciseName: exName}
			dataMap[exID] = entry
			order = append(order, exID)
		}
		entry.Data = append(entry.Data, pt)
	}

	result := make([]ExerciseChartData, 0, len(order))
	for _, id := range order {
		result = append(result, *dataMap[id])
	}
	return result, rows.Err()
}

// ── Body Metrics ────────────────────────────────────────────────

func (r *ProgressRepository) LogBodyMetric(ctx context.Context, bm *BodyMetric) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO body_metrics (user_id, weight_kg, body_fat_pct, muscle_mass_kg, photo_urls, notes)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, logged_at`,
		bm.UserID, bm.WeightKg, bm.BodyFatPct, bm.MuscleMassKg, bm.PhotoURLs, bm.Notes,
	).Scan(&bm.ID, &bm.LoggedAt)
}

func (r *ProgressRepository) GetBodyMetrics(ctx context.Context, userID string, params model.PaginationParams) ([]BodyMetric, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM body_metrics WHERE user_id=$1`, userID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT id, user_id, logged_at, weight_kg, body_fat_pct, muscle_mass_kg, photo_urls, notes
		FROM body_metrics WHERE user_id=$1 ORDER BY logged_at DESC LIMIT $2 OFFSET $3`,
		userID, params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	metrics := make([]BodyMetric, 0)
	for rows.Next() {
		var bm BodyMetric
		if err := rows.Scan(&bm.ID, &bm.UserID, &bm.LoggedAt, &bm.WeightKg,
			&bm.BodyFatPct, &bm.MuscleMassKg, &bm.PhotoURLs, &bm.Notes); err != nil {
			return nil, 0, err
		}
		metrics = append(metrics, bm)
	}
	return metrics, total, rows.Err()
}

// ── Week Completion Check ───────────────────────────────────────

// CountWorkoutsLoggedInWeek counts how many unique workout_ids a user has logged
// progress for in a given week of their program.
func (r *ProgressRepository) CountWorkoutsLoggedInWeek(ctx context.Context, userID string, weekStart, weekEnd string) (int, error) {
	var count int
	err := r.db.QueryRow(ctx, `
		SELECT COUNT(DISTINCT workout_id)
		FROM progress_logs
		WHERE user_id = $1
		  AND workout_id IS NOT NULL
		  AND logged_at >= $2::DATE
		  AND logged_at < ($3::DATE + INTERVAL '1 day')`,
		userID, weekStart, weekEnd,
	).Scan(&count)
	return count, err
}
