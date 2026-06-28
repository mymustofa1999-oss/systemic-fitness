package service

import (
	"context"
	"crypto/sha512"
	"encoding/hex"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
)

// ═══════════════════════════════════════════════════════════════
//  Midtrans Service Unit Tests
//  Pure-function tests that do not touch the database. Covers:
//    - MapTransactionStatus      (gateway → internal status)
//    - VerifySignature           (sha512 formula)
//    - IsConfigured              (env gating)
//    - CreateSnapTransaction     (happy path, error path) — stubs
//                                  Midtrans Snap API via httptest.
// ═══════════════════════════════════════════════════════════════

func testLogger() *slog.Logger {
	return slog.New(slog.NewTextHandler(io.Discard, &slog.HandlerOptions{Level: slog.LevelError}))
}

// ── MapTransactionStatus ────────────────────────────────────────

func TestMapTransactionStatus(t *testing.T) {
	cases := []struct {
		in   string
		want string
	}{
		{"settlement", "completed"},
		{"capture", "completed"},
		{"pending", "pending"},
		{"", "pending"},
		{"deny", "failed"},
		{"cancel", "failed"},
		{"expire", "failed"},
		{"refund", "refunded"},
		{"chargeback", "refunded"},
		{"weird_unknown_value", "pending"},
	}
	for _, c := range cases {
		t.Run(c.in, func(t *testing.T) {
			if got := MapTransactionStatus(c.in); got != c.want {
				t.Errorf("MapTransactionStatus(%q) = %q, want %q", c.in, got, c.want)
			}
		})
	}
}

// ── IsConfigured ────────────────────────────────────────────────

func TestMidtrans_IsConfigured(t *testing.T) {
	configured := NewMidtransService("SB-Mid-server-XXX", "", "sandbox", "", testLogger())
	if !configured.IsConfigured() {
		t.Error("expected IsConfigured=true when server key is set")
	}

	empty := NewMidtransService("", "", "sandbox", "", testLogger())
	if empty.IsConfigured() {
		t.Error("expected IsConfigured=false when server key is empty")
	}
}

// ── VerifySignature ─────────────────────────────────────────────

// Helper: compute the signature Midtrans would send for given fields.
// Formula: sha512(order_id + status_code + gross_amount + server_key)
func makeSignature(orderID, statusCode, grossAmount, serverKey string) string {
	s := orderID + statusCode + grossAmount + serverKey
	h := sha512.Sum512([]byte(s))
	return hex.EncodeToString(h[:])
}

func TestMidtrans_VerifySignature_Valid(t *testing.T) {
	serverKey := "SB-Mid-server-unit-test"
	svc := NewMidtransService(serverKey, "", "sandbox", "", testLogger())

	notif := &MidtransNotification{
		OrderID:     "FC-abc123",
		StatusCode:  "200",
		GrossAmount: "49000.00",
	}
	notif.SignatureKey = makeSignature(notif.OrderID, notif.StatusCode, notif.GrossAmount, serverKey)

	if err := svc.VerifySignature(notif); err != nil {
		t.Errorf("expected valid signature, got error: %v", err)
	}
}

func TestMidtrans_VerifySignature_Invalid(t *testing.T) {
	svc := NewMidtransService("SB-Mid-server-unit-test", "", "sandbox", "", testLogger())

	notif := &MidtransNotification{
		OrderID:      "FC-abc123",
		StatusCode:   "200",
		GrossAmount:  "49000.00",
		SignatureKey: "obviously-wrong-signature",
	}

	if err := svc.VerifySignature(notif); err == nil {
		t.Error("expected invalid signature error, got nil")
	}
}

func TestMidtrans_VerifySignature_WrongServerKey(t *testing.T) {
	realKey := "SB-Mid-server-real"
	attackerKey := "attacker-guess"

	svc := NewMidtransService(realKey, "", "sandbox", "", testLogger())

	notif := &MidtransNotification{
		OrderID:     "FC-abc123",
		StatusCode:  "200",
		GrossAmount: "49000.00",
	}
	// Sign with the wrong key — must be rejected.
	notif.SignatureKey = makeSignature(notif.OrderID, notif.StatusCode, notif.GrossAmount, attackerKey)

	if err := svc.VerifySignature(notif); err == nil {
		t.Error("expected signature signed with wrong key to be rejected")
	}
}

func TestMidtrans_VerifySignature_NotConfigured(t *testing.T) {
	svc := NewMidtransService("", "", "sandbox", "", testLogger())
	notif := &MidtransNotification{OrderID: "X", StatusCode: "200", GrossAmount: "1.00"}
	if err := svc.VerifySignature(notif); err == nil {
		t.Error("expected ErrMidtransNotConfigured when server key empty")
	}
}

// ── CreateSnapTransaction ───────────────────────────────────────

// Swap snap URL to a httptest server for the duration of a test.
// We can't patch the constants, but NewMidtransService computes the
// URL via snapURL() which checks env. Instead we test by stubbing
// http.DefaultClient via a custom httpClient on the service.
func TestMidtrans_CreateSnapTransaction_HappyPath(t *testing.T) {
	var receivedBody map[string]interface{}

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			t.Errorf("expected POST, got %s", r.Method)
		}
		if !strings.HasPrefix(r.Header.Get("Authorization"), "Basic ") {
			t.Errorf("expected Basic auth header, got %q", r.Header.Get("Authorization"))
		}
		if r.Header.Get("Content-Type") != "application/json" {
			t.Errorf("expected Content-Type application/json, got %q", r.Header.Get("Content-Type"))
		}
		_ = json.NewDecoder(r.Body).Decode(&receivedBody)
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"token":"snap-token-abc","redirect_url":"https://app.sandbox.midtrans.com/snap/v2/vtweb/snap-token-abc"}`))
	}))
	defer server.Close()

	svc := NewMidtransService("SB-Mid-server-test", "", "sandbox", "", testLogger())
	// Redirect to the httptest server by swapping the client Transport.
	svc.httpClient = server.Client()
	// Override snap URL via monkey-patching is not easy in Go; instead we
	// use a custom round tripper that rewrites the host.
	svc.httpClient = &http.Client{
		Transport: rewriteHostTransport{target: server.URL},
	}

	req := &SnapTransactionRequest{
		TransactionDetails: SnapTransactionDetails{OrderID: "FC-test-1", GrossAmount: 49000},
		ItemDetails: []SnapItemDetails{
			{ID: "plan-1", Price: 49000, Quantity: 1, Name: "Premium Monthly", Category: "subscription"},
		},
		CustomerDetails: &SnapCustomerDetails{
			FirstName: "Jane",
			Email:     "jane@example.com",
		},
	}
	resp, err := svc.CreateSnapTransaction(context.Background(), req)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp.Token != "snap-token-abc" {
		t.Errorf("expected token=snap-token-abc, got %q", resp.Token)
	}
	if !strings.Contains(resp.RedirectURL, "snap-token-abc") {
		t.Errorf("unexpected redirect url: %q", resp.RedirectURL)
	}
	if got, ok := receivedBody["transaction_details"].(map[string]interface{}); !ok || got["order_id"] != "FC-test-1" {
		t.Errorf("server did not receive expected body: %+v", receivedBody)
	}
}

func TestMidtrans_CreateSnapTransaction_NotConfigured(t *testing.T) {
	svc := NewMidtransService("", "", "sandbox", "", testLogger())
	_, err := svc.CreateSnapTransaction(context.Background(), &SnapTransactionRequest{
		TransactionDetails: SnapTransactionDetails{OrderID: "X", GrossAmount: 100},
	})
	if err == nil {
		t.Error("expected error when not configured")
	}
}

func TestMidtrans_CreateSnapTransaction_GatewayError(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusUnauthorized)
		_, _ = w.Write([]byte(`{"status_code":"401","status_message":"Access denied"}`))
	}))
	defer server.Close()

	svc := NewMidtransService("SB-Mid-server-test", "", "sandbox", "", testLogger())
	svc.httpClient = &http.Client{
		Transport: rewriteHostTransport{target: server.URL},
	}

	_, err := svc.CreateSnapTransaction(context.Background(), &SnapTransactionRequest{
		TransactionDetails: SnapTransactionDetails{OrderID: "X", GrossAmount: 100},
	})
	if err == nil {
		t.Error("expected error on 401 gateway response")
	}
}

// ── Test helpers ────────────────────────────────────────────────

// rewriteHostTransport rewrites every request to point at the test
// server URL, regardless of the original scheme/host. Used to avoid
// hitting the real Midtrans API during tests.
type rewriteHostTransport struct{ target string }

func (r rewriteHostTransport) RoundTrip(req *http.Request) (*http.Response, error) {
	// Clone the URL and rewrite host/scheme while preserving path.
	target := r.target
	if strings.HasSuffix(target, "/") {
		target = strings.TrimSuffix(target, "/")
	}
	// Replace the entire URL's scheme+host with the test server's.
	req.URL.Scheme = "http"
	// Extract host:port from r.target (which is like http://127.0.0.1:xxxxx)
	trimmed := strings.TrimPrefix(target, "http://")
	trimmed = strings.TrimPrefix(trimmed, "https://")
	req.URL.Host = trimmed
	req.Host = trimmed
	return http.DefaultTransport.RoundTrip(req)
}

// Ensure tests are quiet even when run with -v by silencing slog.
func TestMain(m *testing.M) {
	slog.SetDefault(testLogger())
	os.Exit(m.Run())
}
