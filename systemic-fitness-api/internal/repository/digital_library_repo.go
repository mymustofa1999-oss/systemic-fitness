package repository

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

var ErrDuplicateName = errors.New("movement name already exists")

// ════════════════════════════════════════════════════════════════════
//  Digital Library Repository
// ════════════════════════════════════════════════════════════════════

type DigitalLibraryRepository struct {
	db *pgxpool.Pool
}

func NewDigitalLibraryRepository(db *pgxpool.Pool) *DigitalLibraryRepository {
	return &DigitalLibraryRepository{db: db}
}

// ─── Domain Models ──────────────────────────────────────────────

type DLCategory struct {
	ID          string    `json:"id"`
	Code        string    `json:"code"`
	Name        string    `json:"name"`
	Description *string   `json:"description,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type DLLevel struct {
	ID          string    `json:"id"`
	LevelNumber int       `json:"level_number"`
	Name        string    `json:"name"`
	NameID      string    `json:"name_id"`
	Description *string   `json:"description,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type DLMovement struct {
	ID             string    `json:"id"`
	Name           string    `json:"name"`
	BodyPart       string    `json:"body_part"`
	VideoURLMale   *string   `json:"video_url_male,omitempty"`
	VideoURLFemale *string   `json:"video_url_female,omitempty"`
	ImageURL       *string   `json:"image_url,omitempty"`
	Instructions   []string  `json:"instructions,omitempty"`
	Categories     []string  `json:"categories"`
	Type           *string   `json:"type,omitempty"`
	Pattern        *string   `json:"pattern,omitempty"`
	Level          *int      `json:"level,omitempty"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
	NameEN         *string   `json:"name_en,omitempty"`
	InstructionsEN []string  `json:"instructions_en,omitempty"`
	DescriptionEN  *string   `json:"description_en,omitempty"`
}

type DLMenuItem struct {
	ID         string      `json:"id"`
	CategoryID string      `json:"category_id"`
	LevelID    string      `json:"level_id"`
	MovementID string      `json:"movement_id"`
	BodyPart   string      `json:"body_part"`
	SortOrder  int         `json:"sort_order"`
	SetName    *string     `json:"set_name,omitempty"`
	GroupType  *string     `json:"group_type,omitempty"`
	CreatedAt  time.Time   `json:"created_at"`
	UpdatedAt  time.Time   `json:"updated_at"`
	Movement   *DLMovement `json:"movement,omitempty"`
}

type DLIsolateItem struct {
	ID         string     `json:"id"`
	CategoryID string     `json:"category_id"`
	MovementID string     `json:"movement_id"`
	Position   string     `json:"position"`
	SortOrder  int        `json:"sort_order"`
	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`
	Movement   *DLMovement `json:"movement,omitempty"`
}

type DLDynamicItem struct {
	ID              string     `json:"id"`
	CategoryID      string     `json:"category_id"`
	UpperMovementID *string    `json:"upper_movement_id,omitempty"`
	LowerMovementID *string    `json:"lower_movement_id,omitempty"`
	SortOrder       int        `json:"sort_order"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
	UpperMovement   *DLMovement `json:"upper_movement,omitempty"`
	LowerMovement   *DLMovement `json:"lower_movement,omitempty"`
}

// ─── Filters ────────────────────────────────────────────────────

type DLMovementFilter struct {
	BodyPart *string
	Category *string
	Search   string
}

// ─── Categories ─────────────────────────────────────────────────

func (r *DigitalLibraryRepository) ListCategories(ctx context.Context) ([]DLCategory, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, code, name, description, created_at, updated_at FROM dl_categories ORDER BY code`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	cats := make([]DLCategory, 0, 3)
	for rows.Next() {
		var c DLCategory
		if err := rows.Scan(&c.ID, &c.Code, &c.Name, &c.Description, &c.CreatedAt, &c.UpdatedAt); err != nil {
			return nil, err
		}
		cats = append(cats, c)
	}
	return cats, rows.Err()
}

func (r *DigitalLibraryRepository) GetCategoryByCode(ctx context.Context, code string) (*DLCategory, error) {
	var c DLCategory
	err := r.db.QueryRow(ctx,
		`SELECT id, code, name, description, created_at, updated_at FROM dl_categories WHERE code = $1`, code,
	).Scan(&c.ID, &c.Code, &c.Name, &c.Description, &c.CreatedAt, &c.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return &c, err
}

// ─── Levels ─────────────────────────────────────────────────────

func (r *DigitalLibraryRepository) ListLevels(ctx context.Context) ([]DLLevel, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, level_number, name, name_id, description, created_at, updated_at FROM dl_levels ORDER BY level_number`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	levels := make([]DLLevel, 0, 6)
	for rows.Next() {
		var l DLLevel
		if err := rows.Scan(&l.ID, &l.LevelNumber, &l.Name, &l.NameID, &l.Description, &l.CreatedAt, &l.UpdatedAt); err != nil {
			return nil, err
		}
		levels = append(levels, l)
	}
	return levels, rows.Err()
}

// ─── Movements (CRUD) ───────────────────────────────────────────

const movementCols = `id, name, body_part, video_url_male, video_url_female, image_url, instructions, categories, type, pattern, level, created_at, updated_at, name_en, instructions_en, description_en`

func scanMovement(row pgx.Row) (*DLMovement, error) {
	m := &DLMovement{}
	err := row.Scan(
		&m.ID, &m.Name, &m.BodyPart, &m.VideoURLMale, &m.VideoURLFemale, &m.ImageURL,
		&m.Instructions, &m.Categories, &m.Type, &m.Pattern, &m.Level, &m.CreatedAt, &m.UpdatedAt,
		&m.NameEN, &m.InstructionsEN, &m.DescriptionEN,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return m, err
}

func (r *DigitalLibraryRepository) ListMovements(ctx context.Context, params model.PaginationParams, f DLMovementFilter) ([]DLMovement, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.BodyPart != nil {
		where += fmt.Sprintf(" AND body_part = $%d", idx)
		args = append(args, *f.BodyPart)
		idx++
	}
	if f.Category != nil {
		where += fmt.Sprintf(" AND categories @> ARRAY[$%d]::training_category[]", idx)
		args = append(args, *f.Category)
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND name ILIKE $%d", idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM dl_movements "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM dl_movements %s ORDER BY body_part, name ASC LIMIT $%d OFFSET $%d",
		movementCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	movements := make([]DLMovement, 0)
	for rows.Next() {
		var m DLMovement
		if err := rows.Scan(
			&m.ID, &m.Name, &m.BodyPart, &m.VideoURLMale, &m.VideoURLFemale, &m.ImageURL,
			&m.Instructions, &m.Categories, &m.Type, &m.Pattern, &m.Level, &m.CreatedAt, &m.UpdatedAt,
			&m.NameEN, &m.InstructionsEN, &m.DescriptionEN,
		); err != nil {
			return nil, 0, err
		}
		movements = append(movements, m)
	}
	return movements, total, rows.Err()
}

func (r *DigitalLibraryRepository) GetMovementByID(ctx context.Context, id string) (*DLMovement, error) {
	return scanMovement(r.db.QueryRow(ctx,
		`SELECT `+movementCols+` FROM dl_movements WHERE id = $1`, id))
}

func (r *DigitalLibraryRepository) CreateMovement(ctx context.Context, m *DLMovement) error {
	query := `
		INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, image_url, instructions, categories, type, pattern, level, name_en, instructions_en, description_en)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id, created_at, updated_at`
	err := r.db.QueryRow(ctx, query,
		m.Name, m.BodyPart, m.VideoURLMale, m.VideoURLFemale, m.ImageURL,
		m.Instructions, m.Categories, m.Type, m.Pattern, m.Level,
		m.NameEN, m.InstructionsEN, m.DescriptionEN,
	).Scan(&m.ID, &m.CreatedAt, &m.UpdatedAt)
	if err != nil {
		if strings.Contains(err.Error(), "duplicate key") || strings.Contains(err.Error(), "dl_movements_name_key") {
			return ErrDuplicateName
		}
		return err
	}
	return nil
}

func (r *DigitalLibraryRepository) UpdateMovement(ctx context.Context, m *DLMovement) error {
	query := `
		UPDATE dl_movements SET
			name = $2, body_part = $3, video_url_male = $4, video_url_female = $5, image_url = $6,
			instructions = $7, categories = $8, type = $9, pattern = $10, level = $11,
			name_en = $12, instructions_en = $13, description_en = $14
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		m.ID, m.Name, m.BodyPart, m.VideoURLMale, m.VideoURLFemale, m.ImageURL,
		m.Instructions, m.Categories, m.Type, m.Pattern, m.Level,
		m.NameEN, m.InstructionsEN, m.DescriptionEN,
	).Scan(&m.UpdatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return ErrNotFound
		}
		if strings.Contains(err.Error(), "duplicate key") || strings.Contains(err.Error(), "dl_movements_name_key") {
			return ErrDuplicateName
		}
		return err
	}
	return nil
}

func (r *DigitalLibraryRepository) DeleteMovement(ctx context.Context, id string) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// 1. Delete dl_dynamic_items where this movement is the only movement
	_, err = tx.Exec(ctx, `
		DELETE FROM dl_dynamic_items 
		WHERE (upper_movement_id = $1 AND lower_movement_id IS NULL) 
		   OR (lower_movement_id = $1 AND upper_movement_id IS NULL)
	`, id)
	if err != nil {
		return err
	}

	// 2. Delete the movement itself
	tag, err := tx.Exec(ctx, `DELETE FROM dl_movements WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}

	return tx.Commit(ctx)
}

// ─── Menu Items ─────────────────────────────────────────────────

func (r *DigitalLibraryRepository) ListMenuItems(ctx context.Context, categoryCode string, levelNumber *int) ([]DLMenuItem, error) {
	where := "WHERE c.code = $1"
	args := []any{categoryCode}
	idx := 2

	if levelNumber != nil {
		where += fmt.Sprintf(" AND l.level_number = $%d", idx)
		args = append(args, *levelNumber)
	}

	query := fmt.Sprintf(`
		SELECT mi.id, mi.category_id, mi.level_id, mi.movement_id, mi.body_part, mi.sort_order, mi.set_name, mi.group_type,
		       mi.created_at, mi.updated_at,
		       m.id, m.name, m.body_part, m.video_url_male, m.video_url_female, m.image_url,
		       m.instructions, m.categories, m.type, m.pattern, m.level, m.created_at, m.updated_at,
		       m.name_en, m.instructions_en, m.description_en,
		       l.level_number
		FROM dl_menu_items mi
		JOIN dl_categories c ON c.id = mi.category_id
		JOIN dl_levels l ON l.id = mi.level_id
		JOIN dl_movements m ON m.id = mi.movement_id
		%s
		ORDER BY l.level_number, mi.sort_order`, where)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := make([]DLMenuItem, 0)
	for rows.Next() {
		var mi DLMenuItem
		var m DLMovement
		var levelNum int
		if err := rows.Scan(
			&mi.ID, &mi.CategoryID, &mi.LevelID, &mi.MovementID, &mi.BodyPart, &mi.SortOrder, &mi.SetName, &mi.GroupType,
			&mi.CreatedAt, &mi.UpdatedAt,
			&m.ID, &m.Name, &m.BodyPart, &m.VideoURLMale, &m.VideoURLFemale, &m.ImageURL,
			&m.Instructions, &m.Categories, &m.Type, &m.Pattern, &m.Level, &m.CreatedAt, &m.UpdatedAt,
			&m.NameEN, &m.InstructionsEN, &m.DescriptionEN,
			&levelNum,
		); err != nil {
			return nil, err
		}
		m.Level = &levelNum
		mi.Movement = &m
		items = append(items, mi)
	}
	return items, nil
}

// AddModulCardItem adds a movement to a specific level for ALL categories (FC, CC, MC)
func (r *DigitalLibraryRepository) AddModulCardItem(ctx context.Context, levelID string, movementID string) error {
	cats, err := r.ListCategories(ctx)
	if err != nil {
		return err
	}

	var maxSort int
	err = r.db.QueryRow(ctx, "SELECT COALESCE(MAX(sort_order), 0) FROM dl_menu_items WHERE level_id = $1", levelID).Scan(&maxSort)
	if err != nil && err != pgx.ErrNoRows {
		return err
	}
	nextSort := maxSort + 1

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	var bodyPart string
	err = tx.QueryRow(ctx, "SELECT body_part FROM dl_movements WHERE id = $1", movementID).Scan(&bodyPart)
	if err != nil {
		return err
	}

	for _, c := range cats {
		// Check if it already exists to avoid duplicates
		var exists bool
		err = tx.QueryRow(ctx, "SELECT EXISTS(SELECT 1 FROM dl_menu_items WHERE category_id = $1 AND level_id = $2 AND movement_id = $3)", c.ID, levelID, movementID).Scan(&exists)
		if err != nil {
			return err
		}
		if exists {
			continue
		}

		_, err = tx.Exec(ctx, `
			INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order)
			VALUES ($1, $2, $3, $4, $5)`,
			c.ID, levelID, movementID, bodyPart, nextSort)
		if err != nil {
			return err
		}
	}

	return tx.Commit(ctx)
}

// RemoveModulCardItem removes a movement from a specific level for ALL categories (FC, CC, MC)
func (r *DigitalLibraryRepository) RemoveModulCardItem(ctx context.Context, levelID string, movementID string) error {
	_, err := r.db.Exec(ctx, "DELETE FROM dl_menu_items WHERE level_id = $1 AND movement_id = $2", levelID, movementID)
	return err
}

func (r *DigitalLibraryRepository) CreateMenuItem(ctx context.Context, mi *DLMenuItem) error {
	query := `
		INSERT INTO dl_menu_items (category_id, level_id, movement_id, body_part, sort_order)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		mi.CategoryID, mi.LevelID, mi.MovementID, mi.BodyPart, mi.SortOrder,
	).Scan(&mi.ID, &mi.CreatedAt, &mi.UpdatedAt)
}

func (r *DigitalLibraryRepository) DeleteMenuItem(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM dl_menu_items WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ─── Isolate Items ──────────────────────────────────────────────

func (r *DigitalLibraryRepository) ListIsolateItems(ctx context.Context, categoryCode string, position *string) ([]DLIsolateItem, error) {
	where := "WHERE c.code = $1"
	args := []any{categoryCode}
	idx := 2

	if position != nil {
		where += fmt.Sprintf(" AND ii.position = $%d", idx)
		args = append(args, *position)
	}

	query := fmt.Sprintf(`
		SELECT ii.id, ii.category_id, ii.movement_id, ii.position, ii.sort_order,
		       ii.created_at, ii.updated_at,
		       m.id, m.name, m.body_part, m.video_url_male, m.video_url_female, m.image_url,
		       m.instructions, m.categories, m.type, m.pattern, m.level, m.created_at, m.updated_at,
		       m.name_en, m.instructions_en, m.description_en
		FROM dl_isolate_items ii
		JOIN dl_categories c ON c.id = ii.category_id
		JOIN dl_movements m ON m.id = ii.movement_id
		%s
		ORDER BY ii.position, ii.sort_order`, where)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := make([]DLIsolateItem, 0)
	for rows.Next() {
		var ii DLIsolateItem
		var m DLMovement
		if err := rows.Scan(
			&ii.ID, &ii.CategoryID, &ii.MovementID, &ii.Position, &ii.SortOrder,
			&ii.CreatedAt, &ii.UpdatedAt,
			&m.ID, &m.Name, &m.BodyPart, &m.VideoURLMale, &m.VideoURLFemale, &m.ImageURL,
			&m.Instructions, &m.Categories, &m.Type, &m.Pattern, &m.Level, &m.CreatedAt, &m.UpdatedAt,
			&m.NameEN, &m.InstructionsEN, &m.DescriptionEN,
		); err != nil {
			return nil, err
		}
		ii.Movement = &m
		items = append(items, ii)
	}
	return items, rows.Err()
}

func (r *DigitalLibraryRepository) CreateIsolateItem(ctx context.Context, ii *DLIsolateItem) error {
	query := `
		INSERT INTO dl_isolate_items (category_id, movement_id, position, sort_order)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		ii.CategoryID, ii.MovementID, ii.Position, ii.SortOrder,
	).Scan(&ii.ID, &ii.CreatedAt, &ii.UpdatedAt)
}

func (r *DigitalLibraryRepository) DeleteIsolateItem(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM dl_isolate_items WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ─── Dynamic Items ──────────────────────────────────────────────

func (r *DigitalLibraryRepository) ListDynamicItems(ctx context.Context, categoryCode string) ([]DLDynamicItem, error) {
	query := `
		SELECT di.id, di.category_id, di.upper_movement_id, di.lower_movement_id, di.sort_order,
		       di.created_at, di.updated_at,
		       um.id, um.name, um.body_part, um.video_url_male, um.video_url_female, um.image_url,
		       um.instructions, um.categories, um.type, um.pattern, um.level, um.created_at, um.updated_at,
		       um.name_en, um.instructions_en, um.description_en,
		       lm.id, lm.name, lm.body_part, lm.video_url_male, lm.video_url_female, lm.image_url,
		       lm.instructions, lm.categories, lm.type, lm.pattern, lm.level, lm.created_at, lm.updated_at,
		       lm.name_en, lm.instructions_en, lm.description_en
		FROM dl_dynamic_items di
		JOIN dl_categories c ON c.id = di.category_id
		LEFT JOIN dl_movements um ON um.id = di.upper_movement_id
		LEFT JOIN dl_movements lm ON lm.id = di.lower_movement_id
		WHERE c.code = $1
		ORDER BY di.sort_order`

	rows, err := r.db.Query(ctx, query, categoryCode)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := make([]DLDynamicItem, 0)
	for rows.Next() {
		var di DLDynamicItem
		var umID, umName, umBodyPart, umVideoURLMale, umVideoURLFemale, umImageURL, umType, umPattern *string
		var umInstructions []string
		var umCategories []string
		var umLevel *int
		var umCreatedAt, umUpdatedAt *time.Time
		var umNameEN *string
		var umInstructionsEN []string
		var umDescriptionEN *string
		var lmID, lmName, lmBodyPart, lmVideoURLMale, lmVideoURLFemale, lmImageURL, lmType, lmPattern *string
		var lmInstructions []string
		var lmCategories []string
		var lmLevel *int
		var lmCreatedAt, lmUpdatedAt *time.Time
		var lmNameEN *string
		var lmInstructionsEN []string
		var lmDescriptionEN *string

		if err := rows.Scan(
			&di.ID, &di.CategoryID, &di.UpperMovementID, &di.LowerMovementID, &di.SortOrder,
			&di.CreatedAt, &di.UpdatedAt,
			&umID, &umName, &umBodyPart, &umVideoURLMale, &umVideoURLFemale, &umImageURL,
			&umInstructions, &umCategories, &umType, &umPattern, &umLevel, &umCreatedAt, &umUpdatedAt,
			&umNameEN, &umInstructionsEN, &umDescriptionEN,
			&lmID, &lmName, &lmBodyPart, &lmVideoURLMale, &lmVideoURLFemale, &lmImageURL,
			&lmInstructions, &lmCategories, &lmType, &lmPattern, &lmLevel, &lmCreatedAt, &lmUpdatedAt,
			&lmNameEN, &lmInstructionsEN, &lmDescriptionEN,
		); err != nil {
			return nil, err
		}

		if umID != nil {
			di.UpperMovement = &DLMovement{
				ID: *umID, Name: *umName, BodyPart: *umBodyPart,
				VideoURLMale: umVideoURLMale, VideoURLFemale: umVideoURLFemale, ImageURL: umImageURL,
				Instructions: umInstructions, Categories: umCategories, Type: umType, Pattern: umPattern, Level: umLevel,
				CreatedAt: *umCreatedAt, UpdatedAt: *umUpdatedAt,
				NameEN: umNameEN, InstructionsEN: umInstructionsEN, DescriptionEN: umDescriptionEN,
			}
		}
		if lmID != nil {
			di.LowerMovement = &DLMovement{
				ID: *lmID, Name: *lmName, BodyPart: *lmBodyPart,
				VideoURLMale: lmVideoURLMale, VideoURLFemale: lmVideoURLFemale, ImageURL: lmImageURL,
				Instructions: lmInstructions, Categories: lmCategories, Type: lmType, Pattern: lmPattern, Level: lmLevel,
				CreatedAt: *lmCreatedAt, UpdatedAt: *lmUpdatedAt,
				NameEN: lmNameEN, InstructionsEN: lmInstructionsEN, DescriptionEN: lmDescriptionEN,
			}
		}

		items = append(items, di)
	}
	return items, rows.Err()
}

func (r *DigitalLibraryRepository) CreateDynamicItem(ctx context.Context, di *DLDynamicItem) error {
	query := `
		INSERT INTO dl_dynamic_items (category_id, upper_movement_id, lower_movement_id, sort_order)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		di.CategoryID, di.UpperMovementID, di.LowerMovementID, di.SortOrder,
	).Scan(&di.ID, &di.CreatedAt, &di.UpdatedAt)
}

func (r *DigitalLibraryRepository) DeleteDynamicItem(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM dl_dynamic_items WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ─── Program Overview (composite query) ─────────────────────────

type DLProgramOverview struct {
	Category     DLCategory      `json:"category"`
	Levels       []DLLevel       `json:"levels"`
	MenuItems    []DLMenuItem    `json:"menu_items"`
	IsolateItems []DLIsolateItem `json:"isolate_items"`
	DynamicItems []DLDynamicItem `json:"dynamic_items"`
}
