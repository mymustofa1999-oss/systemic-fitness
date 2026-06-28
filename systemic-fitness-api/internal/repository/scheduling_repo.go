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

type SchedulingRepository struct {
	db *pgxpool.Pool
}

func NewSchedulingRepository(db *pgxpool.Pool) *SchedulingRepository {
	return &SchedulingRepository{db: db}
}

// ─── Event Types ───────────────────────────────────────────────────

type EventType struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description *string   `json:"description,omitempty"`
	Category    string    `json:"category"`
	DurationMin int       `json:"duration_min"`
	Color       *string   `json:"color,omitempty"`
	IsActive    bool      `json:"is_active"`
	CreatedBy   *string   `json:"created_by,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

func (r *SchedulingRepository) CreateEventType(ctx context.Context, et *EventType) error {
	query := `
		INSERT INTO event_types (name, description, category, duration_min, color, is_active, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		et.Name, et.Description, et.Category, et.DurationMin, et.Color, et.IsActive, et.CreatedBy,
	).Scan(&et.ID, &et.CreatedAt, &et.UpdatedAt)
}

func (r *SchedulingRepository) GetEventType(ctx context.Context, id string) (*EventType, error) {
	et := &EventType{}
	err := r.db.QueryRow(ctx, `
		SELECT id, name, description, category, duration_min, color, is_active, created_by, created_at, updated_at
		FROM event_types WHERE id = $1`, id).
		Scan(&et.ID, &et.Name, &et.Description, &et.Category, &et.DurationMin,
			&et.Color, &et.IsActive, &et.CreatedBy, &et.CreatedAt, &et.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return et, err
}

func (r *SchedulingRepository) UpdateEventType(ctx context.Context, et *EventType) error {
	query := `
		UPDATE event_types SET name = $2, description = $3, category = $4,
			duration_min = $5, color = $6, is_active = $7
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		et.ID, et.Name, et.Description, et.Category, et.DurationMin, et.Color, et.IsActive,
	).Scan(&et.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *SchedulingRepository) DeleteEventType(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM event_types WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *SchedulingRepository) ListEventTypes(ctx context.Context) ([]EventType, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, name, description, category, duration_min, color, is_active, created_by, created_at, updated_at
		FROM event_types ORDER BY name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var types []EventType
	for rows.Next() {
		var et EventType
		if err := rows.Scan(&et.ID, &et.Name, &et.Description, &et.Category, &et.DurationMin,
			&et.Color, &et.IsActive, &et.CreatedBy, &et.CreatedAt, &et.UpdatedAt); err != nil {
			return nil, err
		}
		types = append(types, et)
	}
	return types, rows.Err()
}

// ─── Calendar Events ───────────────────────────────────────────────

type CalendarEvent struct {
	ID              string    `json:"id"`
	EventTypeID     *string   `json:"event_type_id,omitempty"`
	Title           string    `json:"title"`
	Description     *string   `json:"description,omitempty"`
	Category        string    `json:"category"`
	Status          string    `json:"status"`
	StartAt         time.Time `json:"start_at"`
	EndAt           time.Time `json:"end_at"`
	Location        *string   `json:"location,omitempty"`
	MaxParticipants *int      `json:"max_participants,omitempty"`
	CreatedBy       string    `json:"created_by"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

const calendarEventCols = `id, event_type_id, title, description, category, status,
	start_at, end_at, location, max_participants, created_by, created_at, updated_at`

func scanCalendarEvent(row pgx.Row) (*CalendarEvent, error) {
	e := &CalendarEvent{}
	err := row.Scan(&e.ID, &e.EventTypeID, &e.Title, &e.Description, &e.Category,
		&e.Status, &e.StartAt, &e.EndAt, &e.Location, &e.MaxParticipants,
		&e.CreatedBy, &e.CreatedAt, &e.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return e, err
}

func (r *SchedulingRepository) CreateEvent(ctx context.Context, e *CalendarEvent) error {
	query := `
		INSERT INTO calendar_events (event_type_id, title, description, category, status,
			start_at, end_at, location, max_participants, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		e.EventTypeID, e.Title, e.Description, e.Category, e.Status,
		e.StartAt, e.EndAt, e.Location, e.MaxParticipants, e.CreatedBy,
	).Scan(&e.ID, &e.CreatedAt, &e.UpdatedAt)
}

func (r *SchedulingRepository) GetEvent(ctx context.Context, id string) (*CalendarEvent, error) {
	return scanCalendarEvent(r.db.QueryRow(ctx,
		`SELECT `+calendarEventCols+` FROM calendar_events WHERE id = $1`, id))
}

func (r *SchedulingRepository) UpdateEvent(ctx context.Context, e *CalendarEvent) error {
	query := `
		UPDATE calendar_events SET
			event_type_id = $2, title = $3, description = $4, category = $5, status = $6,
			start_at = $7, end_at = $8, location = $9, max_participants = $10
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		e.ID, e.EventTypeID, e.Title, e.Description, e.Category, e.Status,
		e.StartAt, e.EndAt, e.Location, e.MaxParticipants,
	).Scan(&e.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *SchedulingRepository) DeleteEvent(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM calendar_events WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type EventListFilter struct {
	Category      *string
	Status        *string
	StartFrom     *string
	StartTo       *string
	CreatedBy     *string
	ParticipantID *string // filter events where this user is a participant
}

func (r *SchedulingRepository) ListEvents(ctx context.Context, params model.PaginationParams, f EventListFilter) ([]CalendarEvent, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Category != nil {
		where += fmt.Sprintf(" AND category = $%d", idx)
		args = append(args, *f.Category)
		idx++
	}
	if f.Status != nil {
		where += fmt.Sprintf(" AND status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	if f.StartFrom != nil {
		where += fmt.Sprintf(" AND start_at >= $%d::TIMESTAMPTZ", idx)
		args = append(args, *f.StartFrom)
		idx++
	}
	if f.StartTo != nil {
		where += fmt.Sprintf(" AND start_at <= $%d::TIMESTAMPTZ", idx)
		args = append(args, *f.StartTo)
		idx++
	}
	if f.CreatedBy != nil {
		where += fmt.Sprintf(" AND created_by = $%d", idx)
		args = append(args, *f.CreatedBy)
		idx++
	}
	if f.ParticipantID != nil {
		where += fmt.Sprintf(" AND (created_by = $%d OR id IN (SELECT event_id FROM event_participants WHERE user_id = $%d))", idx, idx)
		args = append(args, *f.ParticipantID)
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM calendar_events "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM calendar_events %s ORDER BY start_at ASC LIMIT $%d OFFSET $%d",
		calendarEventCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	events := make([]CalendarEvent, 0)
	for rows.Next() {
		var e CalendarEvent
		if err := rows.Scan(&e.ID, &e.EventTypeID, &e.Title, &e.Description, &e.Category,
			&e.Status, &e.StartAt, &e.EndAt, &e.Location, &e.MaxParticipants,
			&e.CreatedBy, &e.CreatedAt, &e.UpdatedAt); err != nil {
			return nil, 0, err
		}
		events = append(events, e)
	}
	return events, total, rows.Err()
}

// ─── Event Participants ────────────────────────────────────────────

type EventParticipant struct {
	ID         string    `json:"id"`
	EventID    string    `json:"event_id"`
	UserID     string    `json:"user_id"`
	RSVPStatus string    `json:"rsvp_status"`
	JoinedAt   time.Time `json:"joined_at"`
}

func (r *SchedulingRepository) AddParticipant(ctx context.Context, ep *EventParticipant) error {
	query := `
		INSERT INTO event_participants (event_id, user_id, rsvp_status)
		VALUES ($1, $2, $3)
		ON CONFLICT (event_id, user_id) DO UPDATE SET rsvp_status = EXCLUDED.rsvp_status
		RETURNING id, joined_at`
	return r.db.QueryRow(ctx, query, ep.EventID, ep.UserID, ep.RSVPStatus).
		Scan(&ep.ID, &ep.JoinedAt)
}

func (r *SchedulingRepository) ListParticipants(ctx context.Context, eventID string) ([]EventParticipant, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, event_id, user_id, rsvp_status, joined_at
		FROM event_participants WHERE event_id = $1 ORDER BY joined_at`, eventID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var participants []EventParticipant
	for rows.Next() {
		var ep EventParticipant
		if err := rows.Scan(&ep.ID, &ep.EventID, &ep.UserID, &ep.RSVPStatus, &ep.JoinedAt); err != nil {
			return nil, err
		}
		participants = append(participants, ep)
	}
	return participants, rows.Err()
}

func (r *SchedulingRepository) RemoveParticipant(ctx context.Context, eventID, userID string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM event_participants WHERE event_id = $1 AND user_id = $2`,
		eventID, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ─── Trainer Availability ──────────────────────────────────────────

type TrainerAvailability struct {
	ID        string `json:"id"`
	TrainerID string `json:"trainer_id"`
	DayOfWeek int    `json:"day_of_week"`
	StartTime string `json:"start_time"`
	EndTime   string `json:"end_time"`
	IsActive  bool   `json:"is_active"`
}

func (r *SchedulingRepository) SetAvailability(ctx context.Context, a *TrainerAvailability) error {
	query := `
		INSERT INTO trainer_availability (trainer_id, day_of_week, start_time, end_time, is_active)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id`
	return r.db.QueryRow(ctx, query,
		a.TrainerID, a.DayOfWeek, a.StartTime, a.EndTime, a.IsActive,
	).Scan(&a.ID)
}

func (r *SchedulingRepository) ListAvailability(ctx context.Context, trainerID string) ([]TrainerAvailability, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, trainer_id, day_of_week, start_time, end_time, is_active
		FROM trainer_availability WHERE trainer_id = $1
		ORDER BY day_of_week, start_time`, trainerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var slots []TrainerAvailability
	for rows.Next() {
		var a TrainerAvailability
		if err := rows.Scan(&a.ID, &a.TrainerID, &a.DayOfWeek, &a.StartTime, &a.EndTime, &a.IsActive); err != nil {
			return nil, err
		}
		slots = append(slots, a)
	}
	return slots, rows.Err()
}

func (r *SchedulingRepository) DeleteAvailability(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM trainer_availability WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}
