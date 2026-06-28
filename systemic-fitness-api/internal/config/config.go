package config

import (
	"log/slog"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	Port string
	Env  string // development, staging, production

	DatabaseURL string
	DBMaxConns  int
	DBMinConns  int

	RedisURL string

	JWTSecret       string
	JWTAccessExpiry time.Duration
	JWTRefreshExpiry time.Duration

	CORSAllowedOrigins []string

	BcryptCost int

	MaxUploadSizeMB int
	UploadDir       string
	BaseURL         string

	FCMCredentialsFile string

	// ── Midtrans (payment gateway) ─────────────────────────────
	// All optional. When MidtransServerKey is empty the gateway flow
	// is disabled and only manual transfer works.
	MidtransServerKey string
	MidtransClientKey string
	MidtransEnv       string // sandbox | production
	MidtransNotifyURL string

}

func Load() *Config {
	if err := godotenv.Load(); err != nil {
		slog.Warn("no .env file found, using system environment")
	}

	return &Config{
		Port: getEnv("PORT", "8080"),
		Env:  getEnv("ENV", "development"),

		DatabaseURL: getEnv("DATABASE_URL", "postgres://fitcoach:fitcoach@localhost:5432/fitcoach?sslmode=disable"),
		DBMaxConns:  getEnvInt("DB_MAX_CONNS", 20),
		DBMinConns:  getEnvInt("DB_MIN_CONNS", 5),

		RedisURL: getEnv("REDIS_URL", "redis://localhost:6379"),

		JWTSecret:        getEnv("JWT_SECRET", "change-me-in-production"),
		JWTAccessExpiry:  getEnvDuration("JWT_ACCESS_EXPIRY", 30*24*time.Hour),
		JWTRefreshExpiry: getEnvDuration("JWT_REFRESH_EXPIRY", 30*24*time.Hour),

		CORSAllowedOrigins: getEnvSlice("CORS_ALLOWED_ORIGINS", []string{"http://localhost:3000"}),

		BcryptCost: getEnvInt("BCRYPT_COST", 12),

		MaxUploadSizeMB: getEnvInt("MAX_UPLOAD_SIZE_MB", 5),
		UploadDir:       getEnv("UPLOAD_DIR", "./uploads"),
		BaseURL:         getEnv("BASE_URL", "http://localhost:8080"),

		FCMCredentialsFile: getEnv("FCM_CREDENTIALS_FILE", ""),

		MidtransServerKey: getEnv("MIDTRANS_SERVER_KEY", ""),
		MidtransClientKey: getEnv("MIDTRANS_CLIENT_KEY", ""),
		MidtransEnv:       getEnv("MIDTRANS_ENV", "sandbox"),
		MidtransNotifyURL: getEnv("MIDTRANS_NOTIFY_URL", ""),
	}
}

func (c *Config) IsDevelopment() bool {
	return c.Env == "development"
}

func (c *Config) IsProduction() bool {
	return c.Env == "production"
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return fallback
}

func getEnvDuration(key string, fallback time.Duration) time.Duration {
	if v := os.Getenv(key); v != "" {
		if d, err := time.ParseDuration(v); err == nil {
			return d
		}
	}
	return fallback
}

func getEnvSlice(key string, fallback []string) []string {
	if v := os.Getenv(key); v != "" {
		parts := strings.Split(v, ",")
		result := make([]string, 0, len(parts))
		for _, p := range parts {
			if trimmed := strings.TrimSpace(p); trimmed != "" {
				result = append(result, trimmed)
			}
		}
		return result
	}
	return fallback
}
