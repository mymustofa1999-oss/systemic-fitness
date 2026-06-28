package repository

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

// ════════════════════════════════════════════════════════════════════
//  Assessment Repository
// ════════════════════════════════════════════════════════════════════

type AssessmentRepository struct {
	db *pgxpool.Pool
}

func NewAssessmentRepository(db *pgxpool.Pool) *AssessmentRepository {
	return &AssessmentRepository{db: db}
}

const assessmentCols = `
	id, user_id, tier, status,
	sleep_input, movement_input, metabolic_input,
	sleep_score, recovery_score, movement_score, metabolic_score, system_score,
	sleep_class, movement_class, metabolic_class,
	flags, insight, recommendations,
	reviewed_by, reviewed_at, reviewer_notes,
	created_at, updated_at
`

const assessmentColsPrefixed = `
	a.id, a.user_id, a.tier, a.status,
	a.sleep_input, a.movement_input, a.metabolic_input,
	a.sleep_score, a.recovery_score, a.movement_score, a.metabolic_score, a.system_score,
	a.sleep_class, a.movement_class, a.metabolic_class,
	a.flags, a.insight, a.recommendations,
	a.reviewed_by, a.reviewed_at, a.reviewer_notes,
	a.created_at, a.updated_at
`

func scanAssessment(row pgx.Row) (*model.Assessment, error) {
	return scanAssessmentRow(row, false)
}

func scanAssessmentWithUser(row pgx.Row) (*model.Assessment, error) {
	return scanAssessmentRow(row, true)
}

func scanAssessmentRow(row pgx.Row, withUser bool) (*model.Assessment, error) {
	a := &model.Assessment{}
	var (
		sleepJSON, movementJSON []byte
		metabolicJSON           []byte
		metabolicScore          *int16
		metabolicClass          *string
		userName                *string
	)

	var sleepScore, recoveryScore, movementScore, systemScore int16

	dest := []any{
		&a.ID, &a.UserID, &a.Tier, &a.Status,
		&sleepJSON, &movementJSON, &metabolicJSON,
		&sleepScore, &recoveryScore, &movementScore, &metabolicScore, &systemScore,
		&a.SleepClass, &a.MovementClass, &metabolicClass,
		&a.Flags, &a.Insight, &a.Recommendations,
		&a.ReviewedBy, &a.ReviewedAt, &a.ReviewerNotes,
		&a.CreatedAt, &a.UpdatedAt,
	}
	if withUser {
		dest = append(dest, &userName)
	}
	err := row.Scan(dest...)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}

	if err := json.Unmarshal(sleepJSON, &a.Sleep); err != nil {
		return nil, fmt.Errorf("unmarshal sleep_input: %w", err)
	}
	if err := json.Unmarshal(movementJSON, &a.Movement); err != nil {
		return nil, fmt.Errorf("unmarshal movement_input: %w", err)
	}
	if len(metabolicJSON) > 0 {
		var m model.MetabolicInput
		if err := json.Unmarshal(metabolicJSON, &m); err != nil {
			return nil, fmt.Errorf("unmarshal metabolic_input: %w", err)
		}
		a.Metabolic = &m
	}

	a.Scores = model.AssessmentScores{
		Sleep:    int(sleepScore),
		Recovery: int(recoveryScore),
		Movement: int(movementScore),
		System:   int(systemScore),
	}
	if metabolicScore != nil {
		v := int(*metabolicScore)
		a.Scores.Metabolic = &v
	}
	if metabolicClass != nil {
		c := model.Classification(*metabolicClass)
		a.MetabolicClass = &c
	}
	if a.Flags == nil {
		a.Flags = []string{}
	}
	if a.Recommendations == nil {
		a.Recommendations = []string{}
	}
	if withUser {
		a.UserName = userName
	}

	return a, nil
}

// Create inserts an assessment row. Expects all computed fields already
// populated by the service layer (AssessmentService via assessment_engine).
func (r *AssessmentRepository) Create(ctx context.Context, a *model.Assessment) error {
	sleepJSON, err := json.Marshal(a.Sleep)
	if err != nil {
		return fmt.Errorf("marshal sleep_input: %w", err)
	}
	movementJSON, err := json.Marshal(a.Movement)
	if err != nil {
		return fmt.Errorf("marshal movement_input: %w", err)
	}
	var metabolicJSON []byte
	if a.Metabolic != nil {
		metabolicJSON, err = json.Marshal(a.Metabolic)
		if err != nil {
			return fmt.Errorf("marshal metabolic_input: %w", err)
		}
	}

	var metabolicScore *int16
	if a.Scores.Metabolic != nil {
		v := int16(*a.Scores.Metabolic)
		metabolicScore = &v
	}

	query := `
		INSERT INTO assessments (
			user_id, tier, status,
			sleep_input, movement_input, metabolic_input,
			sleep_score, recovery_score, movement_score, metabolic_score, system_score,
			sleep_class, movement_class, metabolic_class,
			flags, insight, recommendations
		) VALUES (
			$1, $2, $3,
			$4, $5, $6,
			$7, $8, $9, $10, $11,
			$12, $13, $14,
			$15, $16, $17
		)
		RETURNING id, created_at, updated_at`

	return r.db.QueryRow(ctx, query,
		a.UserID, a.Tier, a.Status,
		sleepJSON, movementJSON, metabolicJSON,
		int16(a.Scores.Sleep), int16(a.Scores.Recovery), int16(a.Scores.Movement),
		metabolicScore, int16(a.Scores.System),
		a.SleepClass, a.MovementClass, a.MetabolicClass,
		a.Flags, a.Insight, a.Recommendations,
	).Scan(&a.ID, &a.CreatedAt, &a.UpdatedAt)
}


func (r *AssessmentRepository) GetByID(ctx context.Context, id string) (*model.Assessment, error) {
	return scanAssessment(r.db.QueryRow(ctx,
		`SELECT `+assessmentCols+` FROM assessments WHERE id = $1`, id))
}

// GetPreviousForAssessment returns the most recent assessment for the
// same user that was created strictly before the given assessment.
// Returns ErrNotFound when the given assessment is the user's first.
// Used by the mobile result page to show before/after deltas.
func (r *AssessmentRepository) GetPreviousForAssessment(ctx context.Context, currentID string) (*model.Assessment, error) {
	return scanAssessment(r.db.QueryRow(ctx,
		`SELECT `+assessmentColsPrefixed+`
		 FROM assessments a
		 WHERE a.user_id = (SELECT user_id FROM assessments WHERE id = $1)
		   AND a.created_at < (SELECT created_at FROM assessments WHERE id = $1)
		 ORDER BY a.created_at DESC
		 LIMIT 1`, currentID))
}

// GetLatestByUser returns the most recent assessment for a user, optionally
// filtered by tier ("free" or "paid"). Returns ErrNotFound when none exist.
// Used by the mobile app to pre-fill the paid wizard from the user's last
// free assessment.
func (r *AssessmentRepository) GetLatestByUser(ctx context.Context, userID string, tier string) (*model.Assessment, error) {
	if tier != "" {
		return scanAssessment(r.db.QueryRow(ctx,
			`SELECT `+assessmentCols+` FROM assessments
			 WHERE user_id = $1 AND tier = $2
			 ORDER BY created_at DESC
			 LIMIT 1`, userID, tier))
	}
	return scanAssessment(r.db.QueryRow(ctx,
		`SELECT `+assessmentCols+` FROM assessments
		 WHERE user_id = $1
		 ORDER BY created_at DESC
		 LIMIT 1`, userID))
}

// ListByUser returns paginated assessments for a specific user ordered by newest first.
func (r *AssessmentRepository) ListByUser(ctx context.Context, userID string, params model.PaginationParams) ([]*model.Assessment, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM assessments WHERE user_id = $1`, userID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := `SELECT ` + assessmentCols + `
		FROM assessments
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`
	rows, err := r.db.Query(ctx, query, userID, params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	out := make([]*model.Assessment, 0)
	for rows.Next() {
		a, err := scanAssessment(rows)
		if err != nil {
			return nil, 0, err
		}
		out = append(out, a)
	}
	return out, total, rows.Err()
}

// ListPendingReview returns all paid assessments still awaiting trainer review.
func (r *AssessmentRepository) ListPendingReview(ctx context.Context, params model.PaginationParams) ([]*model.Assessment, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM assessments WHERE tier = 'paid' AND status = 'submitted'`,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := `SELECT ` + assessmentColsPrefixed + `, u.full_name
		FROM assessments a
		LEFT JOIN users u ON u.id = a.user_id
		WHERE a.tier = 'paid' AND a.status = 'submitted'
		ORDER BY a.created_at ASC
		LIMIT $1 OFFSET $2`
	rows, err := r.db.Query(ctx, query, params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	out := make([]*model.Assessment, 0)
	for rows.Next() {
		a, err := scanAssessmentWithUser(rows)
		if err != nil {
			return nil, 0, err
		}
		out = append(out, a)
	}
	return out, total, rows.Err()
}

// AssessmentListFilter is the filter set for the admin "all assessments"
// listing. Any field set narrows the result; nil/empty fields are ignored.
type AssessmentListFilter struct {
	Tier   *string // "free" / "paid"
	Status *string // "submitted" / "verified" / "revised"
	UserID *string // restrict to a specific user
}

// ListAll returns paginated assessments for admin/owner consumption.
// Supports optional tier + status + user_id filters.
func (r *AssessmentRepository) ListAll(ctx context.Context, params model.PaginationParams, f AssessmentListFilter) ([]*model.Assessment, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Tier != nil && *f.Tier != "" {
		where += fmt.Sprintf(" AND a.tier = $%d", idx)
		args = append(args, *f.Tier)
		idx++
	}
	if f.Status != nil && *f.Status != "" {
		where += fmt.Sprintf(" AND a.status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	if f.UserID != nil && *f.UserID != "" {
		where += fmt.Sprintf(" AND a.user_id = $%d", idx)
		args = append(args, *f.UserID)
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx,
		"SELECT COUNT(*) FROM assessments a "+where, args...,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(
		"SELECT %s, u.full_name FROM assessments a LEFT JOIN users u ON u.id = a.user_id %s ORDER BY a.created_at DESC LIMIT $%d OFFSET $%d",
		assessmentColsPrefixed, where, idx, idx+1,
	)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	out := make([]*model.Assessment, 0)
	for rows.Next() {
		a, err := scanAssessmentWithUser(rows)
		if err != nil {
			return nil, 0, err
		}
		out = append(out, a)
	}
	return out, total, rows.Err()
}

// AssessmentReviewPatch captures the fields a trainer may override.
// Scores are recomputed by the service layer — the repo just persists them.
type AssessmentReviewPatch struct {
	ReviewerID     string
	Status         model.AssessmentStatus
	ReviewerNotes  *string
	Metabolic      *model.MetabolicInput
	MetabolicScore *int
	MetabolicClass *model.Classification
	SystemScore    int
	Flags          []string
	Insight        string
	Recommendations []string
}

// ApplyReview persists a trainer review. If Metabolic is provided, the
// row's metabolic_input, metabolic_score, metabolic_class and derivative
// fields are all updated atomically.
func (r *AssessmentRepository) ApplyReview(ctx context.Context, id string, patch AssessmentReviewPatch) error {
	sets := []string{
		"status = $2",
		"reviewed_by = $3",
		"reviewed_at = NOW()",
		"reviewer_notes = $4",
		"system_score = $5",
		"flags = $6",
		"insight = $7",
		"recommendations = $8",
	}
	args := []any{
		id, patch.Status, patch.ReviewerID, patch.ReviewerNotes,
		int16(patch.SystemScore), patch.Flags, patch.Insight, patch.Recommendations,
	}
	idx := 9

	if patch.Metabolic != nil {
		metabolicJSON, err := json.Marshal(patch.Metabolic)
		if err != nil {
			return fmt.Errorf("marshal metabolic_input: %w", err)
		}
		sets = append(sets, fmt.Sprintf("metabolic_input = $%d", idx))
		args = append(args, metabolicJSON)
		idx++
	}
	if patch.MetabolicScore != nil {
		sets = append(sets, fmt.Sprintf("metabolic_score = $%d", idx))
		args = append(args, int16(*patch.MetabolicScore))
		idx++
	}
	if patch.MetabolicClass != nil {
		sets = append(sets, fmt.Sprintf("metabolic_class = $%d", idx))
		args = append(args, *patch.MetabolicClass)
		idx++
	}

	query := `UPDATE assessments SET ` + strings.Join(sets, ", ") + ` WHERE id = $1`
	tag, err := r.db.Exec(ctx, query, args...)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}
