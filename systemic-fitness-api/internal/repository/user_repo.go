package repository

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

var (
	ErrNotFound      = errors.New("record not found")
	ErrDuplicateEmail = errors.New("email already exists")
)

type UserRepository struct {
	db *pgxpool.Pool
}

func NewUserRepository(db *pgxpool.Pool) *UserRepository {
	return &UserRepository{db: db}
}

// ════════════════════════════════════════════════════════════════════
//  Core CRUD
// ════════════════════════════════════════════════════════════════════

// scanUser scans a user row into a User struct. Shared by all SELECT queries.
func scanUser(row pgx.Row) (*model.User, error) {
	u := &model.User{}
	err := row.Scan(
		&u.ID, &u.Email, &u.PasswordHash, &u.FullName,
		&u.Phone, &u.AvatarURL, &u.Role, &u.Status,
		&u.Timezone, &u.CreatedAt, &u.UpdatedAt, &u.DeletedAt,
		&u.Classification,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("scanning user: %w", err)
	}
	return u, nil
}

const userColumns = `id, email, password_hash, full_name, phone, avatar_url,
	role, status, timezone, created_at, updated_at, deleted_at, NULL as classification`

const userPrefixedColumns = `u.id, u.email, u.password_hash, u.full_name, u.phone, u.avatar_url,
	u.role, u.status, u.timezone, u.created_at, u.updated_at, u.deleted_at, COALESCE(up.classification, NULL)`

func (r *UserRepository) Create(ctx context.Context, user *model.User) error {
	query := `
		INSERT INTO users (email, password_hash, full_name, phone, avatar_url, role, status, timezone)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at, updated_at`

	err := r.db.QueryRow(ctx, query,
		user.Email, user.PasswordHash, user.FullName, user.Phone,
		user.AvatarURL, user.Role, user.Status, user.Timezone,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		if strings.Contains(err.Error(), "uq_users_email") || strings.Contains(err.Error(), "duplicate key") {
			return ErrDuplicateEmail
		}
		return fmt.Errorf("insert user: %w", err)
	}
	return nil
}

func (r *UserRepository) GetByID(ctx context.Context, id string) (*model.User, error) {
	query := `SELECT ` + userColumns + ` FROM users WHERE id = $1 AND deleted_at IS NULL`
	return scanUser(r.db.QueryRow(ctx, query, id))
}

func (r *UserRepository) GetByEmail(ctx context.Context, email string) (*model.User, error) {
	query := `SELECT ` + userColumns + ` FROM users WHERE email = $1 AND deleted_at IS NULL`
	return scanUser(r.db.QueryRow(ctx, query, email))
}

func (r *UserRepository) EmailExists(ctx context.Context, email string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(ctx,
		`SELECT EXISTS(SELECT 1 FROM users WHERE email = $1 AND deleted_at IS NULL)`,
		email,
	).Scan(&exists)
	return exists, err
}

func (r *UserRepository) Update(ctx context.Context, user *model.User) error {
	query := `
		UPDATE users SET
			full_name = $2, phone = $3, avatar_url = $4,
			role = $5, status = $6, timezone = $7
		WHERE id = $1 AND deleted_at IS NULL
		RETURNING updated_at`

	err := r.db.QueryRow(ctx, query,
		user.ID, user.FullName, user.Phone, user.AvatarURL,
		user.Role, user.Status, user.Timezone,
	).Scan(&user.UpdatedAt)

	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r *UserRepository) SoftDelete(ctx context.Context, id string) error {
	tag, err := r.db.Exec(ctx,
		`UPDATE users SET deleted_at = NOW() WHERE id = $1 AND deleted_at IS NULL`,
		id,
	)
	if err != nil {
		return fmt.Errorf("soft delete: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

// ════════════════════════════════════════════════════════════════════
//  List with Filters
// ════════════════════════════════════════════════════════════════════

type UserListFilter struct {
	Role      *model.Role
	Status    *model.UserStatus
	TrainerID *string // if set, only list clients assigned to this trainer
	Search    string
	Classification *string
}

func (r *UserRepository) List(ctx context.Context, params model.PaginationParams, filter UserListFilter) ([]model.User, int, error) {
	// ── Build WHERE clauses ─────────────────────────────────────
	where := []string{"u.deleted_at IS NULL"}
	args := []any{}
	argIdx := 1

	if filter.Role != nil {
		where = append(where, fmt.Sprintf("u.role = $%d", argIdx))
		args = append(args, *filter.Role)
		argIdx++
	}
	if filter.Status != nil {
		where = append(where, fmt.Sprintf("u.status = $%d", argIdx))
		args = append(args, *filter.Status)
		argIdx++
	}
	if filter.Search != "" {
		where = append(where, fmt.Sprintf("(u.full_name ILIKE $%d OR u.email ILIKE $%d)", argIdx, argIdx))
		args = append(args, "%"+filter.Search+"%")
		argIdx++
	}

	// ALWAYS include user_profiles since userPrefixedColumns references 'up'
	joinClause := " LEFT JOIN user_profiles up ON u.id = up.user_id "
	
	// Classification filtering
	if filter.Classification != nil {
		where = append(where, fmt.Sprintf("up.classification = $%d", argIdx))
		args = append(args, *filter.Classification)
		argIdx++
	}

	// Trainer scoping: only show assigned clients
	if filter.TrainerID != nil {
		joinClause += fmt.Sprintf(" JOIN trainer_clients tc ON u.id = tc.client_id AND tc.trainer_id = $%d AND tc.status = 'active' ", argIdx)
		args = append(args, *filter.TrainerID)
		argIdx++
	}

	whereSQL := strings.Join(where, " AND ")

	// ── Count ───────────────────────────────────────────────────
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM users u %s WHERE %s", joinClause, whereSQL)
	var total int
	if err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("count users: %w", err)
	}

	// ── Sort ────────────────────────────────────────────────────
	allowedSorts := map[string]bool{
		"created_at": true, "full_name": true, "email": true, "role": true,
	}
	sortCol := "u.created_at"
	if allowedSorts[params.SortBy] {
		sortCol = "u." + params.SortBy
	}
	sortDir := "DESC"
	if params.SortOrder == "asc" {
		sortDir = "ASC"
	}

	// ── Select ──────────────────────────────────────────────────
	listQuery := fmt.Sprintf(`
		SELECT %s,
		       COALESCE(EXTRACT(DAY FROM NOW() - a.created_at) >= 30, true) as needs_reassessment
		FROM users u %s
		LEFT JOIN LATERAL (
		    SELECT created_at FROM assessments WHERE user_id = u.id AND version='v2' ORDER BY created_at DESC LIMIT 1
		) a ON true
		WHERE %s
		ORDER BY %s %s
		LIMIT $%d OFFSET $%d`,
		userPrefixedColumns, joinClause, whereSQL, sortCol, sortDir, argIdx, argIdx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, listQuery, args...)
	if err != nil {
		return nil, 0, fmt.Errorf("list users: %w", err)
	}
	defer rows.Close()

	users := make([]model.User, 0)
	for rows.Next() {
		u := model.User{}
		if err := rows.Scan(
			&u.ID, &u.Email, &u.PasswordHash, &u.FullName,
			&u.Phone, &u.AvatarURL, &u.Role, &u.Status,
			&u.Timezone, &u.CreatedAt, &u.UpdatedAt, &u.DeletedAt,
			&u.Classification,
			&u.NeedsReassessment,
		); err != nil {
			return nil, 0, fmt.Errorf("scan user row: %w", err)
		}
		u.PasswordHash = "" // never expose
		users = append(users, u)
	}

	return users, total, rows.Err()
}

// ════════════════════════════════════════════════════════════════════
//  Profile
// ════════════════════════════════════════════════════════════════════

func (r *UserRepository) UpsertProfile(ctx context.Context, p *model.UserProfile) error {
	query := `
		INSERT INTO user_profiles (
			user_id, date_of_birth, gender, height_cm, weight_kg,
			fitness_goal, experience_level, medical_notes, emergency_contact,
			regional, city, street_address, additional_address, sub_district,
			district, province, postal_code, country, classification
		) VALUES ($1, $2::date, $3::gender_type, $4, $5, $6::fitness_goal, $7::experience_level, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
		ON CONFLICT (user_id) DO UPDATE SET
			date_of_birth    = COALESCE(EXCLUDED.date_of_birth, user_profiles.date_of_birth),
			gender           = COALESCE(EXCLUDED.gender, user_profiles.gender),
			height_cm        = COALESCE(EXCLUDED.height_cm, user_profiles.height_cm),
			weight_kg        = COALESCE(EXCLUDED.weight_kg, user_profiles.weight_kg),
			fitness_goal     = COALESCE(EXCLUDED.fitness_goal, user_profiles.fitness_goal),
			experience_level = COALESCE(EXCLUDED.experience_level, user_profiles.experience_level),
			medical_notes    = COALESCE(EXCLUDED.medical_notes, user_profiles.medical_notes),
			emergency_contact = COALESCE(EXCLUDED.emergency_contact, user_profiles.emergency_contact),
			regional         = COALESCE(EXCLUDED.regional, user_profiles.regional),
			city             = COALESCE(EXCLUDED.city, user_profiles.city),
			street_address   = COALESCE(EXCLUDED.street_address, user_profiles.street_address),
			additional_address = COALESCE(EXCLUDED.additional_address, user_profiles.additional_address),
			sub_district     = COALESCE(EXCLUDED.sub_district, user_profiles.sub_district),
			district         = COALESCE(EXCLUDED.district, user_profiles.district),
			province         = COALESCE(EXCLUDED.province, user_profiles.province),
			postal_code      = COALESCE(EXCLUDED.postal_code, user_profiles.postal_code),
			country          = COALESCE(EXCLUDED.country, user_profiles.country),
			classification   = COALESCE(EXCLUDED.classification, user_profiles.classification)`

	_, err := r.db.Exec(ctx, query,
		p.UserID, p.DateOfBirth, p.Gender, p.HeightCm, p.WeightKg,
		p.FitnessGoal, p.ExperienceLevel, p.MedicalNotes, p.EmergencyContact,
		p.Regional, p.City, p.StreetAddress, p.AdditionalAddress, p.SubDistrict,
		p.District, p.Province, p.PostalCode, p.Country, p.Classification,
	)
	return err
}

func (r *UserRepository) GetProfile(ctx context.Context, userID string) (*model.UserProfile, error) {
	p := &model.UserProfile{}
	var dob *time.Time
	err := r.db.QueryRow(ctx, `
		SELECT user_id, date_of_birth, gender, height_cm, weight_kg,
		       fitness_goal, experience_level, medical_notes, emergency_contact,
		       regional, city, street_address, additional_address, sub_district,
		       district, province, postal_code, country, classification
		FROM user_profiles WHERE user_id = $1`, userID,
	).Scan(
		&p.UserID, &dob, &p.Gender, &p.HeightCm, &p.WeightKg,
		&p.FitnessGoal, &p.ExperienceLevel, &p.MedicalNotes, &p.EmergencyContact,
		&p.Regional, &p.City, &p.StreetAddress, &p.AdditionalAddress, &p.SubDistrict,
		&p.District, &p.Province, &p.PostalCode, &p.Country, &p.Classification,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil // profile doesn't exist yet — that's ok
	}
	if dob != nil {
		s := dob.Format("2006-01-02")
		p.DateOfBirth = &s
	}
	return p, err
}

// ════════════════════════════════════════════════════════════════════
//  User Stats (aggregated from progress_logs, user_programs, etc.)
// ════════════════════════════════════════════════════════════════════

func (r *UserRepository) GetStats(ctx context.Context, userID string) (*model.UserStats, error) {
	stats := &model.UserStats{UserID: userID}

	// Total workouts + last workout date
	err := r.db.QueryRow(ctx, `
		SELECT
			COUNT(DISTINCT (exercise_id, DATE(logged_at))),
			MAX(logged_at)
		FROM progress_logs
		WHERE user_id = $1`, userID,
	).Scan(&stats.TotalWorkouts, &stats.LastWorkoutAt)
	if err != nil {
		return nil, fmt.Errorf("stats total workouts: %w", err)
	}

	// Workouts this week
	err = r.db.QueryRow(ctx, `
		SELECT COUNT(DISTINCT DATE(logged_at))
		FROM progress_logs
		WHERE user_id = $1
		  AND logged_at >= DATE_TRUNC('week', CURRENT_DATE)`, userID,
	).Scan(&stats.WorkoutsThisWeek)
	if err != nil {
		return nil, fmt.Errorf("stats this week: %w", err)
	}

	// Workouts this month
	err = r.db.QueryRow(ctx, `
		SELECT COUNT(DISTINCT DATE(logged_at))
		FROM progress_logs
		WHERE user_id = $1
		  AND logged_at >= DATE_TRUNC('month', CURRENT_DATE)`, userID,
	).Scan(&stats.WorkoutsThisMonth)
	if err != nil {
		return nil, fmt.Errorf("stats this month: %w", err)
	}

	// Current streak: count consecutive days backwards from today
	err = r.db.QueryRow(ctx, `
		WITH workout_dates AS (
			SELECT DISTINCT DATE(logged_at) AS d
			FROM progress_logs
			WHERE user_id = $1
			ORDER BY d DESC
		),
		streak AS (
			SELECT d, d - (ROW_NUMBER() OVER (ORDER BY d DESC))::int AS grp
			FROM workout_dates
		)
		SELECT COUNT(*)
		FROM streak
		WHERE grp = (SELECT grp FROM streak WHERE d = CURRENT_DATE OR d = CURRENT_DATE - 1 LIMIT 1)`,
		userID,
	).Scan(&stats.CurrentStreakDays)
	if err != nil {
		// If no data, streak is 0 — not an error
		stats.CurrentStreakDays = 0
	}

	// Longest streak (all-time)
	err = r.db.QueryRow(ctx, `
		WITH workout_dates AS (
			SELECT DISTINCT DATE(logged_at) AS d
			FROM progress_logs
			WHERE user_id = $1
		),
		grouped AS (
			SELECT d, d - (ROW_NUMBER() OVER (ORDER BY d))::int AS grp
			FROM workout_dates
		)
		SELECT COALESCE(MAX(cnt), 0)
		FROM (SELECT COUNT(*) AS cnt FROM grouped GROUP BY grp) sub`,
		userID,
	).Scan(&stats.LongestStreakDays)
	if err != nil {
		stats.LongestStreakDays = 0
	}

	// Active program
	err = r.db.QueryRow(ctx, `
		SELECT up.program_id, p.name,
		       ROUND(
		           LEAST(
		               (EXTRACT(DAY FROM NOW() - up.start_date)::numeric /
		                NULLIF(p.duration_weeks * 7, 0)) * 100,
		               100
		           ), 1
		       )
		FROM user_programs up
		JOIN programs p ON p.id = up.program_id
		WHERE up.user_id = $1 AND up.status = 'active'
		ORDER BY up.created_at DESC
		LIMIT 1`, userID,
	).Scan(&stats.ActiveProgramID, &stats.ActiveProgramName, &stats.ProgramProgressPct)
	if errors.Is(err, pgx.ErrNoRows) {
		// No active program — fine
	} else if err != nil {
		return nil, fmt.Errorf("stats active program: %w", err)
	}

	// Member since
	err = r.db.QueryRow(ctx,
		`SELECT created_at FROM users WHERE id = $1`, userID,
	).Scan(&stats.MemberSince)
	if err != nil {
		return nil, fmt.Errorf("stats member since: %w", err)
	}

	return stats, nil
}

// ════════════════════════════════════════════════════════════════════
//  Trainer ↔ Client
// ════════════════════════════════════════════════════════════════════

func (r *UserRepository) IsTrainerOfClient(ctx context.Context, trainerID, clientID string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(ctx, `
		SELECT EXISTS(
			SELECT 1 FROM trainer_clients
			WHERE trainer_id = $1 AND client_id = $2 AND status = 'active'
		)`, trainerID, clientID,
	).Scan(&exists)
	return exists, err
}

func (r *UserRepository) GetTrainerClients(ctx context.Context, trainerID string) ([]string, error) {
	rows, err := r.db.Query(ctx,
		`SELECT client_id FROM trainer_clients WHERE trainer_id = $1 AND status = 'active'`,
		trainerID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}

func (r *UserRepository) AssignClient(ctx context.Context, trainerID, clientID string) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO trainer_clients (trainer_id, client_id, status)
		VALUES ($1, $2, 'active')
		ON CONFLICT (trainer_id, client_id) DO UPDATE SET status = 'active'`,
		trainerID, clientID)
	return err
}

func (r *UserRepository) UnassignClient(ctx context.Context, trainerID, clientID string) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE trainer_clients SET status = 'inactive'
		WHERE trainer_id = $1 AND client_id = $2 AND status = 'active'`,
		trainerID, clientID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *UserRepository) ListTeamMembers(ctx context.Context, params model.PaginationParams) ([]model.User, int, error) {
	filter := UserListFilter{Search: params.Search}
	// Team = all non-client roles (owner, admin, finance, trainer)
	where := []string{"u.deleted_at IS NULL", "u.role != 'client'"}
	args := []any{}
	argIdx := 1

	if filter.Search != "" {
		where = append(where, fmt.Sprintf("(u.full_name ILIKE $%d OR u.email ILIKE $%d)", argIdx, argIdx))
		args = append(args, "%"+filter.Search+"%")
		argIdx++
	}

	whereSQL := strings.Join(where, " AND ")

	var total int
	if err := r.db.QueryRow(ctx, fmt.Sprintf("SELECT COUNT(*) FROM users u WHERE %s", whereSQL), args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	query := fmt.Sprintf(`SELECT %s FROM users u LEFT JOIN user_profiles up ON u.id = up.user_id WHERE %s ORDER BY u.role, u.full_name LIMIT $%d OFFSET $%d`,
		userPrefixedColumns, whereSQL, argIdx, argIdx+1)
	args = append(args, params.Limit, params.Offset())

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	users := make([]model.User, 0)
	for rows.Next() {
		u := model.User{}
		if err := rows.Scan(&u.ID, &u.Email, &u.PasswordHash, &u.FullName,
			&u.Phone, &u.AvatarURL, &u.Role, &u.Status,
			&u.Timezone, &u.CreatedAt, &u.UpdatedAt, &u.DeletedAt,
			&u.Classification); err != nil {
			return nil, 0, err
		}
		u.PasswordHash = ""
		users = append(users, u)
	}
	return users, total, rows.Err()
}

// ════════════════════════════════════════════════════════════════════
//  Invite
// ════════════════════════════════════════════════════════════════════

// CreatePendingUser creates a user with 'pending' status and a placeholder password.
// Returns the created user. The invite token is stored separately or sent via email.
func (r *UserRepository) CreatePendingUser(ctx context.Context, email, fullName string, role model.Role) (*model.User, error) {
	user := &model.User{
		Email:        email,
		PasswordHash: "__INVITE_PENDING__", // placeholder — user sets password on accept
		FullName:     fullName,
		Role:         role,
		Status:       model.StatusPending,
		Timezone:     "Asia/Jakarta",
	}
	if err := r.Create(ctx, user); err != nil {
		return nil, err
	}
	return user, nil
}

// GetActiveSubscription returns the user's latest active subscription, if any.
func (r *UserRepository) GetActiveSubscription(ctx context.Context, userID string) (*model.UserSubscription, error) {
	var sub model.UserSubscription
	err := r.db.QueryRow(ctx, `
		SELECT s.id, s.plan_id, pp.name, pp.tier, s.status, s.expires_at
		FROM subscriptions s
		JOIN payment_plans pp ON pp.id = s.plan_id
		WHERE s.user_id = $1 AND s.status = 'active'
		ORDER BY s.created_at DESC
		LIMIT 1`, userID).Scan(&sub.ID, &sub.PlanID, &sub.PlanName, &sub.Tier, &sub.Status, &sub.ExpiresAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil // No active subscription
		}
		return nil, err
	}
	return &sub, nil
}

