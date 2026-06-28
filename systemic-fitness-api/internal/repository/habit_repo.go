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

type HabitRepository struct {
	db *pgxpool.Pool
}

func NewHabitRepository(db *pgxpool.Pool) *HabitRepository {
	return &HabitRepository{db: db}
}

// ─── Habit Folder ──────────────────────────────────────────────────

type HabitFolder struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	SortOrder int       `json:"sort_order"`
	CreatedBy *string   `json:"created_by,omitempty"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (r *HabitRepository) CreateFolder(ctx context.Context, f *HabitFolder) error {
	query := `
		INSERT INTO habit_folders (name, sort_order, created_by)
		VALUES ($1, $2, $3)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query, f.Name, f.SortOrder, f.CreatedBy).
		Scan(&f.ID, &f.CreatedAt, &f.UpdatedAt)
}

func (r *HabitRepository) ListFolders(ctx context.Context) ([]HabitFolder, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, name, sort_order, created_by, created_at, updated_at
		FROM habit_folders ORDER BY sort_order, name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var folders []HabitFolder
	for rows.Next() {
		var f HabitFolder
		if err := rows.Scan(&f.ID, &f.Name, &f.SortOrder, &f.CreatedBy, &f.CreatedAt, &f.UpdatedAt); err != nil {
			return nil, err
		}
		folders = append(folders, f)
	}
	return folders, rows.Err()
}

func (r *HabitRepository) UpdateFolder(ctx context.Context, f *HabitFolder) error {
	query := `UPDATE habit_folders SET name = $2, sort_order = $3 WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query, f.ID, f.Name, f.SortOrder).Scan(&f.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *HabitRepository) DeleteFolder(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM habit_folders WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ─── Habits ────────────────────────────────────────────────────────

type Habit struct {
	ID          string    `json:"id"`
	FolderID    *string   `json:"folder_id,omitempty"`
	Name        string    `json:"name"`
	Description *string   `json:"description,omitempty"`
	Icon        *string   `json:"icon,omitempty"`
	IsSystem    bool      `json:"is_system"`
	CreatedBy   *string   `json:"created_by,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

const habitCols = `id, folder_id, name, description, icon, is_system, created_by, created_at, updated_at`

func scanHabit(row pgx.Row) (*Habit, error) {
	h := &Habit{}
	err := row.Scan(&h.ID, &h.FolderID, &h.Name, &h.Description, &h.Icon,
		&h.IsSystem, &h.CreatedBy, &h.CreatedAt, &h.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return h, err
}

func (r *HabitRepository) Create(ctx context.Context, h *Habit) error {
	query := `
		INSERT INTO habits (folder_id, name, description, icon, is_system, created_by)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		h.FolderID, h.Name, h.Description, h.Icon, h.IsSystem, h.CreatedBy,
	).Scan(&h.ID, &h.CreatedAt, &h.UpdatedAt)
}

func (r *HabitRepository) GetByID(ctx context.Context, id string) (*Habit, error) {
	return scanHabit(r.db.QueryRow(ctx, `SELECT `+habitCols+` FROM habits WHERE id = $1`, id))
}

func (r *HabitRepository) Update(ctx context.Context, h *Habit) error {
	query := `
		UPDATE habits SET folder_id = $2, name = $3, description = $4, icon = $5
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query, h.ID, h.FolderID, h.Name, h.Description, h.Icon).Scan(&h.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *HabitRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM habits WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type HabitListFilter struct {
	FolderID *string
	Search   string
}

func (r *HabitRepository) List(ctx context.Context, params model.PaginationParams, f HabitListFilter) ([]Habit, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.FolderID != nil {
		where += fmt.Sprintf(" AND folder_id = $%d", idx)
		args = append(args, *f.FolderID)
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND name ILIKE $%d", idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM habits "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM habits %s ORDER BY name ASC LIMIT $%d OFFSET $%d",
		habitCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	habits := make([]Habit, 0)
	for rows.Next() {
		var h Habit
		if err := rows.Scan(&h.ID, &h.FolderID, &h.Name, &h.Description, &h.Icon,
			&h.IsSystem, &h.CreatedBy, &h.CreatedAt, &h.UpdatedAt); err != nil {
			return nil, 0, err
		}
		habits = append(habits, h)
	}
	return habits, total, rows.Err()
}

// ─── Habit Logs ────────────────────────────────────────────────────

type HabitLog struct {
	ID        string `json:"id"`
	UserID    string `json:"user_id"`
	HabitID   string `json:"habit_id"`
	LoggedAt  string `json:"logged_at"`
	Completed bool   `json:"completed"`
	Notes     *string `json:"notes,omitempty"`
}

func (r *HabitRepository) LogHabit(ctx context.Context, log *HabitLog) error {
	query := `
		INSERT INTO habit_logs (user_id, habit_id, logged_at, completed, notes)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (user_id, habit_id, logged_at)
		DO UPDATE SET completed = EXCLUDED.completed, notes = EXCLUDED.notes
		RETURNING id`
	return r.db.QueryRow(ctx, query,
		log.UserID, log.HabitID, log.LoggedAt, log.Completed, log.Notes,
	).Scan(&log.ID)
}

func (r *HabitRepository) GetUserHabitLogs(ctx context.Context, userID, startDate, endDate string) ([]HabitLog, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, user_id, habit_id, logged_at, completed, notes
		FROM habit_logs
		WHERE user_id = $1 AND logged_at >= $2::DATE AND logged_at <= $3::DATE
		ORDER BY logged_at DESC`, userID, startDate, endDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var logs []HabitLog
	for rows.Next() {
		var l HabitLog
		if err := rows.Scan(&l.ID, &l.UserID, &l.HabitID, &l.LoggedAt, &l.Completed, &l.Notes); err != nil {
			return nil, err
		}
		logs = append(logs, l)
	}
	return logs, rows.Err()
}
