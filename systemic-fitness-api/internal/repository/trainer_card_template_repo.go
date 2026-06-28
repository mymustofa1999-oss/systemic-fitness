package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type TrainerCardTemplateRepository struct {
	db *pgxpool.Pool
}

func NewTrainerCardTemplateRepository(db *pgxpool.Pool) *TrainerCardTemplateRepository {
	return &TrainerCardTemplateRepository{db: db}
}

// ════════════════════════════════════════════════════════════════════
//  Domain Models
// ════════════════════════════════════════════════════════════════════

type TrainerCardTemplate struct {
	ID        string                        `json:"id"`
	Level     string                        `json:"level"`
	Notes     *string                       `json:"notes,omitempty"`
	CreatedAt time.Time                     `json:"created_at"`
	UpdatedAt time.Time                     `json:"updated_at"`
	Sequences []TrainerCardTemplateSequence `json:"sequences"`
}

type TrainerCardTemplateSequence struct {
	ID                  string                   `json:"id"`
	TemplateID          string                   `json:"template_id"`
	ProgramCategoryID   string                   `json:"program_category_id"`
	ProgramCategoryName string                   `json:"program_category_name,omitempty"`
	ProgramCategoryCode string                   `json:"program_category_code,omitempty"`
	Duration            *string                  `json:"duration,omitempty"`
	SortOrder           int                      `json:"sort_order"`
	CreatedAt           time.Time                `json:"created_at"`
	UpdatedAt           time.Time                `json:"updated_at"`
	Sets                []TrainerCardTemplateSet `json:"sets"`
}

type TrainerCardTemplateSet struct {
	ID             string                        `json:"id"`
	SequenceID     string                        `json:"sequence_id"`
	SetNumber      int                           `json:"set_number"`
	Duration       *string                       `json:"duration,omitempty"`
	EquipmentUpper *string                       `json:"equipment_upper,omitempty"`
	EquipmentLower *string                       `json:"equipment_lower,omitempty"`
	TypeID         *string                       `json:"type_id,omitempty"`
	TypeName       *string                       `json:"type_name,omitempty"`
	BPM            *string                       `json:"bpm,omitempty"`
	ExtraLoad      *string                       `json:"extra_load,omitempty"`
	Notes          *string                       `json:"notes,omitempty"`
	SortOrder      int                           `json:"sort_order"`
	CreatedAt      time.Time                     `json:"created_at"`
	UpdatedAt      time.Time                     `json:"updated_at"`
	Pattern            *string                       `json:"pattern,omitempty"`
	BreathingCore      *string                       `json:"breathing_core,omitempty"`
	BreathingDiaphragm *string                       `json:"breathing_diaphragm,omitempty"`
	Items          []TrainerCardTemplateSetItem `json:"items"`
}

type TrainerCardTemplateSetItem struct {
	ID             string    `json:"id"`
	SetID          string    `json:"set_id"`
	MovementID     *string   `json:"movement_id,omitempty"`
	MovementName   *string   `json:"movement_name,omitempty"`
	BodyPart       string    `json:"body_part"`
	Equipment      *string   `json:"equipment,omitempty"`
	Reps           *int      `json:"reps,omitempty"`
	SetsCount      *int      `json:"sets_count,omitempty"`
	SortOrder      int       `json:"sort_order"`
	VideoURLMale   *string   `json:"video_url_male,omitempty"`
	VideoURLFemale *string   `json:"video_url_female,omitempty"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
	BreathingCore      *string   `json:"breathing_core,omitempty"`
	BreathingDiaphragm *string   `json:"breathing_diaphragm,omitempty"`
	AllowedTiers       []string  `json:"allowed_tiers"`
}

// ════════════════════════════════════════════════════════════════════
//  Trainer Card Template CRUD
// ════════════════════════════════════════════════════════════════════

func (r *TrainerCardTemplateRepository) List(ctx context.Context) ([]TrainerCardTemplate, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, level, notes, created_at, updated_at
		 FROM trainer_card_templates
		 ORDER BY level ASC`)
	if err != nil {
		return nil, fmt.Errorf("list templates: %w", err)
	}
	defer rows.Close()

	templates := make([]TrainerCardTemplate, 0)
	for rows.Next() {
		var t TrainerCardTemplate
		if err := rows.Scan(&t.ID, &t.Level, &t.Notes, &t.CreatedAt, &t.UpdatedAt); err != nil {
			return nil, err
		}
		templates = append(templates, t)
	}
	return templates, rows.Err()
}

func (r *TrainerCardTemplateRepository) GetByLevel(ctx context.Context, level string) (*TrainerCardTemplate, error) {
	tmpl := &TrainerCardTemplate{}
	err := r.db.QueryRow(ctx,
		`SELECT id, level, notes, created_at, updated_at
		 FROM trainer_card_templates
		 WHERE level = $1`, level,
	).Scan(&tmpl.ID, &tmpl.Level, &tmpl.Notes, &tmpl.CreatedAt, &tmpl.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("get template by level: %w", err)
	}

	if err := r.loadSequences(ctx, tmpl); err != nil {
		return nil, err
	}
	return tmpl, nil
}

func (r *TrainerCardTemplateRepository) loadSequences(ctx context.Context, tmpl *TrainerCardTemplate) error {
	rows, err := r.db.Query(ctx,
		`SELECT s.id, s.template_id, s.program_category_id, pc.name, pc.code,
		        s.duration, s.sort_order, s.created_at, s.updated_at
		 FROM trainer_card_template_sequences s
		 JOIN program_categories pc ON pc.id = s.program_category_id
		 WHERE s.template_id = $1
		 ORDER BY s.sort_order ASC`, tmpl.ID)
	if err != nil {
		return fmt.Errorf("load template sequences: %w", err)
	}
	defer rows.Close()

	tmpl.Sequences = make([]TrainerCardTemplateSequence, 0)
	for rows.Next() {
		var seq TrainerCardTemplateSequence
		if err := rows.Scan(
			&seq.ID, &seq.TemplateID, &seq.ProgramCategoryID,
			&seq.ProgramCategoryName, &seq.ProgramCategoryCode,
			&seq.Duration, &seq.SortOrder, &seq.CreatedAt, &seq.UpdatedAt,
		); err != nil {
			return err
		}
		tmpl.Sequences = append(tmpl.Sequences, seq)
	}
	if err := rows.Err(); err != nil {
		return err
	}

	for i := range tmpl.Sequences {
		if err := r.loadSets(ctx, &tmpl.Sequences[i]); err != nil {
			return err
		}
	}
	return nil
}

func (r *TrainerCardTemplateRepository) loadSets(ctx context.Context, seq *TrainerCardTemplateSequence) error {
	rows, err := r.db.Query(ctx,
		`SELECT s.id, s.sequence_id, s.set_number, s.duration,
		        s.equipment_upper, s.equipment_lower,
		        s.type_id, t.name,
		        s.bpm, s.extra_load, s.notes,
		        s.sort_order, s.created_at, s.updated_at,
		        s.pattern, s.breathing_core, s.breathing_diaphragm
		 FROM trainer_card_template_sets s
		 LEFT JOIN trainer_card_types t ON t.id = s.type_id
		 WHERE s.sequence_id = $1
		 ORDER BY s.sort_order ASC`, seq.ID)
	if err != nil {
		return fmt.Errorf("load template sets: %w", err)
	}
	defer rows.Close()

	seq.Sets = make([]TrainerCardTemplateSet, 0)
	for rows.Next() {
		var s TrainerCardTemplateSet
		if err := rows.Scan(
			&s.ID, &s.SequenceID, &s.SetNumber, &s.Duration,
			&s.EquipmentUpper, &s.EquipmentLower,
			&s.TypeID, &s.TypeName,
			&s.BPM, &s.ExtraLoad, &s.Notes,
			&s.SortOrder, &s.CreatedAt, &s.UpdatedAt,
			&s.Pattern, &s.BreathingCore, &s.BreathingDiaphragm,
		); err != nil {
			return err
		}
		seq.Sets = append(seq.Sets, s)
	}
	if err := rows.Err(); err != nil {
		return err
	}

	for i := range seq.Sets {
		if err := r.loadItems(ctx, &seq.Sets[i]); err != nil {
			return err
		}
	}
	return nil
}

func (r *TrainerCardTemplateRepository) loadItems(ctx context.Context, set *TrainerCardTemplateSet) error {
	rows, err := r.db.Query(ctx,
		`SELECT i.id, i.set_id, i.movement_id,
		        COALESCE(i.movement_name, m.name),
		        i.body_part, i.equipment, i.reps, i.sets_count,
		        i.sort_order, m.video_url_male, m.video_url_female,
		        i.created_at, i.updated_at,
		        i.breathing_core, i.breathing_diaphragm, i.allowed_tiers
		 FROM trainer_card_template_set_items i
		 LEFT JOIN dl_movements m ON m.id = i.movement_id
		 WHERE i.set_id = $1
		 ORDER BY i.sort_order ASC`, set.ID)
	if err != nil {
		return fmt.Errorf("load template items: %w", err)
	}
	defer rows.Close()

	set.Items = make([]TrainerCardTemplateSetItem, 0)
	for rows.Next() {
		var item TrainerCardTemplateSetItem
		if err := rows.Scan(
			&item.ID, &item.SetID, &item.MovementID, &item.MovementName,
			&item.BodyPart, &item.Equipment, &item.Reps, &item.SetsCount,
			&item.SortOrder, &item.VideoURLMale, &item.VideoURLFemale,
			&item.CreatedAt, &item.UpdatedAt,
			&item.BreathingCore, &item.BreathingDiaphragm, &item.AllowedTiers,
		); err != nil {
			return err
		}
		set.Items = append(set.Items, item)
	}
	return rows.Err()
}

func (r *TrainerCardTemplateRepository) UpsertTemplate(ctx context.Context, tmpl *TrainerCardTemplate) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	// 1. Upsert the template card
	err = tx.QueryRow(ctx,
		`INSERT INTO trainer_card_templates (level, notes)
		 VALUES ($1, $2)
		 ON CONFLICT (level) DO UPDATE SET
		    notes = $2, updated_at = NOW()
		 RETURNING id, created_at, updated_at`,
		tmpl.Level, tmpl.Notes,
	).Scan(&tmpl.ID, &tmpl.CreatedAt, &tmpl.UpdatedAt)
	if err != nil {
		return fmt.Errorf("upsert template: %w", err)
	}

	// 2. Delete existing nested template sequences (cascade will handle sets+items)
	_, err = tx.Exec(ctx,
		`DELETE FROM trainer_card_template_sequences WHERE template_id = $1`, tmpl.ID)
	if err != nil {
		return fmt.Errorf("delete old template sequences: %w", err)
	}

	// 3. Insert sequences → sets → items
	for si := range tmpl.Sequences {
		seq := &tmpl.Sequences[si]
		seq.TemplateID = tmpl.ID
		if seq.SortOrder == 0 {
			seq.SortOrder = si
		}

		err = tx.QueryRow(ctx,
			`INSERT INTO trainer_card_template_sequences (template_id, program_category_id, duration, sort_order)
			 VALUES ($1, $2, $3, $4)
			 RETURNING id, created_at, updated_at`,
			seq.TemplateID, seq.ProgramCategoryID, seq.Duration, seq.SortOrder,
		).Scan(&seq.ID, &seq.CreatedAt, &seq.UpdatedAt)
		if err != nil {
			return fmt.Errorf("insert template sequence %d: %w", si, err)
		}

		for seti := range seq.Sets {
			set := &seq.Sets[seti]
			set.SequenceID = seq.ID
			if set.SortOrder == 0 {
				set.SortOrder = seti
			}

			err = tx.QueryRow(ctx,
				`INSERT INTO trainer_card_template_sets
				    (sequence_id, set_number, duration, equipment_upper, equipment_lower,
				     type_id, bpm, extra_load, notes, sort_order,
				     pattern, breathing_core, breathing_diaphragm)
				 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
				 RETURNING id, created_at, updated_at`,
				set.SequenceID, set.SetNumber, set.Duration,
				set.EquipmentUpper, set.EquipmentLower,
				set.TypeID, set.BPM, set.ExtraLoad, set.Notes, set.SortOrder,
				set.Pattern, set.BreathingCore, set.BreathingDiaphragm,
			).Scan(&set.ID, &set.CreatedAt, &set.UpdatedAt)
			if err != nil {
				return fmt.Errorf("insert template set %d-%d: %w", si, seti, err)
			}

			for itemi := range set.Items {
				item := &set.Items[itemi]
				item.SetID = set.ID
				if item.SortOrder == 0 {
					item.SortOrder = itemi
				}

				err = tx.QueryRow(ctx,
					`INSERT INTO trainer_card_template_set_items
					    (set_id, movement_id, movement_name, body_part, equipment, reps, sets_count, sort_order,
					     breathing_core, breathing_diaphragm, allowed_tiers)
					 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
					 RETURNING id, created_at, updated_at`,
					item.SetID, item.MovementID, item.MovementName,
					item.BodyPart, item.Equipment, item.Reps, item.SetsCount, item.SortOrder,
					item.BreathingCore, item.BreathingDiaphragm, nonNilTiers(item.AllowedTiers),
				).Scan(&item.ID, &item.CreatedAt, &item.UpdatedAt)
				if err != nil {
					return fmt.Errorf("insert template item %d-%d-%d: %w", si, seti, itemi, err)
				}
			}
		}
	}

	return tx.Commit(ctx)
}

func (r *TrainerCardTemplateRepository) DeleteTemplate(ctx context.Context, level string) error {
	tag, err := r.db.Exec(ctx,
		`DELETE FROM trainer_card_templates WHERE level = $1`, level)
	if err != nil {
		return fmt.Errorf("delete template: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}
