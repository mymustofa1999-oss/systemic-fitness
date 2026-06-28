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

type PromotionRepository struct {
	db *pgxpool.Pool
}

func NewPromotionRepository(db *pgxpool.Pool) *PromotionRepository {
	return &PromotionRepository{db: db}
}

type Promotion struct {
	ID          string    `json:"id"`
	Title       string    `json:"title"`
	Description *string   `json:"description,omitempty"`
	ImageURL    *string   `json:"image_url,omitempty"`
	Badge       string    `json:"badge"`
	Route       string    `json:"route"`
	Status      string    `json:"status"`
	StartDate   string    `json:"start_date"`
	EndDate     string    `json:"end_date"`
	SortOrder   int       `json:"sort_order"`
	CreatedBy   *string   `json:"created_by,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

const promotionCols = `id, title, description, image_url, badge, route, status,
	start_date::text, end_date::text, sort_order, created_by, created_at, updated_at`

func scanPromotion(row pgx.Row) (*Promotion, error) {
	p := &Promotion{}
	err := row.Scan(&p.ID, &p.Title, &p.Description, &p.ImageURL, &p.Badge, &p.Route,
		&p.Status, &p.StartDate, &p.EndDate, &p.SortOrder, &p.CreatedBy, &p.CreatedAt, &p.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return p, err
}

func (r *PromotionRepository) Create(ctx context.Context, p *Promotion) error {
	query := `
		INSERT INTO promotions (title, description, image_url, badge, route, status,
			start_date, end_date, sort_order, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		p.Title, p.Description, p.ImageURL, p.Badge, p.Route, p.Status,
		p.StartDate, p.EndDate, p.SortOrder, p.CreatedBy,
	).Scan(&p.ID, &p.CreatedAt, &p.UpdatedAt)
}

func (r *PromotionRepository) GetByID(ctx context.Context, id string) (*Promotion, error) {
	return scanPromotion(r.db.QueryRow(ctx,
		`SELECT `+promotionCols+` FROM promotions WHERE id = $1`, id))
}

func (r *PromotionRepository) Update(ctx context.Context, p *Promotion) error {
	query := `
		UPDATE promotions SET
			title = $2, description = $3, image_url = $4, badge = $5, route = $6,
			status = $7, start_date = $8, end_date = $9, sort_order = $10
		WHERE id = $1 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query,
		p.ID, p.Title, p.Description, p.ImageURL, p.Badge, p.Route,
		p.Status, p.StartDate, p.EndDate, p.SortOrder,
	).Scan(&p.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *PromotionRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM promotions WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

type PromotionListFilter struct {
	Status *string
	Search string
}

func (r *PromotionRepository) List(ctx context.Context, params model.PaginationParams, f PromotionListFilter) ([]Promotion, int, error) {
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
	if err := r.db.QueryRow(ctx, "SELECT COUNT(*) FROM promotions "+where, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf("SELECT %s FROM promotions %s ORDER BY sort_order ASC, created_at DESC LIMIT $%d OFFSET $%d",
		promotionCols, where, idx, idx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	promotions := make([]Promotion, 0)
	for rows.Next() {
		var p Promotion
		if err := rows.Scan(&p.ID, &p.Title, &p.Description, &p.ImageURL, &p.Badge, &p.Route,
			&p.Status, &p.StartDate, &p.EndDate, &p.SortOrder, &p.CreatedBy, &p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, 0, err
		}
		promotions = append(promotions, p)
	}
	return promotions, total, rows.Err()
}

// ─── Active promotions (for client mobile carousel) ───────────────

func (r *PromotionRepository) ListActive(ctx context.Context) ([]Promotion, error) {
	query := fmt.Sprintf(`SELECT %s FROM promotions
		WHERE status = 'active' AND NOW() BETWEEN start_date AND end_date
		ORDER BY sort_order ASC, created_at DESC`, promotionCols)

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	promotions := make([]Promotion, 0)
	for rows.Next() {
		var p Promotion
		if err := rows.Scan(&p.ID, &p.Title, &p.Description, &p.ImageURL, &p.Badge, &p.Route,
			&p.Status, &p.StartDate, &p.EndDate, &p.SortOrder, &p.CreatedBy, &p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, err
		}
		promotions = append(promotions, p)
	}
	return promotions, rows.Err()
}
