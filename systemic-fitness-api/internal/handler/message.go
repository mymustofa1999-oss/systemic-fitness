package handler

import (
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type MessageHandler struct {
	messageService *service.MessageService
}

func NewMessageHandler(ms *service.MessageService) *MessageHandler {
	return &MessageHandler{messageService: ms}
}

// POST /api/messages/direct — create or reuse a direct conversation
func (h *MessageHandler) CreateDirect(w http.ResponseWriter, r *http.Request) {
	var input struct {
		UserID string `json:"user_id" validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Message.CreateDirect] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body")
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Message.CreateDirect] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	callerID := middleware.GetUserID(r.Context())
	convo, err := h.messageService.GetOrCreateDirect(r.Context(), callerID, input.UserID)
	if err != nil {
		slog.Error("[Message.CreateDirect] failed", "caller_id", callerID, "target_id", input.UserID, "error", err)
		response.BadRequest(w, err.Error())
		return
	}
	slog.Info("[Message.CreateDirect] success", "conversation_id", convo.ID, "caller_id", callerID, "target_id", input.UserID)
	response.OK(w, convo)
}

// POST /api/messages/group
func (h *MessageHandler) CreateGroup(w http.ResponseWriter, r *http.Request) {
	var input service.CreateGroupInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Message.CreateGroup] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body")
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Message.CreateGroup] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	callerID := middleware.GetUserID(r.Context())
	convo, err := h.messageService.CreateGroup(r.Context(), callerID, &input)
	if err != nil {
		slog.Error("[Message.CreateGroup] failed", "caller_id", callerID, "name", input.Name, "error", err)
		response.InternalError(w, err.Error())
		return
	}
	slog.Info("[Message.CreateGroup] success", "conversation_id", convo.ID, "name", input.Name, "caller_id", callerID)
	response.Created(w, convo)
}

// POST /api/messages/send
func (h *MessageHandler) Send(w http.ResponseWriter, r *http.Request) {
	var input struct {
		ConversationID string  `json:"conversation_id" validate:"required"`
		Content        *string `json:"content,omitempty"`
		Type           string  `json:"type" validate:"required,oneof=text image voice"`
		MediaURL       *string `json:"media_url,omitempty" validate:"omitempty,url"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Message.Send] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body")
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Message.Send] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	// Content required for text messages
	if input.Type == "text" && (input.Content == nil || *input.Content == "") {
		slog.Warn("[Message.Send] missing content for text message", "conversation_id", input.ConversationID)
		response.ValidationError(w, []string{"content is required for text messages"})
		return
	}
	// Media URL required for image/voice
	if (input.Type == "image" || input.Type == "voice") && (input.MediaURL == nil || *input.MediaURL == "") {
		slog.Warn("[Message.Send] missing media_url for media message", "conversation_id", input.ConversationID, "type", input.Type)
		response.ValidationError(w, []string{"media_url is required for image/voice messages"})
		return
	}

	callerID := middleware.GetUserID(r.Context())
	msg := &repository.Message{
		ConversationID: input.ConversationID,
		SenderID:       callerID,
		Content:        input.Content,
		Type:           input.Type,
		MediaURL:       input.MediaURL,
	}

	if err := h.messageService.SendMessage(r.Context(), msg); err != nil {
		slog.Error("[Message.Send] failed", "conversation_id", input.ConversationID, "sender_id", callerID, "error", err)
		response.Forbidden(w, err.Error())
		return
	}
	slog.Info("[Message.Send] success", "message_id", msg.ID, "conversation_id", input.ConversationID, "sender_id", callerID, "type", input.Type)
	response.Created(w, msg)
}

// GET /api/messages/conversations?page=1&limit=20
func (h *MessageHandler) ListConversations(w http.ResponseWriter, r *http.Request) {
	callerID := middleware.GetUserID(r.Context())
	params := paginationFromQuery(r)

	convos, meta, err := h.messageService.GetConversations(r.Context(), callerID, params)
	if err != nil {
		slog.Error("[Message.ListConversations] failed", "caller_id", callerID, "error", err)
		response.InternalError(w, "Failed to fetch conversations")
		return
	}
	slog.Debug("[Message.ListConversations] success", "caller_id", callerID, "total", meta.Total)
	response.OKPaginated(w, convos, meta)
}

// GET /api/messages/conversations/{id}?page=1&limit=50
func (h *MessageHandler) GetMessages(w http.ResponseWriter, r *http.Request) {
	conversationID := chi.URLParam(r, "id")
	callerID := middleware.GetUserID(r.Context())
	params := paginationFromQuery(r)
	if params.Limit == 20 {
		params.Limit = 50 // default to 50 for message lists
	}

	msgs, meta, err := h.messageService.GetMessages(r.Context(), conversationID, callerID, params)
	if err != nil {
		slog.Error("[Message.GetMessages] failed", "conversation_id", conversationID, "caller_id", callerID, "error", err)
		response.Forbidden(w, err.Error())
		return
	}
	slog.Debug("[Message.GetMessages] success", "conversation_id", conversationID, "total", meta.Total)
	response.OKPaginated(w, msgs, meta)
}

// POST /api/messages/conversations/{id}/read
func (h *MessageHandler) MarkAsRead(w http.ResponseWriter, r *http.Request) {
	conversationID := chi.URLParam(r, "id")
	callerID := middleware.GetUserID(r.Context())

	count, err := h.messageService.MarkAsRead(r.Context(), conversationID, callerID)
	if err != nil {
		slog.Error("[Message.MarkAsRead] failed", "conversation_id", conversationID, "caller_id", callerID, "error", err)
		response.Forbidden(w, err.Error())
		return
	}
	slog.Debug("[Message.MarkAsRead] success", "conversation_id", conversationID, "marked_read", count)
	response.OK(w, map[string]any{"marked_read": count})
}
