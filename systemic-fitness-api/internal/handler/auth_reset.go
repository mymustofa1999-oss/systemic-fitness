package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

// ────────────────────────────────────────────────────────────────
//  POST /api/auth/forgot-password
// ────────────────────────────────────────────────────────────────

func (h *AuthHandler) ForgotPassword(w http.ResponseWriter, r *http.Request) {
	var input service.ForgotPasswordInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Auth.ForgotPassword] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Auth.ForgotPassword] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	if err := h.authService.ForgotPassword(r.Context(), &input); err != nil {
		slog.Error("[Auth.ForgotPassword] failed", "error", err)
		response.InternalError(w, "Failed to process forgot password request")
		return
	}

	response.OKWithMessage(w, nil, "If your email is registered, you will receive a reset link")
}

// ────────────────────────────────────────────────────────────────
//  POST /api/auth/reset-password
// ────────────────────────────────────────────────────────────────

func (h *AuthHandler) ResetPassword(w http.ResponseWriter, r *http.Request) {
	var input service.ResetPasswordInput
	if err := response.DecodeJSON(r, &input); err != nil {
		slog.Warn("[Auth.ResetPassword] invalid request body", "error", err)
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	if errs := validateStruct(&input); errs != nil {
		slog.Warn("[Auth.ResetPassword] validation failed", "errors", errs)
		response.ValidationError(w, errs)
		return
	}

	if err := h.authService.ResetPassword(r.Context(), &input); err != nil {
		if errors.Is(err, service.ErrInvalidToken) {
			response.BadRequest(w, "Invalid or expired reset token")
			return
		}
		slog.Error("[Auth.ResetPassword] failed", "error", err)
		response.InternalError(w, "Failed to reset password")
		return
	}

	response.OKWithMessage(w, nil, "Password has been reset successfully")
}
