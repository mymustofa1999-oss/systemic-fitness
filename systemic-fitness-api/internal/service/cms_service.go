package service

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"time"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

// ════════════════════════════════════════════════════════════
//  CMS Service — Phase 1 (read-only, public landing payload)
// ════════════════════════════════════════════════════════════

var ErrInvalidLocale = errors.New("invalid locale")

var supportedLocales = map[string]struct{}{
	"id": {},
	"en": {},
}

type CMSService struct {
	contentRepo     *repository.CMSContentRepository
	testimonialRepo *repository.CMSTestimonialRepository
	programRepo     *repository.CMSProgramRepository
	pricingRepo     *repository.CMSPricingRepository
	logger          *slog.Logger
}

func NewCMSService(
	cr *repository.CMSContentRepository,
	tr *repository.CMSTestimonialRepository,
	pr *repository.CMSProgramRepository,
	prc *repository.CMSPricingRepository,
	logger *slog.Logger,
) *CMSService {
	return &CMSService{
		contentRepo:     cr,
		testimonialRepo: tr,
		programRepo:     pr,
		pricingRepo:     prc,
		logger:          logger,
	}
}

// GetLanding returns the full content tree for the landing page at the
// requested locale. Sections + collections are composed into one payload.
func (s *CMSService) GetLanding(ctx context.Context, locale string) (*model.CMSLandingPayload, error) {
	if _, ok := supportedLocales[locale]; !ok {
		return nil, ErrInvalidLocale
	}

	contentRows, err := s.contentRepo.ListPublishedByLocale(ctx, locale)
	if err != nil {
		s.logger.Error("cms list content", "locale", locale, "error", err)
		return nil, err
	}

	sections := make(map[string]json.RawMessage, len(contentRows))
	var latestPublished *time.Time
	for _, row := range contentRows {
		sections[row.SectionKey] = row.PublishedData
		if row.PublishedAt != nil && (latestPublished == nil || row.PublishedAt.After(*latestPublished)) {
			t := *row.PublishedAt
			latestPublished = &t
		}
	}

	testimonials, err := s.testimonialRepo.ListActiveByLocale(ctx, locale)
	if err != nil {
		s.logger.Error("cms list testimonials", "locale", locale, "error", err)
		return nil, err
	}

	programs, err := s.programRepo.ListActiveByLocale(ctx, locale)
	if err != nil {
		s.logger.Error("cms list programs", "locale", locale, "error", err)
		return nil, err
	}

	pricing, err := s.pricingRepo.ListActiveByLocale(ctx, locale)
	if err != nil {
		s.logger.Error("cms list pricing", "locale", locale, "error", err)
		return nil, err
	}

	return &model.CMSLandingPayload{
		Locale:      locale,
		PublishedAt: latestPublished,
		Settings:    map[string]json.RawMessage{}, // Phase 4 populates this
		Sections:    sections,
		Collections: model.CMSLandingCollections{
			Testimonials: toPublicTestimonials(testimonials),
			Programs:     toPublicPrograms(programs),
			Pricing:      toPublicPricing(pricing),
		},
	}, nil
}

// ─── Public DTO mappers ──────────────────────────────────────

func toPublicTestimonials(items []model.CMSTestimonial) []model.CMSTestimonialPublic {
	out := make([]model.CMSTestimonialPublic, 0, len(items))
	for _, t := range items {
		out = append(out, model.CMSTestimonialPublic{
			ID:          t.ID,
			Name:        t.Name,
			Role:        t.Role,
			Title:       t.Title,
			Description: t.Description,
			Rating:      t.Rating,
			ImageURL:    t.ImageURL,
		})
	}
	return out
}

func toPublicPrograms(items []model.CMSProgram) []model.CMSProgramPublic {
	out := make([]model.CMSProgramPublic, 0, len(items))
	for _, p := range items {
		out = append(out, model.CMSProgramPublic{
			ID:          p.ID,
			TierLabel:   p.TierLabel,
			TierColor:   p.TierColor,
			Name:        p.Name,
			Description: p.Description,
			Features:    p.Features,
			Meta:        p.Meta,
			ImageURL:    p.ImageURL,
		})
	}
	return out
}

func toPublicPricing(items []model.CMSPricingTier) []model.CMSPricingPublic {
	out := make([]model.CMSPricingPublic, 0, len(items))
	for _, p := range items {
		out = append(out, model.CMSPricingPublic{
			ID:             p.ID,
			Name:           p.Name,
			ForWhom:        p.ForWhom,
			AmountMonthly:  p.AmountMonthly,
			PerMonthly:     p.PerMonthly,
			AmountYearly:   p.AmountYearly,
			PerYearly:      p.PerYearly,
			EquivYearly:    p.EquivYearly,
			OriginalYearly: p.OriginalYearly,
			SavingsYearly:  p.SavingsYearly,
			Features:       p.Features,
			CTALabel:       p.CTALabel,
			CTAStyle:       p.CTAStyle,
			IsFeatured:     p.IsFeatured,
		})
	}
	return out
}
