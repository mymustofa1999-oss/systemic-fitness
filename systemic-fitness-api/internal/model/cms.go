package model

import (
	"encoding/json"
	"time"
)

// ════════════════════════════════════════════════════════════
//  CMS — landing page content (Phase 1: read-only)
// ════════════════════════════════════════════════════════════

// CMSContent is a singleton section (hero, nav, hero, ...) stored with
// draft/published JSONB bodies. The public endpoint reads published_data.
type CMSContent struct {
	SectionKey    string          `json:"section_key"`
	Locale        string          `json:"locale"`
	DraftData     json.RawMessage `json:"draft_data,omitempty"`
	PublishedData json.RawMessage `json:"published_data,omitempty"`
	PublishedAt   *time.Time      `json:"published_at,omitempty"`
	UpdatedAt     time.Time       `json:"updated_at"`
	UpdatedBy     *string         `json:"updated_by,omitempty"`
}

// CMSTestimonial — collection row.
type CMSTestimonial struct {
	ID          string    `json:"id"`
	Locale      string    `json:"locale"`
	OrderIndex  int       `json:"order_index"`
	Name        string    `json:"name"`
	Role        string    `json:"role"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Rating      int       `json:"rating"`
	ImageID     *string   `json:"image_id,omitempty"`
	ImageURL    *string   `json:"image_url,omitempty"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// CMSProgram — collection row.
type CMSProgram struct {
	ID          string          `json:"id"`
	Locale      string          `json:"locale"`
	OrderIndex  int             `json:"order_index"`
	TierLabel   string          `json:"tier_label"`
	TierColor   string          `json:"tier_color"`
	Name        string          `json:"name"`
	Description string          `json:"description"`
	Features    json.RawMessage `json:"features"`
	Meta        json.RawMessage `json:"meta"`
	ImageID     *string         `json:"image_id,omitempty"`
	ImageURL    *string         `json:"image_url,omitempty"`
	IsActive    bool            `json:"is_active"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}

// CMSPricingTier — collection row.
type CMSPricingTier struct {
	ID             string          `json:"id"`
	Locale         string          `json:"locale"`
	OrderIndex     int             `json:"order_index"`
	Name           string          `json:"name"`
	ForWhom        string          `json:"for_whom"`
	AmountMonthly  string          `json:"amount_monthly"`
	PerMonthly     string          `json:"per_monthly"`
	AmountYearly   *string         `json:"amount_yearly,omitempty"`
	PerYearly      *string         `json:"per_yearly,omitempty"`
	EquivYearly    *string         `json:"equiv_yearly,omitempty"`
	OriginalYearly *string         `json:"original_yearly,omitempty"`
	SavingsYearly  *string         `json:"savings_yearly,omitempty"`
	Features       json.RawMessage `json:"features"`
	CTALabel       string          `json:"cta_label"`
	CTAStyle       string          `json:"cta_style"`
	IsFeatured     bool            `json:"is_featured"`
	IsActive       bool            `json:"is_active"`
	CreatedAt      time.Time       `json:"created_at"`
	UpdatedAt      time.Time       `json:"updated_at"`
}

// ════════════════════════════════════════════════════════════
//  Public composed payload (GET /api/public/cms/landing)
// ════════════════════════════════════════════════════════════

// CMSLandingPayload is the resolved content tree returned to the
// landing page. Sections use section_key as map key and carry the
// published JSONB body untouched. Collections are flattened DTOs.
type CMSLandingPayload struct {
	Locale      string                      `json:"locale"`
	PublishedAt *time.Time                  `json:"published_at,omitempty"`
	Settings    map[string]json.RawMessage  `json:"settings"`
	Sections    map[string]json.RawMessage  `json:"sections"`
	Collections CMSLandingCollections       `json:"collections"`
}

type CMSLandingCollections struct {
	Testimonials []CMSTestimonialPublic `json:"testimonials"`
	Programs     []CMSProgramPublic     `json:"programs"`
	Pricing      []CMSPricingPublic     `json:"pricing"`
}

type CMSTestimonialPublic struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Role        string  `json:"role"`
	Title       string  `json:"title"`
	Description string  `json:"description"`
	Rating      int     `json:"rating"`
	ImageURL    *string `json:"image_url,omitempty"`
}

type CMSProgramPublic struct {
	ID          string          `json:"id"`
	TierLabel   string          `json:"tier_label"`
	TierColor   string          `json:"tier_color"`
	Name        string          `json:"name"`
	Description string          `json:"description"`
	Features    json.RawMessage `json:"features"`
	Meta        json.RawMessage `json:"meta"`
	ImageURL    *string         `json:"image_url,omitempty"`
}

type CMSPricingPublic struct {
	ID             string          `json:"id"`
	Name           string          `json:"name"`
	ForWhom        string          `json:"for_whom"`
	AmountMonthly  string          `json:"amount_monthly"`
	PerMonthly     string          `json:"per_monthly"`
	AmountYearly   *string         `json:"amount_yearly,omitempty"`
	PerYearly      *string         `json:"per_yearly,omitempty"`
	EquivYearly    *string         `json:"equiv_yearly,omitempty"`
	OriginalYearly *string         `json:"original_yearly,omitempty"`
	SavingsYearly  *string         `json:"savings_yearly,omitempty"`
	Features       json.RawMessage `json:"features"`
	CTALabel       string          `json:"cta_label"`
	CTAStyle       string          `json:"cta_style"`
	IsFeatured     bool            `json:"is_featured"`
}
