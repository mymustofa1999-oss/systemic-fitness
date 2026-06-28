package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/pkg/response"
	"github.com/fitcoach/api/pkg/utils"
)

// Context keys — unexported type prevents collisions.
type contextKey string

const (
	ctxUserID contextKey = "user_id"
	ctxEmail  contextKey = "email"
	ctxRole   contextKey = "role"
)

// Auth is JWT authentication middleware.
// It extracts the Bearer token, validates it, and sets user info in context.
func Auth(jwtManager *utils.JWTManager) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				response.Unauthorized(w, "Missing authorization header")
				return
			}

			parts := strings.SplitN(authHeader, " ", 2)
			if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
				response.Unauthorized(w, "Invalid authorization header format")
				return
			}

			claims, err := jwtManager.ValidateToken(parts[1])
			if err != nil {
				response.Unauthorized(w, "Invalid or expired token")
				return
			}

			// Set user claims in request context
			ctx := r.Context()
			ctx = context.WithValue(ctx, ctxUserID, claims.UserID)
			ctx = context.WithValue(ctx, ctxEmail, claims.Email)
			ctx = context.WithValue(ctx, ctxRole, claims.Role)

			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// ─── Context Helpers ────────────────────────────────────────────
// These are used by handlers to extract user info from the request context.

func GetUserID(ctx context.Context) string {
	if v, ok := ctx.Value(ctxUserID).(string); ok {
		return v
	}
	return ""
}

func GetEmail(ctx context.Context) string {
	if v, ok := ctx.Value(ctxEmail).(string); ok {
		return v
	}
	return ""
}

func GetRole(ctx context.Context) model.Role {
	if v, ok := ctx.Value(ctxRole).(model.Role); ok {
		return v
	}
	return ""
}
