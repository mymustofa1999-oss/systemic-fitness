package repository

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type NotificationRepository struct {
	db *pgxpool.Pool
}

func NewNotificationRepository(db *pgxpool.Pool) *NotificationRepository {
	return &NotificationRepository{db: db}
}

// ═══════════════════════════════════════════════════════════════
//  Device Token
// ═══════════════════════════════════════════════════════════════

type DeviceToken struct {
	ID         string    `json:"id"`
	UserID     string    `json:"user_id"`
	Token      string    `json:"token"`
	Platform   string    `json:"platform"` // android, ios, web
	DeviceName *string   `json:"device_name,omitempty"`
	IsActive   bool      `json:"is_active"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// UpsertDeviceToken inserts or updates a device token for a user.
// If the token already exists (for any user), it reassigns it.
func (r *NotificationRepository) UpsertDeviceToken(ctx context.Context, dt *DeviceToken) error {
	query := `
		INSERT INTO device_tokens (user_id, token, platform, device_name, is_active)
		VALUES ($1, $2, $3, $4, true)
		ON CONFLICT (token) DO UPDATE
		SET user_id = $1, platform = $3, device_name = $4, is_active = true, updated_at = NOW()
		RETURNING id`
	return r.db.QueryRow(ctx, query, dt.UserID, dt.Token, dt.Platform, dt.DeviceName).Scan(&dt.ID)
}

// GetActiveTokensByUserID returns all active FCM tokens for a user.
func (r *NotificationRepository) GetActiveTokensByUserID(ctx context.Context, userID string) ([]string, error) {
	query := `SELECT token FROM device_tokens WHERE user_id = $1 AND is_active = true`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tokens []string
	for rows.Next() {
		var token string
		if err := rows.Scan(&token); err != nil {
			return nil, err
		}
		tokens = append(tokens, token)
	}
	return tokens, rows.Err()
}

// GetActiveTokensByUserIDs returns FCM tokens for multiple users.
func (r *NotificationRepository) GetActiveTokensByUserIDs(ctx context.Context, userIDs []string) (map[string][]string, error) {
	query := `SELECT user_id, token FROM device_tokens WHERE user_id = ANY($1) AND is_active = true`
	rows, err := r.db.Query(ctx, query, userIDs)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := make(map[string][]string)
	for rows.Next() {
		var userID, token string
		if err := rows.Scan(&userID, &token); err != nil {
			return nil, err
		}
		result[userID] = append(result[userID], token)
	}
	return result, rows.Err()
}

// GetAllActiveTokens returns all active tokens, optionally filtered by roles.
func (r *NotificationRepository) GetAllActiveTokens(ctx context.Context, roles []string) ([]string, error) {
	var query string
	var args []any

	if len(roles) > 0 {
		query = `
			SELECT dt.token FROM device_tokens dt
			JOIN users u ON u.id = dt.user_id
			WHERE dt.is_active = true AND u.status = 'active' AND u.role = ANY($1)`
		args = append(args, roles)
	} else {
		query = `
			SELECT dt.token FROM device_tokens dt
			JOIN users u ON u.id = dt.user_id
			WHERE dt.is_active = true AND u.status = 'active'`
	}

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tokens []string
	for rows.Next() {
		var token string
		if err := rows.Scan(&token); err != nil {
			return nil, err
		}
		tokens = append(tokens, token)
	}
	return tokens, rows.Err()
}

// DeactivateTokens marks tokens as inactive (expired/invalid).
func (r *NotificationRepository) DeactivateTokens(ctx context.Context, tokens []string) error {
	if len(tokens) == 0 {
		return nil
	}
	query := `UPDATE device_tokens SET is_active = false, updated_at = NOW() WHERE token = ANY($1)`
	_, err := r.db.Exec(ctx, query, tokens)
	return err
}

// RemoveDeviceToken removes a specific token (for logout).
func (r *NotificationRepository) RemoveDeviceToken(ctx context.Context, userID, token string) error {
	query := `UPDATE device_tokens SET is_active = false, updated_at = NOW() WHERE user_id = $1 AND token = $2`
	_, err := r.db.Exec(ctx, query, userID, token)
	return err
}

// ═══════════════════════════════════════════════════════════════
//  Notification (in-app history)
// ═══════════════════════════════════════════════════════════════

type Notification struct {
	ID          string          `json:"id"`
	UserID      string          `json:"user_id"`
	Title       string          `json:"title"`
	Body        string          `json:"body"`
	Type        string          `json:"type"`
	Data        json.RawMessage `json:"data,omitempty"`
	Status      string          `json:"status"` // unread, read, dismissed
	SentViaPush bool            `json:"sent_via_push"`
	PushSentAt  *time.Time      `json:"push_sent_at,omitempty"`
	ReadAt      *time.Time      `json:"read_at,omitempty"`
	CreatedAt   time.Time       `json:"created_at"`
}

// CreateNotification inserts a notification record.
func (r *NotificationRepository) CreateNotification(ctx context.Context, n *Notification) error {
	query := `
		INSERT INTO notifications (user_id, title, body, type, data, sent_via_push, push_sent_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at`
	return r.db.QueryRow(ctx, query,
		n.UserID, n.Title, n.Body, n.Type, n.Data, n.SentViaPush, n.PushSentAt,
	).Scan(&n.ID, &n.CreatedAt)
}

// GetNotifications returns paginated notifications for a user.
func (r *NotificationRepository) GetNotifications(ctx context.Context, userID string, p model.PaginationParams) ([]Notification, int, error) {
	countQuery := `SELECT COUNT(*) FROM notifications WHERE user_id = $1`
	var total int
	if err := r.db.QueryRow(ctx, countQuery, userID).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := `
		SELECT id, user_id, title, body, type, data, status, sent_via_push, push_sent_at, read_at, created_at
		FROM notifications
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`
	rows, err := r.db.Query(ctx, query, userID, p.Limit, p.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var notifications []Notification
	for rows.Next() {
		var n Notification
		if err := rows.Scan(&n.ID, &n.UserID, &n.Title, &n.Body, &n.Type, &n.Data,
			&n.Status, &n.SentViaPush, &n.PushSentAt, &n.ReadAt, &n.CreatedAt); err != nil {
			return nil, 0, err
		}
		notifications = append(notifications, n)
	}
	return notifications, total, rows.Err()
}

// GetUnreadCount returns the number of unread notifications for a user.
func (r *NotificationRepository) GetUnreadCount(ctx context.Context, userID string) (int, error) {
	var count int
	err := r.db.QueryRow(ctx, `SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND status = 'unread'`, userID).Scan(&count)
	return count, err
}

// MarkAsRead marks a single notification as read.
func (r *NotificationRepository) MarkAsRead(ctx context.Context, userID, notificationID string) error {
	query := `UPDATE notifications SET status = 'read', read_at = NOW() WHERE id = $1 AND user_id = $2 AND status = 'unread'`
	tag, err := r.db.Exec(ctx, query, notificationID, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// MarkAllAsRead marks all unread notifications as read for a user.
func (r *NotificationRepository) MarkAllAsRead(ctx context.Context, userID string) error {
	query := `UPDATE notifications SET status = 'read', read_at = NOW() WHERE user_id = $1 AND status = 'unread'`
	_, err := r.db.Exec(ctx, query, userID)
	return err
}

// ═══════════════════════════════════════════════════════════════
//  Broadcast Notifications
// ═══════════════════════════════════════════════════════════════

type BroadcastNotification struct {
	ID          string          `json:"id"`
	Title       string          `json:"title"`
	Body        string          `json:"body"`
	Type        string          `json:"type"` // promo, announcement, maintenance
	Data        json.RawMessage `json:"data,omitempty"`
	TargetRoles []string        `json:"target_roles,omitempty"` // null = all
	ImageURL    *string         `json:"image_url,omitempty"`
	ScheduledAt *time.Time      `json:"scheduled_at,omitempty"`
	SentAt      *time.Time      `json:"sent_at,omitempty"`
	SentCount   int             `json:"sent_count"`
	CreatedBy   *string         `json:"created_by,omitempty"`
	CreatedAt   time.Time       `json:"created_at"`
}

// CreateBroadcast inserts a broadcast notification.
func (r *NotificationRepository) CreateBroadcast(ctx context.Context, b *BroadcastNotification) error {
	query := `
		INSERT INTO broadcast_notifications (title, body, type, data, target_roles, image_url, scheduled_at, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at`
	return r.db.QueryRow(ctx, query,
		b.Title, b.Body, b.Type, b.Data, b.TargetRoles, b.ImageURL, b.ScheduledAt, b.CreatedBy,
	).Scan(&b.ID, &b.CreatedAt)
}

// GetPendingBroadcasts returns broadcasts that are scheduled and due.
func (r *NotificationRepository) GetPendingBroadcasts(ctx context.Context) ([]BroadcastNotification, error) {
	query := `
		SELECT id, title, body, type, data, target_roles, image_url, scheduled_at, created_by, created_at
		FROM broadcast_notifications
		WHERE sent_at IS NULL AND (scheduled_at IS NULL OR scheduled_at <= NOW())
		ORDER BY created_at ASC`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var broadcasts []BroadcastNotification
	for rows.Next() {
		var b BroadcastNotification
		if err := rows.Scan(&b.ID, &b.Title, &b.Body, &b.Type, &b.Data,
			&b.TargetRoles, &b.ImageURL, &b.ScheduledAt, &b.CreatedBy, &b.CreatedAt); err != nil {
			return nil, err
		}
		broadcasts = append(broadcasts, b)
	}
	return broadcasts, rows.Err()
}

// MarkBroadcastSent marks a broadcast as sent.
func (r *NotificationRepository) MarkBroadcastSent(ctx context.Context, id string, sentCount int) error {
	query := `UPDATE broadcast_notifications SET sent_at = NOW(), sent_count = $2 WHERE id = $1`
	_, err := r.db.Exec(ctx, query, id, sentCount)
	return err
}

// ListBroadcasts returns paginated broadcast history.
func (r *NotificationRepository) ListBroadcasts(ctx context.Context, p model.PaginationParams) ([]BroadcastNotification, int, error) {
	var total int
	if err := r.db.QueryRow(ctx, `SELECT COUNT(*) FROM broadcast_notifications`).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := `
		SELECT id, title, body, type, data, target_roles, image_url, scheduled_at, sent_at, sent_count, created_by, created_at
		FROM broadcast_notifications
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2`
	rows, err := r.db.Query(ctx, query, p.Limit, p.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var result []BroadcastNotification
	for rows.Next() {
		var b BroadcastNotification
		if err := rows.Scan(&b.ID, &b.Title, &b.Body, &b.Type, &b.Data,
			&b.TargetRoles, &b.ImageURL, &b.ScheduledAt, &b.SentAt, &b.SentCount, &b.CreatedBy, &b.CreatedAt); err != nil {
			return nil, 0, err
		}
		result = append(result, b)
	}
	return result, total, rows.Err()
}

