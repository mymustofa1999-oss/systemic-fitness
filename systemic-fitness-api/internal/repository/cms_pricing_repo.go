package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type CMSPricingRepository struct {
	db *pgxpool.Pool
}

func NewCMSPricingRepository(db *pgxpool.Pool) *CMSPricingRepository {
	return &CMSPricingRepository{db: db}
}

// ListActiveByLocale returns active pricing tiers for the given locale,
// ordered by order_index.
func (r *CMSPricingRepository) ListActiveByLocale(ctx context.Context, locale string) ([]model.CMSPricingTier, error) {
	const q = `
		SELECT id, locale, order_index, name, for_whom,
		       amount_monthly, per_monthly,
		       amount_yearly, per_yearly, equiv_yearly, original_yearly, savings_yearly,
		       features, cta_label, cta_style, is_featured, is_active,
		       created_at, updated_at
		FROM cms_pricing_tiers
		WHERE locale = $1 AND is_active = TRUE
		ORDER BY order_index ASC, created_at ASC
	`
	rows, err := r.db.Query(ctx, q, locale)
	if err != nil {
		return nil, fmt.Errorf("query cms_pricing_tiers: %w", err)
	}
	defer rows.Close()

	var out []model.CMSPricingTier
	for rows.Next() {
		var p model.CMSPricingTier
		if err := rows.Scan(
			&p.ID, &p.Locale, &p.OrderIndex, &p.Name, &p.ForWhom,
			&p.AmountMonthly, &p.PerMonthly,
			&p.AmountYearly, &p.PerYearly, &p.EquivYearly, &p.OriginalYearly, &p.SavingsYearly,
			&p.Features, &p.CTALabel, &p.CTAStyle, &p.IsFeatured, &p.IsActive,
			&p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan cms_pricing_tiers: %w", err)
		}
		out = append(out, p)
	}
	return out, rows.Err()
}
