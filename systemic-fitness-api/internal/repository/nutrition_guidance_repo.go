package repository

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

// NutritionGuidanceRepository handles persistence for the
// Nutrition Guidance & Monitoring Engine module.
type NutritionGuidanceRepository struct {
	db *pgxpool.Pool
}

func NewNutritionGuidanceRepository(db *pgxpool.Pool) *NutritionGuidanceRepository {
	return &NutritionGuidanceRepository{db: db}
}

// ─── Health Profile ─────────────────────────────────────────────────

const nutritionProfileColumns = `
	user_id, gender, age_group, female_condition, goal,
	weight_kg, allergies, conditions, created_at, updated_at`

func scanNutritionProfile(row pgx.Row) (*model.NutritionHealthProfile, error) {
	var (
		p           model.NutritionHealthProfile
		femCond     *string
		gender      string
		ageGroup    string
		goal        string
	)
	if err := row.Scan(
		&p.UserID, &gender, &ageGroup, &femCond, &goal,
		&p.WeightKg, &p.Allergies, &p.Conditions, &p.CreatedAt, &p.UpdatedAt,
	); err != nil {
		return nil, err
	}
	p.Gender = model.NutritionGender(gender)
	p.AgeGroup = model.NutritionAgeGroup(ageGroup)
	p.Goal = model.NutritionGoal(goal)
	if femCond != nil {
		fc := model.FemaleCondition(*femCond)
		p.FemaleCondition = &fc
	}
	if p.Allergies == nil {
		p.Allergies = []string{}
	}
	if p.Conditions == nil {
		p.Conditions = []string{}
	}
	return &p, nil
}

func (r *NutritionGuidanceRepository) GetProfile(ctx context.Context, userID string) (*model.NutritionHealthProfile, error) {
	row := r.db.QueryRow(ctx, `
		SELECT `+nutritionProfileColumns+`
		FROM nutrition_health_profiles
		WHERE user_id = $1`, userID)
	p, err := scanNutritionProfile(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	return p, err
}

func (r *NutritionGuidanceRepository) UpsertProfile(ctx context.Context, userID string, in *model.UpsertNutritionProfileInput) (*model.NutritionHealthProfile, error) {
	var femCond any
	if in.FemaleCondition != "" {
		femCond = in.FemaleCondition
	}
	allergies := in.Allergies
	if allergies == nil {
		allergies = []string{}
	}
	conditions := in.Conditions
	if conditions == nil {
		conditions = []string{}
	}

	row := r.db.QueryRow(ctx, `
		INSERT INTO nutrition_health_profiles
			(user_id, gender, age_group, female_condition, goal, weight_kg, allergies, conditions, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, now())
		ON CONFLICT (user_id) DO UPDATE SET
			gender = EXCLUDED.gender,
			age_group = EXCLUDED.age_group,
			female_condition = EXCLUDED.female_condition,
			goal = EXCLUDED.goal,
			weight_kg = EXCLUDED.weight_kg,
			allergies = EXCLUDED.allergies,
			conditions = EXCLUDED.conditions,
			updated_at = now()
		RETURNING `+nutritionProfileColumns,
		userID, in.Gender, in.AgeGroup, femCond, in.Goal,
		in.WeightKg, allergies, conditions,
	)
	return scanNutritionProfile(row)
}

// ─── Daily Logs ─────────────────────────────────────────────────────

type NutritionDailyLogRow struct {
	LogDate         time.Time
	VegetableIntake bool
	ProteinIntake   bool
	HydrationOK     bool
	SugarExcess     bool
	DietViolation   bool
	Score           int
	Status          string
}

func (r *NutritionGuidanceRepository) UpsertDailyLog(
	ctx context.Context,
	userID string,
	logDate time.Time,
	in *model.NutritionDailyLogInput,
	score int,
	status string,
) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO nutrition_daily_logs
			(user_id, log_date, vegetable_intake, protein_intake, hydration_ok,
			 sugar_excess, diet_violation, score, status, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, now())
		ON CONFLICT (user_id, log_date) DO UPDATE SET
			vegetable_intake = EXCLUDED.vegetable_intake,
			protein_intake   = EXCLUDED.protein_intake,
			hydration_ok     = EXCLUDED.hydration_ok,
			sugar_excess     = EXCLUDED.sugar_excess,
			diet_violation   = EXCLUDED.diet_violation,
			score            = EXCLUDED.score,
			status           = EXCLUDED.status,
			updated_at       = now()`,
		userID, logDate, in.VegetableIntake, in.ProteinIntake, in.HydrationOK,
		in.SugarExcess, in.DietViolation, score, status,
	)
	return err
}

func (r *NutritionGuidanceRepository) GetDailyLog(ctx context.Context, userID string, logDate time.Time) (*NutritionDailyLogRow, error) {
	row := r.db.QueryRow(ctx, `
		SELECT log_date, vegetable_intake, protein_intake, hydration_ok,
		       sugar_excess, diet_violation, score, status
		FROM nutrition_daily_logs
		WHERE user_id = $1 AND log_date = $2`,
		userID, logDate,
	)
	var l NutritionDailyLogRow
	err := row.Scan(
		&l.LogDate, &l.VegetableIntake, &l.ProteinIntake, &l.HydrationOK,
		&l.SugarExcess, &l.DietViolation, &l.Score, &l.Status,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrNotFound
	}
	if err != nil {
		return nil, err
	}
	return &l, nil
}

// ListRecentLogs returns the N most recent full daily log rows for a user.
func (r *NutritionGuidanceRepository) ListRecentLogs(ctx context.Context, userID string, limit int) ([]NutritionDailyLogRow, error) {
	if limit <= 0 {
		limit = 30
	}
	rows, err := r.db.Query(ctx, `
		SELECT log_date, vegetable_intake, protein_intake, hydration_ok,
		       sugar_excess, diet_violation, score, status
		FROM nutrition_daily_logs
		WHERE user_id = $1
		ORDER BY log_date DESC
		LIMIT $2`, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := make([]NutritionDailyLogRow, 0, limit)
	for rows.Next() {
		var l NutritionDailyLogRow
		if err := rows.Scan(
			&l.LogDate, &l.VegetableIntake, &l.ProteinIntake, &l.HydrationOK,
			&l.SugarExcess, &l.DietViolation, &l.Score, &l.Status,
		); err != nil {
			return nil, err
		}
		out = append(out, l)
	}
	return out, rows.Err()
}

// GetRecentScores returns the N most recent scores ordered by log_date DESC.
func (r *NutritionGuidanceRepository) GetRecentScores(ctx context.Context, userID string, n int) ([]int, error) {
	rows, err := r.db.Query(ctx, `
		SELECT score
		FROM nutrition_daily_logs
		WHERE user_id = $1
		ORDER BY log_date DESC
		LIMIT $2`, userID, n)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	scores := make([]int, 0, n)
	for rows.Next() {
		var s int
		if err := rows.Scan(&s); err != nil {
			return nil, err
		}
		scores = append(scores, s)
	}
	return scores, rows.Err()
}
