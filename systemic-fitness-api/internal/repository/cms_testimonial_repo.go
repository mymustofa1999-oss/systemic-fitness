package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type CMSTestimonialRepository struct {
	db *pgxpool.Pool
}

func NewCMSTestimonialRepository(db *pgxpool.Pool) *CMSTestimonialRepository {
	return &CMSTestimonialRepository{db: db}
}

// ListActiveByLocale returns active testimonials for the given locale,
// ordered by order_index.
func (r *CMSTestimonialRepository) ListActiveByLocale(ctx context.Context, locale string) ([]model.CMSTestimonial, error) {
	const q = `
		SELECT id, locale, order_index, name, role, title, description, rating,
		       image_id, image_url, is_active, created_at, updated_at
		FROM cms_testimonials
		WHERE locale = $1 AND is_active = TRUE
		ORDER BY order_index ASC, created_at ASC
	`
	rows, err := r.db.Query(ctx, q, locale)
	if err != nil {
		return nil, fmt.Errorf("query cms_testimonials: %w", err)
	}
	defer rows.Close()

	var out []model.CMSTestimonial
	for rows.Next() {
		var t model.CMSTestimonial
		if err := rows.Scan(
			&t.ID, &t.Locale, &t.OrderIndex, &t.Name, &t.Role, &t.Title, &t.Description, &t.Rating,
			&t.ImageID, &t.ImageURL, &t.IsActive, &t.CreatedAt, &t.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan cms_testimonials: %w", err)
		}
		out = append(out, t)
	}
	return out, rows.Err()
}
