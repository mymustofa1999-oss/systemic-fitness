package service

// ════════════════════════════════════════════════════════════════
//  Midtrans Service
//
//  Thin wrapper for the Midtrans Snap API and notification (webhook)
//  signature verification. Implemented using stdlib net/http to avoid
//  pulling in the official SDK — keeps the dependency surface small.
//
//  Two environments:
//    - sandbox    : https://app.sandbox.midtrans.com/snap/v1/transactions
//    - production : https://app.midtrans.com/snap/v1/transactions
//
//  Required env vars (loaded by config.Load):
//    - MIDTRANS_SERVER_KEY
//    - MIDTRANS_CLIENT_KEY    (only used by frontend, kept for completeness)
//    - MIDTRANS_ENV           (sandbox | production, default: sandbox)
//    - MIDTRANS_NOTIFY_URL    (full webhook URL the gateway calls back)
//
//  Important: while building, we only enable Midtrans when SERVER_KEY
//  is non-empty. The handler/service still works in "manual transfer
//  only" mode if env vars are absent.
// ════════════════════════════════════════════════════════════════

import (
	"bytes"
	"context"
	"crypto/sha512"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"time"
)

const (
	midtransSandboxURL    = "https://app.sandbox.midtrans.com/snap/v1/transactions"
	midtransProductionURL = "https://app.midtrans.com/snap/v1/transactions"
)

var (
	ErrMidtransNotConfigured = errors.New("midtrans is not configured (MIDTRANS_SERVER_KEY missing)")
	ErrMidtransRequestFailed = errors.New("midtrans request failed")
	ErrMidtransInvalidSig    = errors.New("invalid midtrans signature")
)

type MidtransService struct {
	serverKey string
	clientKey string
	env       string // sandbox | production
	notifyURL string
	httpClient *http.Client
	logger    *slog.Logger
}

func NewMidtransService(
	serverKey, clientKey, env, notifyURL string,
	logger *slog.Logger,
) *MidtransService {
	if env == "" {
		env = "sandbox"
	}
	return &MidtransService{
		serverKey:  serverKey,
		clientKey:  clientKey,
		env:        env,
		notifyURL:  notifyURL,
		httpClient: &http.Client{Timeout: 15 * time.Second},
		logger:     logger,
	}
}

// IsConfigured reports whether the service has a valid server key.
// Callers should check this before invoking CreateSnapTransaction so
// they can fall back to manual transfer.
func (s *MidtransService) IsConfigured() bool {
	return s.serverKey != ""
}

// snapURL returns the right endpoint based on env.
func (s *MidtransService) snapURL() string {
	if s.env == "production" {
		return midtransProductionURL
	}
	return midtransSandboxURL
}

// ── Snap Transaction ────────────────────────────────────────────

type SnapCustomerDetails struct {
	FirstName string `json:"first_name,omitempty"`
	LastName  string `json:"last_name,omitempty"`
	Email     string `json:"email,omitempty"`
	Phone     string `json:"phone,omitempty"`
}

type SnapTransactionDetails struct {
	OrderID     string  `json:"order_id"`
	GrossAmount float64 `json:"gross_amount"`
}

type SnapItemDetails struct {
	ID       string  `json:"id"`
	Price    float64 `json:"price"`
	Quantity int     `json:"quantity"`
	Name     string  `json:"name"`
	Category string  `json:"category,omitempty"`
}

type SnapCallbacks struct {
	Finish string `json:"finish,omitempty"`
}

type SnapTransactionRequest struct {
	TransactionDetails SnapTransactionDetails `json:"transaction_details"`
	ItemDetails        []SnapItemDetails      `json:"item_details,omitempty"`
	CustomerDetails    *SnapCustomerDetails   `json:"customer_details,omitempty"`
	Callbacks          *SnapCallbacks         `json:"callbacks,omitempty"`
	Expiry             *SnapExpiry            `json:"expiry,omitempty"`
}

type SnapExpiry struct {
	StartTime string `json:"start_time,omitempty"` // 2024-01-01 12:00:00 +0700
	Unit      string `json:"unit,omitempty"`       // minute | hour | day
	Duration  int    `json:"duration,omitempty"`
}

type SnapTransactionResponse struct {
	Token       string `json:"token"`
	RedirectURL string `json:"redirect_url"`
}

// CreateSnapTransaction creates a new Snap transaction in Midtrans
// and returns the snap_token + redirect_url that the mobile app will
// use to launch the payment UI.
func (s *MidtransService) CreateSnapTransaction(ctx context.Context, req *SnapTransactionRequest) (*SnapTransactionResponse, error) {
	if !s.IsConfigured() {
		return nil, ErrMidtransNotConfigured
	}

	body, err := json.Marshal(req)
	if err != nil {
		return nil, fmt.Errorf("marshalling snap request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, s.snapURL(), bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("building snap request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Accept", "application/json")
	// Midtrans uses Basic auth: base64(server_key + ":")
	auth := base64.StdEncoding.EncodeToString([]byte(s.serverKey + ":"))
	httpReq.Header.Set("Authorization", "Basic "+auth)

	resp, err := s.httpClient.Do(httpReq)
	if err != nil {
		s.logger.Error("midtrans snap request failed", "error", err)
		return nil, fmt.Errorf("%w: %v", ErrMidtransRequestFailed, err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode >= 400 {
		s.logger.Error("midtrans snap returned error",
			"status", resp.StatusCode,
			"body", string(respBody),
			"order_id", req.TransactionDetails.OrderID,
		)
		return nil, fmt.Errorf("%w: status %d: %s", ErrMidtransRequestFailed, resp.StatusCode, string(respBody))
	}

	var out SnapTransactionResponse
	if err := json.Unmarshal(respBody, &out); err != nil {
		return nil, fmt.Errorf("decoding snap response: %w", err)
	}

	s.logger.Info("midtrans snap transaction created",
		"order_id", req.TransactionDetails.OrderID,
		"amount", req.TransactionDetails.GrossAmount,
	)
	return &out, nil
}

// ── Webhook Notification ────────────────────────────────────────

// MidtransNotification represents the JSON body of a HTTP notification
// callback from Midtrans. We only model the fields we actually need.
// Full reference: https://docs.midtrans.com/docs/https-notification
type MidtransNotification struct {
	TransactionTime    string `json:"transaction_time"`
	TransactionStatus  string `json:"transaction_status"` // settlement | pending | deny | cancel | expire | refund | chargeback
	TransactionID      string `json:"transaction_id"`
	StatusMessage      string `json:"status_message"`
	StatusCode         string `json:"status_code"`
	SignatureKey       string `json:"signature_key"`
	PaymentType        string `json:"payment_type"`
	OrderID            string `json:"order_id"`
	MerchantID         string `json:"merchant_id"`
	GrossAmount        string `json:"gross_amount"`
	FraudStatus        string `json:"fraud_status"`
	Currency           string `json:"currency"`
	SettlementTime     string `json:"settlement_time,omitempty"`
}

// VerifySignature checks the Midtrans notification's signature_key.
// Formula:
//   sha512(order_id + status_code + gross_amount + server_key)
//
// Reference: https://docs.midtrans.com/docs/https-notification
func (s *MidtransService) VerifySignature(notif *MidtransNotification) error {
	if !s.IsConfigured() {
		return ErrMidtransNotConfigured
	}

	expected := sha512Hex(notif.OrderID + notif.StatusCode + notif.GrossAmount + s.serverKey)
	if expected != notif.SignatureKey {
		s.logger.Warn("midtrans signature mismatch",
			"order_id", notif.OrderID,
			"expected", expected,
			"got", notif.SignatureKey,
		)
		return ErrMidtransInvalidSig
	}
	return nil
}

// MapTransactionStatus converts Midtrans transaction_status into
// our internal payment_records.status values.
//
// Internal payment_status enum: pending | completed | failed | refunded
func MapTransactionStatus(midtransStatus string) string {
	switch midtransStatus {
	case "settlement", "capture":
		return "completed"
	case "deny", "cancel", "expire":
		return "failed"
	case "refund", "chargeback":
		return "refunded"
	default:
		return "pending"
	}
}

func sha512Hex(s string) string {
	h := sha512.Sum512([]byte(s))
	return hex.EncodeToString(h[:])
}
