package model

import (
	"time"

	"github.com/google/uuid"
)

type SystemicSessionLog struct {
	ID                  uuid.UUID  `json:"id" db:"id"`
	UserID              uuid.UUID  `json:"user_id" db:"user_id"`
	SessionDate         string     `json:"session_date" db:"session_date"` // YYYY-MM-DD
	SessionNumber       int        `json:"session_number" db:"session_number"`
	MedicationStatus    string     `json:"medication_status" db:"medication_status"`
	
	BPSystolicPre       *int       `json:"bp_systolic_pre" db:"bp_systolic_pre"`
	BPDiastolicPre      *int       `json:"bp_diastolic_pre" db:"bp_diastolic_pre"`
	HRPre               *int       `json:"hr_pre" db:"hr_pre"`
	BPSystolicPost      *int       `json:"bp_systolic_post" db:"bp_systolic_post"`
	BPDiastolicPost     *int       `json:"bp_diastolic_post" db:"bp_diastolic_post"`
	HRPost              *int       `json:"hr_post" db:"hr_post"`
	
	DeltaSBP            *int       `json:"delta_sbp" db:"delta_sbp"`
	DeltaDBP            *int       `json:"delta_dbp" db:"delta_dbp"`
	DeltaHR             *int       `json:"delta_hr" db:"delta_hr"`
	
	Symptom             string     `json:"symptom" db:"symptom"`
	SymptomNotes        string     `json:"symptom_notes" db:"symptom_notes"`
	SessionStopped      bool       `json:"session_stopped" db:"session_stopped"`
	ResolvedUnder5Min   bool       `json:"resolved_under_5_min" db:"resolved_under_5_min"`
	
	P1Score             *float64   `json:"p1_score" db:"p1_score"`
	P2Score             *float64   `json:"p2_score" db:"p2_score"`
	P3Score             *float64   `json:"p3_score" db:"p3_score"`
	TotalSystemicScore  *float64   `json:"total_systemic_score" db:"total_systemic_score"`
	SystemicStatus      string     `json:"systemic_status" db:"systemic_status"`
	
	DrLowFiberIntake    bool       `json:"dr_low_fiber_intake" db:"dr_low_fiber_intake"`
	DrCakesPastries     bool       `json:"dr_cakes_pastries" db:"dr_cakes_pastries"`
	DrStarchyFoods      bool       `json:"dr_starchy_foods" db:"dr_starchy_foods"`
	DrSugaryDrinks      bool       `json:"dr_sugary_drinks" db:"dr_sugary_drinks"`
	DrButterFatty       bool       `json:"dr_butter_fatty" db:"dr_butter_fatty"`
	DrLargeCarbPortion  bool       `json:"dr_large_carb_portion" db:"dr_large_carb_portion"`
	DrSeafoodOrganMeats bool       `json:"dr_seafood_organ_meats" db:"dr_seafood_organ_meats"`
	DrNoneOfAbove       bool       `json:"dr_none_of_above" db:"dr_none_of_above"`
	DrFoodDetail        string     `json:"dr_food_detail" db:"dr_food_detail"`
	DrRiskCount         int        `json:"dr_risk_count" db:"dr_risk_count"`
	DrRiskStatus        string     `json:"dr_risk_status" db:"dr_risk_status"`
	DrRiskScore         *float64   `json:"dr_risk_score" db:"dr_risk_score"`
	
	Hydration           string     `json:"hydration" db:"hydration"`
	HydrationStatus     string     `json:"hydration_status" db:"hydration_status"`
	HydrationNotes      string     `json:"hydration_notes" db:"hydration_notes"`
	HydrationScore      *float64   `json:"hydration_score" db:"hydration_score"`
	
	SleepRecovery       string     `json:"sleep_recovery" db:"sleep_recovery"`
	SleepStatus         string     `json:"sleep_status" db:"sleep_status"`
	SleepNotes          string     `json:"sleep_notes" db:"sleep_notes"`
	SleepScore          *float64   `json:"sleep_score" db:"sleep_score"`
	
	DailyActivity       string     `json:"daily_activity" db:"daily_activity"`
	ActivityStatus      string     `json:"activity_status" db:"activity_status"`
	ActivityNotes       string     `json:"activity_notes" db:"activity_notes"`
	ActivityScore       *float64   `json:"activity_score" db:"activity_score"`
	
	TotalHabitScore     *float64   `json:"total_habit_score" db:"total_habit_score"`
	LifestyleStatus     string     `json:"lifestyle_status" db:"lifestyle_status"`
	
	CreatedAt           time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt           time.Time  `json:"updated_at" db:"updated_at"`
}
