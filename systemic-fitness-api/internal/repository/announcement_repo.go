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

type AnnouncementRepository struct {
	db *pgxpool.Pool
}

func NewAnnouncementRepository(db *pgxpool.Pool) *AnnouncementRepository {
	return &AnnouncementRepository{db: db}
}

type Announcement struct {
	ID          string     `json:"id"`
	Title       string     `json:"title"`
	Body        string     `json:"body"`
	ImageURL    *string    `json:"image_url,omitempty"`
	Status      string     `json:"status"`
	TargetRoles []string   `json:"target_roles"`
	PublishedAt *time.Time `json:"published_at,omitempty"`
	CreatedBy   string     `json:"created_by"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}

const announcementCols = `id, title, body, image_url, status, target_roles, published_at, created_by, created_at, updated_at`

func scanAnnouncement(row pgx.Row) (*Announcement, error) {
	a := &Announcement{}
	err := row.Scan(&a.ID, &a.Title, &a.Body, &a.ImageURL, &a.Status,
		&a.TargetRoles, &a.PublishedAt, &a.CreatedBy, &a.CreatedAt, &a.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return a, err
}

func (r *AnnouncementRepository) Create(ctx context.Context, a *Announcement) error {
	query := `
		INSERT INTO announcements (title, body, image_url, status, target_roles, published_at, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		a.Title, a.Body, a.ImageURL, a.Status, a.TargetRoles, a.PublishedAt, a.CreatedBy,
	).Scan(&a.ID, &a.CreatedAt, &a.UpdatedAt)
}

func (r *AnnouncementRepository) GetByID(ctx context.Context, id string) (*Announcement, error) {
	return scanAnnouncement(r.db.QueryRow(ctx,
		`SELECT `+announcementCols+` FROM announcements WHERE id = $1`, id))
}

func (r *AnnouncementRepository) Update(ctx context.Context, a *Announcement) error {
	query := `
		UPDATE announcements SET
			title = $2, body = $3, image_url = $4, status = $5,
			target_roles = $6, published_at = $7
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		a.ID, a.Title, a.Body, a.ImageURL, a.Status, a.TargetRoles, a.PublishedAt,
	).Scan(&a.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *AnnouncementRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM announcements WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type AnnouncementListFilter struct {
	Status *string
	Search string
}

func (r *AnnouncementRepository) List(ctx context.Context, params model.PaginationParams, f AnnouncementListFilter) ([]Announcement, int, error) {
	where := "WHERE 1=1"
	args := []any{}
	idx := 1

	if f.Status != nil {
		where += fmt.Sprintf(" AND status = $%d", idx)
		args = append(args, *f.Status)
		idx++
	}
	if f.Search != "" {
		where += fmt.Sprintf(" AND title ILIKE $%d", idx)
		args = append(args, "%"+f.Search+"%")
		idx++
	}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM announcements "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM announcements %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d",
		announcementCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	announcements := make([]Announcement, 0)
	for rows.Next() {
		var a Announcement
		if err := rows.Scan(&a.ID, &a.Title, &a.Body, &a.ImageURL, &a.Status,
			&a.TargetRoles, &a.PublishedAt, &a.CreatedBy, &a.CreatedAt, &a.UpdatedAt); err != nil {
			return nil, 0, err
		}
		announcements = append(announcements, a)
	}
	return announcements, total, rows.Err()
}

// ─── Published (for clients to view) ───────────────────────────────

func (r *AnnouncementRepository) ListPublished(ctx context.Context, role string, params model.PaginationParams) ([]Announcement, int, error) {
	where := "WHERE status = 'published' AND (target_roles = '{}' OR $1 = ANY(target_roles))"
	args := []any{role}

	var total int
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM announcements "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM announcements %s ORDER BY published_at DESC LIMIT $2 OFFSET $3",
		announcementCols, where)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	announcements := make([]Announcement, 0)
	for rows.Next() {
		var a Announcement
		if err := rows.Scan(&a.ID, &a.Title, &a.Body, &a.ImageURL, &a.Status,
			&a.TargetRoles, &a.PublishedAt, &a.CreatedBy, &a.CreatedAt, &a.UpdatedAt); err != nil {
			return nil, 0, err
		}
		announcements = append(announcements, a)
	}
	return announcements, total, rows.Err()
}

func (r *AnnouncementRepository) MarkAsRead(ctx context.Context, announcementID, userID string) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO announcement_reads (announcement_id, user_id)
		VALUES ($1, $2) ON CONFLICT DO NOTHING`,
		announcementID, userID)
	return err
}
