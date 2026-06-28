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

// ConditionRepository handles SF master tables introduced in Phase 1:
// condition_classifications, specific_conditions, physical_status_levels.
type ConditionRepository struct {
	db *pgxpool.Pool
}

func NewConditionRepository(db *pgxpool.Pool) *ConditionRepository {
	return &ConditionRepository{db: db}
}

// ─── Domain types ──────────────────────────────────────────────────────

type ConditionClassification struct {
	ID                  string             `json:"id"`
	Slug                string             `json:"slug"`
	Label               string             `json:"label"`
	Description         *string            `json:"description,omitempty"`
	FocusPillar         model.FocusPillar  `json:"focus_pillar"`
	FullProgramFormula  json.RawMessage    `json:"full_program_formula"`
	DailyResetFormula   json.RawMessage    `json:"daily_reset_formula"`
	SortOrder           int16              `json:"sort_order"`
	IsActive            bool               `json:"is_active"`
	CreatedAt           time.Time          `json:"created_at"`
	UpdatedAt           time.Time          `json:"updated_at"`
}

type SpecificCondition struct {
	ID                string          `json:"id"`
	ClassificationID  string          `json:"classification_id"`
	ClassificationSlug string         `json:"classification_slug,omitempty"` // populated by joins
	Slug              string          `json:"slug"`
	Label             string          `json:"label"`
	Description       *string         `json:"description,omitempty"`
	SeverityDefault   *string         `json:"severity_default,omitempty"`
	Notes             json.RawMessage `json:"notes"`
	SortOrder         int16           `json:"sort_order"`
	IsActive          bool            `json:"is_active"`
	CreatedAt         time.Time       `json:"created_at"`
	UpdatedAt         time.Time       `json:"updated_at"`
}

type PhysicalStatusLevel struct {
	ID               string                       `json:"id"`
	Slug             string                       `json:"slug"`
	Label            string                       `json:"label"`
	Description      *string                      `json:"description,omitempty"`
	Routing          model.PhysicalStatusRouting  `json:"routing"`
	WaitlistMessage  *string                      `json:"waitlist_message,omitempty"`
	SortOrder        int16                        `json:"sort_order"`
	IsActive         bool                         `json:"is_active"`
	CreatedAt        time.Time                    `json:"created_at"`
	UpdatedAt        time.Time                    `json:"updated_at"`
}

// ─── Condition Classifications ─────────────────────────────────────────

const classificationCols = `id, slug, label, description, focus_pillar,
	full_program_formula, daily_reset_formula, sort_order, is_active,
	created_at, updated_at`

func scanClassification(row pgx.Row) (*ConditionClassification, error) {
	c := &ConditionClassification{}
	err := row.Scan(
		&c.ID, &c.Slug, &c.Label, &c.Description, &c.FocusPillar,
		&c.FullProgramFormula, &c.DailyResetFormula, &c.SortOrder, &c.IsActive,
		&c.CreatedAt, &c.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return c, err
}

func (r *ConditionRepository) ListClassifications(ctx context.Context, includeInactive bool) ([]ConditionClassification, error) {
	where := "WHERE is_active = TRUE"
	if includeInactive {
		where = "WHERE 1=1"
	}
	query := fmt.Sprintf(
		"SELECT %s FROM condition_classifications %s ORDER BY sort_order ASC, label ASC",
		classificationCols, where,
	)
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := make([]ConditionClassification, 0)
	for rows.Next() {
		var c ConditionClassification
		if err := rows.Scan(
			&c.ID, &c.Slug, &c.Label, &c.Description, &c.FocusPillar,
			&c.FullProgramFormula, &c.DailyResetFormula, &c.SortOrder, &c.IsActive,
			&c.CreatedAt, &c.UpdatedAt,
		); err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

func (r *ConditionRepository) GetClassificationByID(ctx context.Context, id string) (*ConditionClassification, error) {
	return scanClassification(r.db.QueryRow(ctx,
		`SELECT `+classificationCols+` FROM condition_classifications WHERE id = $1`, id))
}

func (r *ConditionRepository) GetClassificationBySlug(ctx context.Context, slug string) (*ConditionClassification, error) {
	return scanClassification(r.db.QueryRow(ctx,
		`SELECT `+classificationCols+` FROM condition_classifications WHERE slug = $1`, slug))
}

func (r *ConditionRepository) CreateClassification(ctx context.Context, c *ConditionClassification) error {
	if len(c.FullProgramFormula) == 0 {
		c.FullProgramFormula = json.RawMessage(`{}`)
	}
	if len(c.DailyResetFormula) == 0 {
		c.DailyResetFormula = json.RawMessage(`{}`)
	}
	query := `
		INSERT INTO condition_classifications
			(slug, label, description, focus_pillar, full_program_formula, daily_reset_formula, sort_order, is_active)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		c.Slug, c.Label, c.Description, c.FocusPillar,
		c.FullProgramFormula, c.DailyResetFormula, c.SortOrder, c.IsActive,
	).Scan(&c.ID, &c.CreatedAt, &c.UpdatedAt)
}

func (r *ConditionRepository) UpdateClassification(ctx context.Context, c *ConditionClassification) error {
	if len(c.FullProgramFormula) == 0 {
		c.FullProgramFormula = json.RawMessage(`{}`)
	}
	if len(c.DailyResetFormula) == 0 {
		c.DailyResetFormula = json.RawMessage(`{}`)
	}
	query := `
		UPDATE condition_classifications SET
			slug = $2, label = $3, description = $4, focus_pillar = $5,
			full_program_formula = $6, daily_reset_formula = $7,
			sort_order = $8, is_active = $9
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		c.ID, c.Slug, c.Label, c.Description, c.FocusPillar,
		c.FullProgramFormula, c.DailyResetFormula, c.SortOrder, c.IsActive,
	).Scan(&c.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *ConditionRepository) DeleteClassification(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM condition_classifications WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ─── Specific Conditions ───────────────────────────────────────────────

const specificCols = `sc.id, sc.classification_id, cc.slug AS classification_slug,
	sc.slug, sc.label, sc.description, sc.severity_default, sc.notes,
	sc.sort_order, sc.is_active, sc.created_at, sc.updated_at`

func scanSpecific(row pgx.Row) (*SpecificCondition, error) {
	s := &SpecificCondition{}
	err := row.Scan(
		&s.ID, &s.ClassificationID, &s.ClassificationSlug, &s.Slug, &s.Label,
		&s.Description, &s.SeverityDefault, &s.Notes,
		&s.SortOrder, &s.IsActive, &s.CreatedAt, &s.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return s, err
}

type SpecificConditionFilter struct {
	ClassificationSlug *string
	IncludeInactive    bool
}

func (r *ConditionRepository) ListSpecificConditions(ctx context.Context, f SpecificConditionFilter) ([]SpecificCondition, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1
	if !f.IncludeInactive {
		where += " AND sc.is_active = TRUE"
	}
	if f.ClassificationSlug != nil && *f.ClassificationSlug != "" {
		where += fmt.Sprintf(" AND cc.slug = $%d", idx)
		args = append(args, *f.ClassificationSlug)
		idx++
	}

	query := fmt.Sprintf(`
		SELECT %s
		FROM specific_conditions sc
		JOIN condition_classifications cc ON cc.id = sc.classification_id
		%s
		ORDER BY cc.sort_order ASC, sc.sort_order ASC, sc.label ASC`,
		specificCols, where)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := make([]SpecificCondition, 0)
	for rows.Next() {
		var s SpecificCondition
		if err := rows.Scan(
			&s.ID, &s.ClassificationID, &s.ClassificationSlug, &s.Slug, &s.Label,
			&s.Description, &s.SeverityDefault, &s.Notes,
			&s.SortOrder, &s.IsActive, &s.CreatedAt, &s.UpdatedAt,
		); err != nil {
			return nil, err
		}
		out = append(out, s)
	}
	return out, rows.Err()
}

func (r *ConditionRepository) GetSpecificByID(ctx context.Context, id string) (*SpecificCondition, error) {
	query := fmt.Sprintf(`
		SELECT %s FROM specific_conditions sc
		JOIN condition_classifications cc ON cc.id = sc.classification_id
		WHERE sc.id = $1`, specificCols)
	return scanSpecific(r.db.QueryRow(ctx, query, id))
}

func (r *ConditionRepository) CreateSpecific(ctx context.Context, s *SpecificCondition) error {
	if len(s.Notes) == 0 {
		s.Notes = json.RawMessage(`{}`)
	}
	query := `
		INSERT INTO specific_conditions
			(classification_id, slug, label, description, severity_default, notes, sort_order, is_active)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		s.ClassificationID, s.Slug, s.Label, s.Description,
		s.SeverityDefault, s.Notes, s.SortOrder, s.IsActive,
	).Scan(&s.ID, &s.CreatedAt, &s.UpdatedAt)
}

func (r *ConditionRepository) UpdateSpecific(ctx context.Context, s *SpecificCondition) error {
	if len(s.Notes) == 0 {
		s.Notes = json.RawMessage(`{}`)
	}
	query := `
		UPDATE specific_conditions SET
			classification_id = $2, slug = $3, label = $4, description = $5,
			severity_default = $6, notes = $7, sort_order = $8, is_active = $9
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		s.ID, s.ClassificationID, s.Slug, s.Label, s.Description,
		s.SeverityDefault, s.Notes, s.SortOrder, s.IsActive,
	).Scan(&s.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *ConditionRepository) DeleteSpecific(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM specific_conditions WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ─── Physical Status Levels ────────────────────────────────────────────

const physLevelCols = `id, slug, label, description, routing, waitlist_message,
	sort_order, is_active, created_at, updated_at`

func (r *ConditionRepository) ListPhysicalStatusLevels(ctx context.Context, includeInactive bool) ([]PhysicalStatusLevel, error) {
	where := "WHERE is_active = TRUE"
	if includeInactive {
		where = "WHERE 1=1"
	}
	query := fmt.Sprintf(
		"SELECT %s FROM physical_status_levels %s ORDER BY sort_order ASC, label ASC",
		physLevelCols, where,
	)
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := make([]PhysicalStatusLevel, 0)
	for rows.Next() {
		var p PhysicalStatusLevel
		if err := rows.Scan(
			&p.ID, &p.Slug, &p.Label, &p.Description, &p.Routing,
			&p.WaitlistMessage, &p.SortOrder, &p.IsActive, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}
