package middleware

import (
	"log/slog"
	"net/http"
	"time"
)

// wrappedWriter captures the status code from ResponseWriter.
type wrappedWriter struct {
	http.ResponseWriter
	statusCode int
}

func (w *wrappedWriter) WriteHeader(code int) {
	w.statusCode = code
	w.ResponseWriter.WriteHeader(code)
}

// Logger is an slog-based HTTP request logger.
func Logger(logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			wrapped := &wrappedWriter{ResponseWriter: w, statusCode: http.StatusOK}

			next.ServeHTTP(wrapped, r)

			duration := time.Since(start)
			attrs := []slog.Attr{
				slog.String("method", r.Method),
				slog.String("path", r.URL.Path),
				slog.Int("status", wrapped.statusCode),
				slog.Duration("duration", duration),
				slog.String("remote", r.RemoteAddr),
			}

			if wrapped.statusCode >= 500 {
				logger.LogAttrs(r.Context(), slog.LevelError, "request", attrs...)
			} else if wrapped.statusCode >= 400 {
				logger.LogAttrs(r.Context(), slog.LevelWarn, "request", attrs...)
			} else {
				logger.LogAttrs(r.Context(), slog.LevelInfo, "request", attrs...)
			}
		})
	}
}
