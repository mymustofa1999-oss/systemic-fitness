package ws

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		// TODO: in production, validate against CORS allowed origins
		return true
	},
}

// MemberResolver is a function that returns member IDs for a conversation.
// Set this after initialization to avoid circular imports with the repository layer.
type MemberResolver func(ctx context.Context, conversationID string) ([]string, error)

// Hub maintains the set of active WebSocket clients and handles broadcasting.
type Hub struct {
	mu              sync.RWMutex
	clients         map[*Client]bool
	userIndex       map[string]*Client // userID → client (1 connection per user)
	broadcast       chan []byte
	register        chan *Client
	unregister      chan *Client
	logger          *slog.Logger
	MemberResolver  MemberResolver // injected after init to resolve conversation members
}

func NewHub(logger *slog.Logger) *Hub {
	return &Hub{
		clients:    make(map[*Client]bool),
		userIndex:  make(map[string]*Client),
		broadcast:  make(chan []byte, 256),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		logger:     logger,
	}
}

// Run starts the hub event loop. Call as `go hub.Run()`.
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			// Disconnect existing connection for same user (replace)
			if old, ok := h.userIndex[client.UserID]; ok {
				close(old.send)
				delete(h.clients, old)
			}
			h.clients[client] = true
			h.userIndex[client.UserID] = client
			h.mu.Unlock()

			h.logger.Info("ws connected", "user_id", client.UserID, "total", len(h.clients))
			h.broadcastToAll("user_online", map[string]string{"user_id": client.UserID})

			// Send initial data to the connecting client
			if client.onConnect != nil {
				go client.onConnect(client)
			}

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				delete(h.userIndex, client.UserID)
				close(client.send)
			}
			h.mu.Unlock()

			h.logger.Info("ws disconnected", "user_id", client.UserID, "total", len(h.clients))
			h.broadcastToAll("user_offline", map[string]string{"user_id": client.UserID})

		case message := <-h.broadcast:
			h.mu.RLock()
			for client := range h.clients {
				select {
				case client.send <- message:
				default:
					// Client buffer full — disconnect it
					close(client.send)
					delete(h.clients, client)
					delete(h.userIndex, client.UserID)
				}
			}
			h.mu.RUnlock()
		}
	}
}

// ═══════════════════════════════════════════════════════════════
//  Online Status
// ═══════════════════════════════════════════════════════════════

// IsOnline checks whether a user has an active WebSocket connection.
func (h *Hub) IsOnline(userID string) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	_, ok := h.userIndex[userID]
	return ok
}

// OnlineCount returns the number of connected clients.
func (h *Hub) OnlineCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}

// OnlineUserIDs returns all currently connected user IDs.
func (h *Hub) OnlineUserIDs() []string {
	h.mu.RLock()
	defer h.mu.RUnlock()
	ids := make([]string, 0, len(h.userIndex))
	for uid := range h.userIndex {
		ids = append(ids, uid)
	}
	return ids
}

// AreOnline checks which of the given user IDs are currently online.
func (h *Hub) AreOnline(userIDs []string) map[string]bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	result := make(map[string]bool, len(userIDs))
	for _, uid := range userIDs {
		_, ok := h.userIndex[uid]
		result[uid] = ok
	}
	return result
}

// ═══════════════════════════════════════════════════════════════
//  Targeted Messaging
// ═══════════════════════════════════════════════════════════════

// SendToUser sends a typed event to a specific user if they're online.
func (h *Hub) SendToUser(userID string, eventType string, data any) {
	h.mu.RLock()
	client, ok := h.userIndex[userID]
	h.mu.RUnlock()
	if !ok {
		return
	}

	payload, err := marshalEvent(eventType, data)
	if err != nil {
		return
	}

	select {
	case client.send <- payload:
	default:
		// buffer full
	}
}

// SendToUsers sends a typed event to multiple users.
func (h *Hub) SendToUsers(userIDs []string, eventType string, data any) {
	payload, err := marshalEvent(eventType, data)
	if err != nil {
		return
	}

	h.mu.RLock()
	defer h.mu.RUnlock()
	for _, uid := range userIDs {
		if client, ok := h.userIndex[uid]; ok {
			select {
			case client.send <- payload:
			default:
			}
		}
	}
}

// BroadcastToConversation sends an event to all online members of a conversation
// except the sender. Uses the MemberResolver to look up member IDs.
func (h *Hub) BroadcastToConversation(conversationID, senderID, eventType string, data any) {
	if h.MemberResolver == nil {
		h.logger.Warn("MemberResolver not set, cannot broadcast to conversation")
		return
	}

	memberIDs, err := h.MemberResolver(context.Background(), conversationID)
	if err != nil {
		h.logger.Warn("failed to resolve conversation members", "error", err)
		return
	}

	payload, err := marshalEvent(eventType, data)
	if err != nil {
		return
	}

	h.mu.RLock()
	defer h.mu.RUnlock()
	for _, uid := range memberIDs {
		if uid == senderID {
			continue
		}
		if client, ok := h.userIndex[uid]; ok {
			select {
			case client.send <- payload:
			default:
			}
		}
	}
}

func (h *Hub) broadcastToAll(eventType string, data any) {
	payload, err := marshalEvent(eventType, data)
	if err != nil {
		return
	}
	h.broadcast <- payload
}

func marshalEvent(eventType string, data any) ([]byte, error) {
	dataBytes, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	return json.Marshal(Event{
		Type: eventType,
		Data: dataBytes,
	})
}

// HandleWebSocket upgrades an HTTP request to a WebSocket connection.
// onConnect is called after the client registers (used to send initial unread count).
func (h *Hub) HandleWebSocket(userID, role string, onConnect func(*Client)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			h.logger.Error("ws upgrade failed", "error", err)
			return
		}

		client := &Client{
			hub:       h,
			conn:      conn,
			send:      make(chan []byte, 256),
			UserID:    userID,
			Role:      role,
			onConnect: onConnect,
		}

		h.register <- client

		go client.writePump()
		go client.readPump()
	}
}
