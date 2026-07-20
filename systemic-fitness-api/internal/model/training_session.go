package model

import "time"

type TrainingSessionLog struct {
	ID              string     `json:"id"`
	UserID          string     `json:"user_id"`
	PeriodName      string     `json:"period_name"`
	SessionNumber   int        `json:"session_number"`
	Date            *time.Time `json:"date"`
	TookMedicine    bool       `json:"took_medicine"`
	LastMealHours   *float64   `json:"last_meal_hours"`
	LastMealFood    *string    `json:"last_meal_food"`
	BPPreSystolic   *int       `json:"bp_pre_systolic"`
	BPPreDiastolic  *int       `json:"bp_pre_diastolic"`
	HRPre           *int       `json:"hr_pre"`
	BPPostSystolic  *int       `json:"bp_post_systolic"`
	BPPostDiastolic *int       `json:"bp_post_diastolic"`
	HRPost          *int       `json:"hr_post"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}
