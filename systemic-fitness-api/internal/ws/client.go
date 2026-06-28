package ws

import (
	"encoding/json"
	"log/slog"
	"time"

	"github.com/gorilla/websocket"
)

const (
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	maxMessageSize = 4096
)

// Client represents a single WebSocket connection.
type Client struct {
	hub       *Hub
	conn      *websocket.Conn
	send      chan []byte
	UserID    string
	Role      string
	onConnect func(*Client) // called after registration
}

// Event is the wire format for WebSocket messages.
type Event struct {
	Type string          `json:"type"`
	Data json.RawMessage `json:"data"`
}

// TypingEvent is sent by clients to indicate typing status.
type TypingEvent struct {
	ConversationID string `json:"conversation_id"`
	UserID         string `json:"user_id"`
	UserName       string `json:"user_name,omitempty"`
}

// Send enqueues a raw message to be written to the WebSocket connection.
func (c *Client) Send(msg []byte) {
	select {
	case c.send <- msg:
	default:
	}
}

// readPump pumps messages from the WebSocket connection to the hub.
func (c *Client) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseNormalClosure) {
				slog.Warn("ws read error", "user_id", c.UserID, "error", err)
			}
			break
		}

		// Parse incoming event
		var event Event
		if err := json.Unmarshal(message, &event); err != nil {
			continue
		}

		// Handle client-to-server events
		switch event.Type {
		case "typing_start", "typing_stop":
			// Parse the conversation ID and broadcast to other members only
			var typing TypingEvent
			if err := json.Unmarshal(event.Data, &typing); err != nil {
				continue
			}
			typing.UserID = c.UserID // enforce server-side

			if typing.ConversationID == "" {
				continue
			}

			// Use the hub's targeted broadcast for conversation members
			c.hub.BroadcastToConversation(typing.ConversationID, c.UserID, event.Type, typing)

		case "ping":
			// Client-level ping (distinct from WebSocket ping/pong)
			payload, _ := marshalEvent("pong", nil)
			select {
			case c.send <- payload:
			default:
			}
		}
	}
}

// writePump pumps messages from the hub to the WebSocket connection.
func (c *Client) writePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				// Hub closed the channel
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			// Drain queued messages into the same write for efficiency
			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write([]byte("\n"))
				w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}
