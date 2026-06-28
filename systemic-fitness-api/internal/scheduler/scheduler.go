package scheduler

import (
	"context"
	"encoding/json"
	"log/slog"
	"strconv"
	"time"

	"github.com/robfig/cron/v3"

	"github.com/fitcoach/api/internal/repository"
)

// Scheduler runs automation rules on a cron schedule.
type Scheduler struct {
	cron                *cron.Cron
	automationRepo      *repository.AutomationRepository
	programRepo         *repository.ProgramRepository
	messageRepo         *repository.MessageRepository
	notifRepo           *repository.NotificationRepository
	workoutReminderRepo *repository.WorkoutReminderRepository
	fcmClient           FCMClient
	logger              *slog.Logger
}

// FCMClient is the interface for sending push notifications.
type FCMClient interface {
	SendMulti(ctx context.Context, tokens []string, title, body string, data map[string]string, image string) []string
}

func New(
	automationRepo *repository.AutomationRepository,
	programRepo *repository.ProgramRepository,
	messageRepo *repository.MessageRepository,
	notifRepo *repository.NotificationRepository,
	workoutReminderRepo *repository.WorkoutReminderRepository,
	fcmClient FCMClient,
	logger *slog.Logger,
) *Scheduler {
	return &Scheduler{
		cron:                cron.New(cron.WithSeconds()),
		automationRepo:      automationRepo,
		programRepo:         programRepo,
		messageRepo:         messageRepo,
		notifRepo:           notifRepo,
		workoutReminderRepo: workoutReminderRepo,
		fcmClient:           fcmClient,
		logger:              logger,
	}
}

// Start begins the cron scheduler.
func (s *Scheduler) Start() {
	// Every minute: check scheduled automations
	s.cron.AddFunc("0 * * * * *", func() {
		s.runScheduledAutomations()
	})

	// Every day at 8 AM: check inactive users
	s.cron.AddFunc("0 0 8 * * *", func() {
		s.checkInactiveUsers()
	})

	// Every day at midnight: check milestones
	s.cron.AddFunc("0 0 0 * * *", func() {
		s.checkMilestones()
	})

	// Every minute: check pending broadcast notifications
	s.cron.AddFunc("0 * * * * *", func() {
		s.processPendingBroadcasts()
	})

	// Every minute: send due client-scheduled workout reminders
	s.cron.AddFunc("0 * * * * *", func() {
		s.sendWorkoutReminders()
	})

	s.cron.Start()
	s.logger.Info("scheduler started", "jobs", len(s.cron.Entries()))
}

// Stop gracefully stops the scheduler.
func (s *Scheduler) Stop() {
	ctx := s.cron.Stop()
	<-ctx.Done()
	s.logger.Info("scheduler stopped")
}

// ═══════════════════════════════════════════════════════════════
//  Scheduled Automations (cron-based)
// ═══════════════════════════════════════════════════════════════

func (s *Scheduler) runScheduledAutomations() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	automations, err := s.automationRepo.GetActiveByTrigger(ctx, "scheduled")
	if err != nil {
		s.logger.Error("fetch scheduled automations", "error", err)
		return
	}

	for _, a := range automations {
		// Parse cron from trigger_config: {"cron": "0 8 * * 1"}
		var cfg struct {
			Cron string `json:"cron"`
		}
		if err := json.Unmarshal(a.TriggerConfig, &cfg); err != nil || cfg.Cron == "" {
			continue
		}

		// Parse the cron expression and check if it matches "now"
		schedule, err := cron.ParseStandard(cfg.Cron)
		if err != nil {
			s.logger.Warn("invalid cron expression", "automation_id", a.ID, "cron", cfg.Cron)
			continue
		}

		// Check if the next scheduled time is within the last minute (our check interval)
		now := time.Now()
		next := schedule.Next(now.Add(-61 * time.Second))
		if next.After(now) {
			continue // not time yet
		}

		s.logger.Info("executing scheduled automation", "id", a.ID, "name", a.Name)
		s.executeAction(ctx, &a, nil)
	}
}

// ═══════════════════════════════════════════════════════════════
//  Inactive User Check
// ═══════════════════════════════════════════════════════════════

func (s *Scheduler) checkInactiveUsers() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	automations, err := s.automationRepo.GetActiveByTrigger(ctx, "on_inactive_days")
	if err != nil {
		s.logger.Error("fetch inactive automations", "error", err)
		return
	}

	for _, a := range automations {
		var cfg struct {
			InactiveDays int `json:"inactive_days"`
		}
		if err := json.Unmarshal(a.TriggerConfig, &cfg); err != nil || cfg.InactiveDays < 1 {
			continue
		}

		userIDs, err := s.automationRepo.GetInactiveUserIDs(ctx, cfg.InactiveDays)
		if err != nil {
			s.logger.Error("get inactive users", "automation_id", a.ID, "error", err)
			continue
		}

		s.logger.Info("inactive users found", "automation_id", a.ID, "count", len(userIDs), "threshold_days", cfg.InactiveDays)

		for _, uid := range userIDs {
			s.executeAction(ctx, &a, &uid)
		}
	}
}

// ═══════════════════════════════════════════════════════════════
//  Milestone Check
// ═══════════════════════════════════════════════════════════════

func (s *Scheduler) checkMilestones() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	automations, err := s.automationRepo.GetActiveByTrigger(ctx, "on_milestone")
	if err != nil {
		s.logger.Error("fetch milestone automations", "error", err)
		return
	}

	for _, a := range automations {
		var cfg struct {
			Milestone string `json:"milestone"` // e.g. "100_workouts"
		}
		if err := json.Unmarshal(a.TriggerConfig, &cfg); err != nil || cfg.Milestone == "" {
			continue
		}

		// Parse milestone like "100_workouts" → check who just hit 100 workout days
		var milestoneCount int
		// Simple parsing: extract leading digits
		for i, c := range cfg.Milestone {
			if c < '0' || c > '9' {
				milestoneCount, _ = strconv.Atoi(cfg.Milestone[:i])
				break
			}
		}
		if milestoneCount < 1 {
			continue
		}

		userIDs, err := s.automationRepo.GetMilestoneUsers(ctx, milestoneCount)
		if err != nil {
			s.logger.Error("get milestone users", "automation_id", a.ID, "error", err)
			continue
		}

		for _, uid := range userIDs {
			s.executeAction(ctx, &a, &uid)
		}
	}
}

// ═══════════════════════════════════════════════════════════════
//  Execute Action
// ═══════════════════════════════════════════════════════════════

// executeAction runs the configured action and logs the result.
func (s *Scheduler) executeAction(ctx context.Context, a *repository.Automation, userID *string) {
	log := &repository.AutomationLog{
		AutomationID: a.ID,
		UserID:       userID,
		Status:       "success",
	}

	var err error
	switch a.ActionType {
	case "send_message":
		err = s.actionSendMessage(ctx, a.ActionConfig, userID)
	case "assign_program":
		err = s.actionAssignProgram(ctx, a.ActionConfig, userID)
	case "send_reminder":
		err = s.actionSendReminder(ctx, a.ActionConfig, userID)
	case "send_notification":
		err = s.actionSendNotification(ctx, a.ActionConfig, userID)
	case "send_email":
		err = s.actionSendEmail(ctx, a.ActionConfig, userID)
	default:
		err = nil
		s.logger.Warn("unknown action type", "type", a.ActionType)
	}

	if err != nil {
		log.Status = "failed"
		errMsg := err.Error()
		log.ErrorMessage = &errMsg
		s.logger.Error("automation action failed",
			"automation_id", a.ID, "action", a.ActionType, "error", err)
	}

	// Write result as JSON
	resultJSON, _ := json.Marshal(map[string]string{
		"action_type": a.ActionType,
		"status":      log.Status,
	})
	log.Result = resultJSON

	if err := s.automationRepo.CreateLog(ctx, log); err != nil {
		s.logger.Error("failed to write automation log", "error", err)
	}
}

// ── Action Implementations ──────────────────────────────────────

func (s *Scheduler) actionSendMessage(ctx context.Context, config json.RawMessage, userID *string) error {
	var cfg struct {
		Message string `json:"message"`
	}
	if err := json.Unmarshal(config, &cfg); err != nil {
		return err
	}
	if userID == nil || cfg.Message == "" {
		return nil
	}

	s.logger.Info("automation: send_message", "user_id", *userID, "message", cfg.Message)
	// TODO: create/find direct conversation with user and send the message
	return nil
}

func (s *Scheduler) actionAssignProgram(ctx context.Context, config json.RawMessage, userID *string) error {
	var cfg struct {
		ProgramID string `json:"program_id"`
	}
	if err := json.Unmarshal(config, &cfg); err != nil {
		return err
	}
	if userID == nil || cfg.ProgramID == "" {
		return nil
	}

	up := &repository.UserProgram{
		UserID:    *userID,
		ProgramID: cfg.ProgramID,
		StartDate: time.Now().Format("2006-01-02"),
		Status:    "active",
	}
	if err := s.programRepo.AssignToUser(ctx, up); err != nil {
		return err
	}

	s.logger.Info("automation: assign_program", "user_id", *userID, "program_id", cfg.ProgramID)
	return nil
}

func (s *Scheduler) actionSendReminder(ctx context.Context, config json.RawMessage, userID *string) error {
	var cfg struct {
		Title    string            `json:"title"`
		Body     string            `json:"body"`
		Type     string            `json:"type"`
		Data     map[string]string `json:"data"`
	}
	if err := json.Unmarshal(config, &cfg); err != nil {
		return err
	}
	if userID == nil || cfg.Title == "" {
		return nil
	}

	return s.sendPushToUser(ctx, *userID, cfg.Title, cfg.Body, cfg.Type, cfg.Data)
}

func (s *Scheduler) actionSendNotification(ctx context.Context, config json.RawMessage, userID *string) error {
	var cfg struct {
		Title string            `json:"title"`
		Body  string            `json:"body"`
		Type  string            `json:"type"`
		Data  map[string]string `json:"data"`
	}
	if err := json.Unmarshal(config, &cfg); err != nil {
		return err
	}
	if userID == nil || cfg.Title == "" {
		return nil
	}

	return s.sendPushToUser(ctx, *userID, cfg.Title, cfg.Body, cfg.Type, cfg.Data)
}

// sendPushToUser saves an in-app notification and sends FCM push.
func (s *Scheduler) sendPushToUser(ctx context.Context, userID, title, body, notifType string, data map[string]string) error {
	if notifType == "" {
		notifType = "general"
	}

	// 1. Save in-app notification
	dataJSON, _ := json.Marshal(data)
	notif := &repository.Notification{
		UserID: userID,
		Title:  title,
		Body:   body,
		Type:   notifType,
		Data:   dataJSON,
	}

	// 2. Send FCM push
	tokens, err := s.notifRepo.GetActiveTokensByUserID(ctx, userID)
	if err != nil {
		s.logger.Error("get device tokens for push", "user_id", userID, "error", err)
	}

	if len(tokens) > 0 {
		failedTokens := s.fcmClient.SendMulti(ctx, tokens, title, body, data, "")
		notif.SentViaPush = true
		now := time.Now()
		notif.PushSentAt = &now

		if len(failedTokens) > 0 {
			_ = s.notifRepo.DeactivateTokens(ctx, failedTokens)
		}
	}

	if err := s.notifRepo.CreateNotification(ctx, notif); err != nil {
		return err
	}

	s.logger.Info("push notification sent", "user_id", userID, "title", title, "tokens", len(tokens))
	return nil
}

// processPendingBroadcasts sends scheduled broadcast notifications that are due.
func (s *Scheduler) processPendingBroadcasts() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	broadcasts, err := s.notifRepo.GetPendingBroadcasts(ctx)
	if err != nil {
		s.logger.Error("fetch pending broadcasts", "error", err)
		return
	}

	for _, b := range broadcasts {
		tokens, err := s.notifRepo.GetAllActiveTokens(ctx, b.TargetRoles)
		if err != nil {
			s.logger.Error("get tokens for broadcast", "broadcast_id", b.ID, "error", err)
			continue
		}

		if len(tokens) > 0 {
			var data map[string]string
			if b.Data != nil {
				_ = json.Unmarshal(b.Data, &data)
			}
			var image string
			if b.ImageURL != nil {
				image = *b.ImageURL
			}
			failedTokens := s.fcmClient.SendMulti(ctx, tokens, b.Title, b.Body, data, image)
			if len(failedTokens) > 0 {
				_ = s.notifRepo.DeactivateTokens(ctx, failedTokens)
			}
		}

		if err := s.notifRepo.MarkBroadcastSent(ctx, b.ID, len(tokens)); err != nil {
			s.logger.Error("mark broadcast sent", "error", err)
		}

		s.logger.Info("broadcast sent", "id", b.ID, "title", b.Title, "recipients", len(tokens))
	}
}

// ═══════════════════════════════════════════════════════════════
//  Workout Reminders (client self-scheduled)
// ═══════════════════════════════════════════════════════════════

// sendWorkoutReminders fires push + in-app reminders for clients whose
// configured time matches the current minute (in their own timezone) on a
// selected day, at most once per day.
func (s *Scheduler) sendWorkoutReminders() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	reminders, err := s.workoutReminderRepo.ListEnabled(ctx)
	if err != nil {
		s.logger.Error("fetch workout reminders", "error", err)
		return
	}

	for _, rm := range reminders {
		loc, err := time.LoadLocation(rm.Timezone)
		if err != nil {
			loc = time.UTC
		}
		now := time.Now().In(loc)

		// time.Weekday() is Sunday=0 .. Saturday=6, matching our stored convention.
		if !containsInt(rm.DaysOfWeek, int(now.Weekday())) {
			continue
		}

		at, err := time.Parse("15:04", rm.RemindAt)
		if err != nil {
			continue
		}
		if now.Hour() != at.Hour() || now.Minute() != at.Minute() {
			continue
		}

		today := now.Format("2006-01-02")
		if rm.LastSentOn != nil && *rm.LastSentOn == today {
			continue // already sent today
		}

		title := "Saatnya Latihan! 💪"
		body := "Jangan lewatkan sesi latihan Systemic Fitness Anda hari ini."
		data := map[string]string{"type": "workout_reminder"}
		if err := s.sendPushToUser(ctx, rm.UserID, title, body, "workout_reminder", data); err != nil {
			s.logger.Error("send workout reminder", "user_id", rm.UserID, "error", err)
			continue
		}
		if err := s.workoutReminderRepo.MarkSent(ctx, rm.ID, today); err != nil {
			s.logger.Error("mark workout reminder sent", "id", rm.ID, "error", err)
		}
		s.logger.Info("workout reminder sent", "user_id", rm.UserID, "at", rm.RemindAt)
	}
}

func containsInt(xs []int, v int) bool {
	for _, x := range xs {
		if x == v {
			return true
		}
	}
	return false
}

func (s *Scheduler) actionSendEmail(ctx context.Context, config json.RawMessage, userID *string) error {
	var cfg struct {
		Subject  string `json:"subject"`
		Template string `json:"template"`
	}
	if err := json.Unmarshal(config, &cfg); err != nil {
		return err
	}

	s.logger.Info("automation: send_email (placeholder)", "user_id", userID, "subject", cfg.Subject)
	// TODO: integrate with email service (SendGrid / SES)
	return nil
}

// ═══════════════════════════════════════════════════════════════
//  Trigger Hooks (called from services)
// ═══════════════════════════════════════════════════════════════

// TriggerOnSignup should be called when a new user registers.
func (s *Scheduler) TriggerOnSignup(userID string) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	automations, err := s.automationRepo.GetActiveByTrigger(ctx, "on_signup")
	if err != nil {
		s.logger.Error("trigger on_signup: fetch", "error", err)
		return
	}
	for _, a := range automations {
		s.executeAction(ctx, &a, &userID)
	}
}

// TriggerOnProgramComplete should be called when a user completes a program.
func (s *Scheduler) TriggerOnProgramComplete(userID string) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	automations, err := s.automationRepo.GetActiveByTrigger(ctx, "on_program_complete")
	if err != nil {
		s.logger.Error("trigger on_program_complete: fetch", "error", err)
		return
	}
	for _, a := range automations {
		s.executeAction(ctx, &a, &userID)
	}
}
