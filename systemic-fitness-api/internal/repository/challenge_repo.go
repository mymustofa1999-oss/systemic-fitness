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

type ChallengeRepository struct {
	db *pgxpool.Pool
}

func NewChallengeRepository(db *pgxpool.Pool) *ChallengeRepository {
	return &ChallengeRepository{db: db}
}

type Challenge struct {
	ID              string     `json:"id"`
	Name            string     `json:"name"`
	Description     *string    `json:"description,omitempty"`
	ImageURL        *string    `json:"image_url,omitempty"`
	Status          string     `json:"status"`
	StartDate       string     `json:"start_date"`
	EndDate         string     `json:"end_date"`
	GoalType        *string    `json:"goal_type,omitempty"`
	GoalValue       *float64   `json:"goal_value,omitempty"`
	MaxParticipants *int       `json:"max_participants,omitempty"`
	CreatedBy       string     `json:"created_by"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
	ParticipantCount int       `json:"participant_count"`
}

const challengeCols = `c.id, c.name, c.description, c.image_url, c.status,
	c.start_date::text, c.end_date::text, c.goal_type, c.goal_value, c.max_participants,
	c.created_by, c.created_at, c.updated_at`

func (r *ChallengeRepository) Create(ctx context.Context, c *Challenge) error {
	query := `
		INSERT INTO challenges (name, description, image_url, status, start_date, end_date,
			goal_type, goal_value, max_participants, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		c.Name, c.Description, c.ImageURL, c.Status, c.StartDate, c.EndDate,
		c.GoalType, c.GoalValue, c.MaxParticipants, c.CreatedBy,
	).Scan(&c.ID, &c.CreatedAt, &c.UpdatedAt)
}

func (r *ChallengeRepository) GetByID(ctx context.Context, id string) (*Challenge, error) {
	c := &Challenge{}
	err := r.db.QueryRow(ctx, `
		SELECT c.id, c.name, c.description, c.image_url, c.status,
			c.start_date::text, c.end_date::text, c.goal_type, c.goal_value, c.max_participants,
			c.created_by, c.created_at, c.updated_at,
			COALESCE((SELECT COUNT(*) FROM challenge_participants cp WHERE cp.challenge_id = c.id), 0)
		FROM challenges c WHERE c.id = $1`, id).
		Scan(&c.ID, &c.Name, &c.Description, &c.ImageURL, &c.Status,
			&c.StartDate, &c.EndDate, &c.GoalType, &c.GoalValue, &c.MaxParticipants,
			&c.CreatedBy, &c.CreatedAt, &c.UpdatedAt, &c.ParticipantCount)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return c, err
}

func (r *ChallengeRepository) Update(ctx context.Context, c *Challenge) error {
	query := `
		UPDATE challenges SET
			name = $2, description = $3, image_url = $4, status = $5,
			start_date = $6, end_date = $7, goal_type = $8, goal_value = $9, max_participants = $10
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		c.ID, c.Name, c.Description, c.ImageURL, c.Status,
		c.StartDate, c.EndDate, c.GoalType, c.GoalValue, c.MaxParticipants,
	).Scan(&c.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *ChallengeRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM challenges WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type ChallengeListFilter struct {
	Status *string
	Search string
}

func (r *ChallengeRepository) List(ctx context.Context, params model.PaginationParams, f ChallengeListFilter) ([]Challenge, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Status != nil {
		where += fmt.Sprintf(" AND c.status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND c.name ILIKE $%d", idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM challenges c "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(`
		SELECT %s,
			COALESCE((SELECT COUNT(*) FROM challenge_participants cp WHERE cp.challenge_id = c.id), 0)
		FROM challenges c %s ORDER BY c.start_date DESC LIMIT $%d OFFSET $%d`,
		challengeCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	challenges := make([]Challenge, 0)
	for rows.Next() {
		var ch Challenge
		if err := rows.Scan(&ch.ID, &ch.Name, &ch.Description, &ch.ImageURL, &ch.Status,
			&ch.StartDate, &ch.EndDate, &ch.GoalType, &ch.GoalValue, &ch.MaxParticipants,
			&ch.CreatedBy, &ch.CreatedAt, &ch.UpdatedAt, &ch.ParticipantCount); err != nil {
			return nil, 0, err
		}
		challenges = append(challenges, ch)
	}
	return challenges, total, rows.Err()
}

// ─── Participants ──────────────────────────────────────────────────

type ChallengeParticipant struct {
	ID            string     `json:"id"`
	ChallengeID   string     `json:"challenge_id"`
	UserID        string     `json:"user_id"`
	ProgressValue float64    `json:"progress_value"`
	JoinedAt      time.Time  `json:"joined_at"`
	CompletedAt   *time.Time `json:"completed_at,omitempty"`
}

func (r *ChallengeRepository) JoinChallenge(ctx context.Context, cp *ChallengeParticipant) error {
	query := `
		INSERT INTO challenge_participants (challenge_id, user_id)
		VALUES ($1, $2)
		ON CONFLICT (challenge_id, user_id) DO NOTHING
		RETURNING id, joined_at`
	return r.db.QueryRow(ctx, query, cp.ChallengeID, cp.UserID).
		Scan(&cp.ID, &cp.JoinedAt)
}

func (r *ChallengeRepository) LeaveChallenge(ctx context.Context, challengeID, userID string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM challenge_participants WHERE challenge_id = $1 AND user_id = $2`,
		challengeID, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *ChallengeRepository) UpdateProgress(ctx context.Context, challengeID, userID string, value float64) error {
	query := `
		UPDATE challenge_participants SET progress_value = $3
		WHERE challenge_id = $1 AND user_id = $2`
	tag, err := r.db.Exec(ctx, query, challengeID, userID, value)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *ChallengeRepository) ListParticipants(ctx context.Context, challengeID string) ([]ChallengeParticipant, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, challenge_id, user_id, progress_value, joined_at, completed_at
		FROM challenge_participants WHERE challenge_id = $1
		ORDER BY progress_value DESC`, challengeID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var participants []ChallengeParticipant
	for rows.Next() {
		var cp ChallengeParticipant
		if err := rows.Scan(&cp.ID, &cp.ChallengeID, &cp.UserID, &cp.ProgressValue,
			&cp.JoinedAt, &cp.CompletedAt); err != nil {
			return nil, err
		}
		participants = append(participants, cp)
	}
	return participants, rows.Err()
}
