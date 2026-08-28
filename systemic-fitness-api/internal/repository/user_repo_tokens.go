package repository

import (
	"context"
	"time"

	"github.com/fitcoach/api/internal/model"
)

// SetResetToken sets the reset token and expiry for a user.
func (r *UserRepository) SetResetToken(ctx context.Context, userID string, token string, expiresAt time.Time) error {
	query := `UPDATE users SET reset_token = $2, reset_expires_at = $3, updated_at = NOW() WHERE id = $1 AND deleted_at IS NULL`
	tag, err := r.db.Exec(ctx, query, userID, token, expiresAt)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// GetByResetToken finds a user by their reset token if it hasn't expired.
func (r *UserRepository) GetByResetToken(ctx context.Context, token string) (*model.User, error) {
	query := `SELECT ` + userColumns + ` FROM users WHERE reset_token = $1 AND reset_expires_at > NOW() AND deleted_at IS NULL`
	return scanUser(r.db.QueryRow(ctx, query, token))
}

// UpdatePasswordAndClearToken updates the password hash and clears the reset token. Also sets status to active if pending.
func (r *UserRepository) UpdatePasswordAndClearToken(ctx context.Context, userID string, passwordHash string) error {
	query := `
		UPDATE users 
		SET password_hash = $2, reset_token = NULL, reset_expires_at = NULL, 
		    status = CASE WHEN status = 'pending' THEN 'active' ELSE status END,
		    updated_at = NOW()
		WHERE id = $1 AND deleted_at IS NULL`
	tag, err := r.db.Exec(ctx, query, userID, passwordHash)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}
