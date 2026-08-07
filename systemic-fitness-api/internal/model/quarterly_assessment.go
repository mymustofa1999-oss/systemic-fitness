package model

import (
	"time"

	"github.com/google/uuid"
)

type QuarterlyAssessment struct {
	ID                    uuid.UUID `json:"id" db:"id"`
	ClientID              uuid.UUID `json:"client_id" db:"client_id" validate:"required"`
	Quarter               string    `json:"quarter" db:"quarter" validate:"required"`
	PeriodRange           string    `json:"period_range" db:"period_range"`
	CurrentLevel          int       `json:"current_level" db:"current_level" validate:"required,min=1,max=6"`
	FunctionalCriteriaMet bool      `json:"functional_criteria_met" db:"functional_criteria_met"`
	MovementQualityMet    bool      `json:"movement_quality_met" db:"movement_quality_met"`
	AvgSystemicScore      float64   `json:"avg_systemic_score" db:"avg_systemic_score"`
	ScoreStatusMet        bool      `json:"score_status_met" db:"score_status_met"`
	Decision              string    `json:"decision" db:"decision" validate:"required"`
	NewLevel              *int      `json:"new_level" db:"new_level"`

	HeightCm             *float64 `json:"height_cm" db:"height_cm"`
	WeightKg             *float64 `json:"weight_kg" db:"weight_kg"`
	Gender               *string  `json:"gender" db:"gender"`
	BMI                  *float64 `json:"bmi" db:"bmi"`
	BMICategory          *string  `json:"bmi_category" db:"bmi_category"`
	WaistCircumferenceCm *float64 `json:"waist_circumference_cm" db:"waist_circumference_cm"`
	WaistStatus          *string  `json:"waist_status" db:"waist_status"`
	MedicalCondition     *string  `json:"medical_condition" db:"medical_condition"`
	LabReportLink        *string  `json:"lab_report_link" db:"lab_report_link"`

	ReviewDate time.Time `json:"review_date" db:"review_date" validate:"required"`
	CreatedAt  time.Time `json:"created_at" db:"created_at"`
	UpdatedAt  time.Time `json:"updated_at" db:"updated_at"`
}
