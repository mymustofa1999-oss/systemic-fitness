package model

import (
	"crypto/rand"
	"encoding/hex"
	"time"
)

// ════════════════════════════════════════════════════════════════════
//  Roles & Enums
// ════════════════════════════════════════════════════════════════════

type Role string

const (
	RoleOwner      Role = "owner"
	RoleAdmin      Role = "admin"
	RoleFinance    Role = "finance"
	RoleConsultant Role = "consultant"
	RoleTrainer    Role = "trainer"
	RoleClient     Role = "client"
)

func (r Role) IsValid() bool {
	switch r {
	case RoleOwner, RoleAdmin, RoleFinance, RoleConsultant, RoleTrainer, RoleClient:
		return true
	}
	return false
}

// Hierarchy returns the role's power level (higher = more privileges).
// Consultant sits between Finance and Trainer — clinical authority above
// Trainer (review assessments, write catatan klinis), but below Finance/Admin
// who own platform/billing concerns.
func (r Role) Hierarchy() int {
	switch r {
	case RoleOwner:
		return 100
	case RoleAdmin:
		return 80
	case RoleFinance:
		return 60
	case RoleConsultant:
		return 50
	case RoleTrainer:
		return 40
	case RoleClient:
		return 20
	default:
		return 0
	}
}

// CanManageRole returns true if this role can modify target role.
func (r Role) CanManageRole(target Role) bool {
	return r.Hierarchy() > target.Hierarchy()
}

type UserStatus string

const (
	StatusActive    UserStatus = "active"
	StatusInactive  UserStatus = "inactive"
	StatusSuspended UserStatus = "suspended"
	StatusPending   UserStatus = "pending"
)

func (s UserStatus) IsValid() bool {
	switch s {
	case StatusActive, StatusInactive, StatusSuspended, StatusPending:
		return true
	}
	return false
}

// ════════════════════════════════════════════════════════════════════
//  User
// ════════════════════════════════════════════════════════════════════

type User struct {
	ID           string     `json:"id"`
	Email        string     `json:"email"`
	PasswordHash string     `json:"-"`
	FullName     string     `json:"full_name"`
	Phone        *string    `json:"phone,omitempty"`
	AvatarURL    *string    `json:"avatar_url,omitempty"`
	Role         Role       `json:"role"`
	Status       UserStatus `json:"status"`
	Timezone     string     `json:"timezone"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`
	DeletedAt         *time.Time `json:"deleted_at,omitempty"`
	NeedsReassessment bool       `json:"needs_reassessment"`
	ResetToken        *string    `json:"-"`
	ResetExpiresAt    *time.Time `json:"-"`
	Classification    *string    `json:"classification,omitempty"`
}

type UserProfile struct {
	UserID           string   `json:"user_id"`
	DateOfBirth      *string  `json:"date_of_birth,omitempty"`
	Gender           *string  `json:"gender,omitempty"`
	HeightCm         *float64 `json:"height_cm,omitempty"`
	WeightKg         *float64 `json:"weight_kg,omitempty"`
	FitnessGoal      *string  `json:"fitness_goal,omitempty"`
	ExperienceLevel  *string  `json:"experience_level,omitempty"`
	MedicalNotes     *string  `json:"medical_notes,omitempty"`
	EmergencyContact *string  `json:"emergency_contact,omitempty"`
	Regional         *string  `json:"regional,omitempty"`
	City             *string  `json:"city,omitempty"`
	StreetAddress    *string  `json:"street_address,omitempty"`
	AdditionalAddress *string `json:"additional_address,omitempty"`
	SubDistrict      *string  `json:"sub_district,omitempty"`
	District         *string  `json:"district,omitempty"`
	Province         *string  `json:"province,omitempty"`
	PostalCode       *string  `json:"postal_code,omitempty"`
	Country          *string  `json:"country,omitempty"`
	Classification   *string  `json:"classification,omitempty"`
}

// UserWithProfile combines the core user record with its extended profile.
type UserWithProfile struct {
	User    `json:"user"`
	Profile *UserProfile `json:"profile,omitempty"`
}

// UserStats holds aggregated statistics for a user.
type UserStats struct {
	UserID               string     `json:"user_id"`
	TotalWorkouts        int        `json:"total_workouts"`
	WorkoutsThisWeek     int        `json:"workouts_this_week"`
	WorkoutsThisMonth    int        `json:"workouts_this_month"`
	CurrentStreakDays     int        `json:"current_streak_days"`
	LongestStreakDays     int        `json:"longest_streak_days"`
	TotalExerciseMinutes int        `json:"total_exercise_minutes"`
	ActiveProgramName    *string    `json:"active_program_name,omitempty"`
	ActiveProgramID      *string    `json:"active_program_id,omitempty"`
	ProgramProgressPct   *float64   `json:"program_progress_pct,omitempty"`
	LastWorkoutAt        *time.Time `json:"last_workout_at,omitempty"`
	MemberSince          time.Time  `json:"member_since"`
}

type UserSubscription struct {
	ID        string    `json:"id"`
	PlanID    string    `json:"plan_id"`
	PlanName  string    `json:"plan_name"`
	Tier      string    `json:"tier"`
	Status    string    `json:"status"`
	ExpiresAt time.Time `json:"expires_at"`
}

// TrainerClient represents a trainer-to-client assignment.
type TrainerClient struct {
	TrainerID  string     `json:"trainer_id"`
	ClientID   string     `json:"client_id"`
	AssignedAt time.Time  `json:"assigned_at"`
	Status     string     `json:"status"`
}

// ════════════════════════════════════════════════════════════════════
//  Auth
// ════════════════════════════════════════════════════════════════════

type TokenPair struct {
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token"`
	ExpiresAt    time.Time `json:"expires_at"`
}

// ════════════════════════════════════════════════════════════════════
//  Pagination
// ════════════════════════════════════════════════════════════════════

type PaginationParams struct {
	Page      int    `json:"page" validate:"min=1"`
	Limit     int    `json:"limit" validate:"min=1,max=1000"`
	SortBy    string `json:"sort_by,omitempty"`
	SortOrder string `json:"sort_order,omitempty" validate:"omitempty,oneof=asc desc"`
	Search    string `json:"search,omitempty"`
}

type PaginationMeta struct {
	Page       int `json:"page"`
	Limit      int `json:"limit"`
	Total      int `json:"total"`
	TotalPages int `json:"total_pages"`
}

func NewPaginationParams(page, limit int) PaginationParams {
	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 20
	}
	if limit > 1000 {
		limit = 1000
	}
	return PaginationParams{Page: page, Limit: limit}
}

func (p PaginationParams) Offset() int {
	return (p.Page - 1) * p.Limit
}

func NewPaginationMeta(page, limit, total int) PaginationMeta {
	totalPages := 0
	if limit > 0 {
		totalPages = total / limit
		if total%limit > 0 {
			totalPages++
		}
	}
	return PaginationMeta{
		Page:       page,
		Limit:      limit,
		Total:      total,
		TotalPages: totalPages,
	}
}

// ════════════════════════════════════════════════════════════════════
//  Upload
// ════════════════════════════════════════════════════════════════════

type Upload struct {
	ID           string     `json:"id"`
	OriginalName string     `json:"original_name"`
	StoredName   string     `json:"stored_name"`
	MimeType     string     `json:"mime_type"`
	SizeBytes    int64      `json:"size_bytes"`
	Width        *int       `json:"width,omitempty"`
	Height       *int       `json:"height,omitempty"`
	Path         string     `json:"-"`
	URL          string     `json:"url"`
	UploadedBy   string     `json:"uploaded_by"`
	EntityType   *string    `json:"entity_type,omitempty"`
	EntityID     *string    `json:"entity_id,omitempty"`
	CreatedAt    time.Time  `json:"created_at"`
	DeletedAt    *time.Time `json:"deleted_at,omitempty"`
}

// ════════════════════════════════════════════════════════════════════
//  Assessment
// ════════════════════════════════════════════════════════════════════

type AssessmentTier string

const (
	TierFree AssessmentTier = "free"
	TierPaid AssessmentTier = "paid"
)

func (t AssessmentTier) IsValid() bool {
	switch t {
	case TierFree, TierPaid:
		return true
	}
	return false
}

type AssessmentStatus string

const (
	AssessmentSubmitted AssessmentStatus = "submitted"
	AssessmentVerified  AssessmentStatus = "verified"
	AssessmentRevised   AssessmentStatus = "revised"
)

func (s AssessmentStatus) IsValid() bool {
	switch s {
	case AssessmentSubmitted, AssessmentVerified, AssessmentRevised:
		return true
	}
	return false
}

type Classification string

const (
	ClassOptimal      Classification = "optimal"
	ClassCompromised  Classification = "compromised"
	ClassCritical     Classification = "critical"
	ClassStable       Classification = "stable"
	ClassCompensation Classification = "compensation"
	ClassDysfunction  Classification = "dysfunction"
	ClassEfficient    Classification = "efficient"
	ClassAtRisk       Classification = "at_risk"
	ClassDysregulated Classification = "dysregulated"
)

// ─── Raw inputs (also persisted as JSONB) ──────────────────────────

type SleepInput struct {
	DurationHours    float64 `json:"duration_hours" validate:"required,gt=0,lt=24"`
	Consistency      int     `json:"consistency" validate:"required,min=1,max=3"`
	LatencyMinutes   int     `json:"latency_minutes" validate:"min=0,max=240"`
	MorningReadiness int     `json:"morning_readiness" validate:"required,min=1,max=3"`
	WakeFrequency    int     `json:"wake_frequency" validate:"min=0,max=10"`
	PreSleepHabit    int     `json:"pre_sleep_habit" validate:"required,min=1,max=3"`
}

type MovementInput struct {
	Squat    int `json:"squat" validate:"required,min=1,max=3"`
	HipHinge int `json:"hip_hinge" validate:"required,min=1,max=3"`
	Overhead int `json:"overhead" validate:"required,min=1,max=3"`
}

type MetabolicInput struct {
	HbA1c        float64  `json:"hba1c" validate:"required,gt=0,lt=20"`
	LDL          float64  `json:"ldl" validate:"required,gt=0"`
	Triglyceride float64  `json:"triglyceride" validate:"required,gt=0"`
	Medications  []string `json:"medications,omitempty" validate:"omitempty,dive,max=100"`
}

// ─── Computed scores & result ──────────────────────────────────────

type AssessmentScores struct {
	Sleep     int  `json:"sleep_score"`
	Recovery  int  `json:"recovery_score"`
	Movement  int  `json:"movement_score"`
	Metabolic *int `json:"metabolic_score,omitempty"`
	System    int  `json:"system_score"`
}

// Assessment represents the persisted entity row.
type Assessment struct {
	ID              string            `json:"id"`
	UserID          *string           `json:"user_id,omitempty"`
	UserName        *string           `json:"user_name,omitempty"`
	Tier            AssessmentTier    `json:"tier"`
	Status          AssessmentStatus  `json:"status"`
	Sleep           SleepInput        `json:"sleep"`
	Movement        MovementInput     `json:"movement"`
	Metabolic       *MetabolicInput   `json:"metabolic,omitempty"`
	Scores          AssessmentScores  `json:"scores"`
	SleepClass      Classification    `json:"sleep_class"`
	MovementClass   Classification    `json:"movement_class"`
	MetabolicClass  *Classification   `json:"metabolic_class,omitempty"`
	Flags           []string          `json:"flags"`
	Insight         string            `json:"insight"`
	Recommendations []string          `json:"recommendations"`
	ReviewedBy      *string           `json:"reviewed_by,omitempty"`
	ReviewedAt      *time.Time        `json:"reviewed_at,omitempty"`
	ReviewerNotes   *string           `json:"reviewer_notes,omitempty"`
	CreatedAt       time.Time         `json:"created_at"`
	UpdatedAt       time.Time         `json:"updated_at"`
}

// ════════════════════════════════════════════════════════════════════
//  Nutrition Guidance & Monitoring Engine
// ════════════════════════════════════════════════════════════════════

type NutritionGender string
type NutritionAgeGroup string
type NutritionGoal string
type FemaleCondition string

const (
	NGenderMale   NutritionGender = "male"
	NGenderFemale NutritionGender = "female"

	NAgeUnder18 NutritionAgeGroup = "under_18"
	NAge18To40  NutritionAgeGroup = "18_40"
	NAge41To60  NutritionAgeGroup = "41_60"
	NAgeOver60  NutritionAgeGroup = "over_60"

	NGoalMaintenance NutritionGoal = "maintenance"
	NGoalFatLoss     NutritionGoal = "fat_loss"
	NGoalRecovery    NutritionGoal = "recovery"

	FemNormal    FemaleCondition = "normal"
	FemPregnant  FemaleCondition = "pregnant"
	FemMenopause FemaleCondition = "menopause"
)

// Health condition codes (stored as TEXT[] in DB)
const (
	ConditionHypertension = "hypertension"
	ConditionDiabetes     = "diabetes"
	ConditionKidney       = "kidney"
	ConditionGout         = "gout"
	ConditionHeart        = "heart"
	ConditionCancer       = "cancer"
	ConditionAutoimmune   = "autoimmune"
	ConditionHormonal     = "hormonal"
)

// Daily log status
const (
	NutritionStatusStable  = "stable"
	NutritionStatusWarning = "warning"
	NutritionStatusRisk    = "risk"
)

type NutritionHealthProfile struct {
	UserID          string            `json:"user_id"`
	Gender          NutritionGender   `json:"gender"`
	AgeGroup        NutritionAgeGroup `json:"age_group"`
	FemaleCondition *FemaleCondition  `json:"female_condition,omitempty"`
	Goal            NutritionGoal     `json:"goal"`
	WeightKg        float64           `json:"weight_kg"`
	Allergies       []string          `json:"allergies"`
	Conditions      []string          `json:"conditions"`
	CreatedAt       time.Time         `json:"created_at"`
	UpdatedAt       time.Time         `json:"updated_at"`
}

type DietPlan struct {
	AllowedFoods []string `json:"allowed_foods"`
	LimitedFoods []string `json:"limited_foods"`
	AvoidFoods   []string `json:"avoid_foods"`
}

type NutritionRules map[string]any

type NutritionPlanResult struct {
	DietPlan       DietPlan       `json:"diet_plan"`
	NutritionRules NutritionRules `json:"nutrition_rules"`
	DailyScore     int            `json:"daily_score"`
	Status         string         `json:"status"`
	Insight        []string       `json:"insight"`
}

type NutritionDailyLogInput struct {
	LogDate         string `json:"log_date" validate:"required,datetime=2006-01-02"`
	VegetableIntake bool   `json:"vegetable_intake"`
	ProteinIntake   bool   `json:"protein_intake"`
	HydrationOK     bool   `json:"hydration_ok"`
	SugarExcess     bool   `json:"sugar_excess"`
	DietViolation   bool   `json:"diet_violation"`
}

type NutritionAlert struct {
	Triggered bool   `json:"alert"`
	Message   string `json:"message"`
}

type NutritionDailyLogResult struct {
	LogDate string          `json:"log_date"`
	Score   int             `json:"daily_score"`
	Status  string          `json:"status"`
	Alert   *NutritionAlert `json:"alert,omitempty"`
}

type UpsertNutritionProfileInput struct {
	Gender          string   `json:"gender" validate:"required,oneof=male female"`
	AgeGroup        string   `json:"age_group" validate:"required,oneof=under_18 18_40 41_60 over_60"`
	FemaleCondition string   `json:"female_condition" validate:"omitempty,oneof=normal pregnant menopause"`
	Goal            string   `json:"goal" validate:"required,oneof=maintenance fat_loss recovery"`
	WeightKg        float64  `json:"weight_kg" validate:"gt=0,lte=500"`
	Allergies       []string `json:"allergies" validate:"omitempty,dive,min=1,max=50"`
	Conditions      []string `json:"conditions" validate:"omitempty,dive,oneof=hypertension diabetes kidney gout heart cancer autoimmune hormonal"`
}

// ════════════════════════════════════════════════════════════════════
//  Utility
// ════════════════════════════════════════════════════════════════════

// GenerateToken produces a cryptographically random hex token of given byte length.
func GenerateToken(byteLen int) (string, error) {
	b := make([]byte, byteLen)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}
