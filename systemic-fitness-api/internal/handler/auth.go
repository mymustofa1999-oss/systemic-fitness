package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type AuthHandler struct {
	authService *service.AuthService
}

func NewAuthHandler(as *service.AuthService) *AuthHandler {
	return &AuthHandler{authService: as}
}

// ────────────────────────────────────────────────────────────────
//  POST /api/auth/register
// ────────────────────────────────────────────────────────────────

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var input service.RegisterInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Auth.Register] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Auth.Register] validation failed", "errors", errs, "email", input.Email)
		response.ValidationError(w, errs)
		return
	}

	result, err := h.authService.Register(r.Context(), &input)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrEmailTaken):
			slog.Warn("[Auth.Register] email already taken", "email", input.Email)
			response.Conflict(w, "Email is already registered")
		default:
			slog.Error("[Auth.Register] failed", "email", input.Email, "error", err)
			response.BadRequest(w, err.Error())
		}
		return
	}

	slog.Info("[Auth.Register] success", "user_id", result.User.ID, "email", result.User.Email, "role", result.User.Role)
	response.CreatedWithMessage(w, map[string]any{
		"user": result.User,
		"tokens": map[string]any{
			"access_token":  result.Token.AccessToken,
			"refresh_token": result.Token.RefreshToken,
			"expires_at":    result.Token.ExpiresAt,
		},
	}, "Registration successful")
}

// ────────────────────────────────────────────────────────────────
//  POST /api/auth/login
// ────────────────────────────────────────────────────────────────

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var input service.LoginInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Auth.Login] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Auth.Login] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	result, err := h.authService.Login(r.Context(), &input)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrInvalidCredentials):
			slog.Warn("[Auth.Login] invalid credentials", "email", input.Email)
			response.Unauthorized(w, "Invalid email or password")
		case errors.Is(err, service.ErrAccountNotActive):
			slog.Warn("[Auth.Login] account not active", "email", input.Email, "error", err)
			response.Forbidden(w, err.Error())
		default:
			slog.Error("[Auth.Login] failed", "email", input.Email, "error", err)
			response.Unauthorized(w, err.Error())
		}
		return
	}

	slog.Info("[Auth.Login] success", "user_id", result.User.ID, "email", result.User.Email)
	response.OKWithMessage(w, map[string]any{
		"user": result.User,
		"tokens": map[string]any{
			"access_token":  result.Token.AccessToken,
			"refresh_token": result.Token.RefreshToken,
			"expires_at":    result.Token.ExpiresAt,
		},
	}, "Login successful")
}

// ────────────────────────────────────────────────────────────────
//  POST /api/auth/refresh
// ────────────────────────────────────────────────────────────────

func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	var input struct {
		RefreshToken string `json:"refresh_token" validate:"required"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Auth.Refresh] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body")
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Auth.Refresh] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	token, err := h.authService.RefreshToken(r.Context(), input.RefreshToken)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrInvalidToken):
			slog.Warn("[Auth.Refresh] invalid or expired token")
			response.Unauthorized(w, "Invalid or expired refresh token")
		case errors.Is(err, service.ErrAccountNotActive):
			slog.Warn("[Auth.Refresh] account no longer active")
			response.Forbidden(w, "Account is no longer active")
		case errors.Is(err, service.ErrUserNotFound):
			slog.Warn("[Auth.Refresh] user no longer exists")
			response.Unauthorized(w, "User no longer exists")
		default:
			slog.Error("[Auth.Refresh] failed", "error", err)
			response.Unauthorized(w, err.Error())
		}
		return
	}

	slog.Debug("[Auth.Refresh] token refreshed")
	response.OK(w, map[string]any{
		"tokens": map[string]any{
			"access_token":  token.AccessToken,
			"refresh_token": token.RefreshToken,
			"expires_at":    token.ExpiresAt,
		},
	})
}

// ────────────────────────────────────────────────────────────────
//  POST /api/auth/forgot-password
// ────────────────────────────────────────────────────────────────

func (h *AuthHandler) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Email string `json:"email" validate:"required,email"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Auth.ForgotPassword] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body")
		return
	}
	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Auth.ForgotPassword] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	slog.Info("[Auth.ForgotPassword] request received", "email", input.Email)
	// Always return success to prevent email enumeration.
	// In production this would trigger an async email job.
	// TODO: generate reset token, store with expiry, send email
	response.SuccessMessage(w, "If the email exists, a password reset link has been sent")
}

// ────────────────────────────────────────────────────────────────
//  GET /api/auth/me
// ────────────────────────────────────────────────────────────────

func (h *AuthHandler) Me(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	if userID == "" {
		slog.Warn("[Auth.Me] no user ID in context")
		response.Unauthorized(w, "Not authenticated")
		return
	}

	result, err := h.authService.GetProfile(r.Context(), userID)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrUserNotFound):
			slog.Warn("[Auth.Me] user not found", "user_id", userID)
			response.NotFound(w, "User not found")
		default:
			slog.Error("[Auth.Me] failed to fetch profile", "user_id", userID, "error", err)
			response.InternalError(w, "Failed to fetch profile")
		}
		return
	}

	slog.Debug("[Auth.Me] profile fetched", "user_id", userID)
	response.OK(w, result)
}
