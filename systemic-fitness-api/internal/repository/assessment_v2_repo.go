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

// ════════════════════════════════════════════════════════════════════
//  Assessment v2 Repository
//
//  Reads/writes the SF v2 columns added in migration 043 — same
//  `assessments` table as v1, distinguished by version='v2'.
//  v1 paths in assessment_repo.go are untouched.
// ════════════════════════════════════════════════════════════════════

type AssessmentV2Repository struct {
	db *pgxpool.Pool
}

func NewAssessmentV2Repository(db *pgxpool.Pool) *AssessmentV2Repository {
	return &AssessmentV2Repository{db: db}
}

const assessmentV2Cols = `
	id, user_id, version, status,
	phase_a_payload, phase_b_payload, phase_c_payload,
	classification_id, specific_condition_id, physical_status_level, program_type,
	chronobiology_window,
	rest_score, nutrition_score, movement_score_v2, system_score_v2,
	flags, recommendations, program_map_payload,
	created_at, updated_at
`

func scanAssessmentV2(row pgx.Row) (*model.AssessmentV2, error) {
	var (
		a                                                model.AssessmentV2
		userID                                           *string
		phaseA, phaseB, phaseC                           []byte
		classificationID, specificConditionID, programTp *string
		windowJSON, programMapJSON                       []byte
		restScore, nutritionScore, movementScore, sysScore *float64
		flags, recommendations                           []string
		createdAt, updatedAt                             time.Time
	)
	err := row.Scan(
		&a.ID, &userID, &a.Version, &a.Status,
		&phaseA, &phaseB, &phaseC,
		&classificationID, &specificConditionID, &a.PhysicalStatusLevel, &programTp,
		&windowJSON,
		&restScore, &nutritionScore, &movementScore, &sysScore,
		&flags, &recommendations, &programMapJSON,
		&createdAt, &updatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}

	a.UserID = userID
	a.ClassificationID = classificationID
	a.SpecificConditionID = specificConditionID
	if programTp != nil {
		a.ProgramType = model.ProgramType(*programTp)
	}
	a.RestScore = restScore
	a.NutritionScore = nutritionScore
	a.MovementScore = movementScore
	a.SystemScore = sysScore
	a.Flags = flags
	a.Recommendations = recommendations
	a.CreatedAt = createdAt
	a.UpdatedAt = updatedAt

	if len(phaseA) > 0 {
		if err := json.Unmarshal(phaseA, &a.PhaseA); err != nil {
			return nil, fmt.Errorf("unmarshal phase_a: %w", err)
		}
	}
	if len(phaseB) > 0 {
		var b model.PhaseBInput
		if err := json.Unmarshal(phaseB, &b); err != nil {
			return nil, fmt.Errorf("unmarshal phase_b: %w", err)
		}
		a.PhaseB = &b
	}
	if len(phaseC) > 0 {
		var c model.PhaseCInput
		if err := json.Unmarshal(phaseC, &c); err != nil {
			return nil, fmt.Errorf("unmarshal phase_c: %w", err)
		}
		a.PhaseC = &c
	}
	if len(windowJSON) > 0 {
		var w model.ChronobiologyWindow
		if err := json.Unmarshal(windowJSON, &w); err != nil {
			return nil, fmt.Errorf("unmarshal chronobiology_window: %w", err)
		}
		a.ChronobiologyWindow = &w
	}
	if len(programMapJSON) > 0 {
		var pm model.ProgramMapRecommendation
		if err := json.Unmarshal(programMapJSON, &pm); err != nil {
			return nil, fmt.Errorf("unmarshal program_map_payload: %w", err)
		}
		a.ProgramMap = &pm
	}
	if a.Flags == nil {
		a.Flags = []string{}
	}
	if a.Recommendations == nil {
		a.Recommendations = []string{}
	}
	return &a, nil
}

// CreateV2 inserts a new v2 assessment. Caller is expected to have
// already populated PhaseA (required) and optionally PhaseB/PhaseC and
// the engine-derived fields.
func (r *AssessmentV2Repository) CreateV2(ctx context.Context, a *model.AssessmentV2) error {
	phaseAJSON, err := json.Marshal(a.PhaseA)
	if err != nil {
		return fmt.Errorf("marshal phase_a: %w", err)
	}
	var phaseBJSON, phaseCJSON, windowJSON []byte
	if a.PhaseB != nil {
		if phaseBJSON, err = json.Marshal(a.PhaseB); err != nil {
			return fmt.Errorf("marshal phase_b: %w", err)
		}
	}
	if a.PhaseC != nil {
		if phaseCJSON, err = json.Marshal(a.PhaseC); err != nil {
			return fmt.Errorf("marshal phase_c: %w", err)
		}
	}
	if a.ChronobiologyWindow != nil {
		if windowJSON, err = json.Marshal(a.ChronobiologyWindow); err != nil {
			return fmt.Errorf("marshal chronobiology_window: %w", err)
		}
	}
	var programMapJSON []byte
	if a.ProgramMap != nil {
		if programMapJSON, err = json.Marshal(a.ProgramMap); err != nil {
			return fmt.Errorf("marshal program_map_payload: %w", err)
		}
	}

	if a.Version == "" {
		a.Version = model.AssessmentVersionV2
	}
	if a.Status == "" {
		a.Status = model.AssessmentSubmitted
	}
	if a.Flags == nil {
		a.Flags = []string{}
	}
	if a.Recommendations == nil {
		a.Recommendations = []string{}
	}

	const q = `
		INSERT INTO assessments (
			user_id, tier, version, status,
			phase_a_payload, phase_b_payload, phase_c_payload,
			classification_id, specific_condition_id, physical_status_level, program_type,
			chronobiology_window,
			rest_score, nutrition_score, movement_score_v2, system_score_v2,
			flags, recommendations, program_map_payload,
			-- legacy v1 NOT NULL columns relaxed by 043; insight kept for back-compat
			insight
		)
		VALUES (
			$1, 'free', $2, $3,
			$4, $5, $6,
			$7, $8, $9, $10,
			$11,
			$12, $13, $14, $15,
			$16, $17, $18,
			''
		)
		RETURNING id, created_at, updated_at`

	return r.db.QueryRow(ctx, q,
		a.UserID, a.Version, a.Status,
		phaseAJSON, nullableBytes(phaseBJSON), nullableBytes(phaseCJSON),
		a.ClassificationID, a.SpecificConditionID, a.PhysicalStatusLevel, string(a.ProgramType),
		nullableBytes(windowJSON),
		a.RestScore, a.NutritionScore, a.MovementScore, a.SystemScore,
		a.Flags, a.Recommendations, nullableBytes(programMapJSON),
	).Scan(&a.ID, &a.CreatedAt, &a.UpdatedAt)
}

func nullableBytes(b []byte) any {
	if len(b) == 0 {
		return nil
	}
	return b
}

func (r *AssessmentV2Repository) GetV2ByID(ctx context.Context, id string) (*model.AssessmentV2, error) {
	q := `SELECT ` + assessmentV2Cols + ` FROM assessments WHERE id = $1 AND version = 'v2'`
	return scanAssessmentV2(r.db.QueryRow(ctx, q, id))
}

// LatestV2ByUser returns the user's most recent v2 assessment (or
// ErrNotFound).
func (r *AssessmentV2Repository) LatestV2ByUser(ctx context.Context, userID string) (*model.AssessmentV2, error) {
	q := `SELECT ` + assessmentV2Cols + `
		FROM assessments
		WHERE user_id = $1 AND version = 'v2'
		ORDER BY created_at DESC
		LIMIT 1`
	return scanAssessmentV2(r.db.QueryRow(ctx, q, userID))
}

// ─── Consultant queue (Phase 7b) ──────────────────────────────────

// PendingReviewItem — lean projection untuk halaman "Antrian Review".
// Tidak ikut-sertakan payload JSONB besar; ambil detail lewat
// GET /api/v2/assessments/{id} kalau perlu.
type PendingReviewItem struct {
	AssessmentID         string     `json:"assessment_id"`
	UserID               *string    `json:"user_id,omitempty"`
	UserName             *string    `json:"user_name,omitempty"`
	UserEmail            *string    `json:"user_email,omitempty"`
	ClassificationID     *string    `json:"classification_id,omitempty"`
	SpecificConditionID  *string    `json:"specific_condition_id,omitempty"`
	PhysicalStatusLevel  *string    `json:"physical_status_level,omitempty"`
	ProgramType          *string    `json:"program_type,omitempty"`
	SystemScore          *float64   `json:"system_score,omitempty"`
	CreatedAt            time.Time  `json:"created_at"`
}

// ListPendingClinicalReview returns v2 assessments yang status='submitted'
// dan belum punya catatan klinis aktif (clinical_notes.assessment_id =
// id, deleted_at IS NULL). Diurutkan oldest-first karena queue kerja
// konsultan biasanya FIFO.
func (r *AssessmentV2Repository) ListPendingClinicalReview(
	ctx context.Context, limit int,
) ([]PendingReviewItem, error) {
	if limit <= 0 || limit > 500 {
		limit = 200
	}
	const q = `
		SELECT a.id, a.user_id, u.full_name, u.email,
		       a.classification_id, a.specific_condition_id,
		       a.physical_status_level, a.program_type,
		       a.system_score_v2, a.created_at
		FROM assessments a
		LEFT JOIN users u ON u.id = a.user_id
		WHERE a.version = 'v2'
		  AND a.status = 'submitted'
		  AND NOT EXISTS (
		      SELECT 1 FROM clinical_notes cn
		      WHERE cn.assessment_id = a.id
		        AND cn.deleted_at IS NULL
		  )
		ORDER BY a.created_at ASC
		LIMIT $1`
	rows, err := r.db.Query(ctx, q, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]PendingReviewItem, 0)
	for rows.Next() {
		var it PendingReviewItem
		if err := rows.Scan(
			&it.AssessmentID, &it.UserID, &it.UserName, &it.UserEmail,
			&it.ClassificationID, &it.SpecificConditionID,
			&it.PhysicalStatusLevel, &it.ProgramType,
			&it.SystemScore, &it.CreatedAt,
		); err != nil {
			return nil, err
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

// ─── System Score Weights ─────────────────────────────────────────

// GetActiveScoreWeights returns the currently active row, or the spec
// default if none is configured.
func (r *AssessmentV2Repository) GetActiveScoreWeights(ctx context.Context) (model.SystemScoreWeights, error) {
	const q = `
		SELECT id, name, movement_pct, nutrition_pct, rest_pct, is_active, notes, created_at, updated_at
		FROM system_score_weights
		WHERE is_active = TRUE
		LIMIT 1`
	var w model.SystemScoreWeights
	err := r.db.QueryRow(ctx, q).Scan(
		&w.ID, &w.Name, &w.MovementPct, &w.NutritionPct, &w.RestPct,
		&w.IsActive, &w.Notes, &w.CreatedAt, &w.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return model.DefaultSystemScoreWeights(), nil
	}
	return w, err
}

// UpdateActiveScoreWeights replaces the active weight row in a single
// transaction (deactivate all, then upsert the new active row).
func (r *AssessmentV2Repository) UpdateActiveScoreWeights(
	ctx context.Context,
	w *model.SystemScoreWeights,
	updatedBy *string,
) error {
	if w.MovementPct+w.NutritionPct+w.RestPct != 100 {
		return fmt.Errorf("score weights must sum to 100 (got %d/%d/%d)",
			w.MovementPct, w.NutritionPct, w.RestPct)
	}
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	if _, err := tx.Exec(ctx, `UPDATE system_score_weights SET is_active = FALSE WHERE is_active = TRUE`); err != nil {
		return err
	}

	const ins = `
		INSERT INTO system_score_weights (name, movement_pct, nutrition_pct, rest_pct, is_active, notes, created_by)
		VALUES ($1, $2, $3, $4, TRUE, $5, $6)
		RETURNING id, created_at, updated_at`
	if err := tx.QueryRow(ctx, ins,
		w.Name, w.MovementPct, w.NutritionPct, w.RestPct, w.Notes, updatedBy,
	).Scan(&w.ID, &w.CreatedAt, &w.UpdatedAt); err != nil {
		return err
	}
	w.IsActive = true
	return tx.Commit(ctx)
}
