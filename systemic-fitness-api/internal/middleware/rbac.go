package middleware

import (
	"context"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/pkg/response"
)

// RequireRole returns middleware that restricts access to the given roles.
// Owner always bypasses role checks.
//
// Usage:
//
//	r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer))
func RequireRole(allowedRoles ...model.Role) func(http.Handler) http.Handler {
	roleSet := make(map[model.Role]struct{}, len(allowedRoles))
	for _, r := range allowedRoles {
		roleSet[r] = struct{}{}
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			userRole := GetRole(r.Context())
			if userRole == "" {
				response.Unauthorized(w, "Authentication required")
				return
			}

			// Owner bypasses all role checks
			if userRole == model.RoleOwner {
				next.ServeHTTP(w, r)
				return
			}

			if _, ok := roleSet[userRole]; !ok {
				response.Forbidden(w, "Insufficient permissions for this resource")
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

// RequireMinRole restricts access to users at or above a minimum role hierarchy level.
// Role hierarchy: owner(100) > admin(80) > finance(60) > trainer(40) > client(20).
func RequireMinRole(minRole model.Role) func(http.Handler) http.Handler {
	minLevel := minRole.Hierarchy()

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			userRole := GetRole(r.Context())
			if userRole == "" {
				response.Unauthorized(w, "Authentication required")
				return
			}

			if userRole.Hierarchy() < minLevel {
				response.Forbidden(w, "Insufficient permissions for this resource")
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}

// RequireSelfOrRole allows access if the user is accessing their own resource
// (URL param {id} matches their user ID) OR if they have one of the allowed roles.
func RequireSelfOrRole(allowedRoles ...model.Role) func(http.Handler) http.Handler {
	roleSet := make(map[model.Role]struct{}, len(allowedRoles))
	for _, r := range allowedRoles {
		roleSet[r] = struct{}{}
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			userID := GetUserID(r.Context())
			userRole := GetRole(r.Context())

			if userRole == "" {
				response.Unauthorized(w, "Authentication required")
				return
			}

			// Owner bypasses all
			if userRole == model.RoleOwner {
				next.ServeHTTP(w, r)
				return
			}

			// Self-access check: {id} in URL matches authenticated user
			if targetID := chi.URLParam(r, "id"); targetID != "" && targetID == userID {
				next.ServeHTTP(w, r)
				return
			}

			// Role-based check
			if _, ok := roleSet[userRole]; !ok {
				response.Forbidden(w, "Insufficient permissions for this resource")
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}


// CustomerAuthorizer interface breaks dependency cycles.
type CustomerAuthorizer interface {
	AuthorizeCustomerAccess(ctx context.Context, callerID string, callerRole model.Role, customerID string) error
}

// RequireCustomerAccess ensures the caller has rights to view/edit the target customer.
// It uses the provided paramName (e.g. "customerId", "userId") to extract the target ID from the URL.
func RequireCustomerAccess(authz CustomerAuthorizer, paramName string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			targetID := chi.URLParam(r, paramName)
			if targetID == "" {
				response.BadRequest(w, "missing "+paramName+" in URL")
				return
			}

			callerID := GetUserID(r.Context())
			callerRole := GetRole(r.Context())

			err := authz.AuthorizeCustomerAccess(r.Context(), callerID, callerRole, targetID)
			if err != nil {
				if err.Error() == "unauthenticated" {
					response.Unauthorized(w, "Authentication required")
				} else {
					response.Forbidden(w, "Insufficient permissions for this resource")
				}
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
