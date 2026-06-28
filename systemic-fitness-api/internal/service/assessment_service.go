package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

// ════════════════════════════════════════════════════════════════════
//  Assessment Service
//
//  All submit paths share the same pipeline:
//   1. compute scores via assessment_engine (pure fns)
//   2. classify each pillar
//   3. generate flags / insight / recommendations
//   4. persist via repository.AssessmentRepository
//   5. return the populated model.Assessment
// ════════════════════════════════════════════════════════════════════

var (
	ErrAssessmentNotFound   = errors.New("assessment not found")
	ErrAssessmentForbidden  = errors.New("forbidden: not your assessment")
	ErrInvalidReviewStatus  = errors.New("invalid review status — only verified or revised")
	ErrPaidOnly             = errors.New("only paid assessments can be reviewed")
)

type AssessmentService struct {
	repo   *repository.AssessmentRepository
	logger *slog.Logger
}

func NewAssessmentService(
	repo *repository.AssessmentRepository,
	logger *slog.Logger,
) *AssessmentService {
	return &AssessmentService{repo: repo, logger: logger}
}

// ─── Input DTOs ────────────────────────────────────────────────────

type SubmitFreeInput struct {
	Sleep    model.SleepInput    `json:"sleep" validate:"required"`
	Movement model.MovementInput `json:"movement" validate:"required"`
}

type SubmitPaidInput struct {
	Sleep     model.SleepInput     `json:"sleep" validate:"required"`
	Movement  model.MovementInput  `json:"movement" validate:"required"`
	Metabolic model.MetabolicInput `json:"metabolic" validate:"required"`
}

type ReviewInput struct {
	Status        model.AssessmentStatus `json:"status" validate:"required,oneof=verified revised"`
	ReviewerNotes string                 `json:"reviewer_notes" validate:"omitempty,max=2000"`
	// Optional trainer override of the lab values. If provided, scores are
	// recomputed before persistence.
	Metabolic *model.MetabolicInput `json:"metabolic,omitempty"`
}

// ─── Submit paths ──────────────────────────────────────────────────

// SubmitFree persists a free assessment for an authenticated user.
func (s *AssessmentService) SubmitFree(ctx context.Context, userID string, input *SubmitFreeInput) (*model.Assessment, error) {
	a := s.buildAssessment(&userID, model.TierFree, input.Sleep, input.Movement, nil)
	if err := s.repo.Create(ctx, a); err != nil {
		s.logger.Error("submit free: create assessment", "user_id", userID, "error", err)
		return nil, fmt.Errorf("creating assessment: %w", err)
	}
	s.logger.Info("free assessment submitted", "assessment_id", a.ID, "user_id", userID, "system_score", a.Scores.System)
	return a, nil
}

// SubmitPaid persists a paid assessment (includes metabolic panel).
func (s *AssessmentService) SubmitPaid(ctx context.Context, userID string, input *SubmitPaidInput) (*model.Assessment, error) {
	metabolic := input.Metabolic
	a := s.buildAssessment(&userID, model.TierPaid, input.Sleep, input.Movement, &metabolic)
	if err := s.repo.Create(ctx, a); err != nil {
		s.logger.Error("submit paid: create assessment", "user_id", userID, "error", err)
		return nil, fmt.Errorf("creating assessment: %w", err)
	}
	s.logger.Info("paid assessment submitted", "assessment_id", a.ID, "user_id", userID, "system_score", a.Scores.System)
	return a, nil
}

// buildAssessment is a thin wrapper over computeAssessmentEntity for
// use by submit paths where metabolic may or may not be present.
func (s *AssessmentService) buildAssessment(
	userID *string,
	tier model.AssessmentTier,
	sleep model.SleepInput,
	movement model.MovementInput,
	metabolic *model.MetabolicInput,
) *model.Assessment {
	return computeAssessmentEntity(userID, tier, sleep, movement, metabolic)
}

// ─── Queries ───────────────────────────────────────────────────────

func (s *AssessmentService) ListMine(ctx context.Context, userID string, params model.PaginationParams) ([]*model.Assessment, int, error) {
	return s.repo.ListByUser(ctx, userID, params)
}

// GetByID enforces RBAC: owner, trainer, admin, finance, or owner role can view.
// For clients, only their own assessments are visible.
func (s *AssessmentService) GetByID(ctx context.Context, id, callerID string, callerRole model.Role) (*model.Assessment, error) {
	a, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrAssessmentNotFound
		}
		return nil, fmt.Errorf("fetching assessment: %w", err)
	}

	// Trainers and above can view any assessment; clients can only view their own.
	if callerRole == model.RoleClient {
		if a.UserID == nil || *a.UserID != callerID {
			return nil, ErrAssessmentForbidden
		}
	}
	return a, nil
}

// GetPrevious returns the assessment created immediately before the
// given assessment, for the same user. Enforces the same RBAC as
// GetByID so clients can only view their own history.
func (s *AssessmentService) GetPrevious(ctx context.Context, currentID, callerID string, callerRole model.Role) (*model.Assessment, error) {
	current, err := s.repo.GetByID(ctx, currentID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrAssessmentNotFound
		}
		return nil, fmt.Errorf("fetching current assessment: %w", err)
	}
	if callerRole == model.RoleClient {
		if current.UserID == nil || *current.UserID != callerID {
			return nil, ErrAssessmentForbidden
		}
	}
	prev, err := s.repo.GetPreviousForAssessment(ctx, currentID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrAssessmentNotFound
		}
		return nil, fmt.Errorf("fetching previous assessment: %w", err)
	}
	return prev, nil
}

// GetLatest returns the most recent assessment owned by callerID,
// optionally filtered by tier ("free" or "paid"). Returns
// ErrAssessmentNotFound if the user has none yet.
func (s *AssessmentService) GetLatest(ctx context.Context, callerID, tier string) (*model.Assessment, error) {
	a, err := s.repo.GetLatestByUser(ctx, callerID, tier)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrAssessmentNotFound
		}
		return nil, fmt.Errorf("fetching latest assessment: %w", err)
	}
	return a, nil
}

func (s *AssessmentService) ListPendingReview(ctx context.Context, params model.PaginationParams) ([]*model.Assessment, int, error) {
	return s.repo.ListPendingReview(ctx, params)
}

// ListAll returns paginated assessments for admin/owner. Filters are
// optional (nil/empty = no constraint).
func (s *AssessmentService) ListAll(ctx context.Context, params model.PaginationParams, filter repository.AssessmentListFilter) ([]*model.Assessment, int, error) {
	return s.repo.ListAll(ctx, params, filter)
}

// ─── Trainer review ────────────────────────────────────────────────

func (s *AssessmentService) Review(ctx context.Context, id, reviewerID string, input *ReviewInput) (*model.Assessment, error) {
	if input.Status != model.AssessmentVerified && input.Status != model.AssessmentRevised {
		return nil, ErrInvalidReviewStatus
	}

	existing, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrAssessmentNotFound
		}
		return nil, fmt.Errorf("fetching assessment: %w", err)
	}
	if existing.Tier != model.TierPaid {
		return nil, ErrPaidOnly
	}

	// Figure out scores. If trainer supplied a new metabolic panel, recompute.
	metabolicUsed := existing.Metabolic
	if input.Metabolic != nil {
		metabolicUsed = input.Metabolic
	}

	var metabolicScore *int
	var metabolicClass *model.Classification
	if metabolicUsed != nil {
		ms := ComputeMetabolicScore(*metabolicUsed)
		metabolicScore = &ms
		mc := ClassifyMetabolic(ms)
		metabolicClass = &mc
	}

	systemScore := ComputeSystemScore(existing.Scores.Sleep, existing.Scores.Movement, metabolicScore)
	scoresForInsight := model.AssessmentScores{
		Sleep:     existing.Scores.Sleep,
		Recovery:  existing.Scores.Recovery,
		Movement:  existing.Scores.Movement,
		Metabolic: metabolicScore,
		System:    systemScore,
	}
	flags := GenerateFlags(existing.Sleep, existing.Movement, metabolicUsed)
	insight := GenerateInsight(scoresForInsight)
	recommendations := GenerateRecommendations(scoresForInsight)

	var notesPtr *string
	if input.ReviewerNotes != "" {
		notesPtr = &input.ReviewerNotes
	}

	patch := repository.AssessmentReviewPatch{
		ReviewerID:      reviewerID,
		Status:          input.Status,
		ReviewerNotes:   notesPtr,
		Metabolic:       input.Metabolic, // persist only if overridden
		MetabolicScore:  metabolicScore,
		MetabolicClass:  metabolicClass,
		SystemScore:     systemScore,
		Flags:           flags,
		Insight:         insight,
		Recommendations: recommendations,
	}

	if err := s.repo.ApplyReview(ctx, id, patch); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrAssessmentNotFound
		}
		return nil, fmt.Errorf("applying review: %w", err)
	}

	s.logger.Info("assessment reviewed",
		"assessment_id", id,
		"reviewer_id", reviewerID,
		"new_status", input.Status,
	)

	return s.repo.GetByID(ctx, id)
}

// ─── Internal helpers ──────────────────────────────────────────────

// computeAssessmentEntity runs the scoring engine and assembles the
// entity. It does NOT persist the row — the caller is responsible.
func computeAssessmentEntity(
	userID *string,
	tier model.AssessmentTier,
	sleep model.SleepInput,
	movement model.MovementInput,
	metabolic *model.MetabolicInput,
) *model.Assessment {
	sleepScore := ComputeSleepScore(sleep)
	recoveryScore := ComputeRecoveryScore(sleep)
	movementScore := ComputeMovementScore(movement)

	var metabolicScore *int
	var metabolicClass *model.Classification
	if metabolic != nil {
		ms := ComputeMetabolicScore(*metabolic)
		metabolicScore = &ms
		mc := ClassifyMetabolic(ms)
		metabolicClass = &mc
	}

	systemScore := ComputeSystemScore(sleepScore, movementScore, metabolicScore)

	scores := model.AssessmentScores{
		Sleep:     sleepScore,
		Recovery:  recoveryScore,
		Movement:  movementScore,
		Metabolic: metabolicScore,
		System:    systemScore,
	}

	flags := GenerateFlags(sleep, movement, metabolic)
	insight := GenerateInsight(scores)
	recommendations := GenerateRecommendations(scores)

	return &model.Assessment{
		UserID:          userID,
		Tier:            tier,
		Status:          model.AssessmentSubmitted,
		Sleep:           sleep,
		Movement:        movement,
		Metabolic:       metabolic,
		Scores:          scores,
		SleepClass:      ClassifySleep(sleepScore),
		MovementClass:   ClassifyMovement(movementScore),
		MetabolicClass:  metabolicClass,
		Flags:           flags,
		Insight:         insight,
		Recommendations: recommendations,
	}
}
