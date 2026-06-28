package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

// NutritionGuidanceService orchestrates the Nutrition Guidance & Monitoring
// Engine. All rule logic lives in nutrition_engine.go (pure functions).
type NutritionGuidanceService struct {
	repo   *repository.NutritionGuidanceRepository
	logger *slog.Logger
}

func NewNutritionGuidanceService(
	repo *repository.NutritionGuidanceRepository,
	logger *slog.Logger,
) *NutritionGuidanceService {
	return &NutritionGuidanceService{repo: repo, logger: logger}
}

var ErrNutritionProfileNotFound = errors.New("nutrition health profile not found")

// UpsertProfile creates or updates the user's nutrition health profile.
func (s *NutritionGuidanceService) UpsertProfile(
	ctx context.Context,
	userID string,
	in *model.UpsertNutritionProfileInput,
) (*model.NutritionHealthProfile, error) {
	profile, err := s.repo.UpsertProfile(ctx, userID, in)
	if err != nil {
		s.logger.Error("upsert nutrition profile", "user_id", userID, "error", err)
		return nil, fmt.Errorf("upserting nutrition profile: %w", err)
	}
	s.logger.Info("nutrition profile upserted", "user_id", userID)
	return profile, nil
}

// GetPlan returns the personalised diet plan + today's score (if any).
func (s *NutritionGuidanceService) GetPlan(
	ctx context.Context,
	userID string,
) (*model.NutritionPlanResult, error) {
	profile, err := s.repo.GetProfile(ctx, userID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrNutritionProfileNotFound
		}
		return nil, fmt.Errorf("loading profile: %w", err)
	}

	plan, rules := BuildDietPlan(*profile)

	score := 0
	status := model.NutritionStatusStable
	today := todayDate()
	if log, err := s.repo.GetDailyLog(ctx, userID, today); err == nil && log != nil {
		score = log.Score
		status = log.Status
	} else if err != nil && !errors.Is(err, repository.ErrNotFound) {
		s.logger.Warn("get today nutrition log", "user_id", userID, "error", err)
	}

	return &model.NutritionPlanResult{
		DietPlan:       plan,
		NutritionRules: rules,
		DailyScore:     score,
		Status:         status,
		Insight:        BuildNutritionInsights(*profile, score),
	}, nil
}

// SubmitDailyLog persists today's intake log, computes score & status,
// and evaluates the alert based on the most recent 3 logs.
func (s *NutritionGuidanceService) SubmitDailyLog(
	ctx context.Context,
	userID string,
	in *model.NutritionDailyLogInput,
) (*model.NutritionDailyLogResult, error) {
	logDate, err := time.Parse("2006-01-02", in.LogDate)
	if err != nil {
		return nil, fmt.Errorf("invalid log_date: %w", err)
	}

	score := ComputeDailyScore(*in)
	status := ClassifyNutritionStatus(score)

	if err := s.repo.UpsertDailyLog(ctx, userID, logDate, in, score, status); err != nil {
		s.logger.Error("upsert nutrition daily log", "user_id", userID, "error", err)
		return nil, fmt.Errorf("saving daily log: %w", err)
	}

	recent, err := s.repo.GetRecentScores(ctx, userID, 3)
	if err != nil {
		s.logger.Warn("recent scores", "user_id", userID, "error", err)
	}

	return &model.NutritionDailyLogResult{
		LogDate: in.LogDate,
		Score:   score,
		Status:  status,
		Alert:   EvaluateNutritionAlert(recent),
	}, nil
}

// GetDailyResult returns the stored result for a given date (defaults to today).
func (s *NutritionGuidanceService) GetDailyResult(
	ctx context.Context,
	userID string,
	dateStr string,
) (*model.NutritionDailyLogResult, error) {
	logDate := todayDate()
	if dateStr != "" {
		t, err := time.Parse("2006-01-02", dateStr)
		if err != nil {
			return nil, fmt.Errorf("invalid date: %w", err)
		}
		logDate = t
	}

	row, err := s.repo.GetDailyLog(ctx, userID, logDate)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return &model.NutritionDailyLogResult{
				LogDate: logDate.Format("2006-01-02"),
				Score:   0,
				Status:  model.NutritionStatusStable,
			}, nil
		}
		return nil, err
	}

	recent, err := s.repo.GetRecentScores(ctx, userID, 3)
	if err != nil {
		s.logger.Warn("recent scores", "user_id", userID, "error", err)
	}

	return &model.NutritionDailyLogResult{
		LogDate: row.LogDate.Format("2006-01-02"),
		Score:   row.Score,
		Status:  row.Status,
		Alert:   EvaluateNutritionAlert(recent),
	}, nil
}

// ─── Admin / Trainer methods ────────────────────────────────────────
//
// These accept an explicit targetUserID and are intended to be invoked
// from admin handlers that have already authorised the caller via RBAC.

// AdminGetProfile loads the health profile of any customer.
func (s *NutritionGuidanceService) AdminGetProfile(ctx context.Context, targetUserID string) (*model.NutritionHealthProfile, error) {
	p, err := s.repo.GetProfile(ctx, targetUserID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrNutritionProfileNotFound
		}
		return nil, fmt.Errorf("admin loading profile: %w", err)
	}
	return p, nil
}

// AdminUpsertProfile creates/updates the health profile of any customer.
func (s *NutritionGuidanceService) AdminUpsertProfile(
	ctx context.Context,
	targetUserID string,
	in *model.UpsertNutritionProfileInput,
) (*model.NutritionHealthProfile, error) {
	profile, err := s.repo.UpsertProfile(ctx, targetUserID, in)
	if err != nil {
		s.logger.Error("admin upsert nutrition profile", "user_id", targetUserID, "error", err)
		return nil, fmt.Errorf("admin upserting nutrition profile: %w", err)
	}
	s.logger.Info("admin nutrition profile upserted", "user_id", targetUserID)
	return profile, nil
}

// AdminGetPlan returns the personalised plan + today's score for any customer.
func (s *NutritionGuidanceService) AdminGetPlan(ctx context.Context, targetUserID string) (*model.NutritionPlanResult, error) {
	profile, err := s.repo.GetProfile(ctx, targetUserID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrNutritionProfileNotFound
		}
		return nil, fmt.Errorf("admin loading profile: %w", err)
	}
	plan, rules := BuildDietPlan(*profile)
	score := 0
	status := model.NutritionStatusStable
	if log, err := s.repo.GetDailyLog(ctx, targetUserID, todayDate()); err == nil && log != nil {
		score = log.Score
		status = log.Status
	}
	return &model.NutritionPlanResult{
		DietPlan:       plan,
		NutritionRules: rules,
		DailyScore:     score,
		Status:         status,
		Insight:        BuildNutritionInsights(*profile, score),
	}, nil
}

// AdminListLogs returns the most recent N daily logs of any customer.
func (s *NutritionGuidanceService) AdminListLogs(ctx context.Context, targetUserID string, limit int) ([]model.NutritionDailyLogResult, error) {
	rows, err := s.repo.ListRecentLogs(ctx, targetUserID, limit)
	if err != nil {
		return nil, fmt.Errorf("admin listing logs: %w", err)
	}
	out := make([]model.NutritionDailyLogResult, 0, len(rows))
	for _, r := range rows {
		out = append(out, model.NutritionDailyLogResult{
			LogDate: r.LogDate.Format("2006-01-02"),
			Score:   r.Score,
			Status:  r.Status,
		})
	}
	return out, nil
}

// ListMyLogs returns the most recent N daily logs of the authenticated user.
// Used by the mobile app to render nutrition log history.
func (s *NutritionGuidanceService) ListMyLogs(ctx context.Context, userID string, limit int) ([]model.NutritionDailyLogResult, error) {
	rows, err := s.repo.ListRecentLogs(ctx, userID, limit)
	if err != nil {
		return nil, fmt.Errorf("listing my logs: %w", err)
	}
	out := make([]model.NutritionDailyLogResult, 0, len(rows))
	for _, r := range rows {
		out = append(out, model.NutritionDailyLogResult{
			LogDate: r.LogDate.Format("2006-01-02"),
			Score:   r.Score,
			Status:  r.Status,
		})
	}
	return out, nil
}

func todayDate() time.Time {
	now := time.Now().UTC()
	return time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)
}
