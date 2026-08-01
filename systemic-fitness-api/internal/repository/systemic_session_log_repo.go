package repository

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/fitcoach/api/internal/model"
)

type SystemicSessionLogRepository interface {
	Create(ctx context.Context, log *model.SystemicSessionLog) error
	GetByUserID(ctx context.Context, userID uuid.UUID) ([]model.SystemicSessionLog, error)
}

type systemicSessionLogRepository struct {
	db *pgxpool.Pool
}

func NewSystemicSessionLogRepository(db *pgxpool.Pool) SystemicSessionLogRepository {
	return &systemicSessionLogRepository{db: db}
}

func (r *systemicSessionLogRepository) Create(ctx context.Context, log *model.SystemicSessionLog) error {
	query := `
		INSERT INTO systemic_session_logs (
			id, user_id, session_date, session_number, medication_status,
			bp_systolic_pre, bp_diastolic_pre, hr_pre,
			bp_systolic_post, bp_diastolic_post, hr_post,
			delta_sbp, delta_dbp, delta_hr,
			symptom, symptom_notes, session_stopped, resolved_under_5_min,
			p1_score, p2_score, p3_score, total_systemic_score, systemic_status,
			dr_low_fiber_intake, dr_cakes_pastries, dr_starchy_foods, dr_sugary_drinks,
			dr_butter_fatty, dr_large_carb_portion, dr_seafood_organ_meats, dr_none_of_above,
			dr_food_detail, dr_risk_count, dr_risk_status, dr_risk_score,
			hydration, hydration_status, hydration_notes, hydration_score,
			sleep_recovery, sleep_status, sleep_notes, sleep_score,
			daily_activity, activity_status, activity_notes, activity_score,
			total_habit_score, lifestyle_status
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8,
			$9, $10, $11,
			$12, $13, $14,
			$15, $16, $17, $18,
			$19, $20, $21, $22, $23,
			$24, $25, $26, $27,
			$28, $29, $30, $31,
			$32, $33, $34, $35,
			$36, $37, $38, $39,
			$40, $41, $42, $43,
			$44, $45, $46, $47,
			$48, $49
		)
	`
	_, err := r.db.Exec(ctx, query,
		log.ID, log.UserID, log.SessionDate, log.SessionNumber, log.MedicationStatus,
		log.BPSystolicPre, log.BPDiastolicPre, log.HRPre,
		log.BPSystolicPost, log.BPDiastolicPost, log.HRPost,
		log.DeltaSBP, log.DeltaDBP, log.DeltaHR,
		log.Symptom, log.SymptomNotes, log.SessionStopped, log.ResolvedUnder5Min,
		log.P1Score, log.P2Score, log.P3Score, log.TotalSystemicScore, log.SystemicStatus,
		log.DrLowFiberIntake, log.DrCakesPastries, log.DrStarchyFoods, log.DrSugaryDrinks,
		log.DrButterFatty, log.DrLargeCarbPortion, log.DrSeafoodOrganMeats, log.DrNoneOfAbove,
		log.DrFoodDetail, log.DrRiskCount, log.DrRiskStatus, log.DrRiskScore,
		log.Hydration, log.HydrationStatus, log.HydrationNotes, log.HydrationScore,
		log.SleepRecovery, log.SleepStatus, log.SleepNotes, log.SleepScore,
		log.DailyActivity, log.ActivityStatus, log.ActivityNotes, log.ActivityScore,
		log.TotalHabitScore, log.LifestyleStatus,
	)
	return err
}

func (r *systemicSessionLogRepository) GetByUserID(ctx context.Context, userID uuid.UUID) ([]model.SystemicSessionLog, error) {
	query := `
		SELECT *
		FROM systemic_session_logs
		WHERE user_id = $1
		ORDER BY session_date DESC, created_at DESC
	`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return pgx.CollectRows(rows, pgx.RowToStructByName[model.SystemicSessionLog])
}
