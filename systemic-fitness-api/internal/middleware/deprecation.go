package middleware

import (
	"log/slog"
	"net/http"
	"time"
)

// Deprecated returns middleware that marks responses dengan RFC 8594
// Deprecation + Sunset + Link successor-version headers, dan log warn
// untuk visibility ke deprecated route.
//
// Reference:
//   - https://datatracker.ietf.org/doc/html/rfc8594  (Sunset)
//   - https://datatracker.ietf.org/doc/draft-ietf-httpapi-deprecation-header/
//
// Usage:
//
//	r.Route("/assessments", func(r chi.Router) {
//	    r.Use(middleware.Deprecated(
//	        "/api/v2/assessments",
//	        time.Date(2026, 10, 27, 0, 0, 0, 0, time.UTC),
//	    ))
//	    ...
//	})
func Deprecated(successorPath string, sunsetAt time.Time) func(http.Handler) http.Handler {
	sunsetStr := sunsetAt.UTC().Format(http.TimeFormat) // RFC 1123
	linkVal := "<" + successorPath + ">; rel=\"successor-version\""

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Headers harus di-set sebelum body ditulis. chi.Use mounts ini
			// di awal chain, jadi aman.
			w.Header().Set("Deprecation", "true")
			w.Header().Set("Sunset", sunsetStr)
			w.Header().Add("Link", linkVal)

			// slog warn supaya kita lihat deprecation traffic real-time.
			// User-Agent + path + caller user_id (kalau auth sudah lewat).
			userID := GetUserID(r.Context())
			slog.Warn("[deprecated route]",
				"path", r.URL.Path,
				"method", r.Method,
				"successor", successorPath,
				"sunset", sunsetStr,
				"user_id", userID,
				"user_agent", r.UserAgent(),
			)

			next.ServeHTTP(w, r)
		})
	}
}
