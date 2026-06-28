package service

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/ws"
)

type MessageService struct {
	messageRepo *repository.MessageRepository
	hub         *ws.Hub
	logger      *slog.Logger
}

func NewMessageService(mr *repository.MessageRepository, hub *ws.Hub, logger *slog.Logger) *MessageService {
	return &MessageService{messageRepo: mr, hub: hub, logger: logger}
}

// ═══════════════════════════════════════════════════════════════
//  Direct Conversation
// ═══════════════════════════════════════════════════════════════

func (s *MessageService) GetOrCreateDirect(ctx context.Context, callerID, targetID string) (*repository.Conversation, error) {
	if callerID == targetID {
		s.logger.Warn("create direct: self-conversation attempt", "user_id", callerID)
		return nil, fmt.Errorf("cannot start a conversation with yourself")
	}

	// Check for existing direct conversation
	existing, err := s.messageRepo.FindDirectConversation(ctx, callerID, targetID)
	if err != nil {
		s.logger.Error("create direct: find existing", "caller_id", callerID, "target_id", targetID, "error", err)
		return nil, fmt.Errorf("finding existing conversation: %w", err)
	}
	if existing != nil {
		s.logger.Debug("create direct: reusing existing", "conversation_id", existing.ID)
		return existing, nil
	}

	// Create new
	convo, err := s.messageRepo.CreateDirectWithMembers(ctx, callerID, targetID)
	if err != nil {
		s.logger.Error("create direct: create", "caller_id", callerID, "target_id", targetID, "error", err)
		return nil, fmt.Errorf("creating direct conversation: %w", err)
	}

	s.logger.Info("direct conversation created", "id", convo.ID, "between", callerID, "and", targetID)
	return convo, nil
}

// ═══════════════════════════════════════════════════════════════
//  Group Conversation
// ═══════════════════════════════════════════════════════════════

type CreateGroupInput struct {
	Name           string   `json:"name"            validate:"required,min=1,max=100"`
	ParticipantIDs []string `json:"participant_ids"  validate:"required,min=1"`
}

func (s *MessageService) CreateGroup(ctx context.Context, creatorID string, input *CreateGroupInput) (*repository.Conversation, error) {
	convo := &repository.Conversation{Type: "group", Name: &input.Name}
	if err := s.messageRepo.CreateConversation(ctx, convo); err != nil {
		s.logger.Error("create group: create conversation", "name", input.Name, "error", err)
		return nil, fmt.Errorf("creating group: %w", err)
	}

	// Creator is admin
	if err := s.messageRepo.AddMember(ctx, convo.ID, creatorID, "admin"); err != nil {
		s.logger.Error("create group: add creator", "conversation_id", convo.ID, "creator_id", creatorID, "error", err)
		return nil, err
	}

	// Add participants
	for _, pid := range input.ParticipantIDs {
		if pid == creatorID {
			continue
		}
		if err := s.messageRepo.AddMember(ctx, convo.ID, pid, "member"); err != nil {
			s.logger.Warn("failed to add group member", "conversation_id", convo.ID, "user_id", pid, "error", err)
		}
	}

	s.logger.Info("group created", "id", convo.ID, "name", input.Name, "members", len(input.ParticipantIDs)+1)
	return convo, nil
}

// ═══════════════════════════════════════════════════════════════
//  Send Message
// ═══════════════════════════════════════════════════════════════

func (s *MessageService) SendMessage(ctx context.Context, m *repository.Message) error {
	// Verify sender is a member
	isMember, err := s.messageRepo.IsMember(ctx, m.ConversationID, m.SenderID)
	if err != nil {
		s.logger.Error("send message: check membership", "conversation_id", m.ConversationID, "sender_id", m.SenderID, "error", err)
		return fmt.Errorf("checking membership: %w", err)
	}
	if !isMember {
		s.logger.Warn("send message: not a member", "conversation_id", m.ConversationID, "sender_id", m.SenderID)
		return fmt.Errorf("not a member of this conversation")
	}

	if err := s.messageRepo.SendMessage(ctx, m); err != nil {
		s.logger.Error("send message: save", "conversation_id", m.ConversationID, "sender_id", m.SenderID, "error", err)
		return fmt.Errorf("sending message: %w", err)
	}

	s.logger.Info("message sent", "message_id", m.ID, "conversation_id", m.ConversationID, "sender_id", m.SenderID, "type", m.Type)

	// Broadcast to all online conversation members via WebSocket
	go s.broadcastNewMessage(m)

	return nil
}

func (s *MessageService) broadcastNewMessage(m *repository.Message) {
	memberIDs, err := s.messageRepo.GetMemberIDs(context.Background(), m.ConversationID)
	if err != nil {
		s.logger.Warn("failed to get member IDs for broadcast", "error", err)
		return
	}

	for _, uid := range memberIDs {
		if uid == m.SenderID {
			continue // don't echo back to sender
		}
		s.hub.SendToUser(uid, "new_message", m)
	}
}

// ═══════════════════════════════════════════════════════════════
//  List Conversations
// ═══════════════════════════════════════════════════════════════

func (s *MessageService) GetConversations(ctx context.Context, userID string, params model.PaginationParams) ([]repository.Conversation, model.PaginationMeta, error) {
	convos, total, err := s.messageRepo.GetConversations(ctx, userID, params)
	if err != nil {
		s.logger.Error("get conversations", "user_id", userID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return convos, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ═══════════════════════════════════════════════════════════════
//  Get Messages
// ═══════════════════════════════════════════════════════════════

func (s *MessageService) GetMessages(ctx context.Context, conversationID, userID string, params model.PaginationParams) ([]repository.Message, model.PaginationMeta, error) {
	isMember, err := s.messageRepo.IsMember(ctx, conversationID, userID)
	if err != nil {
		s.logger.Error("get messages: check membership", "conversation_id", conversationID, "user_id", userID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	if !isMember {
		s.logger.Warn("get messages: not a member", "conversation_id", conversationID, "user_id", userID)
		return nil, model.PaginationMeta{}, fmt.Errorf("not a member of this conversation")
	}

	msgs, total, err := s.messageRepo.GetMessages(ctx, conversationID, params)
	if err != nil {
		s.logger.Error("get messages: fetch", "conversation_id", conversationID, "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return msgs, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ═══════════════════════════════════════════════════════════════
//  Mark as Read
// ═══════════════════════════════════════════════════════════════

func (s *MessageService) MarkAsRead(ctx context.Context, conversationID, userID string) (int64, error) {
	isMember, err := s.messageRepo.IsMember(ctx, conversationID, userID)
	if err != nil {
		s.logger.Error("mark as read: check membership", "conversation_id", conversationID, "user_id", userID, "error", err)
		return 0, err
	}
	if !isMember {
		s.logger.Warn("mark as read: not a member", "conversation_id", conversationID, "user_id", userID)
		return 0, fmt.Errorf("not a member of this conversation")
	}

	count, err := s.messageRepo.MarkAsRead(ctx, conversationID, userID)
	if err != nil {
		s.logger.Error("mark as read: update", "conversation_id", conversationID, "user_id", userID, "error", err)
		return 0, err
	}

	// Notify sender(s) that messages were read
	if count > 0 {
		s.hub.SendToUser(userID, "messages_read", map[string]any{
			"conversation_id": conversationID,
			"count":           count,
		})
	}

	return count, nil
}

// GetUnreadCount returns total unread messages for a user.
func (s *MessageService) GetUnreadCount(ctx context.Context, userID string) (int, error) {
	count, err := s.messageRepo.GetUnreadCount(ctx, userID)
	if err != nil {
		s.logger.Error("get unread count", "user_id", userID, "error", err)
		return 0, err
	}
	return count, nil
}

// SendSystemMessage sends an automated system message to a conversation.
func (s *MessageService) SendSystemMessage(ctx context.Context, conversationID, content string) error {
	if err := s.messageRepo.SendSystemMessage(ctx, conversationID, content); err != nil {
		s.logger.Error("send system message", "conversation_id", conversationID, "error", err)
		return err
	}
	s.logger.Info("system message sent", "conversation_id", conversationID)
	return nil
}
