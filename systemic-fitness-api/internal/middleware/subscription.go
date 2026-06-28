package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/fitcoach/api/pkg/response"
)

// SubscriptionInfo is the minimal subscription data the middleware needs.
type SubscriptionInfo struct {
	HasSubscription bool
	Status          string
	Tier            string
}

// SubscriptionInfoFunc returns the active subscription info for the given user,
// or HasSubscription=false if none. Defined as a function type so the middleware
// package does not need to import internal/service (avoids import cycles).
type SubscriptionInfoFunc func(ctx context.Context, userID string) (SubscriptionInfo, error)

// RequirePaidSubscription rejects requests from users without an active
// non-free subscription. Returns 403 with a stable error message so the
// Flutter client can branch to the upgrade screen.
func RequirePaidSubscription(fn SubscriptionInfoFunc) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			userID := GetUserID(r.Context())
			if userID == "" {
				response.Unauthorized(w, "Authentication required")
				return
			}

			info, err := fn(r.Context(), userID)
			if err != nil {
				response.InternalError(w, "Failed to verify subscription")
				return
			}
			if !info.HasSubscription ||
				!strings.EqualFold(info.Status, "active") ||
				info.Tier == "" ||
				strings.EqualFold(info.Tier, "free") ||
				strings.EqualFold(info.Tier, "sf_free") {
				response.Forbidden(w, "paid subscription required")
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}
