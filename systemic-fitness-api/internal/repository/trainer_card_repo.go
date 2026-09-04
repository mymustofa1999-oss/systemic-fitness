package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type TrainerCardRepository struct {
	db *pgxpool.Pool
}

func NewTrainerCardRepository(db *pgxpool.Pool) *TrainerCardRepository {
	return &TrainerCardRepository{db: db}
}

// ═════��═════════════════════════════════════════════════════════
//  Domain Models
// ══════���════════════���════════════════════════════���══════════════

type TrainerCardType struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description *string   `json:"description,omitempty"`
	IsActive    bool      `json:"is_active"`
	SortOrder   int       `json:"sort_order"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type TrainerCard struct {
	ID           string    `json:"id"`
	CustomerID   string    `json:"customer_id"`
	CustomerName string    `json:"customer_name,omitempty"`
	Level        string    `json:"level"`
	Status       string    `json:"status"`
	Notes        *string   `json:"notes,omitempty"`
	CreatedBy    *string   `json:"created_by,omitempty"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`

	Sequences []TrainerCardSequence `json:"sequences"`
}

type TrainerCardSequence struct {
	ID                  string    `json:"id"`
	TrainerCardID       string    `json:"trainer_card_id"`
	ProgramCategoryID   string    `json:"program_category_id"`
	ProgramCategoryName string    `json:"program_category_name,omitempty"`
	ProgramCategoryCode string    `json:"program_category_code,omitempty"`
	Duration            *string   `json:"duration,omitempty"`
	SortOrder           int       `json:"sort_order"`
	CreatedAt           time.Time `json:"created_at"`
	UpdatedAt           time.Time `json:"updated_at"`

	Sets []TrainerCardSet `json:"sets"`
}

type TrainerCardSet struct {
	ID                 string    `json:"id"`
	SequenceID         string    `json:"sequence_id"`
	SetNumber          int       `json:"set_number"`
	Duration           *string   `json:"duration,omitempty"`
	EquipmentUpper     *string   `json:"equipment_upper,omitempty"`
	EquipmentLower     *string   `json:"equipment_lower,omitempty"`
	Equipment          *string   `json:"equipment,omitempty"`
	TypeID             *string   `json:"type_id,omitempty"`
	TypeName           *string   `json:"type_name,omitempty"`
	BPM                *string   `json:"bpm,omitempty"`
	ExtraLoad          *string   `json:"extra_load,omitempty"`
	Notes              *string   `json:"notes,omitempty"`
	SortOrder          int       `json:"sort_order"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
	Pattern            *string   `json:"pattern,omitempty"`
	BreathingCore      *string   `json:"breathing_core,omitempty"`
	BreathingDiaphragm *string   `json:"breathing_diaphragm,omitempty"`

	Items []TrainerCardSetItem `json:"items"`
}

type TrainerCardSetItem struct {
	ID                 string    `json:"id"`
	SetID              string    `json:"set_id"`
	MovementID         *string   `json:"movement_id,omitempty"`
	MovementName       *string   `json:"movement_name,omitempty"`
	BodyPart           string    `json:"body_part"`
	Equipment          *string   `json:"equipment,omitempty"`
	Reps               *int      `json:"reps,omitempty"`
	SetsCount          *int      `json:"sets_count,omitempty"`
	SortOrder          int       `json:"sort_order"`
	VideoURLMale       *string   `json:"video_url_male,omitempty"`
	VideoURLFemale     *string   `json:"video_url_female,omitempty"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
	BreathingCore      *string   `json:"breathing_core,omitempty"`
	BreathingDiaphragm *string   `json:"breathing_diaphragm,omitempty"`
	AllowedTiers       []string  `json:"allowed_tiers"`
}

// nonNilTiers guarantees a non-nil slice so the NOT NULL allowed_tiers column
// never receives a SQL NULL. An empty slice means "open to all tiers".
func nonNilTiers(t []string) []string {
	if t == nil {
		return []string{}
	}
	return t
}

// ════════════════════════════════════════════════════════════════
//  Trainer Card Types (Master)
// ════════════════════════════════════════════════════════════════

func (r *TrainerCardRepository) ListTypes(ctx context.Context) ([]TrainerCardType, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, name, description, is_active, sort_order, created_at, updated_at
		 FROM trainer_card_types
		 ORDER BY sort_order ASC`)
	if err != nil {
		return nil, fmt.Errorf("list types: %w", err)
	}
	defer rows.Close()

	types := make([]TrainerCardType, 0)
	for rows.Next() {
		var t TrainerCardType
		var desc *string
		if err := rows.Scan(&t.ID, &t.Name, &desc, &t.IsActive, &t.SortOrder, &t.CreatedAt, &t.UpdatedAt); err != nil {
			return nil, err
		}
		t.Description = desc
		types = append(types, t)
	}
	return types, rows.Err()
}

func (r *TrainerCardRepository) CreateType(ctx context.Context, t *TrainerCardType) error {
	return r.db.QueryRow(ctx,
		`INSERT INTO trainer_card_types (name, description, sort_order)
		 VALUES ($1, $2, $3)
		 RETURNING id, is_active, created_at, updated_at`,
		t.Name, t.Description, t.SortOrder,
	).Scan(&t.ID, &t.IsActive, &t.CreatedAt, &t.UpdatedAt)
}

func (r *TrainerCardRepository) UpdateType(ctx context.Context, id string, t *TrainerCardType) error {
	tag, err := r.db.Exec(ctx,
		`UPDATE trainer_card_types
		 SET name = $1, description = $2, sort_order = $3, is_active = $4, updated_at = NOW()
		 WHERE id = $5`,
		t.Name, t.Description, t.SortOrder, t.IsActive, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *TrainerCardRepository) DeleteType(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM trainer_card_types WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ════════════════════════════════════════════════════════════════
//  Trainer Card Core
// ════════════════════════════════════════════════════════════════

func (r *TrainerCardRepository) GetByCustomerID(ctx context.Context, customerID string) (*TrainerCard, error) {
	row := r.db.QueryRow(ctx,
		`SELECT c.id, c.customer_id, u.full_name, c.level, c.status, c.notes, c.created_by, c.created_at, c.updated_at
		 FROM trainer_cards c
		 LEFT JOIN users u ON c.customer_id = u.id
		 WHERE c.customer_id = $1`,
		customerID,
	)

	var card TrainerCard
	err := row.Scan(
		&card.ID, &card.CustomerID, &card.CustomerName, &card.Level, &card.Status,
		&card.Notes, &card.CreatedBy, &card.CreatedAt, &card.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("get training card: %w", err)
	}

	if err := r.loadSequences(ctx, &card); err != nil {
		return nil, err
	}

	return &card, nil
}

func (r *TrainerCardRepository) loadSequences(ctx context.Context, card *TrainerCard) error {
	rows, err := r.db.Query(ctx,
		`SELECT s.id, s.trainer_card_id, s.program_category_id, pc.name, pc.code,
		        s.duration, s.sort_order, s.created_at, s.updated_at
		 FROM trainer_card_sequences s
		 JOIN program_categories pc ON pc.id = s.program_category_id
		 WHERE s.trainer_card_id = $1
		 ORDER BY s.sort_order ASC`, card.ID)
	if err != nil {
		return fmt.Errorf("load sequences: %w", err)
	}
	defer rows.Close()

	card.Sequences = make([]TrainerCardSequence, 0)
	for rows.Next() {
		var seq TrainerCardSequence
		if err := rows.Scan(
			&seq.ID, &seq.TrainerCardID, &seq.ProgramCategoryID,
			&seq.ProgramCategoryName, &seq.ProgramCategoryCode,
			&seq.Duration, &seq.SortOrder, &seq.CreatedAt, &seq.UpdatedAt,
		); err != nil {
			return err
		}
		card.Sequences = append(card.Sequences, seq)
	}
	if err := rows.Err(); err != nil {
		return err
	}

	for i := range card.Sequences {
		if err := r.loadSets(ctx, &card.Sequences[i]); err != nil {
			return err
		}
	}
	return nil
}

func (r *TrainerCardRepository) loadSets(ctx context.Context, seq *TrainerCardSequence) error {
	rows, err := r.db.Query(ctx,
		`SELECT s.id, s.sequence_id, s.set_number, s.duration,
		        s.equipment_upper, s.equipment_lower, s.equipment,
		        s.type_id, t.name,
		        s.bpm, s.extra_load, s.notes,
		        s.sort_order, s.created_at, s.updated_at,
		        s.pattern, s.breathing_core, s.breathing_diaphragm
		 FROM trainer_card_sets s
		 LEFT JOIN trainer_card_types t ON t.id = s.type_id
		 WHERE s.sequence_id = $1
		 ORDER BY s.sort_order ASC`, seq.ID)
	if err != nil {
		return fmt.Errorf("load sets: %w", err)
	}
	defer rows.Close()

	seq.Sets = make([]TrainerCardSet, 0)
	for rows.Next() {
		var s TrainerCardSet
		if err := rows.Scan(
			&s.ID, &s.SequenceID, &s.SetNumber, &s.Duration,
			&s.EquipmentUpper, &s.EquipmentLower, &s.Equipment,
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

func (r *TrainerCardRepository) loadItems(ctx context.Context, set *TrainerCardSet) error {
	rows, err := r.db.Query(ctx,
		`SELECT i.id, i.set_id, i.movement_id,
		        COALESCE(i.movement_name, m.name),
		        i.body_part, i.equipment, i.reps, i.sets_count,
		        i.sort_order, m.video_url_male, m.video_url_female,
		        i.created_at, i.updated_at,
		        i.breathing_core, i.breathing_diaphragm, i.allowed_tiers
		 FROM trainer_card_set_items i
		 LEFT JOIN dl_movements m ON m.id = i.movement_id
		 WHERE i.set_id = $1
		 ORDER BY i.sort_order ASC`, set.ID)
	if err != nil {
		return fmt.Errorf("load items: %w", err)
	}
	defer rows.Close()

	set.Items = make([]TrainerCardSetItem, 0)
	for rows.Next() {
		var item TrainerCardSetItem
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

// ════════════════════════════════════════════════════════════════
//  Upsert Full Trainer Card (transactional)
// ════════════════════════════════════════════════════════════════

func (r *TrainerCardRepository) UpsertCard(ctx context.Context, card *TrainerCard, updateSequences bool) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	if card.ID == "" {
		card.ID = uuid.New().String()
	} else {
		// If it's an update, ensure we have the card.ID for sequences, sets, etc.
		// Wait, ON CONFLICT (customer_id) will handle it. We can just RETURNING id into card.ID
	}

	// 1. Upsert the trainer card
	err = tx.QueryRow(ctx,
		`INSERT INTO trainer_cards (customer_id, level, notes, created_by)
		 VALUES ($1, $2, $3, $4)
		 ON CONFLICT (customer_id) DO UPDATE SET
		    level = $2, notes = $3, updated_at = NOW()
		 RETURNING id, created_at, updated_at`,
		card.CustomerID, card.Level, card.Notes, card.CreatedBy,
	).Scan(&card.ID, &card.CreatedAt, &card.UpdatedAt)
	if err != nil {
		return fmt.Errorf("upsert card: %w", err)
	}

	if !updateSequences {
		return tx.Commit(ctx)
	}

	var keepSeqIDs []string
	var keepSetIDs []string
	var keepItemIDs []string

	for si := range card.Sequences {
		seq := &card.Sequences[si]
		if seq.ID == "" {
			seq.ID = uuid.New().String()
		}
		keepSeqIDs = append(keepSeqIDs, seq.ID)

		for seti := range seq.Sets {
			set := &seq.Sets[seti]
			if set.ID == "" {
				set.ID = uuid.New().String()
			}
			keepSetIDs = append(keepSetIDs, set.ID)

			for ii := range set.Items {
				item := &set.Items[ii]
				if item.ID == "" {
					item.ID = uuid.New().String()
				}
				keepItemIDs = append(keepItemIDs, item.ID)
			}
		}
	}

	// Delete items not in payload
	if len(keepItemIDs) > 0 {
		_, err = tx.Exec(ctx, `DELETE FROM trainer_card_set_items 
			WHERE set_id IN (SELECT id FROM trainer_card_sets WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = $1))
			AND NOT (id = ANY($2))`, card.ID, keepItemIDs)
	} else {
		_, err = tx.Exec(ctx, `DELETE FROM trainer_card_set_items 
			WHERE set_id IN (SELECT id FROM trainer_card_sets WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = $1))`, card.ID)
	}
	if err != nil {
		return fmt.Errorf("delete old items: %w", err)
	}

	if len(keepSetIDs) > 0 {
		_, err = tx.Exec(ctx, `DELETE FROM trainer_card_sets 
			WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = $1)
			AND NOT (id = ANY($2))`, card.ID, keepSetIDs)
	} else {
		_, err = tx.Exec(ctx, `DELETE FROM trainer_card_sets 
			WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = $1)`, card.ID)
	}
	if err != nil {
		return fmt.Errorf("delete old sets: %w", err)
	}

	if len(keepSeqIDs) > 0 {
		_, err = tx.Exec(ctx, `DELETE FROM trainer_card_sequences WHERE trainer_card_id = $1 AND NOT (id = ANY($2))`, card.ID, keepSeqIDs)
	} else {
		_, err = tx.Exec(ctx, `DELETE FROM trainer_card_sequences WHERE trainer_card_id = $1`, card.ID)
	}
	if err != nil {
		return fmt.Errorf("delete old sequences: %w", err)
	}

	batch := &pgx.Batch{}

	// 3. Queue sequences + sets + items
	for si := range card.Sequences {
		seq := &card.Sequences[si]
		seq.TrainerCardID = card.ID
		if seq.SortOrder == 0 {
			seq.SortOrder = si
		}

		batch.Queue(
			`INSERT INTO trainer_card_sequences (id, trainer_card_id, program_category_id, duration, sort_order)
			 VALUES ($1, $2, $3, $4, $5)
			 ON CONFLICT (id) DO UPDATE SET
			    program_category_id = EXCLUDED.program_category_id, duration = EXCLUDED.duration, sort_order = EXCLUDED.sort_order, updated_at = NOW()`,
			seq.ID, seq.TrainerCardID, seq.ProgramCategoryID, seq.Duration, seq.SortOrder,
		)

		for seti := range seq.Sets {
			set := &seq.Sets[seti]
			set.SequenceID = seq.ID
			if set.SortOrder == 0 {
				set.SortOrder = seti
			}

			batch.Queue(
				`INSERT INTO trainer_card_sets
				    (id, sequence_id, set_number, duration, equipment_upper, equipment_lower, equipment,
				     type_id, bpm, extra_load, notes, sort_order,
				     pattern, breathing_core, breathing_diaphragm)
				 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
				 ON CONFLICT (id) DO UPDATE SET
				     set_number = EXCLUDED.set_number, duration = EXCLUDED.duration, equipment_upper = EXCLUDED.equipment_upper, equipment_lower = EXCLUDED.equipment_lower, equipment = EXCLUDED.equipment,
				     type_id = EXCLUDED.type_id, bpm = EXCLUDED.bpm, extra_load = EXCLUDED.extra_load, notes = EXCLUDED.notes, sort_order = EXCLUDED.sort_order,
				     pattern = EXCLUDED.pattern, breathing_core = EXCLUDED.breathing_core, breathing_diaphragm = EXCLUDED.breathing_diaphragm, updated_at = NOW()`,
				set.ID, set.SequenceID, set.SetNumber, set.Duration,
				set.EquipmentUpper, set.EquipmentLower, set.Equipment,
				set.TypeID, set.BPM, set.ExtraLoad, set.Notes, set.SortOrder,
				set.Pattern, set.BreathingCore, set.BreathingDiaphragm,
			)

			for ii := range set.Items {
				item := &set.Items[ii]
				item.SetID = set.ID
				if item.SortOrder == 0 {
					item.SortOrder = ii
				}

				batch.Queue(
					`INSERT INTO trainer_card_set_items
					    (id, set_id, movement_id, movement_name, body_part, equipment, reps, sets_count, sort_order,
					     breathing_core, breathing_diaphragm, allowed_tiers, video_url_snapshot)
					 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
					 ON CONFLICT (id) DO UPDATE SET
					     movement_id = EXCLUDED.movement_id, movement_name = EXCLUDED.movement_name, body_part = EXCLUDED.body_part, equipment = EXCLUDED.equipment,
					     reps = EXCLUDED.reps, sets_count = EXCLUDED.sets_count, sort_order = EXCLUDED.sort_order,
					     breathing_core = EXCLUDED.breathing_core, breathing_diaphragm = EXCLUDED.breathing_diaphragm, allowed_tiers = EXCLUDED.allowed_tiers, video_url_snapshot = EXCLUDED.video_url_snapshot, updated_at = NOW()`,
					item.ID, item.SetID, item.MovementID, item.MovementName,
					item.BodyPart, item.Equipment, item.Reps, item.SetsCount, item.SortOrder,
					item.BreathingCore, item.BreathingDiaphragm, nonNilTiers(item.AllowedTiers), nil,
				)
			}
		}
	}

	if batch.Len() > 0 {
		br := tx.SendBatch(ctx, batch)
		// We need to consume all results otherwise commit fails
		for i := 0; i < batch.Len(); i++ {
			if _, err := br.Exec(); err != nil {
				br.Close()
				return fmt.Errorf("batch execute at idx %d: %w", i, err)
			}
		}
		if err := br.Close(); err != nil {
			return fmt.Errorf("close batch: %w", err)
		}
	}

	return tx.Commit(ctx)
}

// ═══════════════════════════════════════════════════════════════
//  Delete Trainer Card
// ═══════════════════════════════════════════════════════════════

func (r *TrainerCardRepository) DeleteCard(ctx context.Context, customerID string) error {
	tag, err := r.db.Exec(ctx,
		`DELETE FROM trainer_cards WHERE customer_id = $1`, customerID)
	if err != nil {
		return fmt.Errorf("delete trainer card: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ═══════════════════════════════════════════════════════════════
//  Activation Metadata and Auto-Creation Helpers
// ═══════════════════════════════════════════════════════════════

type CustomerActivationMetadata struct {
	HasActiveSub        bool
	SubscriptionTier    string
	PhysicalStatusLevel string
	SpecificConditionID *string
	SpecificSlug        *string
	Gender              *string
	HeightCm            *float64
	DateOfBirth         *string
}

func (r *TrainerCardRepository) GetActivationMetadata(ctx context.Context, customerID string) (*CustomerActivationMetadata, error) {
	meta := &CustomerActivationMetadata{}

	// 1. Check active subscription and get tier
	var tier string
	err := r.db.QueryRow(ctx,
		`SELECT pp.tier FROM subscriptions s
		 JOIN payment_plans pp ON pp.id = s.plan_id
		 WHERE s.user_id = $1 AND s.status = 'active'
		 ORDER BY s.created_at DESC LIMIT 1`, customerID,
	).Scan(&tier)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			meta.HasActiveSub = false
			return meta, nil
		}
		return nil, fmt.Errorf("checking active subscription: %w", err)
	}

	meta.HasActiveSub = true
	meta.SubscriptionTier = tier

	// 2. Fetch latest v2 assessment details
	err = r.db.QueryRow(ctx,
		`SELECT physical_status_level, specific_condition_id
		 FROM assessments
		 WHERE user_id = $1 AND version = 'v2'
		 ORDER BY created_at DESC LIMIT 1`, customerID,
	).Scan(&meta.PhysicalStatusLevel, &meta.SpecificConditionID)
	if errors.Is(err, pgx.ErrNoRows) {
		// No assessment yet
		return meta, nil
	}
	if err != nil {
		return nil, fmt.Errorf("fetching latest assessment: %w", err)
	}

	// 3. Resolve specific condition slug if present
	if meta.SpecificConditionID != nil {
		var slug string
		err = r.db.QueryRow(ctx,
			`SELECT slug FROM specific_conditions WHERE id = $1`, *meta.SpecificConditionID,
		).Scan(&slug)
		if err == nil {
			meta.SpecificSlug = &slug
		}
	}

	// 4. Fetch user profile for load calculations
	var (
		gender *string
		height *float64
		dob    *string
	)
	_ = r.db.QueryRow(ctx,
		`SELECT gender, height_cm, date_of_birth FROM user_profiles WHERE user_id = $1`, customerID,
	).Scan(&gender, &height, &dob)
	meta.Gender = gender
	meta.HeightCm = height
	meta.DateOfBirth = dob

	return meta, nil
}

func (r *TrainerCardRepository) UpsertCustomerHRZone(ctx context.Context, customerID string, maxHR int, zone1L, zone1U, zone2L, zone2U, zone3L, zone3U, zone4L, zone4U, zone5L, zone5U int) error {
	query := `
		INSERT INTO customer_hr_zones (customer_id, max_hr_upper, max_hr_lower,
			zone5_upper, zone5_lower, zone4_upper, zone4_lower,
			zone3_upper, zone3_lower, zone2_upper, zone2_lower,
			zone1_upper, zone1_lower, notes)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
		ON CONFLICT (customer_id) DO UPDATE SET
			max_hr_upper=$2, max_hr_lower=$3,
			zone5_upper=$4, zone5_lower=$5, zone4_upper=$6, zone4_lower=$7,
			zone3_upper=$8, zone3_lower=$9, zone2_upper=$10, zone2_lower=$11,
			zone1_upper=$12, zone1_lower=$13, notes=$14`
	notes := "Auto-calculated based on v2 assessment."
	_, err := r.db.Exec(ctx, query,
		customerID, maxHR, maxHR,
		zone5U, zone5L, zone4U, zone4L,
		zone3U, zone3L, zone2U, zone2L,
		zone1U, zone1L, notes,
	)
	return err
}

type ProgramCategoryAssignmentLean struct {
	ID   string
	Name string
	Code string
}

func (r *TrainerCardRepository) EnsureDefaultAssignmentsAndGetCategories(ctx context.Context, customerID string) ([]ProgramCategoryAssignmentLean, error) {
	// Query active categories
	rows, err := r.db.Query(ctx,
		`SELECT id, name, code FROM program_categories
		 WHERE is_active = TRUE
		 ORDER BY display_order ASC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	cats := make([]ProgramCategoryAssignmentLean, 0)
	for rows.Next() {
		var c ProgramCategoryAssignmentLean
		if err := rows.Scan(&c.ID, &c.Name, &c.Code); err != nil {
			return nil, err
		}
		cats = append(cats, c)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	// Insert default assignments if not already present
	for _, c := range cats {
		_, err = r.db.Exec(ctx,
			`INSERT INTO customer_program_assignments (customer_id, program_category_id, is_active,
				has_beban_upper, has_beban_lower, has_resistance)
			 VALUES ($1, $2, TRUE, FALSE, FALSE, FALSE)
			 ON CONFLICT (customer_id, program_category_id) DO NOTHING`,
			customerID, c.ID,
		)
		if err != nil {
			return nil, fmt.Errorf("ensuring assignment for category %s: %w", c.Code, err)
		}
	}

	return cats, nil
}

func (r *TrainerCardRepository) GetMovementsByNames(ctx context.Context, names []string) ([]TrainerCardSetItem, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, name, body_part FROM dl_movements 
		WHERE name = ANY($1)`, names)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := make([]TrainerCardSetItem, 0)
	for rows.Next() {
		var id, name, bodyPart string
		if err := rows.Scan(&id, &name, &bodyPart); err != nil {
			return nil, err
		}
		idCopy := id
		nameCopy := name
		items = append(items, TrainerCardSetItem{
			MovementID:   &idCopy,
			MovementName: &nameCopy,
			BodyPart:     bodyPart,
		})
	}
	return items, rows.Err()
}

func (r *TrainerCardRepository) PublishCard(ctx context.Context, customerID string) error {
	tag, err := r.db.Exec(ctx,
		`UPDATE trainer_cards SET status = 'published', updated_at = NOW() WHERE customer_id = $1`,
		customerID,
	)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *TrainerCardRepository) GetTrainerIDForCustomer(ctx context.Context, customerID string) (string, error) {
	var trainerID string
	err := r.db.QueryRow(ctx, `SELECT trainer_id FROM trainer_clients WHERE client_id = $1`, customerID).Scan(&trainerID)
	return trainerID, err
}
