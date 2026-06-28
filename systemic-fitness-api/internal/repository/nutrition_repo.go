package repository

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type NutritionRepository struct {
	db *pgxpool.Pool
}

func NewNutritionRepository(db *pgxpool.Pool) *NutritionRepository {
	return &NutritionRepository{db: db}
}

type MealPlan struct {
	ID             string    `json:"id"`
	Name           string    `json:"name"`
	Description    *string   `json:"description,omitempty"`
	DailyCalories  *int      `json:"daily_calories,omitempty"`
	ProteinG       *int      `json:"protein_g,omitempty"`
	CarbsG         *int      `json:"carbs_g,omitempty"`
	FatG           *int      `json:"fat_g,omitempty"`
	CreatedBy      *string   `json:"created_by,omitempty"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type NutritionLog struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	LoggedAt  time.Time `json:"logged_at"`
	MealType  string    `json:"meal_type"`
	FoodName  string    `json:"food_name"`
	Calories  *int      `json:"calories,omitempty"`
	ProteinG  *float64  `json:"protein_g,omitempty"`
	CarbsG    *float64  `json:"carbs_g,omitempty"`
	FatG      *float64  `json:"fat_g,omitempty"`
	PhotoURL  *string   `json:"photo_url,omitempty"`
}

func (r *NutritionRepository) CreateMealPlan(ctx context.Context, mp *MealPlan) error {
	query := `
		INSERT INTO meal_plans (name, description, daily_calories, protein_g, carbs_g, fat_g, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query,
		mp.Name, mp.Description, mp.DailyCalories, mp.ProteinG, mp.CarbsG, mp.FatG, mp.CreatedBy,
	).Scan(&mp.ID, &mp.CreatedAt, &mp.UpdatedAt)
}

func (r *NutritionRepository) ListMealPlans(ctx context.Context, params model.PaginationParams) ([]MealPlan, int, error) {
	var total int
	if err := r.db.QueryRow(ctx, `SELECT COUNT(*) FROM meal_plans`).Scan(&total); err != nil {
		return nil, 0, err
	}

	rows, err := r.db.Query(ctx, `
		SELECT id, name, description, daily_calories, protein_g, carbs_g, fat_g, created_by, created_at, updated_at
		FROM meal_plans ORDER BY created_at DESC LIMIT $1 OFFSET $2`,
		params.Limit, params.Offset())
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var plans []MealPlan
	for rows.Next() {
		var mp MealPlan
		if err := rows.Scan(&mp.ID, &mp.Name, &mp.Description, &mp.DailyCalories,
			&mp.ProteinG, &mp.CarbsG, &mp.FatG, &mp.CreatedBy, &mp.CreatedAt, &mp.UpdatedAt); err != nil {
			return nil, 0, err
		}
		plans = append(plans, mp)
	}
	return plans, total, nil
}

func (r *NutritionRepository) LogNutrition(ctx context.Context, log *NutritionLog) error {
	query := `
		INSERT INTO nutrition_logs (user_id, meal_type, food_name, calories, protein_g, carbs_g, fat_g, photo_url)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, logged_at`
	return r.db.QueryRow(ctx, query,
		log.UserID, log.MealType, log.FoodName, log.Calories,
		log.ProteinG, log.CarbsG, log.FatG, log.PhotoURL,
	).Scan(&log.ID, &log.LoggedAt)
}

func (r *NutritionRepository) GetDailyLogs(ctx context.Context, userID, date string) ([]NutritionLog, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, user_id, logged_at, meal_type, food_name, calories, protein_g, carbs_g, fat_g, photo_url
		FROM nutrition_logs
		WHERE user_id = $1 AND logged_at::DATE = $2::DATE
		ORDER BY logged_at`, userID, date)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var logs []NutritionLog
	for rows.Next() {
		var l NutritionLog
		if err := rows.Scan(&l.ID, &l.UserID, &l.LoggedAt, &l.MealType, &l.FoodName,
			&l.Calories, &l.ProteinG, &l.CarbsG, &l.FatG, &l.PhotoURL); err != nil {
			return nil, err
		}
		logs = append(logs, l)
	}
	return logs, nil
}
