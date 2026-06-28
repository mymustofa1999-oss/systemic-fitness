package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type MessageRepository struct {
	db *pgxpool.Pool
}

func NewMessageRepository(db *pgxpool.Pool) *MessageRepository {
	return &MessageRepository{db: db}
}

// ── Structs ─────────────────────────────────────────────────────

type Conversation struct {
	ID             string    `json:"id"`
	Type           string    `json:"type"`
	Name           *string   `json:"name,omitempty"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
	LastMessage    *Message  `json:"last_message,omitempty"`
	UnreadCount    int       `json:"unread_count"`
	MemberCount    int       `json:"member_count"`
}

type Message struct {
	ID             string    `json:"id"`
	ConversationID string    `json:"conversation_id"`
	SenderID       string    `json:"sender_id"`
	SenderName     *string   `json:"sender_name,omitempty"`
	Content        *string   `json:"content,omitempty"`
	Type           string    `json:"type"`
	MediaURL       *string   `json:"media_url,omitempty"`
	IsRead         bool      `json:"is_read"`
	CreatedAt      time.Time `json:"created_at"`
}

// ── Conversations ───────────────────────────────────────────────

func (r *MessageRepository) CreateConversation(ctx context.Context, c *Conversation) error {
	return r.db.QueryRow(ctx,
		`INSERT INTO conversations (type, name) VALUES ($1, $2) RETURNING id, created_at, updated_at`,
		c.Type, c.Name,
	).Scan(&c.ID, &c.CreatedAt, &c.UpdatedAt)
}

func (r *MessageRepository) GetConversationByID(ctx context.Context, id string) (*Conversation, error) {
	c := &Conversation{}
	err := r.db.QueryRow(ctx,
		`SELECT id, type, name, created_at, updated_at FROM conversations WHERE id = $1`, id,
	).Scan(&c.ID, &c.Type, &c.Name, &c.CreatedAt, &c.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return c, err
}

// FindDirectConversation finds an existing direct conversation between two users.
func (r *MessageRepository) FindDirectConversation(ctx context.Context, userA, userB string) (*Conversation, error) {
	c := &Conversation{}
	err := r.db.QueryRow(ctx, `
		SELECT c.id, c.type, c.name, c.created_at, c.updated_at
		FROM conversations c
		WHERE c.type = 'direct'
		  AND EXISTS (SELECT 1 FROM conversation_members WHERE conversation_id = c.id AND user_id = $1)
		  AND EXISTS (SELECT 1 FROM conversation_members WHERE conversation_id = c.id AND user_id = $2)
		LIMIT 1`, userA, userB,
	).Scan(&c.ID, &c.Type, &c.Name, &c.CreatedAt, &c.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil // not found is not an error for this query
	}
	return c, err
}

// GetConversations returns conversations for a user with last message preview and unread count.
func (r *MessageRepository) GetConversations(ctx context.Context, userID string, params model.PaginationParams) ([]Conversation, int, error) {
	var total int
	if err := r.db.QueryRow(ctx, `
		SELECT COUNT(*) FROM conversation_members WHERE user_id = $1`, userID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT
			c.id, c.type, c.name, c.created_at, c.updated_at,
			(SELECT COUNT(*) FROM conversation_members WHERE conversation_id = c.id) AS member_count,
			(SELECT COUNT(*) FROM messages m
			 WHERE m.conversation_id = c.id AND m.is_read = FALSE AND m.sender_id != $1) AS unread_count,
			lm.id, lm.sender_id, u.full_name, lm.content, lm.type, lm.created_at
		FROM conversations c
		JOIN conversation_members cm ON cm.conversation_id = c.id AND cm.user_id = $1
		LEFT JOIN LATERAL (
			SELECT id, sender_id, content, type, created_at
			FROM messages
			WHERE conversation_id = c.id
			ORDER BY created_at DESC LIMIT 1
		) lm ON TRUE
		LEFT JOIN users u ON u.id = lm.sender_id
		ORDER BY COALESCE(lm.created_at, c.updated_at) DESC
		LIMIT $2 OFFSET $3`,
		userID, params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	convos := make([]Conversation, 0)
	for rows.Next() {
		var c Conversation
		var lmID, lmSenderID, lmSenderName, lmContent, lmType *string
		var lmCreatedAt *time.Time

		if err := rows.Scan(
			&c.ID, &c.Type, &c.Name, &c.CreatedAt, &c.UpdatedAt,
			&c.MemberCount, &c.UnreadCount,
			&lmID, &lmSenderID, &lmSenderName, &lmContent, &lmType, &lmCreatedAt,
		); err != nil {
			return nil, 0, err
		}

		if lmID != nil {
			c.LastMessage = &Message{
				ID:             *lmID,
				ConversationID: c.ID,
				SenderID:       *lmSenderID,
				SenderName:     lmSenderName,
				Content:        lmContent,
				Type:           *lmType,
				CreatedAt:      *lmCreatedAt,
			}
		}
		convos = append(convos, c)
	}
	return convos, total, rows.Err()
}

// ── Members ─────────────────────────────────────────────────────

func (r *MessageRepository) AddMember(ctx context.Context, conversationID, userID, role string) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO conversation_members (conversation_id, user_id, role)
		VALUES ($1, $2, $3)
		ON CONFLICT (conversation_id, user_id) DO NOTHING`,
		conversationID, userID, role)
	return err
}

func (r *MessageRepository) IsMember(ctx context.Context, conversationID, userID string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM conversation_members
			WHERE conversation_id = $1 AND user_id = $2
		)`, conversationID, userID).Scan(&exists)
	return exists, err
}

func (r *MessageRepository) GetMemberIDs(ctx context.Context, conversationID string) ([]string, error) {
	rows, err := r.db.Query(ctx,
		`SELECT user_id FROM conversation_members WHERE conversation_id = $1`,
		conversationID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}

// ── Messages ────────────────────────────────────────────────────

func (r *MessageRepository) SendMessage(ctx context.Context, m *Message) error {
	return r.db.QueryRow(ctx, `
		INSERT INTO messages (conversation_id, sender_id, content, type, media_url)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, created_at`,
		m.ConversationID, m.SenderID, m.Content, m.Type, m.MediaURL,
	).Scan(&m.ID, &m.CreatedAt)
}

func (r *MessageRepository) GetMessages(ctx context.Context, conversationID string, params model.PaginationParams) ([]Message, int, error) {
	var total int
	if err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM messages WHERE conversation_id = $1`, conversationID,
	).Scan(&total); err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT m.id, m.conversation_id, m.sender_id, u.full_name,
		       m.content, m.type, m.media_url, m.is_read, m.created_at
		FROM messages m
		JOIN users u ON u.id = m.sender_id
		WHERE m.conversation_id = $1
		ORDER BY m.created_at DESC
		LIMIT $2 OFFSET $3`,
		conversationID, params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	messages := make([]Message, 0)
	for rows.Next() {
		var msg Message
		if err := rows.Scan(
			&msg.ID, &msg.ConversationID, &msg.SenderID, &msg.SenderName,
			&msg.Content, &msg.Type, &msg.MediaURL, &msg.IsRead, &msg.CreatedAt,
		); err != nil {
			return nil, 0, err
		}
		messages = append(messages, msg)
	}
	return messages, total, rows.Err()
}

func (r *MessageRepository) MarkAsRead(ctx context.Context, conversationID, userID string) (int64, error) {
	tag, err := r.db.Exec(ctx, `
		UPDATE messages SET is_read = TRUE
		WHERE conversation_id = $1
		  AND sender_id != $2
		  AND is_read = FALSE`,
		conversationID, userID)
	if err != nil {
		return 0, err
	}
	return tag.RowsAffected(), nil
}

// GetUnreadCount returns total unread messages across all conversations for a user.
func (r *MessageRepository) GetUnreadCount(ctx context.Context, userID string) (int, error) {
	var count int
	err := r.db.QueryRow(ctx, `
		SELECT COUNT(*)
		FROM messages m
		JOIN conversation_members cm ON cm.conversation_id = m.conversation_id AND cm.user_id = $1
		WHERE m.sender_id != $1 AND m.is_read = FALSE`, userID,
	).Scan(&count)
	return count, err
}

// GetConversationMembers returns user IDs for a conversation (used by WS broadcast).
func (r *MessageRepository) GetConversationMemberCount(ctx context.Context, id string) (int, error) {
	var count int
	err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM conversation_members WHERE conversation_id = $1`, id,
	).Scan(&count)
	return count, err
}

// SendSystemMessage creates a system-type message.
func (r *MessageRepository) SendSystemMessage(ctx context.Context, conversationID, content string) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO messages (conversation_id, sender_id, content, type)
		SELECT $1, id, $2, 'system'
		FROM users WHERE role = 'owner' LIMIT 1`,
		conversationID, content)
	return err
}

// CreateDirectWithMembers creates a direct conversation and adds both members in a transaction.
func (r *MessageRepository) CreateDirectWithMembers(ctx context.Context, userA, userB string) (*Conversation, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)

	c := &Conversation{}
	err = tx.QueryRow(ctx,
		`INSERT INTO conversations (type) VALUES ('direct') RETURNING id, type, created_at, updated_at`,
	).Scan(&c.ID, &c.Type, &c.CreatedAt, &c.UpdatedAt)
	if err != nil {
		return nil, err
	}

	for _, uid := range []string{userA, userB} {
		if _, err := tx.Exec(ctx,
			`INSERT INTO conversation_members (conversation_id, user_id, role) VALUES ($1, $2, 'member')`,
			c.ID, uid); err != nil {
			return nil, fmt.Errorf("adding member %s: %w", uid, err)
		}
	}

	return c, tx.Commit(ctx)
}
