package repository

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type AutomationRepository struct {
	db *pgxpool.Pool
}

func NewAutomationRepository(db *pgxpool.Pool) *AutomationRepository {
	return &AutomationRepository{db: db}
}

type Automation struct {
	ID            string          `json:"id"`
	Name          string          `json:"name"`
	Description   *string         `json:"description,omitempty"`
	TriggerType   string          `json:"trigger_type"`
	TriggerConfig json.RawMessage `json:"trigger_config"`
	ActionType    string          `json:"action_type"`
	ActionConfig  json.RawMessage `json:"action_config"`
	IsActive      bool            `json:"is_active"`
	CreatedBy     *string         `json:"created_by,omitempty"`
	CreatedAt     time.Time       `json:"created_at"`
	UpdatedAt     time.Time       `json:"updated_at"`
}

type AutomationLog struct {
	ID           string          `json:"id"`
	AutomationID string          `json:"automation_id"`
	UserID       *string         `json:"user_id,omitempty"`
	TriggeredAt  time.Time       `json:"triggered_at"`
	Status       string          `json:"status"` // success, failed, skipped
	Result       json.RawMessage `json:"result,omitempty"`
	ErrorMessage *string         `json:"error_message,omitempty"`
}

const automationCols = `id, name, description, trigger_type, trigger_config,
	action_type, action_config, is_active, created_by, created_at, updated_at`

func scanAutomation(row pgx.Row) (*Automation, error) {
	a := &Automation{}
	err := row.Scan(&a.ID, &a.Name, &a.Description, &a.TriggerType, &a.TriggerConfig,
		&a.ActionType, &a.ActionConfig, &a.IsActive, &a.CreatedBy, &a.CreatedAt, &a.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return a, err
}

func (r *AutomationRepository) Create(ctx context.Context, a *Automation) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO automations (name, description, trigger_type, trigger_config, action_type, action_config, is_active, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at, updated_at`,
		a.Name, a.Description, a.TriggerType, a.TriggerConfig,
		a.ActionType, a.ActionConfig, a.IsActive, a.CreatedBy,
	).Scan(&a.ID, &a.CreatedAt, &a.UpdatedAt)
}

func (r *AutomationRepository) GetByID(ctx context.Context, id string) (*Automation, error) {
	return scanAutomation(r.db.QueryRow(ctx,
		`SELECT `+automationCols+` FROM automations WHERE id = $1`, id))
}

func (r *AutomationRepository) Update(ctx context.Context, a *Automation) error {
	err := r.db.QueryRow(ctx, `
		UPDATE automations SET name=$2, description=$3, trigger_type=$4, trigger_config=$5,
			action_type=$6, action_config=$7, is_active=$8
		WHERE id=$1 RETURNING updated_at`,
		a.ID, a.Name, a.Description, a.TriggerType, a.TriggerConfig,
		a.ActionType, a.ActionConfig, a.IsActive,
	).Scan(&a.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *AutomationRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM automations WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type AutomationListFilter struct {
	TriggerType *string
	IsActive    *bool
	Search      string
}

func (r *AutomationRepository) List(ctx context.Context, params model.PaginationParams, f AutomationListFilter) ([]Automation, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.TriggerType != nil {
		where += fmt.Sprintf(" AND trigger_type = $%d", idx)
		args = append(args, *f.TriggerType)
		idx++
	}
	if f.IsActive != nil {
		where += fmt.Sprintf(" AND is_active = $%d", idx)
		args = append(args, *f.IsActive)
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND name ILIKE $%d", idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM automations "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM automations %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		automationCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	automations := make([]Automation, 0)
	for rows.Next() {
		var a Automation
		if err := rows.Scan(&a.ID, &a.Name, &a.Description, &a.TriggerType, &a.TriggerConfig,
			&a.ActionType, &a.ActionConfig, &a.IsActive, &a.CreatedBy, &a.CreatedAt, &a.UpdatedAt); err != nil {
			return nil, 0, err
		}
		automations = append(automations, a)
	}
	return automations, total, rows.Err()
}

func (r *AutomationRepository) GetActiveByTrigger(ctx context.Context, triggerType string) ([]Automation, error) {
	rows, err := r.db.Query(ctx,
		`SELECT `+automationCols+` FROM automations WHERE trigger_type = $1 AND is_active = TRUE`,
		triggerType)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var automations []Automation
	for rows.Next() {
		var a Automation
		if err := rows.Scan(&a.ID, &a.Name, &a.Description, &a.TriggerType, &a.TriggerConfig,
			&a.ActionType, &a.ActionConfig, &a.IsActive, &a.CreatedBy, &a.CreatedAt, &a.UpdatedAt); err != nil {
			return nil, err
		}
		automations = append(automations, a)
	}
	return automations, rows.Err()
}

// ── Automation Logs ─────────────────────────────────────────────

func (r *AutomationRepository) CreateLog(ctx context.Context, log *AutomationLog) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO automation_logs (automation_id, user_id, status, result, error_message)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, triggered_at`,
		log.AutomationID, log.UserID, log.Status, log.Result, log.ErrorMessage,
	).Scan(&log.ID, &log.TriggeredAt)
}

func (r *AutomationRepository) GetLogs(ctx context.Context, automationID string, params model.PaginationParams) ([]AutomationLog, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM automation_logs WHERE automation_id = $1`, automationID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT id, automation_id, user_id, triggered_at, status, result, error_message
		FROM automation_logs WHERE automation_id = $1
		ORDER BY triggered_at DESC LIMIT $2 OFFSET $3`,
		automationID, params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	logs := make([]AutomationLog, 0)
	for rows.Next() {
		var l AutomationLog
		if err := rows.Scan(&l.ID, &l.AutomationID, &l.UserID, &l.TriggeredAt,
			&l.Status, &l.Result, &l.ErrorMessage); err != nil {
			return nil, 0, err
		}
		logs = append(logs, l)
	}
	return logs, total, rows.Err()
}

// ── Inactive Users Query ────────────────────────────────────────

// GetInactiveUserIDs returns user IDs that have no progress_logs in the last N days.
func (r *AutomationRepository) GetInactiveUserIDs(ctx context.Context, inactiveDays int) ([]string, error) {
	rows, err := r.db.Query(ctx, `
		SELECT u.id FROM users u
		WHERE u.status = 'active' AND u.role = 'client' AND u.deleted_at IS NULL
		  AND NOT EXISTS (
			SELECT 1 FROM progress_logs pl
			WHERE pl.user_id = u.id
			  AND pl.logged_at >= NOW() - ($1 || ' days')::INTERVAL
		  )`, inactiveDays)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}

// GetMilestoneUsers returns users who just reached exactly N total workouts.
func (r *AutomationRepository) GetMilestoneUsers(ctx context.Context, milestone int) ([]string, error) {
	rows, err := r.db.Query(ctx, `
		SELECT user_id FROM (
			SELECT user_id, COUNT(DISTINCT DATE(logged_at)) AS total
			FROM progress_logs GROUP BY user_id
		) sub WHERE total = $1`, milestone)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}
