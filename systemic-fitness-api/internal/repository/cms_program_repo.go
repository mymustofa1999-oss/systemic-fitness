package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type CMSProgramRepository struct {
	db *pgxpool.Pool
}

func NewCMSProgramRepository(db *pgxpool.Pool) *CMSProgramRepository {
	return &CMSProgramRepository{db: db}
}

// ListActiveByLocale returns active programs for the given locale,
// ordered by order_index.
func (r *CMSProgramRepository) ListActiveByLocale(ctx context.Context, locale string) ([]model.CMSProgram, error) {
	const q = `
		SELECT id, locale, order_index, tier_label, tier_color, name, description,
		       features, meta, image_id, image_url, is_active, created_at, updated_at
		FROM cms_programs
		WHERE locale = $1 AND is_active = TRUE
		ORDER BY order_index ASC, created_at ASC
	`
	rows, err := r.db.Query(ctx, q, locale)
	if err != nil {
		return nil, fmt.Errorf("query cms_programs: %w", err)
	}
	defer rows.Close()

	var out []model.CMSProgram
	for rows.Next() {
		var p model.CMSProgram
		if err := rows.Scan(
			&p.ID, &p.Locale, &p.OrderIndex, &p.TierLabel, &p.TierColor, &p.Name, &p.Description,
			&p.Features, &p.Meta, &p.ImageID, &p.ImageURL, &p.IsActive, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan cms_programs: %w", err)
		}
		out = append(out, p)
	}
	return out, rows.Err()
}
