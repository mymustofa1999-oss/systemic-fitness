package handler

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/fitcoach/api/pkg/response"
)

// ═══════════════════════════════════════════════════════════════
//  Integration-style tests for auth handlers
//  These test the HTTP layer (request parsing, validation,
//  response formatting) without a real DB.
// ═══════════════════════════════════════════════════════════════

func TestLogin_MissingFields(t *testing.T) {
	// No AuthService needed — validation fails before service is called
	handler := &AuthHandler{authService: nil}

	body := `{}`
	req := httptest.NewRequest(http.MethodPost, "/api/auth/login", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	handler.Login(rec, req)

	assert.Equal(t, http.StatusBadRequest, rec.Code)

	var resp response.Envelope
	err := json.NewDecoder(rec.Body).Decode(&resp)
	require.NoError(t, err)
	assert.False(t, resp.Success)
	assert.NotEmpty(t, resp.Errors)
}

func TestLogin_InvalidJSON(t *testing.T) {
	handler := &AuthHandler{authService: nil}

	req := httptest.NewRequest(http.MethodPost, "/api/auth/login", bytes.NewBufferString(`{invalid}`))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	handler.Login(rec, req)

	assert.Equal(t, http.StatusBadRequest, rec.Code)
}

func TestLogin_InvalidEmail(t *testing.T) {
	handler := &AuthHandler{authService: nil}

	body := `{"email":"not-an-email","password":"password123"}`
	req := httptest.NewRequest(http.MethodPost, "/api/auth/login", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	handler.Login(rec, req)

	assert.Equal(t, http.StatusBadRequest, rec.Code)

	var resp response.Envelope
	err := json.NewDecoder(rec.Body).Decode(&resp)
	require.NoError(t, err)
	assert.Contains(t, resp.Errors[0], "email")
}

func TestRegister_MissingFields(t *testing.T) {
	handler := &AuthHandler{authService: nil}

	body := `{"email":"test@example.com"}`
	req := httptest.NewRequest(http.MethodPost, "/api/auth/register", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	handler.Register(rec, req)

	assert.Equal(t, http.StatusBadRequest, rec.Code)

	var resp response.Envelope
	err := json.NewDecoder(rec.Body).Decode(&resp)
	require.NoError(t, err)
	assert.False(t, resp.Success)
	assert.True(t, len(resp.Errors) >= 2, "Should have multiple validation errors")
}

func TestRegister_PasswordTooShort(t *testing.T) {
	handler := &AuthHandler{authService: nil}

	body := `{"email":"test@example.com","password":"short","full_name":"Test","role":"client"}`
	req := httptest.NewRequest(http.MethodPost, "/api/auth/register", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	handler.Register(rec, req)

	assert.Equal(t, http.StatusBadRequest, rec.Code)

	var resp response.Envelope
	err := json.NewDecoder(rec.Body).Decode(&resp)
	require.NoError(t, err)
	assert.Contains(t, resp.Errors[0], "password")
}

func TestRegister_InvalidRole(t *testing.T) {
	handler := &AuthHandler{authService: nil}

	body := `{"email":"test@example.com","password":"password123","full_name":"Test","role":"superadmin"}`
	req := httptest.NewRequest(http.MethodPost, "/api/auth/register", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	handler.Register(rec, req)

	assert.Equal(t, http.StatusBadRequest, rec.Code)

	var resp response.Envelope
	err := json.NewDecoder(rec.Body).Decode(&resp)
	require.NoError(t, err)
	assert.Contains(t, resp.Errors[0], "role")
}

func TestRefresh_MissingToken(t *testing.T) {
	handler := &AuthHandler{authService: nil}

	body := `{}`
	req := httptest.NewRequest(http.MethodPost, "/api/auth/refresh", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	handler.Refresh(rec, req)

	assert.Equal(t, http.StatusBadRequest, rec.Code)
}

func TestForgotPassword_AlwaysReturns200(t *testing.T) {
	handler := &AuthHandler{authService: nil}

	body := `{"email":"anyone@example.com"}`
	req := httptest.NewRequest(http.MethodPost, "/api/auth/forgot-password", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	handler.ForgotPassword(rec, req)

	// Should always return 200 to prevent email enumeration
	assert.Equal(t, http.StatusOK, rec.Code)

	var resp response.Envelope
	err := json.NewDecoder(rec.Body).Decode(&resp)
	require.NoError(t, err)
	assert.True(t, resp.Success)
}

func TestMe_NoAuth(t *testing.T) {
	handler := &AuthHandler{authService: nil}

	req := httptest.NewRequest(http.MethodGet, "/api/auth/me", nil)
	rec := httptest.NewRecorder()

	// No auth middleware → no user in context
	handler.Me(rec, req)

	assert.Equal(t, http.StatusUnauthorized, rec.Code)
}

// ═══════════════════════════════════════════════════════════════
//  Response envelope helper test
// ═══════════════════════════════════════════════════════════════

func TestResponseEnvelope_Format(t *testing.T) {
	rec := httptest.NewRecorder()
	response.OK(rec, map[string]string{"hello": "world"})

	assert.Equal(t, http.StatusOK, rec.Code)
	assert.Equal(t, "application/json", rec.Header().Get("Content-Type"))

	var resp response.Envelope
	err := json.NewDecoder(rec.Body).Decode(&resp)
	require.NoError(t, err)
	assert.True(t, resp.Success)
	assert.NotNil(t, resp.Data)
}
