package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

// CMSContentRepository handles singleton section bodies (cms_content).
type CMSContentRepository struct {
	db *pgxpool.Pool
}

func NewCMSContentRepository(db *pgxpool.Pool) *CMSContentRepository {
	return &CMSContentRepository{db: db}
}

// ListPublishedByLocale returns every section that has been published
// for the given locale. Unpublished rows (no published_data) are skipped.
func (r *CMSContentRepository) ListPublishedByLocale(ctx context.Context, locale string) ([]model.CMSContent, error) {
	const q = `
		SELECT section_key, locale, published_data, published_at, updated_at
		FROM cms_content
		WHERE locale = $1 AND published_data IS NOT NULL
	`
	rows, err := r.db.Query(ctx, q, locale)
	if err != nil {
		return nil, fmt.Errorf("query cms_content: %w", err)
	}
	defer rows.Close()

	var out []model.CMSContent
	for rows.Next() {
		var c model.CMSContent
		if err := rows.Scan(&c.SectionKey, &c.Locale, &c.PublishedData, &c.PublishedAt, &c.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan cms_content: %w", err)
		}
		out = append(out, c)
	}
	return out, rows.Err()
}
