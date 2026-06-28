package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type WorkoutSessionRepository struct {
	db *pgxpool.Pool
}

func NewWorkoutSessionRepository(db *pgxpool.Pool) *WorkoutSessionRepository {
	return &WorkoutSessionRepository{db: db}
}

// WorkoutSessionLog is one completed guided training session.
type WorkoutSessionLog struct {
	ID              string    `json:"id"`
	UserID          string    `json:"user_id"`
	TrainerCardID   *string   `json:"trainer_card_id,omitempty"`
	SessionType     string    `json:"session_type"` // full | daily
	Level           string    `json:"level"`
	DurationSeconds int       `json:"duration_seconds"`
	CompletedAt     time.Time `json:"completed_at"`
	CreatedAt       time.Time `json:"created_at"`
}

// WorkoutSessionStats summarises a user's session history.
type WorkoutSessionStats struct {
	TotalSessions int        `json:"total_sessions"`
	TotalSeconds  int        `json:"total_seconds"`
	FullSessions  int        `json:"full_sessions"`
	DailySessions int        `json:"daily_sessions"`
	CurrentStreak int        `json:"current_streak"` // consecutive days with ≥1 session
	ThisWeekCount int        `json:"this_week_count"`
	LastSessionAt *time.Time `json:"last_session_at,omitempty"`
}

// WorkoutSessionFilter narrows a history query.
type WorkoutSessionFilter struct {
	SessionType *string // "full" | "daily" | nil (all)
}

const statsTZ = "Asia/Jakarta"

// Create inserts a session log and fills generated fields.
func (r *WorkoutSessionRepository) Create(ctx context.Context, log *WorkoutSessionLog) error {
	query := `
		INSERT INTO workout_session_logs
			(user_id, trainer_card_id, session_type, level, duration_seconds, completed_at)
		VALUES ($1, $2, $3, $4, $5, COALESCE($6, NOW()))
		RETURNING id, completed_at, created_at`
	var completedAt *time.Time
	if !log.CompletedAt.IsZero() {
		completedAt = &log.CompletedAt
	}
	return r.db.QueryRow(ctx, query,
		log.UserID, log.TrainerCardID, log.SessionType, log.Level, log.DurationSeconds, completedAt,
	).Scan(&log.ID, &log.CompletedAt, &log.CreatedAt)
}

// ListByUser returns paginated session logs, newest first.
func (r *WorkoutSessionRepository) ListByUser(ctx context.Context, userID string, p model.PaginationParams, f WorkoutSessionFilter) ([]WorkoutSessionLog, int, error) {
	const cols = `id, user_id, trainer_card_id, session_type, level, duration_seconds, completed_at, created_at`

	var (
		total     int
		countSQL  string
		selectSQL string
		args      []any
	)
	if f.SessionType != nil && *f.SessionType != "" {
		countSQL = `SELECT COUNT(*) FROM workout_session_logs WHERE user_id = $1 AND session_type = $2`
		selectSQL = `SELECT ` + cols + ` FROM workout_session_logs
			WHERE user_id = $1 AND session_type = $2
			ORDER BY completed_at DESC LIMIT $3 OFFSET $4`
		args = []any{userID, *f.SessionType, p.Limit, p.Offset()}
		if err := r.db.QueryRow(ctx, countSQL, userID, *f.SessionType).Scan(&total); err != nil {
			return nil, 0, err
		}
	} else {
		countSQL = `SELECT COUNT(*) FROM workout_session_logs WHERE user_id = $1`
		selectSQL = `SELECT ` + cols + ` FROM workout_session_logs
			WHERE user_id = $1
			ORDER BY completed_at DESC LIMIT $2 OFFSET $3`
		args = []any{userID, p.Limit, p.Offset()}
		if err := r.db.QueryRow(ctx, countSQL, userID).Scan(&total); err != nil {
			return nil, 0, err
		}
	}

	rows, err := r.db.Query(ctx, selectSQL, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var logs []WorkoutSessionLog
	for rows.Next() {
		var l WorkoutSessionLog
		if err := rows.Scan(&l.ID, &l.UserID, &l.TrainerCardID, &l.SessionType,
			&l.Level, &l.DurationSeconds, &l.CompletedAt, &l.CreatedAt); err != nil {
			return nil, 0, err
		}
		logs = append(logs, l)
	}
	return logs, total, rows.Err()
}

// Stats aggregates totals + streak for a user.
func (r *WorkoutSessionRepository) Stats(ctx context.Context, userID string) (*WorkoutSessionStats, error) {
	stats := &WorkoutSessionStats{}
	aggQuery := `
		SELECT
			COUNT(*),
			COALESCE(SUM(duration_seconds), 0),
			COUNT(*) FILTER (WHERE session_type = 'full'),
			COUNT(*) FILTER (WHERE session_type = 'daily'),
			MAX(completed_at),
			COUNT(*) FILTER (
				WHERE (completed_at AT TIME ZONE '` + statsTZ + `')::date
				      >= (NOW() AT TIME ZONE '` + statsTZ + `')::date - 6
			)
		FROM workout_session_logs
		WHERE user_id = $1`
	if err := r.db.QueryRow(ctx, aggQuery, userID).Scan(
		&stats.TotalSessions, &stats.TotalSeconds, &stats.FullSessions,
		&stats.DailySessions, &stats.LastSessionAt, &stats.ThisWeekCount,
	); err != nil {
		return nil, err
	}

	streak, err := r.currentStreak(ctx, userID)
	if err != nil {
		return nil, err
	}
	stats.CurrentStreak = streak
	return stats, nil
}

// currentStreak counts consecutive local days (ending today or yesterday)
// that have at least one completed session.
func (r *WorkoutSessionRepository) currentStreak(ctx context.Context, userID string) (int, error) {
	query := `
		SELECT DISTINCT (completed_at AT TIME ZONE '` + statsTZ + `')::date AS d
		FROM workout_session_logs
		WHERE user_id = $1
		ORDER BY d DESC
		LIMIT 400`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return 0, err
	}
	defer rows.Close()

	var days []int
	for rows.Next() {
		var d time.Time
		if err := rows.Scan(&d); err != nil {
			return 0, err
		}
		days = append(days, dayNumber(d))
	}
	if err := rows.Err(); err != nil {
		return 0, err
	}
	if len(days) == 0 {
		return 0, nil
	}

	loc, err := time.LoadLocation(statsTZ)
	if err != nil {
		loc = time.UTC
	}
	now := time.Now().In(loc)
	todayNum := dayNumber(time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC))

	// Streak only counts if the latest activity is today or yesterday.
	if days[0] != todayNum && days[0] != todayNum-1 {
		return 0, nil
	}
	streak := 1
	for i := 1; i < len(days); i++ {
		if days[i] == days[i-1]-1 {
			streak++
		} else if days[i] == days[i-1] {
			continue
		} else {
			break
		}
	}
	return streak, nil
}

// dayNumber converts a midnight-UTC date to a whole-day index since epoch.
func dayNumber(t time.Time) int {
	return int(t.UTC().Unix() / 86400)
}
