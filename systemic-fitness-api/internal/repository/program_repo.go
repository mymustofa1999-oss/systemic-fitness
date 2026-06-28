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

type ProgramRepository struct {
	db *pgxpool.Pool
}

func NewProgramRepository(db *pgxpool.Pool) *ProgramRepository {
	return &ProgramRepository{db: db}
}

type Program struct {
	ID            string    `json:"id"`
	Name          string    `json:"name"`
	Description   *string   `json:"description,omitempty"`
	DurationWeeks int       `json:"duration_weeks"`
	Difficulty    string    `json:"difficulty"`
	Goal          string    `json:"goal"`
	CreatedBy     *string   `json:"created_by,omitempty"`
	IsTemplate    bool      `json:"is_template"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type ProgramDay struct {
	ID          string  `json:"id"`
	ProgramID   string  `json:"program_id"`
	WeekNumber  int     `json:"week_number"`
	DayOfWeek   int     `json:"day_of_week"`
	WorkoutID   *string `json:"workout_id,omitempty"`
	WorkoutName *string `json:"workout_name,omitempty"` // populated via join
	IsRestDay   bool    `json:"is_rest_day"`
}

type UserProgram struct {
	ID          string    `json:"id"`
	UserID      string    `json:"user_id"`
	ProgramID   string    `json:"program_id"`
	ProgramName *string   `json:"program_name,omitempty"`
	AssignedBy  *string   `json:"assigned_by,omitempty"`
	StartDate   string    `json:"start_date"`
	EndDate     *string   `json:"end_date,omitempty"`
	Status      string    `json:"status"`
	CurrentWeek int       `json:"current_week"`
	CurrentDay  int       `json:"current_day"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// ProgramDetail combines a program with its full schedule.
type ProgramDetail struct {
	Program
	Days []ProgramDay `json:"days"`
}

const programCols = `id, name, description, duration_weeks, difficulty, goal,
	created_by, is_template, created_at, updated_at`

func (r *ProgramRepository) Create(ctx context.Context, p *Program) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO programs (name, description, duration_weeks, difficulty, goal, created_by, is_template)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at`,
		p.Name, p.Description, p.DurationWeeks, p.Difficulty,
		p.Goal, p.CreatedBy, p.IsTemplate,
	).Scan(&p.ID, &p.CreatedAt, &p.UpdatedAt)
}

func (r *ProgramRepository) GetByID(ctx context.Context, id string) (*Program, error) {
	p := &Program{}
	err := r.db.QueryRow(ctx, `SELECT `+programCols+` FROM programs WHERE id = $1`, id).Scan(
		&p.ID, &p.Name, &p.Description, &p.DurationWeeks, &p.Difficulty,
		&p.Goal, &p.CreatedBy, &p.IsTemplate, &p.CreatedAt, &p.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return p, err
}

// GetDetail returns a program with its full weekly schedule + workout names.
func (r *ProgramRepository) GetDetail(ctx context.Context, id string) (*ProgramDetail, error) {
	p, err := r.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT pd.id, pd.program_id, pd.week_number, pd.day_of_week,
		       pd.workout_id, w.name, pd.is_rest_day
		FROM program_days pd
		LEFT JOIN workouts w ON w.id = pd.workout_id
		WHERE pd.program_id = $1
		ORDER BY pd.week_number, pd.day_of_week`, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	days := make([]ProgramDay, 0)
	for rows.Next() {
		var d ProgramDay
		if err := rows.Scan(&d.ID, &d.ProgramID, &d.WeekNumber, &d.DayOfWeek,
			&d.WorkoutID, &d.WorkoutName, &d.IsRestDay); err != nil {
			return nil, err
		}
		days = append(days, d)
	}

	return &ProgramDetail{Program: *p, Days: days}, rows.Err()
}

func (r *ProgramRepository) Update(ctx context.Context, p *Program) error {
	err := r.db.QueryRow(ctx, `
		UPDATE programs SET name=$2, description=$3, duration_weeks=$4, difficulty=$5, goal=$6
		WHERE id=$1 RETURNING updated_at`,
		p.ID, p.Name, p.Description, p.DurationWeeks, p.Difficulty, p.Goal,
	).Scan(&p.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

type ProgramListFilter struct {
	Difficulty *string
	Goal       *string
	IsTemplate *bool
	Search     string
}

func (r *ProgramRepository) List(ctx context.Context, params model.PaginationParams, f ProgramListFilter) ([]Program, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Difficulty != nil {
		where += fmt.Sprintf(" AND difficulty = $%d", idx)
		args = append(args, *f.Difficulty)
		idx++
	}
	if f.Goal != nil {
		where += fmt.Sprintf(" AND goal = $%d", idx)
		args = append(args, *f.Goal)
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
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM programs "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM programs %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		programCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	programs := make([]Program, 0)
	for rows.Next() {
		var p Program
		if err := rows.Scan(
			&p.ID, &p.Name, &p.Description, &p.DurationWeeks, &p.Difficulty,
			&p.Goal, &p.CreatedBy, &p.IsTemplate, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, 0, err
		}
		programs = append(programs, p)
	}
	return programs, total, rows.Err()
}

func (r *ProgramRepository) ListTemplates(ctx context.Context) ([]Program, error) {
	rows, err := r.db.Query(ctx, `
		SELECT `+programCols+` FROM programs
		WHERE is_template = TRUE ORDER BY difficulty, name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	programs := make([]Program, 0)
	for rows.Next() {
		var p Program
		if err := rows.Scan(
			&p.ID, &p.Name, &p.Description, &p.DurationWeeks, &p.Difficulty,
			&p.Goal, &p.CreatedBy, &p.IsTemplate, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, err
		}
		programs = append(programs, p)
	}
	return programs, rows.Err()
}

// ── Program Days ────────────────────────────────────────────────

type ProgramDayInput struct {
	WeekNumber int
	DayOfWeek  int
	WorkoutID  *string
	IsRestDay  bool
}

// ReplaceDays deletes all days for a program and inserts new ones.
func (r *ProgramRepository) ReplaceDays(ctx context.Context, programID string, days []ProgramDayInput) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	if _, err := tx.Exec(ctx, `DELETE FROM program_days WHERE program_id = $1`, programID); err != nil {
		return err
	}

	for _, d := range days {
		_, err := tx.Exec(ctx, `
			INSERT INTO program_days (program_id, week_number, day_of_week, workout_id, is_rest_day)
			VALUES ($1, $2, $3, $4, $5)`,
			programID, d.WeekNumber, d.DayOfWeek, d.WorkoutID, d.IsRestDay)
		if err != nil {
			return fmt.Errorf("insert day w%dd%d: %w", d.WeekNumber, d.DayOfWeek, err)
		}
	}

	return tx.Commit(ctx)
}

func (r *ProgramRepository) GetDays(ctx context.Context, programID string) ([]ProgramDay, error) {
	rows, err := r.db.Query(ctx, `
		SELECT pd.id, pd.program_id, pd.week_number, pd.day_of_week,
		       pd.workout_id, w.name, pd.is_rest_day
		FROM program_days pd
		LEFT JOIN workouts w ON w.id = pd.workout_id
		WHERE pd.program_id = $1
		ORDER BY pd.week_number, pd.day_of_week`, programID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	days := make([]ProgramDay, 0)
	for rows.Next() {
		var d ProgramDay
		if err := rows.Scan(&d.ID, &d.ProgramID, &d.WeekNumber, &d.DayOfWeek,
			&d.WorkoutID, &d.WorkoutName, &d.IsRestDay); err != nil {
			return nil, err
		}
		days = append(days, d)
	}
	return days, rows.Err()
}

// ── User Programs (assignments) ─────────────────────────────────

func (r *ProgramRepository) AssignToUser(ctx context.Context, up *UserProgram) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO user_programs (user_id, program_id, assigned_by, start_date, end_date, status)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at, updated_at`,
		up.UserID, up.ProgramID, up.AssignedBy, up.StartDate, up.EndDate, up.Status,
	).Scan(&up.ID, &up.CreatedAt, &up.UpdatedAt)
}

func (r *ProgramRepository) GetUserProgram(ctx context.Context, userProgramID string) (*UserProgram, error) {
	up := &UserProgram{}
	err := r.db.QueryRow(ctx, `
		SELECT up.id, up.user_id, up.program_id, p.name, up.assigned_by,
		       up.start_date, up.end_date, up.status,
		       up.current_week, up.current_day, up.created_at, up.updated_at
		FROM user_programs up
		JOIN programs p ON p.id = up.program_id
		WHERE up.id = $1`, userProgramID,
	).Scan(&up.ID, &up.UserID, &up.ProgramID, &up.ProgramName, &up.AssignedBy,
		&up.StartDate, &up.EndDate, &up.Status,
		&up.CurrentWeek, &up.CurrentDay, &up.CreatedAt, &up.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return up, err
}

func (r *ProgramRepository) AdvanceWeek(ctx context.Context, userProgramID string, newWeek int) error {
	_, err := r.db.Exec(ctx,
		`UPDATE user_programs SET current_week = $2, current_day = 0 WHERE id = $1`,
		userProgramID, newWeek)
	return err
}

func (r *ProgramRepository) CompleteUserProgram(ctx context.Context, userProgramID string) error {
	_, err := r.db.Exec(ctx,
		`UPDATE user_programs SET status = 'completed' WHERE id = $1`,
		userProgramID)
	return err
}

// GetActiveUserProgram returns the active program assignment for a user, if any.
func (r *ProgramRepository) GetActiveUserProgram(ctx context.Context, userID string) (*UserProgram, error) {
	up := &UserProgram{}
	err := r.db.QueryRow(ctx, `
		SELECT up.id, up.user_id, up.program_id, p.name, up.assigned_by,
		       up.start_date, up.end_date, up.status,
		       up.current_week, up.current_day, up.created_at, up.updated_at
		FROM user_programs up
		JOIN programs p ON p.id = up.program_id
		WHERE up.user_id = $1 AND up.status = 'active'
		ORDER BY up.created_at DESC LIMIT 1`, userID,
	).Scan(&up.ID, &up.UserID, &up.ProgramID, &up.ProgramName, &up.AssignedBy,
		&up.StartDate, &up.EndDate, &up.Status,
		&up.CurrentWeek, &up.CurrentDay, &up.CreatedAt, &up.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return up, err
}
