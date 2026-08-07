package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"

	"systemic-fitness-api/internal/model"
)

type QuarterlyAssessmentRepository interface {
	Create(ctx context.Context, assessment *model.QuarterlyAssessment) error
	GetByClientID(ctx context.Context, clientID uuid.UUID) ([]model.QuarterlyAssessment, error)
}

type quarterlyAssessmentRepository struct {
	db *sqlx.DB
}

func NewQuarterlyAssessmentRepository(db *sqlx.DB) QuarterlyAssessmentRepository {
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
			:client_id, :quarter, :period_range, :current_level, :functional_criteria_met,
			:movement_quality_met, :avg_systemic_score, :score_status_met, :decision, :new_level,
			:height_cm, :weight_kg, :gender, :bmi, :bmi_category,
			:waist_circumference_cm, :waist_status, :medical_condition, :lab_report_link, :review_date
		) RETURNING id, created_at, updated_at
	`
	stmt, err := r.db.PrepareNamedContext(ctx, query)
	if err != nil {
		return fmt.Errorf("prepare named: %w", err)
	}
	defer stmt.Close()

	if err := stmt.GetContext(ctx, assessment, assessment); err != nil {
		return fmt.Errorf("execute and get: %w", err)
	}

	return nil
}

func (r *quarterlyAssessmentRepository) GetByClientID(ctx context.Context, clientID uuid.UUID) ([]model.QuarterlyAssessment, error) {
	var assessments []model.QuarterlyAssessment
	query := `
		SELECT * FROM quarterly_assessments 
		WHERE client_id = $1 
		ORDER BY created_at ASC
	`
	if err := r.db.SelectContext(ctx, &assessments, query, clientID); err != nil {
		return nil, fmt.Errorf("select context: %w", err)
	}

	return assessments, nil
}
