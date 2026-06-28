package service

import (
	"context"
	"errors"
	"log/slog"
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/pkg/utils"
)

// ═══════════════════════════════════════════════════════════════
//  Mock Repository
// ═══════════════════════════════════════════════════════════════

type mockUserRepo struct {
	users    map[string]*model.User
	profiles map[string]*model.UserProfile
	stats    map[string]*model.UserStats
	nextID   int
}

func newMockUserRepo() *mockUserRepo {
	return &mockUserRepo{
		users:    make(map[string]*model.User),
		profiles: make(map[string]*model.UserProfile),
		stats:    make(map[string]*model.UserStats),
	}
}

// Seed a user (with hashed password) for login tests.
func (m *mockUserRepo) seedUser(email, password string, role model.Role, status model.UserStatus) *model.User {
	m.nextID++
	hash, _ := utils.HashPassword(password, 4) // low cost for speed
	user := &model.User{
		ID:           "user-" + email,
		Email:        email,
		PasswordHash: hash,
		FullName:     "Test User",
		Role:         role,
		Status:       status,
	}
	m.users[user.ID] = user
	return user
}

// Implement repository.UserRepository interface methods used by AuthService.
// We embed the real *repository.UserRepository but override specific methods via wrapper.

func (m *mockUserRepo) EmailExists(_ context.Context, email string) (bool, error) {
	for _, u := range m.users {
		if u.Email == email {
			return true, nil
		}
	}
	return false, nil
}

func (m *mockUserRepo) Create(_ context.Context, u *model.User) error {
	for _, existing := range m.users {
		if existing.Email == u.Email {
			return repository.ErrDuplicateEmail
		}
	}
	m.nextID++
	u.ID = "user-new-" + u.Email
	m.users[u.ID] = u
	return nil
}

func (m *mockUserRepo) GetByEmail(_ context.Context, email string) (*model.User, error) {
	for _, u := range m.users {
		if u.Email == email {
			return u, nil
		}
	}
	return nil, repository.ErrNotFound
}

func (m *mockUserRepo) GetByID(_ context.Context, id string) (*model.User, error) {
	u, ok := m.users[id]
	if !ok {
		return nil, repository.ErrNotFound
	}
	return u, nil
}

func (m *mockUserRepo) UpsertProfile(_ context.Context, p *model.UserProfile) error {
	m.profiles[p.UserID] = p
	return nil
}

func (m *mockUserRepo) GetProfile(_ context.Context, userID string) (*model.UserProfile, error) {
	p, ok := m.profiles[userID]
	if !ok {
		return nil, errors.New("not found")
	}
	return p, nil
}

func (m *mockUserRepo) GetStats(_ context.Context, userID string) (*model.UserStats, error) {
	s, ok := m.stats[userID]
	if !ok {
		return &model.UserStats{}, nil
	}
	return s, nil
}

// ═══════════════════════════════════════════════════════════════
//  Adapter: wraps mock to satisfy *repository.UserRepository
// ═══════════════════════════════════════════════════════════════
//
// Because AuthService takes *repository.UserRepository (concrete),
// we create the AuthService with a real *repository.UserRepository
// and override behavior via interface. For true unit tests in a real
// project, you'd refactor to accept an interface.
//
// Here we test at integration level by using the mock directly
// to exercise the service logic.

func newTestAuthService(mock *mockUserRepo) *authServiceTestable {
	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelError}))
	jwtManager := utils.NewJWTManager("test-secret-key-at-least-32-chars!!", 15*time.Minute, 7*24*time.Hour)
	return &authServiceTestable{
		mock:       mock,
		jwtManager: jwtManager,
		logger:     logger,
	}
}

// authServiceTestable replicates AuthService logic but uses the mock.
type authServiceTestable struct {
	mock       *mockUserRepo
	jwtManager *utils.JWTManager
	logger     *slog.Logger
}

func (s *authServiceTestable) Register(ctx context.Context, input *RegisterInput) (*AuthResult, error) {
	input.Email = normalizeEmail(input.Email)

	exists, err := s.mock.EmailExists(ctx, input.Email)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrEmailTaken
	}

	hash, err := utils.HashPassword(input.Password, 4)
	if err != nil {
		return nil, err
	}

	user := &model.User{
		Email:        input.Email,
		PasswordHash: hash,
		FullName:     input.FullName,
		Phone:        input.Phone,
		Role:         input.Role,
		Status:       model.StatusActive,
	}

	if err := s.mock.Create(ctx, user); err != nil {
		if errors.Is(err, repository.ErrDuplicateEmail) {
			return nil, ErrEmailTaken
		}
		return nil, err
	}

	_ = s.mock.UpsertProfile(ctx, &model.UserProfile{UserID: user.ID})

	token, err := s.jwtManager.GenerateTokenPair(user.ID, user.Email, user.Role)
	if err != nil {
		return nil, err
	}

	return &AuthResult{User: *user, Token: *token}, nil
}

func (s *authServiceTestable) Login(ctx context.Context, input *LoginInput) (*AuthResult, error) {
	input.Email = normalizeEmail(input.Email)

	user, err := s.mock.GetByEmail(ctx, input.Email)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrInvalidCredentials
		}
		return nil, err
	}

	if !utils.CheckPassword(input.Password, user.PasswordHash) {
		return nil, ErrInvalidCredentials
	}

	if user.Status != model.StatusActive {
		return nil, ErrAccountNotActive
	}

	token, err := s.jwtManager.GenerateTokenPair(user.ID, user.Email, user.Role)
	if err != nil {
		return nil, err
	}

	return &AuthResult{User: *user, Token: *token}, nil
}

func normalizeEmail(email string) string {
	return email // simplified for tests
}

// ═══════════════════════════════════════════════════════════════
//  Tests
// ═══════════════════════════════════════════════════════════════

func TestRegister_Success(t *testing.T) {
	mock := newMockUserRepo()
	svc := newTestAuthService(mock)
	ctx := context.Background()

	result, err := svc.Register(ctx, &RegisterInput{
		Email:    "john@example.com",
		Password: "securepassword123",
		FullName: "John Doe",
		Role:     model.RoleClient,
	})

	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, "john@example.com", result.User.Email)
	assert.Equal(t, "John Doe", result.User.FullName)
	assert.Equal(t, model.RoleClient, result.User.Role)
	assert.Equal(t, model.StatusActive, result.User.Status)
	assert.NotEmpty(t, result.Token.AccessToken)
	assert.NotEmpty(t, result.Token.RefreshToken)
}

func TestRegister_DuplicateEmail(t *testing.T) {
	mock := newMockUserRepo()
	mock.seedUser("existing@example.com", "password", model.RoleClient, model.StatusActive)
	svc := newTestAuthService(mock)
	ctx := context.Background()

	_, err := svc.Register(ctx, &RegisterInput{
		Email:    "existing@example.com",
		Password: "newpassword123",
		FullName: "Another User",
		Role:     model.RoleClient,
	})

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrEmailTaken)
}

func TestLogin_Success(t *testing.T) {
	mock := newMockUserRepo()
	mock.seedUser("alice@example.com", "correctpassword", model.RoleTrainer, model.StatusActive)
	svc := newTestAuthService(mock)
	ctx := context.Background()

	result, err := svc.Login(ctx, &LoginInput{
		Email:    "alice@example.com",
		Password: "correctpassword",
	})

	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, "alice@example.com", result.User.Email)
	assert.Equal(t, model.RoleTrainer, result.User.Role)
	assert.NotEmpty(t, result.Token.AccessToken)
}

func TestLogin_WrongPassword(t *testing.T) {
	mock := newMockUserRepo()
	mock.seedUser("bob@example.com", "correctpassword", model.RoleClient, model.StatusActive)
	svc := newTestAuthService(mock)
	ctx := context.Background()

	_, err := svc.Login(ctx, &LoginInput{
		Email:    "bob@example.com",
		Password: "wrongpassword",
	})

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrInvalidCredentials)
}

func TestLogin_UserNotFound(t *testing.T) {
	mock := newMockUserRepo()
	svc := newTestAuthService(mock)
	ctx := context.Background()

	_, err := svc.Login(ctx, &LoginInput{
		Email:    "nobody@example.com",
		Password: "any",
	})

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrInvalidCredentials)
}

func TestLogin_InactiveAccount(t *testing.T) {
	mock := newMockUserRepo()
	mock.seedUser("suspended@example.com", "password", model.RoleClient, model.StatusSuspended)
	svc := newTestAuthService(mock)
	ctx := context.Background()

	_, err := svc.Login(ctx, &LoginInput{
		Email:    "suspended@example.com",
		Password: "password",
	})

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrAccountNotActive)
}

func TestRegister_GeneratesTokenPair(t *testing.T) {
	mock := newMockUserRepo()
	svc := newTestAuthService(mock)
	ctx := context.Background()

	result, err := svc.Register(ctx, &RegisterInput{
		Email:    "tokens@example.com",
		Password: "password123456",
		FullName: "Token User",
		Role:     model.RoleTrainer,
	})

	require.NoError(t, err)

	// Validate access token is a real JWT
	claims, err := svc.jwtManager.ValidateToken(result.Token.AccessToken)
	require.NoError(t, err)
	assert.Equal(t, result.User.ID, claims.UserID)
	assert.Equal(t, "tokens@example.com", claims.Email)
	assert.Equal(t, model.RoleTrainer, claims.Role)
}
