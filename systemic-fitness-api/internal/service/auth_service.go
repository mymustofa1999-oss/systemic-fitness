package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"strings"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/pkg/utils"
)

// ════════════════════════════════════════════════════════════════════
//  Errors
// ════════════════════════════════════════════════════════════════════

var (
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrEmailTaken         = errors.New("email is already registered")
	ErrAccountNotActive   = errors.New("account is not active")
	ErrUserNotFound       = errors.New("user not found")
	ErrInvalidToken       = errors.New("invalid or expired token")
)

// ════════════════════════════════════════════════════════════════════
//  Service
// ════════════════════════════════════════════════════════════════════

type AuthService struct {
	userRepo   *repository.UserRepository
	jwtManager *utils.JWTManager
	bcryptCost int
	logger     *slog.Logger
	mailer     MailerService
}

func NewAuthService(
	userRepo *repository.UserRepository,
	jwtManager *utils.JWTManager,
	bcryptCost int,
	logger *slog.Logger,
	mailer MailerService,
) *AuthService {
	return &AuthService{
		userRepo:   userRepo,
		jwtManager: jwtManager,
		bcryptCost: bcryptCost,
		logger:     logger,
		mailer:     mailer,
	}
}

// ════════════════════════════════════════════════════════════════════
//  Register
// ════════════════════════════════════════════════════════════════════

type RegisterInput struct {
	Email    string     `json:"email"     validate:"required,email,max=255"`
	Password string     `json:"password"  validate:"required,min=8,max=128"`
	FullName string     `json:"full_name" validate:"required,min=1,max=100"`
	Phone    *string    `json:"phone,omitempty" validate:"omitempty,min=6,max=20"`
	Role     model.Role `json:"role,omitempty" validate:"omitempty,oneof=owner admin finance consultant trainer client"`
}

type AuthResult struct {
	User  model.User       `json:"user"`
	Token model.TokenPair  `json:"token"`
}

func (s *AuthService) Register(ctx context.Context, input *RegisterInput) (*AuthResult, error) {
	// 1. Normalize email
	input.Email = strings.ToLower(strings.TrimSpace(input.Email))

	// Default role to client if not provided (mobile self-registration)
	if input.Role == "" {
		input.Role = model.RoleClient
	}

	// 2. Check uniqueness
	exists, err := s.userRepo.EmailExists(ctx, input.Email)
	if err != nil {
		s.logger.Error("register: check email", "error", err)
		return nil, fmt.Errorf("checking email availability: %w", err)
	}
	if exists {
		return nil, ErrEmailTaken
	}

	// 3. Hash password
	hash, err := utils.HashPassword(input.Password, s.bcryptCost)
	if err != nil {
		s.logger.Error("register: hash password", "error", err)
		return nil, fmt.Errorf("hashing password: %w", err)
	}

	// 4. Create user
	user := &model.User{
		Email:        input.Email,
		PasswordHash: hash,
		FullName:     strings.TrimSpace(input.FullName),
		Phone:        input.Phone,
		Role:         input.Role,
		Status:       model.StatusActive,
		Timezone:     "Asia/Jakarta",
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		if errors.Is(err, repository.ErrDuplicateEmail) {
			return nil, ErrEmailTaken
		}
		s.logger.Error("register: create user", "error", err)
		return nil, fmt.Errorf("creating user: %w", err)
	}

	// 5. Create empty profile row
	if err := s.userRepo.UpsertProfile(ctx, &model.UserProfile{UserID: user.ID}); err != nil {
		s.logger.Warn("register: create profile", "user_id", user.ID, "error", err)
		// non-fatal — user can fill in profile later
	}

	// 6. Generate JWT pair
	token, err := s.jwtManager.GenerateTokenPair(user.ID, user.Email, user.Role)
	if err != nil {
		s.logger.Error("register: generate token", "error", err)
		return nil, fmt.Errorf("generating tokens: %w", err)
	}

	s.logger.Info("user registered",
		"user_id", user.ID,
		"email", user.Email,
		"role", user.Role,
	)

	return &AuthResult{User: *user, Token: *token}, nil
}

// ════════════════════════════════════════════════════════════════════
//  Login
// ════════════════════════════════════════════════════════════════════

type LoginInput struct {
	Email    string `json:"email"    validate:"required,email"`
	Password string `json:"password" validate:"required,min=1"`
}

func (s *AuthService) Login(ctx context.Context, input *LoginInput) (*AuthResult, error) {
	input.Email = strings.ToLower(strings.TrimSpace(input.Email))

	// 1. Fetch user
	user, err := s.userRepo.GetByEmail(ctx, input.Email)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrInvalidCredentials
		}
		s.logger.Error("login: get user", "error", err)
		return nil, fmt.Errorf("fetching user: %w", err)
	}

	// 2. Verify password
	if !utils.CheckPassword(input.Password, user.PasswordHash) {
		return nil, ErrInvalidCredentials
	}

	// 3. Check status
	switch user.Status {
	case model.StatusActive:
		// ok
	case model.StatusPending:
		return nil, fmt.Errorf("account is pending activation")
	case model.StatusSuspended:
		return nil, fmt.Errorf("account has been suspended, contact support")
	case model.StatusInactive:
		return nil, fmt.Errorf("account is deactivated")
	default:
		return nil, ErrAccountNotActive
	}

	// 4. Generate tokens
	token, err := s.jwtManager.GenerateTokenPair(user.ID, user.Email, user.Role)
	if err != nil {
		s.logger.Error("login: generate token", "error", err)
		return nil, fmt.Errorf("generating tokens: %w", err)
	}

	s.logger.Info("user logged in", "user_id", user.ID, "email", user.Email)

	return &AuthResult{User: *user, Token: *token}, nil
}

// ════════════════════════════════════════════════════════════════════
//  Refresh Token
// ════════════════════════════════════════════════════════════════════

func (s *AuthService) RefreshToken(ctx context.Context, refreshToken string) (*model.TokenPair, error) {
	// 1. Validate the refresh token
	claims, err := s.jwtManager.ValidateToken(refreshToken)
	if err != nil {
		return nil, ErrInvalidToken
	}

	// 2. Ensure user still exists and is active
	user, err := s.userRepo.GetByID(ctx, claims.UserID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, fmt.Errorf("fetching user for refresh: %w", err)
	}
	if user.Status != model.StatusActive {
		return nil, ErrAccountNotActive
	}

	// 3. Issue fresh pair (re-read role in case it changed)
	token, err := s.jwtManager.GenerateTokenPair(user.ID, user.Email, user.Role)
	if err != nil {
		return nil, fmt.Errorf("generating tokens: %w", err)
	}

	s.logger.Debug("token refreshed", "user_id", user.ID)
	return token, nil
}

// ════════════════════════════════════════════════════════════════════
//  Me (profile)
// ════════════════════════════════════════════════════════════════════

type ProfileResult struct {
	User    model.User        `json:"user"`
	Profile *model.UserProfile `json:"profile"`
	Stats   *model.UserStats   `json:"stats"`
}

func (s *AuthService) GetProfile(ctx context.Context, userID string) (*ProfileResult, error) {
	// 1. Fetch user
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, fmt.Errorf("fetching user: %w", err)
	}

	// 2. Fetch profile
	profile, err := s.userRepo.GetProfile(ctx, userID)
	if err != nil {
		s.logger.Warn("me: get profile", "user_id", userID, "error", err)
	}

	// 3. Fetch stats
	stats, err := s.userRepo.GetStats(ctx, userID)
	if err != nil {
		s.logger.Warn("me: get stats", "user_id", userID, "error", err)
	}

	return &ProfileResult{
		User:    *user,
		Profile: profile,
		Stats:   stats,
	}, nil
}
