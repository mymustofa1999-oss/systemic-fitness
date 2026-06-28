package service

import (
	"context"
	"encoding/json"
	"log/slog"
	"time"

	"github.com/fitcoach/api/internal/fcm"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

type NotificationService struct {
	repo   *repository.NotificationRepository
	fcm    *fcm.Client
	logger *slog.Logger
}

func NewNotificationService(
	repo *repository.NotificationRepository,
	fcmClient *fcm.Client,
	logger *slog.Logger,
) *NotificationService {
	return &NotificationService{
		repo:   repo,
		fcm:    fcmClient,
		logger: logger,
	}
}

// ═══════════════════════════════════════════════════════════════
//  Device Token Management
// ═══════════════════════════════════════════════════════════════

// RegisterToken registers or updates a device FCM token.
func (s *NotificationService) RegisterToken(ctx context.Context, userID, token, platform, deviceName string) error {
	dt := &repository.DeviceToken{
		UserID:   userID,
		Token:    token,
		Platform: platform,
	}
	if deviceName != "" {
		dt.DeviceName = &deviceName
	}
	return s.repo.UpsertDeviceToken(ctx, dt)
}

// UnregisterToken deactivates a device token (e.g., on logout).
func (s *NotificationService) UnregisterToken(ctx context.Context, userID, token string) error {
	return s.repo.RemoveDeviceToken(ctx, userID, token)
}

// ═══════════════════════════════════════════════════════════════
//  Send Notifications
// ═══════════════════════════════════════════════════════════════

// SendToUser sends a push notification + saves in-app notification for a user.
func (s *NotificationService) SendToUser(ctx context.Context, userID, title, body, notifType string, data map[string]string) error {
	// 1. Save in-app notification
	dataJSON, _ := json.Marshal(data)
	notif := &repository.Notification{
		UserID: userID,
		Title:  title,
		Body:   body,
		Type:   notifType,
		Data:   dataJSON,
	}

	// 2. Get user's FCM tokens and send push
	tokens, err := s.repo.GetActiveTokensByUserID(ctx, userID)
	if err != nil {
		s.logger.Error("get device tokens", "user_id", userID, "error", err)
	}

	if len(tokens) > 0 {
		failedTokens := s.fcm.SendMulti(ctx, tokens, title, body, data, "")
		notif.SentViaPush = true
		now := time.Now()
		notif.PushSentAt = &now

		// Deactivate expired tokens
		if len(failedTokens) > 0 {
			if err := s.repo.DeactivateTokens(ctx, failedTokens); err != nil {
				s.logger.Error("deactivate tokens", "error", err)
			}
		}
	}

	if err := s.repo.CreateNotification(ctx, notif); err != nil {
		return err
	}

	return nil
}

// SendToUsers sends push + in-app notification to multiple users.
func (s *NotificationService) SendToUsers(ctx context.Context, userIDs []string, title, body, notifType string, data map[string]string) error {
	for _, uid := range userIDs {
		if err := s.SendToUser(ctx, uid, title, body, notifType, data); err != nil {
			s.logger.Error("send to user", "user_id", uid, "error", err)
			// Continue sending to other users
		}
	}
	return nil
}

// Broadcast sends a push notification to all users (or filtered by roles).
// Also creates a broadcast record.
func (s *NotificationService) Broadcast(ctx context.Context, title, body, notifType string, data map[string]string, targetRoles []string, imageURL, createdBy string) error {
	dataJSON, _ := json.Marshal(data)

	broadcast := &repository.BroadcastNotification{
		Title:       title,
		Body:        body,
		Type:        notifType,
		Data:        dataJSON,
		TargetRoles: targetRoles,
	}
	if imageURL != "" {
		broadcast.ImageURL = &imageURL
	}
	if createdBy != "" {
		broadcast.CreatedBy = &createdBy
	}

	if err := s.repo.CreateBroadcast(ctx, broadcast); err != nil {
		return err
	}

	// Get all active tokens for target roles
	tokens, err := s.repo.GetAllActiveTokens(ctx, targetRoles)
	if err != nil {
		return err
	}

	if len(tokens) > 0 {
		failedTokens := s.fcm.SendMulti(ctx, tokens, title, body, data, imageURL)
		if len(failedTokens) > 0 {
			_ = s.repo.DeactivateTokens(ctx, failedTokens)
		}
	}

	// Update broadcast as sent
	if err := s.repo.MarkBroadcastSent(ctx, broadcast.ID, len(tokens)); err != nil {
		s.logger.Error("mark broadcast sent", "error", err)
	}

	s.logger.Info("broadcast sent", "id", broadcast.ID, "title", title, "recipients", len(tokens))
	return nil
}

// ═══════════════════════════════════════════════════════════════
//  In-App Notification Management
// ═══════════════════════════════════════════════════════════════

// GetNotifications returns paginated notifications for a user.
func (s *NotificationService) GetNotifications(ctx context.Context, userID string, p model.PaginationParams) ([]repository.Notification, model.PaginationMeta, error) {
	notifications, total, err := s.repo.GetNotifications(ctx, userID, p)
	if err != nil {
		return nil, model.PaginationMeta{}, err
	}
	return notifications, model.NewPaginationMeta(p.Page, p.Limit, total), nil
}

// GetUnreadCount returns the count of unread notifications.
func (s *NotificationService) GetUnreadCount(ctx context.Context, userID string) (int, error) {
	return s.repo.GetUnreadCount(ctx, userID)
}

// MarkAsRead marks a notification as read.
func (s *NotificationService) MarkAsRead(ctx context.Context, userID, notificationID string) error {
	return s.repo.MarkAsRead(ctx, userID, notificationID)
}

// MarkAllAsRead marks all notifications as read for a user.
func (s *NotificationService) MarkAllAsRead(ctx context.Context, userID string) error {
	return s.repo.MarkAllAsRead(ctx, userID)
}

// ListBroadcasts returns broadcast notification history (admin).
func (s *NotificationService) ListBroadcasts(ctx context.Context, p model.PaginationParams) ([]repository.BroadcastNotification, model.PaginationMeta, error) {
	broadcasts, total, err := s.repo.ListBroadcasts(ctx, p)
	if err != nil {
		return nil, model.PaginationMeta{}, err
	}
	return broadcasts, model.NewPaginationMeta(p.Page, p.Limit, total), nil
}
