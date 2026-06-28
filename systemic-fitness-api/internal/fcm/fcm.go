package fcm

import (
	"bytes"
	"context"
	"crypto/rsa"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// Client wraps FCM HTTP v1 API calls.
type Client struct {
	projectID  string
	httpClient *http.Client
	logger     *slog.Logger

	// Service account fields for OAuth2 token generation
	clientEmail string
	privateKey  *rsa.PrivateKey

	// Cached access token
	mu          sync.Mutex
	accessToken string
	tokenExpiry time.Time
}

// Message represents an FCM message payload.
type Message struct {
	Token string            // FCM device token
	Title string            // Notification title
	Body  string            // Notification body
	Data  map[string]string // Custom data payload (for deep linking)
	Image string            // Optional image URL
}

// ── FCM HTTP v1 request structs ─────────────────────────────────

type fcmRequest struct {
	Message fcmMessage `json:"message"`
}

type fcmMessage struct {
	Token        string            `json:"token"`
	Notification *fcmNotification  `json:"notification,omitempty"`
	Data         map[string]string `json:"data,omitempty"`
	Android      *fcmAndroid       `json:"android,omitempty"`
	APNS         *fcmAPNS          `json:"apns,omitempty"`
}

type fcmNotification struct {
	Title string `json:"title"`
	Body  string `json:"body"`
	Image string `json:"image,omitempty"`
}

type fcmAndroid struct {
	Priority     string           `json:"priority,omitempty"`
	Notification *fcmAndroidNotif `json:"notification,omitempty"`
}

type fcmAndroidNotif struct {
	Sound string `json:"sound,omitempty"`
}

type fcmAPNS struct {
	Payload *fcmAPNSPayload `json:"payload,omitempty"`
}

type fcmAPNSPayload struct {
	APS *fcmAPS `json:"aps,omitempty"`
}

type fcmAPS struct {
	Sound string `json:"sound,omitempty"`
	Badge int    `json:"badge,omitempty"`
}

// serviceAccount is the structure of a Firebase service account JSON file.
type serviceAccount struct {
	ProjectID   string `json:"project_id"`
	ClientEmail string `json:"client_email"`
	PrivateKey  string `json:"private_key"`
}

// New creates a new FCM client from a service account credentials JSON file.
func New(credentialsFile string, logger *slog.Logger) (*Client, error) {
	data, err := os.ReadFile(credentialsFile)
	if err != nil {
		return nil, fmt.Errorf("read FCM credentials: %w", err)
	}

	var sa serviceAccount
	if err := json.Unmarshal(data, &sa); err != nil {
		return nil, fmt.Errorf("parse FCM credentials: %w", err)
	}

	if sa.ProjectID == "" || sa.ClientEmail == "" || sa.PrivateKey == "" {
		return nil, fmt.Errorf("FCM credentials missing required fields (project_id, client_email, private_key)")
	}

	block, _ := pem.Decode([]byte(sa.PrivateKey))
	if block == nil {
		return nil, fmt.Errorf("FCM: failed to decode private key PEM")
	}

	key, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("FCM: parse private key: %w", err)
	}

	rsaKey, ok := key.(*rsa.PrivateKey)
	if !ok {
		return nil, fmt.Errorf("FCM: private key is not RSA")
	}

	logger.Info("FCM client initialized", "project_id", sa.ProjectID)

	return &Client{
		projectID:   sa.ProjectID,
		clientEmail: sa.ClientEmail,
		privateKey:  rsaKey,
		httpClient:  &http.Client{Timeout: 10 * time.Second},
		logger:      logger,
	}, nil
}

// NewNoop creates a no-op client that logs instead of sending.
// Use this when FCM is not configured (development mode).
func NewNoop(logger *slog.Logger) *Client {
	logger.Warn("FCM not configured — running in noop mode (push notifications will be logged only)")
	return &Client{
		projectID:  "",
		httpClient: nil,
		logger:     logger,
	}
}

// IsNoop returns true if this is a no-op (development) client.
func (c *Client) IsNoop() bool {
	return c.projectID == ""
}

// getAccessToken returns a cached or fresh OAuth2 access token for FCM.
func (c *Client) getAccessToken() (string, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	// Return cached token if still valid (with 5-min buffer)
	if c.accessToken != "" && time.Now().Before(c.tokenExpiry.Add(-5*time.Minute)) {
		return c.accessToken, nil
	}

	// Generate a new JWT and exchange it for an access token
	now := time.Now()
	claims := jwt.MapClaims{
		"iss":   c.clientEmail,
		"sub":   c.clientEmail,
		"aud":   "https://oauth2.googleapis.com/token",
		"iat":   now.Unix(),
		"exp":   now.Add(time.Hour).Unix(),
		"scope": "https://www.googleapis.com/auth/firebase.messaging",
	}

	token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	signedJWT, err := token.SignedString(c.privateKey)
	if err != nil {
		return "", fmt.Errorf("sign JWT: %w", err)
	}

	// Exchange JWT for access token
	resp, err := http.PostForm("https://oauth2.googleapis.com/token", map[string][]string{
		"grant_type": {"urn:ietf:params:oauth:grant-type:jwt-bearer"},
		"assertion":  {signedJWT},
	})
	if err != nil {
		return "", fmt.Errorf("token exchange: %w", err)
	}
	defer resp.Body.Close()

	var tokenResp struct {
		AccessToken string `json:"access_token"`
		ExpiresIn   int    `json:"expires_in"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&tokenResp); err != nil {
		return "", fmt.Errorf("decode token response: %w", err)
	}

	c.accessToken = tokenResp.AccessToken
	c.tokenExpiry = now.Add(time.Duration(tokenResp.ExpiresIn) * time.Second)

	return c.accessToken, nil
}

// Send sends a push notification to a single device token.
func (c *Client) Send(ctx context.Context, msg *Message) error {
	if c.IsNoop() {
		c.logger.Info("FCM noop: would send push",
			"token", truncate(msg.Token, 20),
			"title", msg.Title,
			"data", msg.Data,
		)
		return nil
	}

	accessToken, err := c.getAccessToken()
	if err != nil {
		return fmt.Errorf("FCM auth: %w", err)
	}

	url := fmt.Sprintf("https://fcm.googleapis.com/v1/projects/%s/messages:send", c.projectID)

	payload := fcmRequest{
		Message: fcmMessage{
			Token: msg.Token,
			Notification: &fcmNotification{
				Title: msg.Title,
				Body:  msg.Body,
				Image: msg.Image,
			},
			Data: msg.Data,
			Android: &fcmAndroid{
				Priority: "high",
				Notification: &fcmAndroidNotif{
					Sound: "default",
				},
			},
			APNS: &fcmAPNS{
				Payload: &fcmAPNSPayload{
					APS: &fcmAPS{
						Sound: "default",
						Badge: 1,
					},
				},
			},
		},
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshal FCM: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create FCM request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+accessToken)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("FCM request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		c.logger.Debug("FCM sent", "token", truncate(msg.Token, 20), "title", msg.Title)
		return nil
	}

	respBody, _ := io.ReadAll(resp.Body)

	// 404 or UNREGISTERED = token expired → caller should deactivate
	if resp.StatusCode == 404 || resp.StatusCode == 410 {
		return ErrTokenExpired
	}

	return fmt.Errorf("FCM error %d: %s", resp.StatusCode, string(respBody))
}

// SendMulti sends push to multiple tokens.
// Returns tokens that failed (expired/invalid — should be deactivated).
func (c *Client) SendMulti(ctx context.Context, tokens []string, title, body string, data map[string]string, image string) []string {
	var failedTokens []string
	for _, token := range tokens {
		err := c.Send(ctx, &Message{
			Token: token,
			Title: title,
			Body:  body,
			Data:  data,
			Image: image,
		})
		if err != nil {
			c.logger.Warn("FCM send failed", "error", err)
			failedTokens = append(failedTokens, token)
		}
	}
	return failedTokens
}

// ErrTokenExpired indicates the FCM token is no longer valid.
var ErrTokenExpired = fmt.Errorf("FCM token expired or invalid")

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "..."
}
