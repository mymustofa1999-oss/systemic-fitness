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

type TrainingScheduleRepository struct {
	db *pgxpool.Pool
}

func NewTrainingScheduleRepository(db *pgxpool.Pool) *TrainingScheduleRepository {
	return &TrainingScheduleRepository{db: db}
}

// ════════════════════════════════════════════════════════════════════
//  Domain types
// ════════════════════════════════════════════════════════════════════

type TrainingSchedule struct {
	ID          string    `json:"id"`
	ClientID    string    `json:"client_id"`
	TrainerID   string    `json:"trainer_id"`
	DayOfWeek   int       `json:"day_of_week"`
	StartTime   string    `json:"start_time"`
	EndTime     string    `json:"end_time"`
	Location    *string   `json:"location,omitempty"`
	Notes       *string   `json:"notes,omitempty"`
	IsActive    bool      `json:"is_active"`
	CreatedBy   string    `json:"created_by"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	// Joined fields
	ClientName  *string `json:"client_name,omitempty"`
	TrainerName *string `json:"trainer_name,omitempty"`
}

type TrainingSession struct {
	ID                string     `json:"id"`
	ScheduleID        *string    `json:"schedule_id,omitempty"`
	ClientID          string     `json:"client_id"`
	TrainerID         string     `json:"trainer_id"`
	SessionDate       string     `json:"session_date"`
	StartTime         string     `json:"start_time"`
	EndTime           string     `json:"end_time"`
	Status            string     `json:"status"`
	Location          *string    `json:"location,omitempty"`
	Notes             *string    `json:"notes,omitempty"`
	IsSubstitute      bool       `json:"is_substitute"`
	OriginalTrainerID *string    `json:"original_trainer_id,omitempty"`
	SubstituteReason  *string    `json:"substitute_reason,omitempty"`
	SubstitutedBy     *string    `json:"substituted_by,omitempty"`
	SubstitutedAt     *time.Time `json:"substituted_at,omitempty"`
	CreatedBy         string     `json:"created_by"`
	CreatedAt         time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`
	// Joined fields
	ClientName          *string `json:"client_name,omitempty"`
	TrainerName         *string `json:"trainer_name,omitempty"`
	OriginalTrainerName *string `json:"original_trainer_name,omitempty"`
	SubstitutedByName   *string `json:"substituted_by_name,omitempty"`
}

// ════════════════════════════════════════════════════════════════════
//  Schedule CRUD
// ════════════════════════════════════════════════════════════════════

const scheduleCols = `s.id, s.client_id, s.trainer_id, s.day_of_week, s.start_time::text, s.end_time::text,
	s.location, s.notes, s.is_active, s.created_by, s.created_at, s.updated_at`

const scheduleJoinCols = scheduleCols + `, c.full_name AS client_name, t.full_name AS trainer_name`

const scheduleJoins = ` FROM training_schedules s
	LEFT JOIN users c ON c.id = s.client_id
	LEFT JOIN users t ON t.id = s.trainer_id`

func scanSchedule(row pgx.Row, withJoins bool) (*TrainingSchedule, error) {
	s := &TrainingSchedule{}
	var targets []any
	targets = append(targets,
		&s.ID, &s.ClientID, &s.TrainerID, &s.DayOfWeek, &s.StartTime, &s.EndTime,
		&s.Location, &s.Notes, &s.IsActive, &s.CreatedBy, &s.CreatedAt, &s.UpdatedAt,
	)
	if withJoins {
		targets = append(targets, &s.ClientName, &s.TrainerName)
	}
	err := row.Scan(targets...)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return s, err
}

func (r *TrainingScheduleRepository) Create(ctx context.Context, s *TrainingSchedule) error {
	query := `
		INSERT INTO training_schedules (client_id, trainer_id, day_of_week, start_time, end_time, location, notes, is_active, created_by)
		VALUES ($1, $2, $3, $4::time, $5::time, $6, $7, $8, $9)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		s.ClientID, s.TrainerID, s.DayOfWeek, s.StartTime, s.EndTime,
		s.Location, s.Notes, s.IsActive, s.CreatedBy,
	).Scan(&s.ID, &s.CreatedAt, &s.UpdatedAt)
}

func (r *TrainingScheduleRepository) GetByID(ctx context.Context, id string) (*TrainingSchedule, error) {
	query := `SELECT ` + scheduleJoinCols + scheduleJoins + ` WHERE s.id = $1`
	return scanSchedule(r.db.QueryRow(ctx, query, id), true)
}

func (r *TrainingScheduleRepository) Update(ctx context.Context, s *TrainingSchedule) error {
	query := `
		UPDATE training_schedules SET
			client_id = $2, trainer_id = $3, day_of_week = $4,
			start_time = $5::time, end_time = $6::time,
			location = $7, notes = $8, is_active = $9
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		s.ID, s.ClientID, s.TrainerID, s.DayOfWeek, s.StartTime, s.EndTime,
		s.Location, s.Notes, s.IsActive,
	).Scan(&s.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *TrainingScheduleRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM training_schedules WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type ScheduleListFilter struct {
	ClientID  *string
	TrainerID *string
	DayOfWeek *int
	ActiveOnly bool
}

func (r *TrainingScheduleRepository) List(ctx context.Context, params model.PaginationParams, f ScheduleListFilter) ([]TrainingSchedule, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.ClientID != nil {
		where += fmt.Sprintf(" AND s.client_id = $%d", idx)
		args = append(args, *f.ClientID)
		idx++
	}
	if f.TrainerID != nil {
		where += fmt.Sprintf(" AND s.trainer_id = $%d", idx)
		args = append(args, *f.TrainerID)
		idx++
	}
	if f.DayOfWeek != nil {
		where += fmt.Sprintf(" AND s.day_of_week = $%d", idx)
		args = append(args, *f.DayOfWeek)
		idx++
	}
	if f.ActiveOnly {
		where += " AND s.is_active = true"
	}
	if params.Search != "" {
		where += fmt.Sprintf(" AND (c.full_name ILIKE $%d OR t.full_name ILIKE $%d)", idx, idx)
		args = append(args, "%"+params.Search+"%")
		idx++
	}

	countQuery := "SELECT COUNT(*) FROM training_schedules s LEFT JOIN users c ON c.id = s.client_id LEFT JOIN users t ON t.id = s.trainer_id " + where
	var total int
	if err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s %s %s ORDER BY s.day_of_week ASC, s.start_time ASC LIMIT $%d OFFSET $%d",
		scheduleJoinCols, scheduleJoins, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	schedules := make([]TrainingSchedule, 0)
	for rows.Next() {
		var s TrainingSchedule
		if err := rows.Scan(
			&s.ID, &s.ClientID, &s.TrainerID, &s.DayOfWeek, &s.StartTime, &s.EndTime,
			&s.Location, &s.Notes, &s.IsActive, &s.CreatedBy, &s.CreatedAt, &s.UpdatedAt,
			&s.ClientName, &s.TrainerName,
		); err != nil {
			return nil, 0, err
		}
		schedules = append(schedules, s)
	}
	return schedules, total, rows.Err()
}

// ════════════════════════════════════════════════════════════════════
//  Session CRUD
// ════════════════════════════════════════════════════════════════════

const sessionCols = `s.id, s.schedule_id, s.client_id, s.trainer_id, s.session_date::text, s.start_time::text, s.end_time::text,
	s.status, s.location, s.notes, s.is_substitute, s.original_trainer_id, s.substitute_reason,
	s.substituted_by, s.substituted_at,
	s.created_by, s.created_at, s.updated_at`

const sessionJoinCols = sessionCols + `, c.full_name AS client_name, t.full_name AS trainer_name, ot.full_name AS original_trainer_name, sb.full_name AS substituted_by_name`

const sessionJoins = ` FROM training_sessions s
	LEFT JOIN users c ON c.id = s.client_id
	LEFT JOIN users t ON t.id = s.trainer_id
	LEFT JOIN users ot ON ot.id = s.original_trainer_id
	LEFT JOIN users sb ON sb.id = s.substituted_by`

func scanSession(row pgx.Row) (*TrainingSession, error) {
	s := &TrainingSession{}
	err := row.Scan(
		&s.ID, &s.ScheduleID, &s.ClientID, &s.TrainerID, &s.SessionDate, &s.StartTime, &s.EndTime,
		&s.Status, &s.Location, &s.Notes, &s.IsSubstitute, &s.OriginalTrainerID, &s.SubstituteReason,
		&s.SubstitutedBy, &s.SubstitutedAt,
		&s.CreatedBy, &s.CreatedAt, &s.UpdatedAt,
		&s.ClientName, &s.TrainerName, &s.OriginalTrainerName, &s.SubstitutedByName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return s, err
}

func (r *TrainingScheduleRepository) CreateSession(ctx context.Context, s *TrainingSession) error {
	query := `
		INSERT INTO training_sessions (schedule_id, client_id, trainer_id, session_date, start_time, end_time,
			status, location, notes, is_substitute, original_trainer_id, substitute_reason, created_by)
		VALUES ($1, $2, $3, $4::date, $5::time, $6::time, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		s.ScheduleID, s.ClientID, s.TrainerID, s.SessionDate, s.StartTime, s.EndTime,
		s.Status, s.Location, s.Notes, s.IsSubstitute, s.OriginalTrainerID, s.SubstituteReason, s.CreatedBy,
	).Scan(&s.ID, &s.CreatedAt, &s.UpdatedAt)
}

func (r *TrainingScheduleRepository) GetSessionByID(ctx context.Context, id string) (*TrainingSession, error) {
	query := `SELECT ` + sessionJoinCols + sessionJoins + ` WHERE s.id = $1`
	return scanSession(r.db.QueryRow(ctx, query, id))
}

func (r *TrainingScheduleRepository) UpdateSession(ctx context.Context, s *TrainingSession) error {
	query := `
		UPDATE training_sessions SET
			trainer_id = $2, session_date = $3::date, start_time = $4::time, end_time = $5::time,
			status = $6, location = $7, notes = $8,
			is_substitute = $9, original_trainer_id = $10, substitute_reason = $11
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		s.ID, s.TrainerID, s.SessionDate, s.StartTime, s.EndTime,
		s.Status, s.Location, s.Notes,
		s.IsSubstitute, s.OriginalTrainerID, s.SubstituteReason,
	).Scan(&s.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *TrainingScheduleRepository) DeleteSession(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM training_sessions WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// SubstituteTrainer replaces a trainer for a specific session and records
// audit info (which consultant did it + when). Returns the original
// trainer id (the one being replaced) so callers can notify them.
func (r *TrainingScheduleRepository) SubstituteTrainer(ctx context.Context, sessionID, substituteTrainerID, reason, substitutedByID string) (originalTrainerID string, err error) {
	query := `
		UPDATE training_sessions SET
			original_trainer_id = trainer_id,
			trainer_id = $2,
			is_substitute = true,
			substitute_reason = $3,
			status = 'substituted',
			substituted_by = $4,
			substituted_at = NOW()
		WHERE id = $1 AND is_substitute = false
		RETURNING original_trainer_id`
	err = r.db.QueryRow(ctx, query, sessionID, substituteTrainerID, reason, substitutedByID).Scan(&originalTrainerID)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", ErrNotFound
	}
	return originalTrainerID, err
}

type SessionListFilter struct {
	ClientID   *string
	TrainerID  *string
	DateFrom   *string
	DateTo     *string
	Status     *string
	ScheduleID *string
}

func (r *TrainingScheduleRepository) ListSessions(ctx context.Context, params model.PaginationParams, f SessionListFilter) ([]TrainingSession, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.ClientID != nil {
		where += fmt.Sprintf(" AND s.client_id = $%d", idx)
		args = append(args, *f.ClientID)
		idx++
	}
	if f.TrainerID != nil {
		where += fmt.Sprintf(" AND s.trainer_id = $%d", idx)
		args = append(args, *f.TrainerID)
		idx++
	}
	if f.DateFrom != nil {
		where += fmt.Sprintf(" AND s.session_date >= $%d::date", idx)
		args = append(args, *f.DateFrom)
		idx++
	}
	if f.DateTo != nil {
		where += fmt.Sprintf(" AND s.session_date <= $%d::date", idx)
		args = append(args, *f.DateTo)
		idx++
	}
	if f.Status != nil {
		where += fmt.Sprintf(" AND s.status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	if f.ScheduleID != nil {
		where += fmt.Sprintf(" AND s.schedule_id = $%d", idx)
		args = append(args, *f.ScheduleID)
		idx++
	}
	if params.Search != "" {
		where += fmt.Sprintf(" AND (c.full_name ILIKE $%d OR t.full_name ILIKE $%d)", idx, idx)
		args = append(args, "%"+params.Search+"%")
		idx++
	}

	countQuery := "SELECT COUNT(*) FROM training_sessions s LEFT JOIN users c ON c.id = s.client_id LEFT JOIN users t ON t.id = s.trainer_id LEFT JOIN users ot ON ot.id = s.original_trainer_id LEFT JOIN users sb ON sb.id = s.substituted_by " + where
	var total int
	if err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s %s %s ORDER BY s.session_date ASC, s.start_time ASC LIMIT $%d OFFSET $%d",
		sessionJoinCols, sessionJoins, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	sessions := make([]TrainingSession, 0)
	for rows.Next() {
		var s TrainingSession
		if err := rows.Scan(
			&s.ID, &s.ScheduleID, &s.ClientID, &s.TrainerID, &s.SessionDate, &s.StartTime, &s.EndTime,
			&s.Status, &s.Location, &s.Notes, &s.IsSubstitute, &s.OriginalTrainerID, &s.SubstituteReason,
			&s.SubstitutedBy, &s.SubstitutedAt,
			&s.CreatedBy, &s.CreatedAt, &s.UpdatedAt,
			&s.ClientName, &s.TrainerName, &s.OriginalTrainerName, &s.SubstitutedByName,
		); err != nil {
			return nil, 0, err
		}
		sessions = append(sessions, s)
	}
	return sessions, total, rows.Err()
}
