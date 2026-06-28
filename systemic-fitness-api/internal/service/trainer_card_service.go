package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"strconv"
	"strings"
	"time"

	"github.com/fitcoach/api/internal/repository"
)

type TrainerCardService struct {
	repo         *repository.TrainerCardRepository
	templateRepo *repository.TrainerCardTemplateRepository
	logger       *slog.Logger
}

func NewTrainerCardService(r *repository.TrainerCardRepository, tr *repository.TrainerCardTemplateRepository, logger *slog.Logger) *TrainerCardService {
	return &TrainerCardService{repo: r, templateRepo: tr, logger: logger}
}

// ── Trainer Card Types ─────────────────────────────────────────

func (s *TrainerCardService) ListTypes(ctx context.Context) ([]repository.TrainerCardType, error) {
	return s.repo.ListTypes(ctx)
}

func (s *TrainerCardService) CreateType(ctx context.Context, t *repository.TrainerCardType) error {
	if err := s.repo.CreateType(ctx, t); err != nil {
		s.logger.Error("create training card type", "name", t.Name, "error", err)
		return fmt.Errorf("creating training card type: %w", err)
	}
	s.logger.Info("training card type created", "id", t.ID, "name", t.Name)
	return nil
}

func (s *TrainerCardService) UpdateType(ctx context.Context, id string, t *repository.TrainerCardType) error {
	if err := s.repo.UpdateType(ctx, id, t); err != nil {
		s.logger.Error("update training card type", "id", id, "error", err)
		return fmt.Errorf("updating training card type: %w", err)
	}
	return nil
}

func (s *TrainerCardService) DeleteType(ctx context.Context, id string) error {
	if err := s.repo.DeleteType(ctx, id); err != nil {
		s.logger.Error("delete training card type", "id", id, "error", err)
		return fmt.Errorf("deleting training card type: %w", err)
	}
	return nil
}

// ── Trainer Card ───────────────────────────────────────────────

// GetTemplateByLevel returns the level-based training card template (e.g. the
// shared "free" template) so callers can serve it without a per-customer card.
func (s *TrainerCardService) GetTemplateByLevel(ctx context.Context, level string) (*repository.TrainerCardTemplate, error) {
	return s.templateRepo.GetByLevel(ctx, level)
}

func (s *TrainerCardService) GetByCustomerID(ctx context.Context, customerID string) (*repository.TrainerCard, error) {
	card, err := s.repo.GetByCustomerID(ctx, customerID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			s.logger.Info("[TrainerCard.GetByCustomerID] card not found, attempting auto-create", "customer_id", customerID)
			if autoErr := s.AutoCreateDefaultCard(ctx, customerID); autoErr == nil {
				// Retry fetching
				if cardRetried, retryErr := s.repo.GetByCustomerID(ctx, customerID); retryErr == nil {
					return cardRetried, nil
				}
			} else {
				s.logger.Error("[TrainerCard.GetByCustomerID] auto-create failed", "customer_id", customerID, "error", autoErr)
			}
		}
		return nil, fmt.Errorf("get training card: %w", err)
	}
	return card, nil
}

func (s *TrainerCardService) UpsertCard(ctx context.Context, card *repository.TrainerCard) error {
	if err := s.repo.UpsertCard(ctx, card); err != nil {
		s.logger.Error("upsert training card", "customer_id", card.CustomerID, "error", err)
		return fmt.Errorf("upserting training card: %w", err)
	}
	s.logger.Info("training card saved", "customer_id", card.CustomerID, "level", card.Level)
	return nil
}

func (s *TrainerCardService) DeleteCard(ctx context.Context, customerID string) error {
	if err := s.repo.DeleteCard(ctx, customerID); err != nil {
		s.logger.Error("delete training card", "customer_id", customerID, "error", err)
		return fmt.Errorf("deleting training card: %w", err)
	}
	s.logger.Info("training card deleted", "customer_id", customerID)
	return nil
}

// AutoCreateDefaultCard generates a default training card and program assignments for a customer
// based on their latest v2 assessment details and health condition classifications.

// resolveLevelFromStatus maps an assessment physical_status_level to the
// trainer-card / template level string. level_4_5_perf clients are the
// performance tier and resolve to the "5-6" template; everyone else to "1".
func resolveLevelFromStatus(physicalStatusLevel string) string {
	if physicalStatusLevel == "level_4_5_perf" {
		return "5-6"
	}
	return "1"
}

func (s *TrainerCardService) AutoCreateDefaultCard(ctx context.Context, customerID string) error {
	// Never overwrite a manually-managed card. Only the free and 5-6 templates are
	// system-driven; every other client card must follow its own manual setup. A
	// card is system-managed iff its notes carry the auto-generated marker; manual
	// cards (no marker) are preserved so payment/subscription/assessment events that
	// call this never clobber an admin/trainer's edits.
	if existing, err := s.repo.GetByCustomerID(ctx, customerID); err == nil && existing != nil {
		if existing.Notes == nil || !strings.Contains(*existing.Notes, "Auto-generated") {
			s.logger.Info("[AutoCreateDefaultCard] manual card present, preserving it", "customer_id", customerID)
			return nil
		}
	}

	// 1. Get metadata
	meta, err := s.repo.GetActivationMetadata(ctx, customerID)
	if err != nil {
		return fmt.Errorf("getting activation metadata: %w", err)
	}

	// Only proceed if user has active subscription and has completed their v2 assessment
	if !meta.HasActiveSub || meta.PhysicalStatusLevel == "" {
		return nil
	}

	// 2. Ensure assignments in customer_program_assignments are created and retrieve categories
	categories, err := s.repo.EnsureDefaultAssignmentsAndGetCategories(ctx, customerID)
	if err != nil {
		return fmt.Errorf("ensuring program assignments: %w", err)
	}

	// 3. Resolve level
	level := resolveLevelFromStatus(meta.PhysicalStatusLevel)

	// 4. Resolve durations & loads using engine functions
	rec := ResolveSequenceFormula(meta.SpecificSlug)

	gender := "male"
	age := 30
	height := 170.0
	if meta.Gender != nil && *meta.Gender != "" {
		gender = *meta.Gender
	}
	if meta.HeightCm != nil && *meta.HeightCm > 0 {
		height = *meta.HeightCm
	}
	if meta.DateOfBirth != nil && *meta.DateOfBirth != "" {
		// parse YYYY-MM-DD
		if t, parseErr := time.Parse("2006-01-02", *meta.DateOfBirth); parseErr == nil {
			age = time.Now().Year() - t.Year()
			if time.Now().YearDay() < t.YearDay() {
				age--
			}
		}
	}
	ResolveLoadWeight(rec, gender, age, height)

	// 4.5 Auto-calculate & save HR zones based on age (Max HR = 220 - age)
	maxHR := 220 - age
	zone1Lower := roundBpm(float64(maxHR) * 0.50)
	zone1Upper := roundBpm(float64(maxHR) * 0.60)
	zone2Lower := roundBpm(float64(maxHR) * 0.60)
	zone2Upper := roundBpm(float64(maxHR) * 0.70)
	zone3Lower := roundBpm(float64(maxHR) * 0.70)
	zone3Upper := roundBpm(float64(maxHR) * 0.80)
	zone4Lower := roundBpm(float64(maxHR) * 0.80)
	zone4Upper := roundBpm(float64(maxHR) * 0.90)
	zone5Lower := roundBpm(float64(maxHR) * 0.90)
	zone5Upper := roundBpm(float64(maxHR))

	if err := s.repo.UpsertCustomerHRZone(ctx, customerID, maxHR,
		zone1Lower, zone1Upper,
		zone2Lower, zone2Upper,
		zone3Lower, zone3Upper,
		zone4Lower, zone4Upper,
		zone5Lower, zone5Upper,
	); err != nil {
		s.logger.Warn("auto-calculated HR zone upsert failed", "customer_id", customerID, "error", err)
	}

	// Fetch preset movements if user is Tier 2 or Tier 3
	presetItems := make([]repository.TrainerCardSetItem, 0)
	isPresetTier := meta.SubscriptionTier == "sf_tier_2" || meta.SubscriptionTier == "sf_tier_3"
	if isPresetTier {
		presetNames := []string{
			"Arm Rotation",
			"Arm Rotation Stand",
			"Arm Rotation Stand Weight",
			"Barbel Row",
			"Bent Over Fly",
			"Bicep Curls",
			"Chest Press",
			"Cross Up",
		}
		dbItems, err := s.repo.GetMovementsByNames(ctx, presetNames)
		if err != nil {
			s.logger.Warn("fetching preset movements failed", "error", err)
		} else {
			// Map to order of presetNames
			itemMap := make(map[string]repository.TrainerCardSetItem)
			for _, it := range dbItems {
				if it.MovementName != nil {
					itemMap[*it.MovementName] = it
				}
			}
			for idx, name := range presetNames {
				var repsVal int = 20
				var setsVal int = 1
				sortIdx := idx
				if it, ok := itemMap[name]; ok {
					it.Reps = &repsVal
					it.SetsCount = &setsVal
					it.SortOrder = sortIdx
					presetItems = append(presetItems, it)
				} else {
					presetItems = append(presetItems, repository.TrainerCardSetItem{
						MovementName: &name,
						BodyPart:     "upper",
						Reps:         &repsVal,
						SetsCount:    &setsVal,
						SortOrder:    sortIdx,
					})
				}
			}
		}
	}

	// 5. Construct default sequences list: check if a level-based template exists
	tmpl, err := s.templateRepo.GetByLevel(ctx, level)
	var sequences []repository.TrainerCardSequence
	if err == nil && tmpl != nil {
		s.logger.Info("[AutoCreateDefaultCard] found template for level, cloning template contents", "level", level, "customer_id", customerID)
		sequences = make([]repository.TrainerCardSequence, 0)
		for _, tSeq := range tmpl.Sequences {
			var catID string
			for _, c := range categories {
				if strings.ToLower(c.Code) == strings.ToLower(tSeq.ProgramCategoryCode) {
					catID = c.ID
					break
				}
			}
			if catID == "" {
				continue
			}

			sets := make([]repository.TrainerCardSet, 0)
			for _, tSet := range tSeq.Sets {
				items := make([]repository.TrainerCardSetItem, 0)
				for _, tItem := range tSet.Items {
					items = append(items, repository.TrainerCardSetItem{
						MovementID:         tItem.MovementID,
						MovementName:       tItem.MovementName,
						BodyPart:           tItem.BodyPart,
						Equipment:          tItem.Equipment,
						Reps:               tItem.Reps,
						SetsCount:          tItem.SetsCount,
						SortOrder:          tItem.SortOrder,
						BreathingCore:      tItem.BreathingCore,
						BreathingDiaphragm: tItem.BreathingDiaphragm,
						AllowedTiers:       tItem.AllowedTiers,
					})
				}
				sets = append(sets, repository.TrainerCardSet{
					SetNumber:          tSet.SetNumber,
					Duration:           tSet.Duration,
					EquipmentUpper:     tSet.EquipmentUpper,
					EquipmentLower:     tSet.EquipmentLower,
					TypeID:             tSet.TypeID,
					BPM:                tSet.BPM,
					ExtraLoad:          tSet.ExtraLoad,
					Notes:              tSet.Notes,
					SortOrder:          tSet.SortOrder,
					Pattern:            tSet.Pattern,
					BreathingCore:      tSet.BreathingCore,
					BreathingDiaphragm: tSet.BreathingDiaphragm,
					Items:              items,
				})
			}
			sequences = append(sequences, repository.TrainerCardSequence{
				ProgramCategoryID: catID,
				Duration:          tSeq.Duration,
				SortOrder:         tSeq.SortOrder,
				Sets:              sets,
			})
		}
	} else {
		s.logger.Info("[AutoCreateDefaultCard] template not found or error, falling back to default preset setup", "level", level, "error", err)
		sequences = make([]repository.TrainerCardSequence, 0)
		for i, cat := range categories {
			var durationVal string
			var equipUpper, equipLower string
			var bpmVal string

			switch cat.Code {
			case "functional":
				if rec.Formula.FCMins > 0 {
					durationVal = fmt.Sprintf("%d'", rec.Formula.FCMins)
				}
				bpmVal = fmt.Sprintf("%d-%d", zone1Lower, zone1Upper)
			case "cardiorespiratory":
				if rec.Formula.CCMins > 0 {
					durationVal = fmt.Sprintf("%d'", rec.Formula.CCMins)
				}
				equipUpper = formatLoadWeight(rec.CardioLoad.UpperBodyKg)
				equipLower = formatLoadWeight(rec.CardioLoad.LowerBodyKg)
				bpmVal = fmt.Sprintf("%d-%d", zone2Lower, zone2Upper)
			case "metabolic":
				if rec.Formula.MCMins > 0 {
					durationVal = fmt.Sprintf("%d'", rec.Formula.MCMins)
				}
				equipUpper = formatLoadWeight(rec.MetabLoad.UpperBodyKg)
				equipLower = formatLoadWeight(rec.MetabLoad.LowerBodyKg)
				bpmVal = fmt.Sprintf("%d-%d", zone3Lower, zone3Upper)
			}

			itemsVal := []repository.TrainerCardSetItem{}
			if isPresetTier {
				itemsVal = presetItems
			}

			sets := []repository.TrainerCardSet{
				{
					SetNumber:      1,
					EquipmentUpper: &equipUpper,
					EquipmentLower: &equipLower,
					SortOrder:      0,
					BPM:            &bpmVal,
					Items:          itemsVal,
				},
			}

			sequences = append(sequences, repository.TrainerCardSequence{
				ProgramCategoryID: cat.ID,
				Duration:          &durationVal,
				SortOrder:         i,
				Sets:              sets,
			})
		}
	}

	notes := "Auto-generated upon subscription activation."
	card := &repository.TrainerCard{
		CustomerID: customerID,
		Level:      level,
		Notes:      &notes,
		Sequences:  sequences,
	}

	if err := s.repo.UpsertCard(ctx, card); err != nil {
		return fmt.Errorf("saving auto-created card: %w", err)
	}

	s.logger.Info("auto-created default trainer card", "customer_id", customerID, "level", level)
	return nil
}

// ShouldRegenFromTemplate reports whether an auto-generated preset card is stale
// relative to the level template — the card's level no longer matches the
// assessment-resolved level, or the template was edited after the card was last
// built. Lets template + per-movement access edits propagate to existing cards.
// Manually customised cards (notes without the "Auto-generated" marker) are left
// untouched, as is a level with no template (keeps the preset fallback).
func (s *TrainerCardService) ShouldRegenFromTemplate(ctx context.Context, customerID, cardLevel string, cardUpdatedAt time.Time, cardNotes *string) (bool, error) {
	if cardNotes == nil || !strings.Contains(*cardNotes, "Auto-generated") {
		return false, nil
	}
	meta, err := s.repo.GetActivationMetadata(ctx, customerID)
	if err != nil {
		return false, err
	}
	if meta.PhysicalStatusLevel == "" {
		return false, nil
	}
	level := resolveLevelFromStatus(meta.PhysicalStatusLevel)
	tmpl, err := s.templateRepo.GetByLevel(ctx, level)
	if err != nil || tmpl == nil {
		return false, nil
	}
	return cardLevel != level || cardUpdatedAt.Before(tmpl.UpdatedAt), nil
}

func formatLoadWeight(val float64) string {
	if val <= 0 {
		return ""
	}
	return strconv.FormatFloat(val, 'f', -1, 64) + " kg"
}

func roundBpm(val float64) int {
	intVal := int(val + 0.5)
	lastDigit := intVal % 10
	base := (intVal / 10) * 10
	if lastDigit <= 5 {
		return base
	}
	return base + 10
}

