package repository

import (
	"context"
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type WorkoutReminderRepository struct {
	db *pgxpool.Pool
}

func NewWorkoutReminderRepository(db *pgxpool.Pool) *WorkoutReminderRepository {
	return &WorkoutReminderRepository{db: db}
}

// WorkoutReminder is a client's self-scheduled workout push config.
type WorkoutReminder struct {
	ID         string    `json:"id"`
	UserID     string    `json:"user_id"`
	Enabled    bool      `json:"enabled"`
	DaysOfWeek []int     `json:"days_of_week"` // 0=Sun .. 6=Sat
	RemindAt   string    `json:"remind_at"`    // HH:MM in local timezone
	Timezone   string    `json:"timezone"`
	LastSentOn *string   `json:"last_sent_on,omitempty"` // YYYY-MM-DD
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// GetByUser returns the user's reminder config, or (nil, nil) if none exists.
func (r *WorkoutReminderRepository) GetByUser(ctx context.Context, userID string) (*WorkoutReminder, error) {
	var (
		wr       WorkoutReminder
		days     string
		lastSent *time.Time
	)
	err := r.db.QueryRow(ctx, `
		SELECT id, user_id, enabled, days_of_week, remind_at, timezone, last_sent_on, created_at, updated_at
		FROM workout_reminders WHERE user_id = $1`, userID).
		Scan(&wr.ID, &wr.UserID, &wr.Enabled, &days, &wr.RemindAt, &wr.Timezone, &lastSent, &wr.CreatedAt, &wr.UpdatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	wr.DaysOfWeek = parseDays(days)
	wr.LastSentOn = formatDatePtr(lastSent)
	return &wr, nil
}

// Upsert creates or replaces the user's reminder config. Changing the config
// clears last_sent_on so an updated schedule can still fire today.
func (r *WorkoutReminderRepository) Upsert(ctx context.Context, wr *WorkoutReminder) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO workout_reminders (user_id, enabled, days_of_week, remind_at, timezone, updated_at)
		VALUES ($1, $2, $3, $4, $5, NOW())
		ON CONFLICT (user_id) DO UPDATE SET
			enabled       = EXCLUDED.enabled,
			days_of_week  = EXCLUDED.days_of_week,
			remind_at     = EXCLUDED.remind_at,
			timezone      = EXCLUDED.timezone,
			last_sent_on  = NULL,
			updated_at    = NOW()
		RETURNING id, created_at, updated_at`,
		wr.UserID, wr.Enabled, formatDays(wr.DaysOfWeek), wr.RemindAt, wr.Timezone).
		Scan(&wr.ID, &wr.CreatedAt, &wr.UpdatedAt)
}

// ListEnabled returns every enabled reminder with at least one selected day,
// for the scheduler to evaluate.
func (r *WorkoutReminderRepository) ListEnabled(ctx context.Context) ([]WorkoutReminder, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, user_id, enabled, days_of_week, remind_at, timezone, last_sent_on
		FROM workout_reminders
		WHERE enabled = TRUE AND days_of_week <> ''`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []WorkoutReminder
	for rows.Next() {
		var (
			wr       WorkoutReminder
			days     string
			lastSent *time.Time
		)
		if err := rows.Scan(&wr.ID, &wr.UserID, &wr.Enabled, &days, &wr.RemindAt, &wr.Timezone, &lastSent); err != nil {
			return nil, err
		}
		wr.DaysOfWeek = parseDays(days)
		wr.LastSentOn = formatDatePtr(lastSent)
		list = append(list, wr)
	}
	return list, rows.Err()
}

// MarkSent records the local date a reminder last fired (dedupe per day).
func (r *WorkoutReminderRepository) MarkSent(ctx context.Context, id, localDate string) error {
	_, err := r.db.Exec(ctx,
		`UPDATE workout_reminders SET last_sent_on = $2, updated_at = NOW() WHERE id = $1`,
		id, localDate)
	return err
}

// ── helpers ──────────────────────────────────────────────────────

func parseDays(s string) []int {
	s = strings.TrimSpace(s)
	if s == "" {
		return []int{}
	}
	parts := strings.Split(s, ",")
	out := make([]int, 0, len(parts))
	for _, p := range parts {
		n, err := strconv.Atoi(strings.TrimSpace(p))
		if err == nil && n >= 0 && n <= 6 {
			out = append(out, n)
		}
	}
	return out
}

func formatDays(days []int) string {
	seen := make(map[int]bool, len(days))
	parts := make([]string, 0, len(days))
	for _, d := range days {
		if d < 0 || d > 6 || seen[d] {
			continue
		}
		seen[d] = true
		parts = append(parts, strconv.Itoa(d))
	}
	return strings.Join(parts, ",")
}

func formatDatePtr(t *time.Time) *string {
	if t == nil {
		return nil
	}
	s := t.Format("2006-01-02")
	return &s
}
