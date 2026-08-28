package service

import (
	"context"
	"fmt"
	"time"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/pkg/utils"
)

type ForgotPasswordInput struct {
	Email string `json:"email" validate:"required,email"`
}

type ResetPasswordInput struct {
	Token       string `json:"token" validate:"required"`
	NewPassword string `json:"new_password" validate:"required,min=8"`
}

// ForgotPassword generates a reset token and sends it via email if configured.
func (s *AuthService) ForgotPassword(ctx context.Context, input *ForgotPasswordInput) error {
	user, err := s.userRepo.GetByEmail(ctx, input.Email)
	if err != nil {
		// Don't leak whether the email exists or not
		s.logger.Warn("forgot_password: user not found", "email", input.Email)
		return nil
	}

	// Generate reset token
	token, err := model.GenerateToken(32)
	if err != nil {
		s.logger.Error("forgot_password: generate token", "error", err)
		return fmt.Errorf("generating token: %w", err)
	}

	expiresAt := time.Now().Add(1 * time.Hour)
	if err := s.userRepo.SetResetToken(ctx, user.ID, token, expiresAt); err != nil {
		s.logger.Error("forgot_password: set reset token", "error", err)
		return fmt.Errorf("saving token: %w", err)
	}

	// In a real app, send email with a link: https://frontend.com/reset-password?token=...
	subject := "Reset Password - Systemic Fitness"
	body := fmt.Sprintf("Halo %s,\n\nBerikut adalah token/link reset password Anda:\n\n%s\n\nToken berlaku selama 1 jam.", user.FullName, token)
	_ = s.mailer.SendEmail(ctx, user.Email, subject, body)

	s.logger.Info("forgot_password: token generated", "email", user.Email)
	return nil
}

// ResetPassword consumes the token and updates the user's password.
func (s *AuthService) ResetPassword(ctx context.Context, input *ResetPasswordInput) error {
	user, err := s.userRepo.GetByResetToken(ctx, input.Token)
	if err != nil {
		s.logger.Warn("reset_password: invalid or expired token")
		return ErrInvalidToken
	}

	hash, err := utils.HashPassword(input.NewPassword, s.bcryptCost)
	if err != nil {
		s.logger.Error("reset_password: hash password", "error", err)
		return fmt.Errorf("hashing password: %w", err)
	}

	if err := s.userRepo.UpdatePasswordAndClearToken(ctx, user.ID, hash); err != nil {
		s.logger.Error("reset_password: update password", "error", err)
		return fmt.Errorf("updating password: %w", err)
	}

	s.logger.Info("reset_password: success", "user_id", user.ID)
	return nil
}
