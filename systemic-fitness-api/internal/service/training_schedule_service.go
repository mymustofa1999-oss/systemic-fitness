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

type TrainingScheduleService struct {
	scheduleRepo *repository.TrainingScheduleRepository
	notifService *NotificationService
	logger       *slog.Logger
}

func NewTrainingScheduleService(
	repo *repository.TrainingScheduleRepository,
	notifService *NotificationService,
	logger *slog.Logger,
) *TrainingScheduleService {
	return &TrainingScheduleService{
		scheduleRepo: repo,
		notifService: notifService,
		logger:       logger,
	}
}

// ════════════════════════════════════════════════════════════════════
//  Schedule CRUD
// ════════════════════════════════════════════════════════════════════

func (s *TrainingScheduleService) CreateSchedule(ctx context.Context, sch *repository.TrainingSchedule) error {
	if err := s.scheduleRepo.Create(ctx, sch); err != nil {
		s.logger.Error("create training schedule", "client_id", sch.ClientID, "error", err)
		return fmt.Errorf("creating schedule: %w", err)
	}
	s.logger.Info("training schedule created", "id", sch.ID, "client_id", sch.ClientID, "trainer_id", sch.TrainerID)
	return nil
}

func (s *TrainingScheduleService) GetSchedule(ctx context.Context, id string) (*repository.TrainingSchedule, error) {
	sch, err := s.scheduleRepo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get training schedule", "id", id, "error", err)
		}
		return nil, err
	}
	return sch, nil
}

func (s *TrainingScheduleService) UpdateSchedule(ctx context.Context, sch *repository.TrainingSchedule) error {
	if err := s.scheduleRepo.Update(ctx, sch); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update training schedule", "id", sch.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *TrainingScheduleService) DeleteSchedule(ctx context.Context, id string) error {
	if err := s.scheduleRepo.Delete(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete training schedule", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *TrainingScheduleService) ListSchedules(ctx context.Context, params model.PaginationParams, f repository.ScheduleListFilter) ([]repository.TrainingSchedule, model.PaginationMeta, error) {
	schedules, total, err := s.scheduleRepo.List(ctx, params, f)
	if err != nil {
		s.logger.Error("list training schedules", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return schedules, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ════════════════════════════════════════════════════════════════════
//  Session CRUD
// ════════════════════════════════════════════════════════════════════

func (s *TrainingScheduleService) CreateSession(ctx context.Context, sess *repository.TrainingSession) error {
	if err := s.scheduleRepo.CreateSession(ctx, sess); err != nil {
		s.logger.Error("create training session", "client_id", sess.ClientID, "error", err)
		return fmt.Errorf("creating session: %w", err)
	}
	s.logger.Info("training session created", "id", sess.ID, "date", sess.SessionDate)
	return nil
}

func (s *TrainingScheduleService) GetSession(ctx context.Context, id string) (*repository.TrainingSession, error) {
	sess, err := s.scheduleRepo.GetSessionByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get training session", "id", id, "error", err)
		}
		return nil, err
	}
	return sess, nil
}

func (s *TrainingScheduleService) UpdateSession(ctx context.Context, sess *repository.TrainingSession) error {
	if err := s.scheduleRepo.UpdateSession(ctx, sess); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("update training session", "id", sess.ID, "error", err)
		}
		return err
	}
	return nil
}

func (s *TrainingScheduleService) DeleteSession(ctx context.Context, id string) error {
	if err := s.scheduleRepo.DeleteSession(ctx, id); err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("delete training session", "id", id, "error", err)
		}
		return err
	}
	return nil
}

func (s *TrainingScheduleService) ListSessions(ctx context.Context, params model.PaginationParams, f repository.SessionListFilter) ([]repository.TrainingSession, model.PaginationMeta, error) {
	sessions, total, err := s.scheduleRepo.ListSessions(ctx, params, f)
	if err != nil {
		s.logger.Error("list training sessions", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return sessions, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// SubstituteTrainer replaces the trainer for a specific session, records
// the audit log (consultant id + timestamp), and notifies BOTH the new
// substitute trainer and the original trainer.
//
// Notifications are best-effort — failures are logged but do NOT roll
// back the substitution.
func (s *TrainingScheduleService) SubstituteTrainer(ctx context.Context, sessionID, substituteTrainerID, reason, substitutedByID string) error {
	originalTrainerID, err := s.scheduleRepo.SubstituteTrainer(ctx, sessionID, substituteTrainerID, reason, substitutedByID)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("substitute trainer", "session_id", sessionID, "error", err)
		}
		return err
	}
	s.logger.Info("trainer substituted",
		"session_id", sessionID,
		"substitute_trainer_id", substituteTrainerID,
		"original_trainer_id", originalTrainerID,
		"substituted_by", substitutedByID,
	)

	s.notifySubstitution(ctx, sessionID, substituteTrainerID, originalTrainerID, reason)
	return nil
}

// notifySubstitution fires push + in-app notifications for both
// trainers involved in a substitution. Best-effort — never errors.
func (s *TrainingScheduleService) notifySubstitution(
	ctx context.Context,
	sessionID, newTrainerID, oldTrainerID, reason string,
) {
	if s.notifService == nil {
		return
	}

	// Re-fetch the session for accurate display values (date, time, client name).
	sess, err := s.scheduleRepo.GetSessionByID(ctx, sessionID)
	if err != nil {
		s.logger.Warn("notify substitution: fetch session", "session_id", sessionID, "error", err)
		return
	}

	clientName := "klien"
	if sess.ClientName != nil {
		clientName = *sess.ClientName
	}
	when := fmt.Sprintf("%s %s", sess.SessionDate, sess.StartTime[:5])

	data := map[string]string{
		"type":       "training_substitution",
		"session_id": sessionID,
		"session_date": sess.SessionDate,
		"start_time":   sess.StartTime,
	}

	// 1. Notify the new substitute trainer (the one taking over).
	if newTrainerID != "" {
		if err := s.notifService.SendToUser(
			ctx,
			newTrainerID,
			"Sesi training baru ditugaskan",
			fmt.Sprintf("Anda menggantikan trainer untuk sesi %s pada %s. Alasan: %s", clientName, when, reason),
			"training_substitution_assigned",
			data,
		); err != nil {
			s.logger.Warn("notify new substitute trainer",
				"trainer_id", newTrainerID, "session_id", sessionID, "error", err)
		}
	}

	// 2. Notify the original trainer (the one being replaced).
	if oldTrainerID != "" && oldTrainerID != newTrainerID {
		if err := s.notifService.SendToUser(
			ctx,
			oldTrainerID,
			"Sesi training dialihkan",
			fmt.Sprintf("Sesi Anda dengan %s pada %s telah dialihkan ke trainer lain. Alasan: %s", clientName, when, reason),
			"training_substitution_replaced",
			data,
		); err != nil {
			s.logger.Warn("notify original trainer",
				"trainer_id", oldTrainerID, "session_id", sessionID, "error", err)
		}
	}
}

// ════════════════════════════════════════════════════════════════════
//  Bulk Substitution
// ════════════════════════════════════════════════════════════════════

// BulkSubstituteInput describes a multi-day substitute assignment for
// a single trainer's whole schedule across a date range.
type BulkSubstituteInput struct {
	OriginalTrainerID   string `json:"original_trainer_id"   validate:"required"`
	SubstituteTrainerID string `json:"substitute_trainer_id" validate:"required"`
	DateFrom            string `json:"date_from"             validate:"required"` // YYYY-MM-DD
	DateTo              string `json:"date_to"               validate:"required"` // YYYY-MM-DD
	Reason              string `json:"reason"                validate:"required,min=1"`
}

// BulkSubstituteResult is what the handler returns to the caller.
type BulkSubstituteResult struct {
	MaterializedSessions int      `json:"materialized_sessions"` // schedules promoted to sessions
	SubstitutedSessions  int      `json:"substituted_sessions"`  // total successfully substituted
	SkippedSessions      int      `json:"skipped_sessions"`      // already substituted / completed / cancelled
	Errors               []string `json:"errors,omitempty"`
}

// BulkSubstitute reassigns ALL active sessions + recurring schedule
// occurrences belonging to OriginalTrainerID within the date range to
// SubstituteTrainerID.
//
// Algorithm:
//
//  1. List existing sessions in [date_from, date_to] for original trainer.
//     Skip ones that are already substituted/completed/cancelled.
//  2. List active recurring schedules for the original trainer.
//     For each day in the range, if a schedule's day_of_week matches AND
//     no session row exists yet, create one then mark for substitution.
//  3. Substitute every collected session id one by one, calling the same
//     `SubstituteTrainer` flow so notifications fire per-session.
//
// Errors on individual sessions are collected but the loop continues —
// partial success is preferable to all-or-nothing.
func (s *TrainingScheduleService) BulkSubstitute(
	ctx context.Context,
	input BulkSubstituteInput,
	substitutedByID string,
) (*BulkSubstituteResult, error) {
	if input.OriginalTrainerID == input.SubstituteTrainerID {
		return nil, fmt.Errorf("substitute trainer cannot be the same as original trainer")
	}

	from, err := time.Parse("2006-01-02", input.DateFrom)
	if err != nil {
		return nil, fmt.Errorf("invalid date_from: %w", err)
	}
	to, err := time.Parse("2006-01-02", input.DateTo)
	if err != nil {
		return nil, fmt.Errorf("invalid date_to: %w", err)
	}
	if to.Before(from) {
		return nil, fmt.Errorf("date_to must be on or after date_from")
	}

	result := &BulkSubstituteResult{}

	// ─── 1. Existing sessions in range for original trainer ──
	sessFilter := repository.SessionListFilter{
		TrainerID: &input.OriginalTrainerID,
		DateFrom:  &input.DateFrom,
		DateTo:    &input.DateTo,
	}
	pageParams := model.PaginationParams{Page: 1, Limit: 500}
	existingSessions, _, err := s.scheduleRepo.ListSessions(ctx, pageParams, sessFilter)
	if err != nil {
		return nil, fmt.Errorf("list existing sessions: %w", err)
	}

	// Build a fast lookup: "YYYY-MM-DD|schedule_id" → session id
	sessionByKey := make(map[string]string, len(existingSessions))
	candidateIDs := make([]string, 0, len(existingSessions))
	for _, sess := range existingSessions {
		// Skip terminal / already-substituted statuses.
		if sess.IsSubstitute || sess.Status == "completed" || sess.Status == "cancelled" || sess.Status == "substituted" {
			result.SkippedSessions++
			continue
		}
		if sess.ScheduleID != nil {
			sessionByKey[sess.SessionDate+"|"+*sess.ScheduleID] = sess.ID
		}
		candidateIDs = append(candidateIDs, sess.ID)
	}

	// ─── 2. Active recurring schedules — materialize ghost days ──
	scheduleFilter := repository.ScheduleListFilter{
		TrainerID:  &input.OriginalTrainerID,
		ActiveOnly: true,
	}
	schedules, _, err := s.scheduleRepo.List(ctx, pageParams, scheduleFilter)
	if err != nil {
		return nil, fmt.Errorf("list schedules: %w", err)
	}

	for d := from; !d.After(to); d = d.AddDate(0, 0, 1) {
		dow := int(d.Weekday())
		dateStr := d.Format("2006-01-02")
		for _, sch := range schedules {
			if sch.DayOfWeek != dow {
				continue
			}
			// If this day already has a session row for this schedule, skip.
			if _, exists := sessionByKey[dateStr+"|"+sch.ID]; exists {
				continue
			}
			// Materialize a fresh session, mirroring the schedule.
			newSess := &repository.TrainingSession{
				ScheduleID:  &sch.ID,
				ClientID:    sch.ClientID,
				TrainerID:   sch.TrainerID,
				SessionDate: dateStr,
				StartTime:   sch.StartTime,
				EndTime:     sch.EndTime,
				Status:      "scheduled",
				Location:    sch.Location,
				Notes:       sch.Notes,
				CreatedBy:   substitutedByID,
			}
			if err := s.scheduleRepo.CreateSession(ctx, newSess); err != nil {
				result.Errors = append(result.Errors,
					fmt.Sprintf("materialize %s schedule %s: %v", dateStr, sch.ID, err))
				continue
			}
			result.MaterializedSessions++
			candidateIDs = append(candidateIDs, newSess.ID)
		}
	}

	// ─── 3. Substitute each collected session ──
	for _, sid := range candidateIDs {
		if err := s.SubstituteTrainer(ctx, sid, input.SubstituteTrainerID, input.Reason, substitutedByID); err != nil {
			result.Errors = append(result.Errors,
				fmt.Sprintf("substitute %s: %v", sid, err))
			continue
		}
		result.SubstitutedSessions++
	}

	s.logger.Info("bulk substitute completed",
		"original_trainer_id", input.OriginalTrainerID,
		"substitute_trainer_id", input.SubstituteTrainerID,
		"date_from", input.DateFrom,
		"date_to", input.DateTo,
		"materialized", result.MaterializedSessions,
		"substituted", result.SubstitutedSessions,
		"skipped", result.SkippedSessions,
		"errors", len(result.Errors),
	)
	return result, nil
}
