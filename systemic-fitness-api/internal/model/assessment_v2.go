package model

import (
	"encoding/json"
	"time"
)

// SF Assessment v2 — Phase A/B/C, Chronobiology Window, System Score 35/35/30.
// Reference: SF_Master_Platform_Spec.docx §03 (Assessment Flow), §04 (System
// Score), halaman 333–456 (Chronobiology Window per Kondisi).
//
// Coexists with v1 types (SleepInput / MovementInput / MetabolicInput).
// Distinguished at the row level by Assessment.Version = "v1" | "v2".

// ─── Versioning ─────────────────────────────────────────────────────

const (
	AssessmentVersionV1 = "v1"
	AssessmentVersionV2 = "v2"
)

// ─── Program Types (output of Phase A engine) ───────────────────────

type ProgramType string

const (
	ProgramConditionSpecific      ProgramType = "condition_specific"
	ProgramPreventive             ProgramType = "preventive"
	ProgramPerformanceWomen35_45  ProgramType = "performance_women_35_45"
	ProgramPerformanceWomen46_60  ProgramType = "performance_women_46_60"
	ProgramPerformanceMen35_45    ProgramType = "performance_men_35_45"
	ProgramPerformanceMen46_60    ProgramType = "performance_men_46_60"
	ProgramWaitlist               ProgramType = "waitlist"
)

func (p ProgramType) IsValid() bool {
	switch p {
	case ProgramConditionSpecific, ProgramPreventive,
		ProgramPerformanceWomen35_45, ProgramPerformanceWomen46_60,
		ProgramPerformanceMen35_45, ProgramPerformanceMen46_60,
		ProgramWaitlist:
		return true
	}
	return false
}

// ─── Phase A Input ──────────────────────────────────────────────────

// Q3 primary goal categories.
type PhaseAGoal string

const (
	GoalControlMedical    PhaseAGoal = "control_medical"     // Mengontrol kondisi medis
	GoalHormonalFeminine  PhaseAGoal = "hormonal_feminine"   // Performance Women
	GoalStaminaMasculine  PhaseAGoal = "stamina_masculine"   // Performance Men
)

type PhaseAGender string

const (
	GenderWomen PhaseAGender = "women"
	GenderMen   PhaseAGender = "men"
)

type PhaseAAgeBucket string

const (
	Age35to45 PhaseAAgeBucket = "35_45"
	Age46to60 PhaseAAgeBucket = "46_60"
)

// PhaseAInput captures the 3-question Phase A flow.
//
//   Q1 PhysicalStatusLevel: "level_0_1" | "level_2_3" | "level_4_5_perf"
//   Q2 HasMedicalCondition: true → ClassificationSlug + SpecificConditionSlug required
//                           false → user goes to Performance flow (Gender + AgeBucket)
//   Q3 PrimaryGoal:         conditional (only required when HasMedicalCondition && Level 4-5)
//
// MovementTest (squat / hip_hinge / overhead — 0..2 each, total max 6) is
// only required for the Preventive path (Level 4-5 + no medical condition).
// Score >=4 (i.e. >=60% of 6) = continue to Phase B; <=3 = book free 15-min
// online consultation per spec hal. 158.
type PhaseAInput struct {
	PhysicalStatusLevel    string         `json:"physical_status_level"           validate:"required,oneof=level_0_1 level_2_3 level_4_5_perf"`
	HasMedicalCondition    bool           `json:"has_medical_condition"`
	ClassificationSlug     *string        `json:"classification_slug,omitempty"   validate:"omitempty,min=2,max=64"`
	SpecificConditionSlug  *string        `json:"specific_condition_slug,omitempty" validate:"omitempty,min=2,max=80"`
	SeriousConditionNote   *string        `json:"serious_condition_note,omitempty"`
	PrimaryGoal            *PhaseAGoal    `json:"primary_goal,omitempty"          validate:"omitempty,oneof=control_medical hormonal_feminine stamina_masculine"`
	Gender                 *PhaseAGender  `json:"gender,omitempty"                validate:"omitempty,oneof=women men"`
	AgeBucket              *PhaseAAgeBucket `json:"age_bucket,omitempty"          validate:"omitempty,oneof=35_45 46_60"`
	MovementTest           *PhaseAMovementTest `json:"movement_test,omitempty"`
}

// Each gerakan: 0 = tidak bisa / nyeri, 1 = bisa dengan kompensasi, 2 = bisa penuh.
type PhaseAMovementTest struct {
	Squat    int `json:"squat"     validate:"min=0,max=2"`
	HipHinge int `json:"hip_hinge" validate:"min=0,max=2"`
	Overhead int `json:"overhead"  validate:"min=0,max=2"`
}

func (m PhaseAMovementTest) Total() int { return m.Squat + m.HipHinge + m.Overhead }

// ─── Phase B Input (Rest Audit + Chronobiology) ─────────────────────

// PhaseBInput stores the 10 sleep / chronobiology questions.
//
// Slug values follow the spec literally so seed/i18n can map UI copy to
// the engine's expectations.
type PhaseBInput struct {
	// B1 Slider 4.0..10.0 hour.
	DurationHours    float64 `json:"duration_hours"     validate:"required,gte=4,lte=10"`
	// B2 1=very irregular >2h, 2=sometimes 1-2h, 3=consistent.
	Consistency      int     `json:"consistency"        validate:"required,min=1,max=3"`
	// B3 1=<15 mnt, 2=15-30, 3=30-45, 4=>45.
	SleepLatency     int     `json:"sleep_latency"      validate:"required,min=1,max=4"`
	// B4 1=lelah/pusing, 2=biasa, 3=segar.
	MorningReadiness int     `json:"morning_readiness"  validate:"required,min=1,max=3"`
	// B5 1=tidak pernah, 2=1-2x, 3=3+x, 4=sering & sulit tidur lagi.
	WakeFrequency    int     `json:"wake_frequency"     validate:"required,min=1,max=4"`
	// B6 1=gadget/makan berat, 2=campuran, 3=relaksasi.
	PreSleepHabit    int     `json:"pre_sleep_habit"    validate:"required,min=1,max=3"`
	// B7 1=<21:00, 2=21-22, 3=22-23, 4=23-00, 5=>00:00.
	BedtimeBucket    int     `json:"bedtime_bucket"     validate:"required,min=1,max=5"`
	// B8 1=<05:00, 2=05-06, 3=06-07, 4=07-08, 5=>08:00.
	WakeTimeBucket   int     `json:"wake_time_bucket"   validate:"required,min=1,max=5"`
	// B9 enumerated activity profile slug.
	ActivityProfile  string  `json:"activity_profile"   validate:"required,oneof=executive creative traveller homemaker shift_worker mixed"`
	// B10 1=<18:00, 2=18-19, 3=19-20, 4=>20:00, 5=tidak menentu.
	DinnerTime       int     `json:"dinner_time"        validate:"required,min=1,max=5"`
}

// ─── Phase C Input (Nutrition Assessment) ───────────────────────────

type PhaseCInput struct {
	// C1 1=3 kali besar, 2=4-5 kali kecil, 3=skip irregular, 4=IF terencana, 5=tidak menentu.
	MealPattern   int      `json:"meal_pattern"     validate:"required,min=1,max=5"`
	// C2 1=karbo dominan, 2=protein fokus, 3=sayur dominan, 4=campuran seimbang, 5=ultraprocessed.
	FoodDominance int      `json:"food_dominance"   validate:"required,min=1,max=5"`
	// C3 1=<4 gelas, 2=4-6, 3=7-8, 4=>8.
	Hydration     int      `json:"hydration"        validate:"required,min=1,max=4"`
	// C4 multi-select tags. Allowed slugs:
	//     coffee, sweet_drinks, soda_energy, alcohol, fried, high_salt,
	//     organ_meat, seafood, dairy, fermented.
	RoutineFoods  []string `json:"routine_foods,omitempty"  validate:"omitempty,dive,min=2,max=32"`
	// C5 multi-select + open text.
	Restrictions  []string `json:"restrictions,omitempty"   validate:"omitempty,dive,max=160"`
	RestrictionNote *string `json:"restriction_note,omitempty"`
	// C6 multi-select supplements.
	Supplements   []string `json:"supplements,omitempty"    validate:"omitempty,dive,max=160"`
	SupplementNote *string `json:"supplement_note,omitempty"`
	// C7 single-select goal slug. Allowed: blood_sugar, anti_inflammation,
	//     energy_vitality, hormonal_balance, weight, muscle_recovery, organ_health.
	NutritionGoal string   `json:"nutrition_goal"  validate:"required,oneof=blood_sugar anti_inflammation energy_vitality hormonal_balance weight muscle_recovery organ_health"`
}

// ─── Chronobiology Window ───────────────────────────────────────────

// ChronobiologyWindow is the resolved training-time recommendation.
// All times are "HH:MM" 24h local time. Empty fields mean "no
// alternative" or "no override applied".
type ChronobiologyWindow struct {
	IdealStart     string `json:"ideal_start"`
	IdealEnd       string `json:"ideal_end"`
	AltStart       string `json:"alt_start,omitempty"`
	AltEnd         string `json:"alt_end,omitempty"`
	Avoid          string `json:"avoid,omitempty"`
	OverrideReason string `json:"override_reason,omitempty"`
	HardCap        string `json:"hard_cap,omitempty"` // e.g. "21:00"
}

// ─── Score Weights ──────────────────────────────────────────────────

// SystemScoreWeights mirrors the system_score_weights row.
// MovementPct + NutritionPct + RestPct must sum to 100.
type SystemScoreWeights struct {
	ID           string    `json:"id"`
	Name         string    `json:"name"`
	MovementPct  int16     `json:"movement_pct"`
	NutritionPct int16     `json:"nutrition_pct"`
	RestPct      int16     `json:"rest_pct"`
	IsActive     bool      `json:"is_active"`
	Notes        *string   `json:"notes,omitempty"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// DefaultSystemScoreWeights is used when no row is active in the DB.
func DefaultSystemScoreWeights() SystemScoreWeights {
	return SystemScoreWeights{
		Name:         "SF Default",
		MovementPct:  35,
		NutritionPct: 35,
		RestPct:      30,
		IsActive:     true,
	}
}

// ─── v2 Computed Result ─────────────────────────────────────────────

// SystemScoreV2 carries the breakdown for the SF v2 result page.
type SystemScoreV2 struct {
	Movement  *float64 `json:"movement,omitempty"`  // nullable — populated when sessions accrue
	Nutrition float64  `json:"nutrition"`
	Rest      float64  `json:"rest"`
	Total     float64  `json:"total"`
	Weights   SystemScoreWeights `json:"weights"`
}

// AssessmentV2 represents the v2 row.  Fields it shares with v1
// (id/user_id/status/created_at/...) are intentionally duplicated here
// so the v2 service can return a self-contained DTO without leaking v1
// concerns.
type AssessmentV2 struct {
	ID                    string                `json:"id"`
	UserID                *string               `json:"user_id,omitempty"`
	Version               string                `json:"version"` // always "v2"
	Status                AssessmentStatus      `json:"status"`

	// Inputs
	PhaseA                PhaseAInput           `json:"phase_a"`
	PhaseB                *PhaseBInput          `json:"phase_b,omitempty"`
	PhaseC                *PhaseCInput          `json:"phase_c,omitempty"`

	// Phase A outputs
	ClassificationID      *string               `json:"classification_id,omitempty"`
	SpecificConditionID   *string               `json:"specific_condition_id,omitempty"`
	PhysicalStatusLevel   string                `json:"physical_status_level"`
	ProgramType           ProgramType           `json:"program_type"`

	// Phase B output
	ChronobiologyWindow   *ChronobiologyWindow  `json:"chronobiology_window,omitempty"`

	// Computed scores (Phase B+C)
	RestScore             *float64              `json:"rest_score,omitempty"`
	NutritionScore        *float64              `json:"nutrition_score,omitempty"`
	MovementScore         *float64              `json:"movement_score,omitempty"`
	SystemScore           *float64              `json:"system_score,omitempty"`
	Weights               *SystemScoreWeights   `json:"weights,omitempty"`

	Flags                 []string              `json:"flags"`
	Recommendations       []string              `json:"recommendations"`
	ProgramMap            *ProgramMapRecommendation `json:"program_map,omitempty"`

	CreatedAt             time.Time             `json:"created_at"`
	UpdatedAt             time.Time             `json:"updated_at"`
}

// ─── JSON helpers (used by repo) ────────────────────────────────────

// MarshalJSONOrNil returns json.RawMessage of v, or nil if v is nil.
func MarshalJSONOrNil(v any) (json.RawMessage, error) {
	if v == nil {
		return nil, nil
	}
	return json.Marshal(v)
}
