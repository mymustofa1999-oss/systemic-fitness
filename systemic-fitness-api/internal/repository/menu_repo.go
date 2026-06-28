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

type MenuRepository struct {
	db *pgxpool.Pool
}

func NewMenuRepository(db *pgxpool.Pool) *MenuRepository {
	return &MenuRepository{db: db}
}

// ════════════════════════════════════════════════════════════════════
//  Domain types
// ════════════════════════════════════════════════════════════════════

type Menu struct {
	ID        string    `json:"id"`
	ParentID  *string   `json:"parent_id,omitempty"`
	Code      string    `json:"code"`
	Label     string    `json:"label"`
	Icon      *string   `json:"icon,omitempty"`
	Href      *string   `json:"href,omitempty"`
	SortOrder int       `json:"sort_order"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	// Populated by joins / app logic
	Children []Menu `json:"children,omitempty"`
}

type MenuRolePrivilege struct {
	ID        string    `json:"id"`
	MenuID    string    `json:"menu_id"`
	Role      string    `json:"role"`
	CanAccess bool      `json:"can_access"`
	CreatedAt time.Time `json:"created_at"`
}

// MenuWithPrivileges is used for the admin management view.
type MenuWithPrivileges struct {
	Menu
	Privileges []MenuRolePrivilege `json:"privileges"`
}

// ════════════════════════════════════════════════════════════════════
//  Scan helpers
// ════════════════════════════════════════════════════════════════════

const menuCols = `id, parent_id, code, label, icon, href, sort_order, is_active, created_at, updated_at`

func scanMenu(row pgx.Row) (*Menu, error) {
	m := &Menu{}
	err := row.Scan(
		&m.ID, &m.ParentID, &m.Code, &m.Label, &m.Icon, &m.Href,
		&m.SortOrder, &m.IsActive, &m.CreatedAt, &m.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return m, err
}

func scanMenuRows(rows pgx.Rows) ([]Menu, error) {
	menus := make([]Menu, 0)
	for rows.Next() {
		var m Menu
		if err := rows.Scan(
			&m.ID, &m.ParentID, &m.Code, &m.Label, &m.Icon, &m.Href,
			&m.SortOrder, &m.IsActive, &m.CreatedAt, &m.UpdatedAt,
		); err != nil {
			return nil, err
		}
		menus = append(menus, m)
	}
	return menus, rows.Err()
}

// ════════════════════════════════════════════════════════════════════
//  Menu CRUD
// ════════════════════════════════════════════════════════════════════

func (r *MenuRepository) Create(ctx context.Context, m *Menu) error {
	query := `
		INSERT INTO menus (parent_id, code, label, icon, href, sort_order, is_active)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		m.ParentID, m.Code, m.Label, m.Icon, m.Href, m.SortOrder, m.IsActive,
	).Scan(&m.ID, &m.CreatedAt, &m.UpdatedAt)
}

func (r *MenuRepository) GetByID(ctx context.Context, id string) (*Menu, error) {
	return scanMenu(r.db.QueryRow(ctx, `SELECT `+menuCols+` FROM menus WHERE id = $1`, id))
}

func (r *MenuRepository) Update(ctx context.Context, m *Menu) error {
	query := `
		UPDATE menus SET
			parent_id = $2, code = $3, label = $4, icon = $5,
			href = $6, sort_order = $7, is_active = $8
		WHERE id = $1
		RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		m.ID, m.ParentID, m.Code, m.Label, m.Icon, m.Href, m.SortOrder, m.IsActive,
	).Scan(&m.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *MenuRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM menus WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ════════════════════════════════════════════════════════════════════
//  Queries
// ════════════════════════════════════════════════════════════════════

// ListAll returns all menus ordered by sort_order (for admin management).
func (r *MenuRepository) ListAll(ctx context.Context, params model.PaginationParams) ([]Menu, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if params.Search != "" {
		where += fmt.Sprintf(" AND (label ILIKE $%d OR code ILIKE $%d)", idx, idx)
		args = append(args, "%"+params.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM menus "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM menus %s ORDER BY sort_order ASC, label ASC LIMIT $%d OFFSET $%d",
		menuCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	menus, err := scanMenuRows(rows)
	return menus, total, err
}

// ListByRole returns active menus accessible by a given role, built as a tree.
func (r *MenuRepository) ListByRole(ctx context.Context, role string) ([]Menu, error) {
	query := `
		SELECT m.id, m.parent_id, m.code, m.label, m.icon, m.href, m.sort_order, m.is_active, m.created_at, m.updated_at
		FROM menus m
		INNER JOIN menu_role_privileges mrp ON mrp.menu_id = m.id
		WHERE m.is_active = true
		  AND mrp.role = $1
		  AND mrp.can_access = true
		ORDER BY m.sort_order ASC, m.label ASC`

	rows, err := r.db.Query(ctx, query, role)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanMenuRows(rows)
}

// ListTreeAll returns ALL menus as a flat list (admin view, includes inactive).
func (r *MenuRepository) ListTreeAll(ctx context.Context) ([]Menu, error) {
	query := `SELECT ` + menuCols + ` FROM menus ORDER BY sort_order ASC, label ASC`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanMenuRows(rows)
}

// ════════════════════════════════════════════════════════════════════
//  Privileges CRUD
// ════════════════════════════════════════════════════════════════════

func (r *MenuRepository) GetPrivilegesByMenuID(ctx context.Context, menuID string) ([]MenuRolePrivilege, error) {
	query := `SELECT id, menu_id, role, can_access, created_at
		FROM menu_role_privileges WHERE menu_id = $1 ORDER BY role`
	rows, err := r.db.Query(ctx, query, menuID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	privileges := make([]MenuRolePrivilege, 0)
	for rows.Next() {
		var p MenuRolePrivilege
		if err := rows.Scan(&p.ID, &p.MenuID, &p.Role, &p.CanAccess, &p.CreatedAt); err != nil {
			return nil, err
		}
		privileges = append(privileges, p)
	}
	return privileges, rows.Err()
}

func (r *MenuRepository) GetAllPrivileges(ctx context.Context) ([]MenuRolePrivilege, error) {
	query := `SELECT id, menu_id, role, can_access, created_at
		FROM menu_role_privileges ORDER BY menu_id, role`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	privileges := make([]MenuRolePrivilege, 0)
	for rows.Next() {
		var p MenuRolePrivilege
		if err := rows.Scan(&p.ID, &p.MenuID, &p.Role, &p.CanAccess, &p.CreatedAt); err != nil {
			return nil, err
		}
		privileges = append(privileges, p)
	}
	return privileges, rows.Err()
}

// UpsertPrivileges replaces all role privileges for a given menu.
func (r *MenuRepository) UpsertPrivileges(ctx context.Context, menuID string, privileges []MenuRolePrivilege) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	// Delete existing privileges for this menu
	if _, err := tx.Exec(ctx, `DELETE FROM menu_role_privileges WHERE menu_id = $1`, menuID); err != nil {
		return fmt.Errorf("delete old privileges: %w", err)
	}

	// Insert new privileges
	for _, p := range privileges {
		_, err := tx.Exec(ctx,
			`INSERT INTO menu_role_privileges (menu_id, role, can_access) VALUES ($1, $2, $3)`,
			menuID, p.Role, p.CanAccess,
		)
		if err != nil {
			return fmt.Errorf("insert privilege role=%s: %w", p.Role, err)
		}
	}

	return tx.Commit(ctx)
}

// BulkUpsertPrivileges replaces all privileges for multiple menus at once.
func (r *MenuRepository) BulkUpsertPrivileges(ctx context.Context, menuPrivileges map[string][]MenuRolePrivilege) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	for menuID, privileges := range menuPrivileges {
		if _, err := tx.Exec(ctx, `DELETE FROM menu_role_privileges WHERE menu_id = $1`, menuID); err != nil {
			return fmt.Errorf("delete privileges for menu %s: %w", menuID, err)
		}
		for _, p := range privileges {
			_, err := tx.Exec(ctx,
				`INSERT INTO menu_role_privileges (menu_id, role, can_access) VALUES ($1, $2, $3)`,
				menuID, p.Role, p.CanAccess,
			)
			if err != nil {
				return fmt.Errorf("insert privilege menu=%s role=%s: %w", menuID, p.Role, err)
			}
		}
	}

	return tx.Commit(ctx)
}

// Reorder updates the sort_order for a batch of menus.
func (r *MenuRepository) Reorder(ctx context.Context, items []MenuReorderItem) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	for _, item := range items {
		_, err := tx.Exec(ctx,
			`UPDATE menus SET sort_order = $2, parent_id = $3 WHERE id = $1`,
			item.ID, item.SortOrder, item.ParentID,
		)
		if err != nil {
			return fmt.Errorf("reorder menu %s: %w", item.ID, err)
		}
	}

	return tx.Commit(ctx)
}

type MenuReorderItem struct {
	ID        string  `json:"id"`
	SortOrder int     `json:"sort_order"`
	ParentID  *string `json:"parent_id"`
}
