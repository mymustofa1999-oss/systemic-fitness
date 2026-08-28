package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/fitcoach/api/pkg/response"
)

type visitor struct {
	requests int
	lastSeen time.Time
}

type IPRateLimiter struct {
	visitors map[string]*visitor
	mu       sync.Mutex
	rate     int
	window   time.Duration
}

func NewIPRateLimiter(rate int, window time.Duration) *IPRateLimiter {
	limiter := &IPRateLimiter{
		visitors: make(map[string]*visitor),
		rate:     rate,
		window:   window,
	}
	go limiter.cleanup()
	return limiter
}

func (l *IPRateLimiter) cleanup() {
	for {
		time.Sleep(l.window)
		l.mu.Lock()
		for ip, v := range l.visitors {
			if time.Since(v.lastSeen) > l.window {
				delete(l.visitors, ip)
			}
		}
		l.mu.Unlock()
	}
}

// Limit returns a middleware that applies the configured rate limit per IP.
func (l *IPRateLimiter) Limit(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ip := r.RemoteAddr

		l.mu.Lock()
		v, exists := l.visitors[ip]
		if !exists {
			l.visitors[ip] = &visitor{requests: 1, lastSeen: time.Now()}
			l.mu.Unlock()
			next.ServeHTTP(w, r)
			return
		}
		
		if time.Since(v.lastSeen) > l.window {
			v.requests = 1
			v.lastSeen = time.Now()
			l.mu.Unlock()
			next.ServeHTTP(w, r)
			return
		}

		v.requests++
		v.lastSeen = time.Now()
		
		if v.requests > l.rate {
			l.mu.Unlock()
			response.TooManyRequests(w, "Too many requests. Please try again later.")
			return
		}
		
		l.mu.Unlock()
		next.ServeHTTP(w, r)
	})
}
