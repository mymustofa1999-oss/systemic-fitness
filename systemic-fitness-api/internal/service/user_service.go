package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

// ════════════════════════════════════════════════════════════════════
//  Service
// ════════════════════════════════════════════════════════════════════

type UserService struct {
	userRepo *repository.UserRepository
	logger   *slog.Logger
}

func NewUserService(userRepo *repository.UserRepository, logger *slog.Logger) *UserService {
	return &UserService{userRepo: userRepo, logger: logger}
}

// ════════════════════════════════════════════════════════════════════
//  List
// ════════════════════════════════════════════════════════════════════

type ListUsersInput struct {
	Pagination model.PaginationParams
	Role       *model.Role
	Status     *model.UserStatus
	// Populated by handler from JWT context — scopes list to trainer's clients
	CallerRole model.Role
	CallerID   string
}

func (s *UserService) List(ctx context.Context, input *ListUsersInput) ([]model.User, model.PaginationMeta, error) {
	filter := repository.UserListFilter{
		Role:   input.Role,
		Status: input.Status,
		Search: input.Pagination.Search,
	}

	// Trainer sees only their own assigned clients
	if input.CallerRole == model.RoleTrainer {
		filter.TrainerID = &input.CallerID
		// Force client role filter — trainers shouldn't browse other trainers/admins
		clientRole := model.RoleClient
		filter.Role = &clientRole
	}

	users, total, err := s.userRepo.List(ctx, input.Pagination, filter)
	if err != nil {
		s.logger.Error("list users", "caller_id", input.CallerID, "error", err)
		return nil, model.PaginationMeta{}, fmt.Errorf("listing users: %w", err)
	}

	meta := model.NewPaginationMeta(input.Pagination.Page, input.Pagination.Limit, total)
	return users, meta, nil
}

// ════════════════════════════════════════════════════════════════════
//  Get Detail
// ════════════════════════════════════════════════════════════════════

type UserDetailResult struct {
	User    model.User         `json:"user"`
	Profile *model.UserProfile `json:"profile"`
	Stats   *model.UserStats   `json:"stats"`
	Subscription *model.UserSubscription `json:"subscription,omitempty"`
}

func (s *UserService) GetByID(ctx context.Context, id string, callerRole model.Role, callerID string) (*UserDetailResult, error) {
	// Trainer visibility check: can only see assigned clients or self
	if callerRole == model.RoleTrainer && callerID != id {
		isTrainer, err := s.userRepo.IsTrainerOfClient(ctx, callerID, id)
		if err != nil {
			s.logger.Error("get user: check trainer assignment", "caller_id", callerID, "target_id", id, "error", err)
			return nil, fmt.Errorf("checking trainer assignment: %w", err)
		}
		if !isTrainer {
			s.logger.Warn("get user: access denied", "caller_id", callerID, "target_id", id)
			return nil, fmt.Errorf("you do not have access to this user")
		}
	}

	user, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrUserNotFound
		}
		s.logger.Error("get user: fetch", "user_id", id, "error", err)
		return nil, fmt.Errorf("fetching user: %w", err)
	}

	profile, err := s.userRepo.GetProfile(ctx, id)
	if err != nil {
		s.logger.Warn("get user: fetch profile", "user_id", id, "error", err)
	}
	stats, err := s.userRepo.GetStats(ctx, id)
	if err != nil {
		s.logger.Warn("get user: fetch stats", "user_id", id, "error", err)
	}

	subscription, err := s.userRepo.GetActiveSubscription(ctx, id)
	if err != nil {
		s.logger.Warn("get user: fetch active subscription", "user_id", id, "error", err)
	}

	return &UserDetailResult{
		User:         *user,
		Profile:      profile,
		Stats:        stats,
		Subscription: subscription,
	}, nil
}

// ════════════════════════════════════════════════════════════════════
//  Update
// ════════════════════════════════════════════════════════════════════

type UpdateUserInput struct {
	FullName  *string        `json:"full_name,omitempty"  validate:"omitempty,min=1,max=100"`
	Phone     *string        `json:"phone,omitempty"      validate:"omitempty,max=20"`
	AvatarURL *string        `json:"avatar_url,omitempty" validate:"omitempty,url,max=2048"`
	Role      *model.Role    `json:"role,omitempty"       validate:"omitempty,oneof=owner admin finance consultant trainer client"`
	Status    *model.UserStatus `json:"status,omitempty"  validate:"omitempty,oneof=active inactive suspended pending"`
	Timezone  *string        `json:"timezone,omitempty"   validate:"omitempty,max=50"`

	// Profile fields (nested update)
	DateOfBirth      *string  `json:"date_of_birth,omitempty"`
	Gender           *string  `json:"gender,omitempty"           validate:"omitempty,oneof=male female other"`
	HeightCm         *float64 `json:"height_cm,omitempty"        validate:"omitempty,gt=0,lt=300"`
	WeightKg         *float64 `json:"weight_kg,omitempty"        validate:"omitempty,gt=0,lt=500"`
	FitnessGoal      *string  `json:"fitness_goal,omitempty"     validate:"omitempty,oneof=lose_weight gain_muscle maintain improve_endurance flexibility"`
	ExperienceLevel  *string  `json:"experience_level,omitempty" validate:"omitempty,oneof=beginner intermediate advanced"`
	MedicalNotes     *string  `json:"medical_notes,omitempty"`
	EmergencyContact *string  `json:"emergency_contact,omitempty" validate:"omitempty,max=100"`
	Regional         *string  `json:"regional,omitempty"`
	City             *string  `json:"city,omitempty"`
	StreetAddress    *string  `json:"street_address,omitempty"`
	AdditionalAddress *string `json:"additional_address,omitempty"`
	SubDistrict      *string  `json:"sub_district,omitempty"`
	District         *string  `json:"district,omitempty"`
	Province         *string  `json:"province,omitempty"`
	PostalCode       *string  `json:"postal_code,omitempty"`
	Country          *string  `json:"country,omitempty"`
}

func (s *UserService) Update(
	ctx context.Context,
	targetID string,
	input *UpdateUserInput,
	callerRole model.Role,
	callerID string,
) (*UserDetailResult, error) {
	// 1. Fetch existing user
	user, err := s.userRepo.GetByID(ctx, targetID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrUserNotFound
		}
		s.logger.Error("update user: fetch", "target_id", targetID, "error", err)
		return nil, fmt.Errorf("fetching user: %w", err)
	}

	// Trainer visibility check: can only see/update assigned clients or self
	if callerRole == model.RoleTrainer && callerID != targetID {
		isTrainer, err := s.userRepo.IsTrainerOfClient(ctx, callerID, targetID)
		if err != nil {
			s.logger.Error("update user: check trainer assignment", "caller_id", callerID, "target_id", targetID, "error", err)
			return nil, fmt.Errorf("checking trainer assignment: %w", err)
		}
		if !isTrainer {
			s.logger.Warn("update user: access denied", "caller_id", callerID, "target_id", targetID)
			return nil, fmt.Errorf("you do not have access to update this user")
		}
	}

	// 2. Permission checks for role changes
	if input.Role != nil && *input.Role != user.Role {
		// Only owner can assign owner role
		if *input.Role == model.RoleOwner && callerRole != model.RoleOwner {
			s.logger.Warn("update user: unauthorized owner role assignment", "target_id", targetID, "caller_id", callerID)
			return nil, fmt.Errorf("only owner can assign owner role")
		}
		// Cannot promote to same or higher level than yourself
		if !callerRole.CanManageRole(*input.Role) && callerRole != model.RoleOwner {
			s.logger.Warn("update user: cannot assign higher role", "target_id", targetID, "caller_id", callerID, "target_role", *input.Role)
			return nil, fmt.Errorf("cannot assign role equal to or above your own")
		}
		// Cannot change role of someone at or above your level (unless owner)
		if !callerRole.CanManageRole(user.Role) && callerRole != model.RoleOwner {
			s.logger.Warn("update user: cannot modify higher role user", "target_id", targetID, "caller_id", callerID)
			return nil, fmt.Errorf("cannot modify a user with equal or higher role")
		}
	}

	// 3. Apply partial update to user fields
	if input.FullName != nil {
		user.FullName = *input.FullName
	}
	if input.Phone != nil {
		user.Phone = input.Phone
	}
	if input.AvatarURL != nil {
		user.AvatarURL = input.AvatarURL
	}
	if input.Role != nil {
		user.Role = *input.Role
	}
	if input.Status != nil {
		user.Status = *input.Status
	}
	if input.Timezone != nil {
		user.Timezone = *input.Timezone
	}

	if err := s.userRepo.Update(ctx, user); err != nil {
		s.logger.Error("update user: save", "target_id", targetID, "error", err)
		return nil, fmt.Errorf("updating user: %w", err)
	}

	// 4. Update profile if any profile fields were provided
	hasProfileUpdate := input.DateOfBirth != nil || input.Gender != nil ||
		input.HeightCm != nil || input.WeightKg != nil ||
		input.FitnessGoal != nil || input.ExperienceLevel != nil ||
		input.MedicalNotes != nil || input.EmergencyContact != nil ||
		input.Regional != nil || input.City != nil ||
		input.StreetAddress != nil || input.AdditionalAddress != nil ||
		input.SubDistrict != nil || input.District != nil ||
		input.Province != nil || input.PostalCode != nil ||
		input.Country != nil

	if hasProfileUpdate {
		profile := &model.UserProfile{
			UserID:           targetID,
			DateOfBirth:      input.DateOfBirth,
			Gender:           input.Gender,
			HeightCm:         input.HeightCm,
			WeightKg:         input.WeightKg,
			FitnessGoal:      input.FitnessGoal,
			ExperienceLevel:  input.ExperienceLevel,
			MedicalNotes:     input.MedicalNotes,
			EmergencyContact: input.EmergencyContact,
			Regional:         input.Regional,
			City:             input.City,
			StreetAddress:    input.StreetAddress,
			AdditionalAddress: input.AdditionalAddress,
			SubDistrict:      input.SubDistrict,
			District:         input.District,
			Province:         input.Province,
			PostalCode:       input.PostalCode,
			Country:          input.Country,
		}
		if err := s.userRepo.UpsertProfile(ctx, profile); err != nil {
			s.logger.Error("update: upsert profile", "user_id", targetID, "error", err)
			return nil, fmt.Errorf("updating profile: %w", err)
		}
	}

	s.logger.Info("user updated", "target_id", targetID, "by", callerID)

	// 5. Return full detail
	return s.GetByID(ctx, targetID, callerRole, callerID)
}

// ════════════════════════════════════════════════════════════════════
//  Invite
// ════════════════════════════════════════════════════════════════════

type InviteUserInput struct {
	Email    string     `json:"email"     validate:"required,email,max=255"`
	FullName string     `json:"full_name" validate:"required,min=1,max=100"`
	Role     model.Role `json:"role"      validate:"required,oneof=admin finance consultant trainer client"`
	Message  *string    `json:"message,omitempty" validate:"omitempty,max=500"`
}

type InviteResult struct {
	UserID      string `json:"user_id"`
	Email       string `json:"email"`
	InviteToken string `json:"invite_token"`
}

func (s *UserService) Invite(ctx context.Context, input *InviteUserInput, callerRole model.Role) (*InviteResult, error) {
	// Cannot invite someone with equal or higher role
	if !callerRole.CanManageRole(input.Role) && callerRole != model.RoleOwner {
		s.logger.Warn("invite: unauthorized role", "email", input.Email, "role", input.Role, "caller_role", callerRole)
		return nil, fmt.Errorf("cannot invite user with role %s", input.Role)
	}

	// Check if email already taken
	exists, err := s.userRepo.EmailExists(ctx, input.Email)
	if err != nil {
		s.logger.Error("invite: check email", "email", input.Email, "error", err)
		return nil, fmt.Errorf("checking email: %w", err)
	}
	if exists {
		return nil, ErrEmailTaken
	}

	// Create pending user
	user, err := s.userRepo.CreatePendingUser(ctx, input.Email, input.FullName, input.Role)
	if err != nil {
		if errors.Is(err, repository.ErrDuplicateEmail) {
			return nil, ErrEmailTaken
		}
		s.logger.Error("invite: create pending user", "email", input.Email, "error", err)
		return nil, fmt.Errorf("creating pending user: %w", err)
	}

	// Generate invite token
	token, err := model.GenerateToken(32) // 64-char hex string
	if err != nil {
		s.logger.Error("invite: generate token", "error", err)
		return nil, fmt.Errorf("generating invite token: %w", err)
	}

	// TODO: Store invite token in a dedicated table with expiry
	// TODO: Send email via email service with invite link containing this token

	s.logger.Info("user invited",
		"user_id", user.ID,
		"email", input.Email,
		"role", input.Role,
	)

	return &InviteResult{
		UserID:      user.ID,
		Email:       user.Email,
		InviteToken: token,
	}, nil
}

// ════════════════════════════════════════════════════════════════════
//  Client Management
// ════════════════════════════════════════════════════════════════════

func (s *UserService) AssignClient(ctx context.Context, trainerID, clientID string) error {
	if err := s.userRepo.AssignClient(ctx, trainerID, clientID); err != nil {
		s.logger.Error("assign client", "trainer_id", trainerID, "client_id", clientID, "error", err)
		return fmt.Errorf("assigning client: %w", err)
	}
	s.logger.Info("client assigned", "trainer_id", trainerID, "client_id", clientID)
	return nil
}

func (s *UserService) UnassignClient(ctx context.Context, trainerID, clientID string) error {
	if err := s.userRepo.UnassignClient(ctx, trainerID, clientID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return ErrUserNotFound
		}
		s.logger.Error("unassign client", "trainer_id", trainerID, "client_id", clientID, "error", err)
		return fmt.Errorf("unassigning client: %w", err)
	}
	return nil
}

func (s *UserService) ListTeamMembers(ctx context.Context, params model.PaginationParams) ([]model.User, model.PaginationMeta, error) {
	users, total, err := s.userRepo.ListTeamMembers(ctx, params)
	if err != nil {
		s.logger.Error("list team members", "error", err)
		return nil, model.PaginationMeta{}, err
	}
	return users, model.NewPaginationMeta(params.Page, params.Limit, total), nil
}

// ════════════════════════════════════════════════════════════════════
//  Soft Delete
// ════════════════════════════════════════════════════════════════════

func (s *UserService) SoftDelete(ctx context.Context, targetID, callerID string) error {
	// Cannot delete yourself
	if targetID == callerID {
		s.logger.Warn("soft delete: self-delete attempt", "user_id", callerID)
		return fmt.Errorf("cannot delete your own account")
	}

	// Verify target exists
	user, err := s.userRepo.GetByID(ctx, targetID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return ErrUserNotFound
		}
		s.logger.Error("soft delete: fetch user", "target_id", targetID, "error", err)
		return fmt.Errorf("fetching user: %w", err)
	}

	// Cannot delete an owner
	if user.Role == model.RoleOwner {
		s.logger.Warn("soft delete: attempt to delete owner", "target_id", targetID, "caller_id", callerID)
		return fmt.Errorf("cannot delete an owner account")
	}

	if err := s.userRepo.SoftDelete(ctx, targetID); err != nil {
		s.logger.Error("soft delete: delete", "target_id", targetID, "error", err)
		return fmt.Errorf("deleting user: %w", err)
	}

	s.logger.Info("user soft-deleted", "target_id", targetID, "by", callerID)
	return nil
}

// ════════════════════════════════════════════════════════════════════
//  Stats
// ════════════════════════════════════════════════════════════════════

func (s *UserService) GetStats(ctx context.Context, userID string, callerRole model.Role, callerID string) (*model.UserStats, error) {
	// Trainer visibility check
	if callerRole == model.RoleTrainer && callerID != userID {
		isTrainer, err := s.userRepo.IsTrainerOfClient(ctx, callerID, userID)
		if err != nil {
			s.logger.Error("get stats: check trainer assignment", "caller_id", callerID, "user_id", userID, "error", err)
			return nil, fmt.Errorf("checking trainer assignment: %w", err)
		}
		if !isTrainer {
			s.logger.Warn("get stats: access denied", "caller_id", callerID, "user_id", userID)
			return nil, fmt.Errorf("you do not have access to this user's stats")
		}
	}

	// Verify user exists
	if _, err := s.userRepo.GetByID(ctx, userID); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, ErrUserNotFound
		}
		s.logger.Error("get stats: fetch user", "user_id", userID, "error", err)
		return nil, fmt.Errorf("fetching user: %w", err)
	}

	stats, err := s.userRepo.GetStats(ctx, userID)
	if err != nil {
		s.logger.Error("get stats: fetch stats", "user_id", userID, "error", err)
		return nil, fmt.Errorf("fetching stats: %w", err)
	}

	return stats, nil
}
