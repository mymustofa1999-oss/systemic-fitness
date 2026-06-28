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

type GroupRepository struct {
	db *pgxpool.Pool
}

func NewGroupRepository(db *pgxpool.Pool) *GroupRepository {
	return &GroupRepository{db: db}
}

type Group struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description *string   `json:"description,omitempty"`
	ImageURL    *string   `json:"image_url,omitempty"`
	MaxMembers  *int      `json:"max_members,omitempty"`
	CreatedBy   string    `json:"created_by"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	MemberCount int       `json:"member_count"`
}

type GroupMember struct {
	ID       string    `json:"id"`
	GroupID  string    `json:"group_id"`
	UserID   string    `json:"user_id"`
	Role     string    `json:"role"`
	JoinedAt time.Time `json:"joined_at"`
}

const groupCols = `g.id, g.name, g.description, g.image_url, g.max_members, g.created_by, g.created_at, g.updated_at`

func (r *GroupRepository) Create(ctx context.Context, g *Group) error {
	query := `
		INSERT INTO groups (name, description, image_url, max_members, created_by)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		g.Name, g.Description, g.ImageURL, g.MaxMembers, g.CreatedBy,
	).Scan(&g.ID, &g.CreatedAt, &g.UpdatedAt)
}

func (r *GroupRepository) GetByID(ctx context.Context, id string) (*Group, error) {
	g := &Group{}
	err := r.db.QueryRow(ctx, `
		SELECT g.id, g.name, g.description, g.image_url, g.max_members, g.created_by, g.created_at, g.updated_at,
			COALESCE((SELECT COUNT(*) FROM group_members gm WHERE gm.group_id = g.id), 0) AS member_count
		FROM groups g WHERE g.id = $1`, id).
		Scan(&g.ID, &g.Name, &g.Description, &g.ImageURL, &g.MaxMembers,
			&g.CreatedBy, &g.CreatedAt, &g.UpdatedAt, &g.MemberCount)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return g, err
}

func (r *GroupRepository) Update(ctx context.Context, g *Group) error {
	query := `
		UPDATE groups SET name = $2, description = $3, image_url = $4, max_members = $5
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		g.ID, g.Name, g.Description, g.ImageURL, g.MaxMembers,
	).Scan(&g.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *GroupRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM groups WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *GroupRepository) List(ctx context.Context, params model.PaginationParams, search string) ([]Group, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if search != "" {
		where += fmt.Sprintf(" AND g.name ILIKE $%d", idx)
		args = append(args, "%"+search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM groups g "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(`
		SELECT %s,
			COALESCE((SELECT COUNT(*) FROM group_members gm WHERE gm.group_id = g.id), 0) AS member_count
		FROM groups g %s ORDER BY g.name ASC LIMIT $%d OFFSET $%d`,
		groupCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	groups := make([]Group, 0)
	for rows.Next() {
		var g Group
		if err := rows.Scan(&g.ID, &g.Name, &g.Description, &g.ImageURL, &g.MaxMembers,
			&g.CreatedBy, &g.CreatedAt, &g.UpdatedAt, &g.MemberCount); err != nil {
			return nil, 0, err
		}
		groups = append(groups, g)
	}
	return groups, total, rows.Err()
}

// ─── Members ───────────────────────────────────────────────────────

func (r *GroupRepository) AddMember(ctx context.Context, gm *GroupMember) error {
	query := `
		INSERT INTO group_members (group_id, user_id, role)
		VALUES ($1, $2, $3)
		ON CONFLICT (group_id, user_id) DO UPDATE SET role = EXCLUDED.role
		RETURNING id, joined_at`
	return r.db.QueryRow(ctx, query, gm.GroupID, gm.UserID, gm.Role).
		Scan(&gm.ID, &gm.JoinedAt)
}

func (r *GroupRepository) RemoveMember(ctx context.Context, groupID, userID string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM group_members WHERE group_id = $1 AND user_id = $2`,
		groupID, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *GroupRepository) ListMembers(ctx context.Context, groupID string) ([]GroupMember, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, group_id, user_id, role, joined_at
		FROM group_members WHERE group_id = $1 ORDER BY joined_at`, groupID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var members []GroupMember
	for rows.Next() {
		var gm GroupMember
		if err := rows.Scan(&gm.ID, &gm.GroupID, &gm.UserID, &gm.Role, &gm.JoinedAt); err != nil {
			return nil, err
		}
		members = append(members, gm)
	}
	return members, rows.Err()
}
