package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"regexp"
	"strings"
	"time"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

// AssessmentV2Service orchestrates the SF v2 assessment flow.
//
//   submit (Phase A only)         → returns AssessmentV2 with program_type & waitlist routing
//   submit (Phase A + B)          → adds rest_score + chronobiology_window
//   submit (Phase A + B + C)      → adds nutrition_score + system_score_v2
//
// Movement Score is NOT computed here — it accrues later from session
// completion logs (Phase 5 mobile + future session work). The result
// page handles the "movement = pending" state.
type AssessmentV2Service struct {
	repo               *repository.AssessmentV2Repository
	conditionRepo      *repository.ConditionRepository
	userRepo           *repository.UserRepository
	subRepo            *repository.ClientSubscriptionRepository
	trainerCardService *TrainerCardService
	logger             *slog.Logger
}

func NewAssessmentV2Service(
	repo *repository.AssessmentV2Repository,
	cr *repository.ConditionRepository,
	ur *repository.UserRepository,
	subRepo *repository.ClientSubscriptionRepository,
	tcs *TrainerCardService,
	logger *slog.Logger,
) *AssessmentV2Service {
	return &AssessmentV2Service{
		repo:               repo,
		conditionRepo:      cr,
		userRepo:           ur,
		subRepo:            subRepo,
		trainerCardService: tcs,
		logger:             logger,
	}
}

// SubmitV2Input is the full payload the client sends. PhaseA is always
// required; PhaseB and PhaseC are optional so users can save partial
// progress and come back later (mobile draft persistence in Fase 5).
type SubmitV2Input struct {
	PhaseA model.PhaseAInput  `json:"phase_a" validate:"required"`
	PhaseB *model.PhaseBInput `json:"phase_b,omitempty"`
	PhaseC *model.PhaseCInput `json:"phase_c,omitempty"`
}

func (s *AssessmentV2Service) Submit(
	ctx context.Context, userID string, in *SubmitV2Input, callerRole model.Role,
) (*model.AssessmentV2, error) {
	prog := ResolveProgramType(in.PhaseA)

	// Resolve classification & specific condition IDs by slug (if provided).
	var classificationID, specificID *string
	if in.PhaseA.ClassificationSlug != nil && *in.PhaseA.ClassificationSlug != "" {
		c, err := s.conditionRepo.GetClassificationBySlug(ctx, *in.PhaseA.ClassificationSlug)
		if err != nil && !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("lookup classification", "slug", *in.PhaseA.ClassificationSlug, "error", err)
			return nil, fmt.Errorf("classification lookup: %w", err)
		}
		if c != nil {
			classificationID = &c.ID
		}
	}
	if in.PhaseA.SpecificConditionSlug != nil && *in.PhaseA.SpecificConditionSlug != "" {
		// Use repo filter (slug is unique)
		list, err := s.conditionRepo.ListSpecificConditions(ctx, repository.SpecificConditionFilter{
			IncludeInactive: true,
		})
		if err != nil {
			s.logger.Error("list specific", "error", err)
			return nil, fmt.Errorf("specific lookup: %w", err)
		}
		for i := range list {
			if list[i].Slug == *in.PhaseA.SpecificConditionSlug {
				specificID = &list[i].ID
				break
			}
		}
	}

	a := &model.AssessmentV2{
		UserID:              &userID,
		Version:             model.AssessmentVersionV2,
		Status:              model.AssessmentSubmitted,
		PhaseA:              in.PhaseA,
		PhaseB:              in.PhaseB,
		PhaseC:              in.PhaseC,
		ClassificationID:    classificationID,
		SpecificConditionID: specificID,
		PhysicalStatusLevel: in.PhaseA.PhysicalStatusLevel,
		ProgramType:         prog,
	}

	// Phase B → Rest Score + Chronobiology Window
	if in.PhaseB != nil {
		rest := ComputeRestScore(*in.PhaseB)
		a.RestScore = &rest
		w := ResolveChronobiologyWindow(in.PhaseA.SpecificConditionSlug, prog, in.PhaseB)
		a.ChronobiologyWindow = &w
	} else if prog == model.ProgramWaitlist {
		// Waitlist still gets a static window (the "Gerakan dari Kursi" copy
		// is mobile-only — engine just emits empty window).
	}

	// Phase C → Nutrition Score
	var nutritionPtr *float64
	if in.PhaseC != nil {
		n := ComputeNutritionScore(*in.PhaseC)
		a.NutritionScore = &n
		nutritionPtr = &n
	}

	// System Score (when both Rest + Nutrition available; movement nil for now)
	if a.RestScore != nil && nutritionPtr != nil {
		w, err := s.repo.GetActiveScoreWeights(ctx)
		if err != nil {
			s.logger.Warn("score weights fetch failed, using default", "error", err)
			w = model.DefaultSystemScoreWeights()
		}
		total, _ := ComputeSystemScoreV2(nil, *nutritionPtr, *a.RestScore, w)
		a.SystemScore = &total
	}

	// Calculate Program Map (Sequence Formula & Load Weight)
	a.ProgramMap = ResolveSequenceFormula(in.PhaseA.SpecificConditionSlug)
	
	// Try to get user profile to resolve LoadWeight
	if profile, err := s.userRepo.GetProfile(ctx, userID); err == nil && profile != nil {
		gender := "male" // default
		age := 30        // default
		height := 170.0  // default

		if profile.Gender != nil && *profile.Gender != "" {
			gender = *profile.Gender
		}
		if profile.HeightCm != nil && *profile.HeightCm > 0 {
			height = *profile.HeightCm
		}
		if profile.DateOfBirth != nil && *profile.DateOfBirth != "" {
			// parse YYYY-MM-DD
			if t, err := time.Parse("2006-01-02", *profile.DateOfBirth); err == nil {
				age = time.Now().Year() - t.Year()
				if time.Now().YearDay() < t.YearDay() {
					age--
				}
			}
		}
		ResolveLoadWeight(a.ProgramMap, gender, age, height)
	} else {
		// fallback default
		ResolveLoadWeight(a.ProgramMap, "male", 30, 170)
	}

	// Flags
	a.Flags = GenerateV2Flags(in.PhaseA, in.PhaseB, in.PhaseC, prog)

	// Persist
	if err := s.repo.CreateV2(ctx, a); err != nil {
		s.logger.Error("create v2 assessment", "error", err)
		return nil, fmt.Errorf("creating v2 assessment: %w", err)
	}
	s.logger.Info("v2 assessment created",
		"id", a.ID, "user_id", userID, "program", prog,
		"rest", a.RestScore, "nutrition", a.NutritionScore, "system", a.SystemScore)

	// Auto-create/regenerate the default training card on assessment submit.
	// As requested, this now unconditionally overwrites ANY existing training card
	// for the client whenever a new manual assessment is submitted by anyone (Trainer, Consultant, etc).
	if s.trainerCardService != nil {
		s.logger.Info("[AssessmentV2.Submit] unconditionally regenerating training card from assessment", "user_id", userID, "role", callerRole)
		_ = s.trainerCardService.DeleteCard(ctx, userID)
		if tcErr := s.trainerCardService.AutoCreateDefaultCard(ctx, userID); tcErr != nil {
			s.logger.Error("[AssessmentV2.Submit] failed to auto-create training card", "user_id", userID, "error", tcErr)
		}
	}

	return a, nil
}

func (s *AssessmentV2Service) Get(ctx context.Context, id string) (*model.AssessmentV2, error) {
	a, err := s.repo.GetV2ByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get v2 assessment", "id", id, "error", err)
		}
		return nil, err
	}
	return a, nil
}

func (s *AssessmentV2Service) Latest(ctx context.Context, userID string) (*model.AssessmentV2, error) {
	a, err := s.repo.LatestV2ByUser(ctx, userID)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("latest v2 assessment", "user_id", userID, "error", err)
		}
		return nil, err
	}
	return a, nil
}

// ─── System Score Weights ─────────────────────────────────────────

func (s *AssessmentV2Service) GetActiveWeights(ctx context.Context) (model.SystemScoreWeights, error) {
	return s.repo.GetActiveScoreWeights(ctx)
}

type UpdateWeightsInput struct {
	Name         string  `json:"name"          validate:"required,min=2,max=80"`
	MovementPct  int16   `json:"movement_pct"  validate:"min=0,max=100"`
	NutritionPct int16   `json:"nutrition_pct" validate:"min=0,max=100"`
	RestPct      int16   `json:"rest_pct"      validate:"min=0,max=100"`
	Notes        *string `json:"notes,omitempty"`
}

func (s *AssessmentV2Service) UpdateWeights(
	ctx context.Context, in UpdateWeightsInput, updatedBy string,
) (*model.SystemScoreWeights, error) {
	w := &model.SystemScoreWeights{
		Name:         in.Name,
		MovementPct:  in.MovementPct,
		NutritionPct: in.NutritionPct,
		RestPct:      in.RestPct,
		Notes:        in.Notes,
	}
	if err := s.repo.UpdateActiveScoreWeights(ctx, w, &updatedBy); err != nil {
		s.logger.Error("update score weights", "error", err)
		return nil, err
	}
	s.logger.Info("score weights updated",
		"id", w.ID, "movement", w.MovementPct, "nutrition", w.NutritionPct, "rest", w.RestPct)
	return w, nil
}

// ─── Training Card ───────────────────────────────────────────────

var ErrSubscriptionRequired = errors.New("active subscription required to view training card")

// freeTemplateLevel is the level key of the shared template served to free-tier
// (registered-but-unpaid) clients.
const freeTemplateLevel = "free"

// autoGeneratedMarker is the substring AutoCreateDefaultCard writes into a card's
// notes. Its presence means the card is system-managed and may be regenerated;
// a manually edited card must NOT contain it (see trainer card UpsertCard).
const autoGeneratedMarker = "Auto-generated"

// templateToTrainerCard converts a level-based template into the per-customer
// TrainerCard shape so the free template flows through the same response mapping
// as a personalized card. Template items already carry resolved video URLs.
func templateToTrainerCard(tmpl *repository.TrainerCardTemplate, userID string) *repository.TrainerCard {
	seqs := make([]repository.TrainerCardSequence, 0, len(tmpl.Sequences))
	for _, ts := range tmpl.Sequences {
		sets := make([]repository.TrainerCardSet, 0, len(ts.Sets))
		for _, tset := range ts.Sets {
			items := make([]repository.TrainerCardSetItem, 0, len(tset.Items))
			for _, ti := range tset.Items {
				items = append(items, repository.TrainerCardSetItem{
					ID:                 ti.ID,
					SetID:              ti.SetID,
					MovementID:         ti.MovementID,
					MovementName:       ti.MovementName,
					BodyPart:           ti.BodyPart,
					Equipment:          ti.Equipment,
					Reps:               ti.Reps,
					SetsCount:          ti.SetsCount,
					SortOrder:          ti.SortOrder,
					VideoURLMale:       ti.VideoURLMale,
					VideoURLFemale:     ti.VideoURLFemale,
					BreathingCore:      ti.BreathingCore,
					BreathingDiaphragm: ti.BreathingDiaphragm,
					AllowedTiers:       ti.AllowedTiers,
				})
			}
			sets = append(sets, repository.TrainerCardSet{
				ID:                 tset.ID,
				SequenceID:         tset.SequenceID,
				SetNumber:          tset.SetNumber,
				Duration:           tset.Duration,
				EquipmentUpper:     tset.EquipmentUpper,
				EquipmentLower:     tset.EquipmentLower,
				TypeID:             tset.TypeID,
				TypeName:           tset.TypeName,
				BPM:                tset.BPM,
				ExtraLoad:          tset.ExtraLoad,
				Notes:              tset.Notes,
				SortOrder:          tset.SortOrder,
				Pattern:            tset.Pattern,
				BreathingCore:      tset.BreathingCore,
				BreathingDiaphragm: tset.BreathingDiaphragm,
				Items:              items,
			})
		}
		seqs = append(seqs, repository.TrainerCardSequence{
			ID:                  ts.ID,
			ProgramCategoryID:   ts.ProgramCategoryID,
			ProgramCategoryName: ts.ProgramCategoryName,
			ProgramCategoryCode: ts.ProgramCategoryCode,
			Duration:            ts.Duration,
			SortOrder:           ts.SortOrder,
			Sets:                sets,
		})
	}
	return &repository.TrainerCard{
		ID:         tmpl.ID,
		CustomerID: userID,
		Level:      tmpl.Level,
		Notes:      tmpl.Notes,
		CreatedAt:  tmpl.CreatedAt,
		UpdatedAt:  tmpl.UpdatedAt,
		Sequences:  seqs,
	}
}

// GetTrainingCard retrieves the latest assessment for the user, checks subscription,
// and dynamically generates the Training Card based on the calculated ProgramMap.
func (s *AssessmentV2Service) GetTrainingCard(ctx context.Context, userID string) (*model.TrainingCardResponse, error) {
	// 1. Determine subscription status. Paid-active clients get their personalized
	//    card; everyone else (no subscription, pending payment, or the sf_free tier)
	//    is served the shared "free" level template so the Training Card menu stays
	//    open right after sign-up — no payment or assessment required.
	activeSub, subErr := s.subRepo.GetActiveSubscription(ctx, userID)
	if subErr != nil && !errors.Is(subErr, repository.ErrNotFound) {
		return nil, fmt.Errorf("checking subscription: %w", subErr)
	}
	isPaidActive := subErr == nil &&
		activeSub.Status == "active" &&
		activeSub.Tier != "sf_free" && activeSub.Tier != "free"

	// 2.5 Get user profile to determine gender for video resolution
	userProfile, _ := s.userRepo.GetProfile(ctx, userID)

	var dbCard *repository.TrainerCard
	
	// 2. Fetch the trainer card. GetByCustomerID auto-creates one from the
	//    assessment-derived level when none exists; if the user has neither a
	//    card nor an assessment yet, it returns ErrNotFound (handler → 404).
	card, cerr := s.trainerCardService.GetByCustomerID(ctx, userID)
	
	// We no longer check hasPublishedCard here. If they are unpaid, they always see preview.

	var isPreview bool
	if !isPaidActive {
		isPreview = true
		
		if card != nil && len(card.Sequences) > 0 {
			// Tease 3 videos directly from their own personal card!
			dbCard = card
			truncateToNVideos(dbCard, 3)
		} else if card != nil && card.Level != "" {
			// Fallback to template if card is empty for some reason
			tmpl, terr := s.trainerCardService.GetTemplateByLevel(ctx, card.Level)
			if terr == nil {
				dbCard = templateToTrainerCard(tmpl, userID)
				truncateToNVideos(dbCard, 3)
			}
		} else {
			// If they have no personal card (because they are unpaid), use their assessment level
			if meta, err := s.trainerCardService.repo.GetActivationMetadata(ctx, userID); err == nil && meta != nil && meta.PhysicalStatusLevel != "" {
				levelStr := resolveLevelFromStatus(meta.PhysicalStatusLevel)
				tmpl, terr := s.trainerCardService.GetTemplateByLevel(ctx, levelStr)
				if terr == nil && tmpl != nil {
					dbCard = templateToTrainerCard(tmpl, userID)
					truncateToNVideos(dbCard, 3)
				}
			}
		}

		if dbCard == nil {
			tmplFree, terrFree := s.trainerCardService.GetTemplateByLevel(ctx, "free")
			
			dbCard = &repository.TrainerCard{
				CustomerID: userID,
				Level:      "free",
				Sequences:  make([]repository.TrainerCardSequence, 0),
			}

			if terrFree == nil && tmplFree != nil {
				cardFree := templateToTrainerCard(tmplFree, userID)
				truncateToNVideos(cardFree, 3)
				dbCard.Sequences = append(dbCard.Sequences, cardFree.Sequences...)
			}

			if len(dbCard.Sequences) == 0 {
				return nil, repository.ErrNotFound
			}
		}
	} else {
		if cerr != nil {
			// If they are paid active but have no card/assessment at all
			if errors.Is(cerr, repository.ErrNotFound) {
				return nil, repository.ErrNotFound
			}
			return nil, fmt.Errorf("getting database trainer card: %w", cerr)
		}
		dbCard = card
		
		// If it's not published, they can't see it unless we are falling back to something else.
		// But since they are paid active, they should just see "Not Created Yet" (404) if it's draft.
		if dbCard.Status != "published" {
			return nil, repository.ErrNotFound
		}

		//    AutoCreateDefaultCard marker in its notes AND is not published. Manually edited/published cards
		//    must never be overwritten automatically.
		isAutoGenerated := dbCard.Notes != nil && strings.Contains(*dbCard.Notes, autoGeneratedMarker) && dbCard.Status != "published"

		// 3.5 Check if the user has sf_tier_2 or sf_tier_3 active subscription
		// but the auto-generated card sets are empty or have fewer than 8 items (e.g. upgraded from sf_tier_1).
		isPresetTier := activeSub.Tier == "sf_tier_2" || activeSub.Tier == "sf_tier_3"
		needsRegen := false
		if isPresetTier && isAutoGenerated {
			if len(dbCard.Sequences) == 0 {
				needsRegen = true
			} else {
				for _, seq := range dbCard.Sequences {
					if len(seq.Sets) == 0 {
						needsRegen = true
						break
					}
					// Only require 8 items for Functional Conditioning sequences
					if seq.ProgramCategoryCode != nil && strings.ToLower(*seq.ProgramCategoryCode) == "functional" {
						for _, set := range seq.Sets {
							if len(set.Items) < 8 {
								needsRegen = true
								break
							}
						}
					}
					if needsRegen {
						break
					}
				}
			}
		}

		// Also regenerate when a level template now exists that the (auto-generated)
		// card predates or no longer matches — so template + per-movement access
		// edits propagate to existing cards.
		if isPresetTier && isAutoGenerated && !needsRegen {
			if should, serr := s.trainerCardService.ShouldRegenFromTemplate(ctx, userID, dbCard.Level, dbCard.UpdatedAt, dbCard.Notes); serr == nil && should {
				needsRegen = true
			}
		}

		if needsRegen {
			s.logger.Info("[GetTrainingCard] user tier upgraded or preset movements missing, regenerating trainer card", "user_id", userID, "tier", activeSub.Tier)
			if delErr := s.trainerCardService.DeleteCard(ctx, userID); delErr == nil || errors.Is(delErr, repository.ErrNotFound) {
				if autoErr := s.trainerCardService.AutoCreateDefaultCard(ctx, userID); autoErr == nil {
					// Reload the card
					if reloadedCard, reloadErr := s.trainerCardService.GetByCustomerID(ctx, userID); reloadErr == nil {
						dbCard = reloadedCard
					}
				}
			}
		}
	}

	// 4. Map to model.TrainingCardResponse
	clientSeqs := make([]model.ClientSequence, 0)
	for _, seq := range dbCard.Sequences {
		sets := make([]model.ClientSet, 0)
		for _, set := range seq.Sets {
			items := make([]model.ClientItem, 0)
			for _, item := range set.Items {
				items = append(items, model.ClientItem{
					ID:             item.ID,
					SetID:          item.SetID,
					MovementID:     item.MovementID,
					MovementName:   item.MovementName,
					BodyPart:       item.BodyPart,
					Equipment:      item.Equipment,
					Reps:           item.Reps,
					SetsCount:      item.SetsCount,
					SortOrder:      item.SortOrder,
					VideoURLMale:   item.VideoURLMale,
					VideoURLFemale: item.VideoURLFemale,
					AllowedTiers:   item.AllowedTiers,
					CreatedAt:      item.CreatedAt,
					UpdatedAt:      item.UpdatedAt,
				})
			}
			sets = append(sets, model.ClientSet{
				ID:             set.ID,
				SequenceID:     set.SequenceID,
				SetNumber:      set.SetNumber,
				Duration:       set.Duration,
				EquipmentUpper: set.EquipmentUpper,
				EquipmentLower: set.EquipmentLower,
				TypeID:         set.TypeID,
				TypeName:       set.TypeName,
				BPM:            set.BPM,
				ExtraLoad:      set.ExtraLoad,
				Notes:          set.Notes,
				SortOrder:      set.SortOrder,
				CreatedAt:      set.CreatedAt,
				UpdatedAt:      set.UpdatedAt,
				Items:          items,
			})
		}
		clientSeqs = append(clientSeqs, model.ClientSequence{
			ID:                  seq.ID,
			TrainerCardID:       seq.TrainerCardID,
			ProgramCategoryID:   seq.ProgramCategoryID,
			ProgramCategoryName: seq.ProgramCategoryName,
			ProgramCategoryCode: seq.ProgramCategoryCode,
			Duration:            seq.Duration,
			SortOrder:           seq.SortOrder,
			CreatedAt:           seq.CreatedAt,
			UpdatedAt:           seq.UpdatedAt,
			Sets:                sets,
		})
	}

	// Map sequences to ProgramCategory list for mobile app backward-compatibility
	mapSequences := func(seqs []model.ClientSequence) []model.ProgramCategory {
		cats := make([]model.ProgramCategory, 0)
		for _, seq := range seqs {
			var pCat model.ProgramCategory

			switch seq.ProgramCategoryCode {
			case "functional":
				pCat.Type = "FUNCTIONAL"
			case "cardiorespiratory":
				pCat.Type = "CARDIO"
			case "metabolic":
				pCat.Type = "METABOLIC"
			default:
				pCat.Type = strings.ToUpper(seq.ProgramCategoryCode)
			}

			if seq.Duration != nil {
				pCat.Duration = *seq.Duration
			} else {
				pCat.Duration = ""
			}

			pCat.Sets = make([]model.TrainingSet, 0)
			for _, set := range seq.Sets {
				var tSet model.TrainingSet
				tSet.SetName = fmt.Sprintf("Set %d", set.SetNumber)
				tSet.DurationMins = 5 // default
				if set.Duration != nil {
					var mins int
					if _, err := fmt.Sscanf(*set.Duration, "%d", &mins); err == nil {
						tSet.DurationMins = mins
					}
				}

				if set.BPM != nil {
					tSet.BpmRange = *set.BPM
				} else {
					tSet.BpmRange = ""
				}

				if set.EquipmentUpper != nil {
					tSet.EquipmentUpper = cleanWeightString(*set.EquipmentUpper)
				}
				if set.EquipmentLower != nil {
					tSet.EquipmentLower = cleanWeightString(*set.EquipmentLower)
				}

				tSet.Tags = make([]string, 0)
				if set.TypeName != nil && *set.TypeName != "" {
					tSet.Tags = append(tSet.Tags, *set.TypeName)
				}
				if set.EquipmentUpper != nil && *set.EquipmentUpper != "" {
					tSet.Tags = append(tSet.Tags, cleanWeightString(*set.EquipmentUpper))
				}
				if set.EquipmentLower != nil && *set.EquipmentLower != "" {
					tSet.Tags = append(tSet.Tags, cleanWeightString(*set.EquipmentLower))
				}
				if set.ExtraLoad != nil && *set.ExtraLoad != "" {
					tSet.Tags = append(tSet.Tags, cleanWeightString(*set.ExtraLoad))
				}

				tSet.Movements = make([]model.TrainingMovement, 0)
				for _, item := range set.Items {
					var tm model.TrainingMovement
					if item.MovementID != nil {
						tm.ID = *item.MovementID
					} else {
						tm.ID = item.ID
					}
					tm.Sequence = item.SortOrder + 1
					if item.MovementName != nil {
						tm.Title = *item.MovementName
					}
					tm.MovementTag = item.BodyPart
					tm.AllowedTiers = item.AllowedTiers

					// Determine correct video URL based on gender
					gender := "female"
					if userProfile != nil && userProfile.Gender != nil {
						gender = strings.ToLower(*userProfile.Gender)
					}
					if gender == "male" || gender == "men" {
						if item.VideoURLMale != nil {
							tm.VideoUrl = *item.VideoURLMale
						} else if item.VideoURLFemale != nil {
							tm.VideoUrl = *item.VideoURLFemale
						}
					} else {
						if item.VideoURLFemale != nil {
							tm.VideoUrl = *item.VideoURLFemale
						} else if item.VideoURLMale != nil {
							tm.VideoUrl = *item.VideoURLMale
						}
					}

					tSet.Movements = append(tSet.Movements, tm)
				}
				pCat.Sets = append(pCat.Sets, tSet)
			}
			cats = append(cats, pCat)
		}
		return cats
	}

	res := &model.TrainingCardResponse{
		ID:           dbCard.ID,
		CustomerID:   dbCard.CustomerID,
		CustomerName: dbCard.CustomerName,
		Level:        dbCard.Level,
		Notes:        dbCard.Notes,
		CreatedBy:    dbCard.CreatedBy,
		CreatedAt:    dbCard.CreatedAt,
		UpdatedAt:    dbCard.UpdatedAt,
		Sequences:    clientSeqs,
		FullProgram:  mapSequences(clientSeqs),
		DailyReset:   mapSequences(clientSeqs), // both tabs show user's customized card
	}
	
	if isPreview {
		previewFlag := true
		res.IsPreview = &previewFlag
	}

	return res, nil
}

var (
	reDec2 = regexp.MustCompile(`(\d+)\.00`)
	reDec1 = regexp.MustCompile(`(\d+\.\d)0`)
)

func cleanWeightString(w string) string {
	w = reDec2.ReplaceAllString(w, "$1")
	w = reDec1.ReplaceAllString(w, "${1}")
	return w
}

func truncateToNVideos(dbCard *repository.TrainerCard, n int) {
	if dbCard == nil {
		return
	}
	itemCount := 0
	var newSeqs []repository.TrainerCardSequence

	for _, seq := range dbCard.Sequences {
		if itemCount >= n {
			break
		}
		var newSets []repository.TrainerCardSet
		for _, set := range seq.Sets {
			if itemCount >= n {
				break
			}
			var newItems []repository.TrainerCardSetItem
			for _, item := range set.Items {
				if itemCount < n {
					newItems = append(newItems, item)
					itemCount++
				} else {
					break
				}
			}
			if len(newItems) > 0 {
				set.Items = newItems
				newSets = append(newSets, set)
			}
		}
		if len(newSets) > 0 {
			seq.Sets = newSets
			newSeqs = append(newSeqs, seq)
		}
	}
	dbCard.Sequences = newSeqs
}
