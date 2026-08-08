package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/model"
)

type QuarterlyAssessmentRepository interface {
	Create(ctx context.Context, assessment *model.QuarterlyAssessment) error
	GetByClientID(ctx context.Context, clientID uuid.UUID) ([]model.QuarterlyAssessment, error)
}

type quarterlyAssessmentRepository struct {
	db *pgxpool.Pool
}

func NewQuarterlyAssessmentRepository(db *pgxpool.Pool) QuarterlyAssessmentRepository {
	return &quarterlyAssessmentRepository{db: db}
}

func (r *quarterlyAssessmentRepository) Create(ctx context.Context, assessment *model.QuarterlyAssessment) error {
	query := `
		INSERT INTO quarterly_assessments (
			client_id, quarter, period_range, current_level, functional_criteria_met,
			movement_quality_met, avg_systemic_score, score_status_met, decision, new_level,
			height_cm, weight_kg, gender, bmi, bmi_category,
			waist_circumference_cm, waist_status, medical_condition, lab_report_link, review_date
		) VALUES (
			$1, $2, $3, $4, $5,
			$6, $7, $8, $9, $10,
			$11, $12, $13, $14, $15,
			$16, $17, $18, $19, $20
		) RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query,
		assessment.ClientID, assessment.Quarter, assessment.PeriodRange, assessment.CurrentLevel, assessment.FunctionalCriteriaMet,
		assessment.MovementQualityMet, assessment.AvgSystemicScore, assessment.ScoreStatusMet, assessment.Decision, assessment.NewLevel,
		assessment.HeightCm, assessment.WeightKg, assessment.Gender, assessment.BMI, assessment.BMICategory,
		assessment.WaistCircumferenceCm, assessment.WaistStatus, assessment.MedicalCondition, assessment.LabReportLink, assessment.ReviewDate,
	).Scan(&assessment.ID, &assessment.CreatedAt, &assessment.UpdatedAt)

	if err != nil {
		return fmt.Errorf("execute and get: %w", err)
	}

	return nil
}

func (r *quarterlyAssessmentRepository) GetByClientID(ctx context.Context, clientID uuid.UUID) ([]model.QuarterlyAssessment, error) {
	var assessments []model.QuarterlyAssessment
	query := `
		SELECT id, client_id, quarter, period_range, current_level, functional_criteria_met,
		movement_quality_met, avg_systemic_score, score_status_met, decision, new_level,
		height_cm, weight_kg, gender, bmi, bmi_category, waist_circumference_cm, waist_status,
		medical_condition, lab_report_link, review_date, created_at, updated_at
		FROM quarterly_assessments 
		WHERE client_id = $1 
		ORDER BY created_at ASC
	`
	rows, err := r.db.Query(ctx, query, clientID)
	if err != nil {
		return nil, fmt.Errorf("query context: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var a model.QuarterlyAssessment
		err := rows.Scan(
			&a.ID, &a.ClientID, &a.Quarter, &a.PeriodRange, &a.CurrentLevel, &a.FunctionalCriteriaMet,
			&a.MovementQualityMet, &a.AvgSystemicScore, &a.ScoreStatusMet, &a.Decision, &a.NewLevel,
			&a.HeightCm, &a.WeightKg, &a.Gender, &a.BMI, &a.BMICategory, &a.WaistCircumferenceCm, &a.WaistStatus,
			&a.MedicalCondition, &a.LabReportLink, &a.ReviewDate, &a.CreatedAt, &a.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan: %w", err)
		}
		assessments = append(assessments, a)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows err: %w", err)
	}

	return assessments, nil
}
