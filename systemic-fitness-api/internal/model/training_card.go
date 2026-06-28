package model

import "time"

// TrainingCardResponse is the root structure returned to the client
// containing the dynamically generated Training Card based on their Level.
type TrainingCardResponse struct {
	ID           string           `json:"id"`
	CustomerID   string           `json:"customer_id"`
	CustomerName string           `json:"customer_name,omitempty"`
	Level        string           `json:"level"`
	Notes        *string          `json:"notes,omitempty"`
	CreatedBy    *string          `json:"created_by,omitempty"`
	CreatedAt    time.Time        `json:"created_at"`
	UpdatedAt    time.Time        `json:"updated_at"`
	Sequences    []ClientSequence `json:"sequences"`

	FullProgram []ProgramCategory `json:"full_program"`
	DailyReset  []ProgramCategory `json:"daily_reset"`
}

// ProgramCategory groups sets under a specific workout type (e.g. FUNCTIONAL).
type ProgramCategory struct {
	Type     string        `json:"type"`     // "FUNCTIONAL", "CARDIO", "METABOLIC"
	Duration string        `json:"duration"` // "15'", "30'", "10'"
	Sets     []TrainingSet `json:"sets"`
}

// TrainingSet represents a specific set (e.g. "Set 1") inside a category.
type TrainingSet struct {
	SetName        string             `json:"set_name"`      // "Set 1"
	DurationMins   int                `json:"duration_mins"` // 5, 10
	BpmRange       string             `json:"bpm_range"`     // "80-100" (Calculated dynamically)
	EquipmentUpper string             `json:"equipment_upper"`
	EquipmentLower string             `json:"equipment_lower"`
	Tags           []string           `json:"tags"`          // ["Dynamic", "Bodyweight / TRX"]
	Movements      []TrainingMovement `json:"movements"`
}

// TrainingMovement represents a single exercise inside a set.
type TrainingMovement struct {
	ID           string   `json:"id"`
	Sequence     int      `json:"sequence"`
	Title        string   `json:"title"`         // e.g. "Arm Rotation – Wide Step Touch"
	VideoUrl     string   `json:"video_url"`     // Usually retrieved from Digital Library (dl_movement)
	MovementTag  string   `json:"movement_tag"`  // e.g. "Diafragma 1:1" or "Core" or empty string
	AllowedTiers []string `json:"allowed_tiers"` // subscription tiers allowed to access; empty = all
}

type ClientSequence struct {
	ID                  string      `json:"id"`
	TrainerCardID       string      `json:"trainer_card_id"`
	ProgramCategoryID   string      `json:"program_category_id"`
	ProgramCategoryName string      `json:"program_category_name,omitempty"`
	ProgramCategoryCode string      `json:"program_category_code,omitempty"`
	Duration            *string     `json:"duration,omitempty"`
	SortOrder           int         `json:"sort_order"`
	CreatedAt           time.Time   `json:"created_at"`
	UpdatedAt           time.Time   `json:"updated_at"`
	Sets                []ClientSet `json:"sets"`
}

type ClientSet struct {
	ID             string       `json:"id"`
	SequenceID     string       `json:"sequence_id"`
	SetNumber      int          `json:"set_number"`
	Duration       *string      `json:"duration,omitempty"`
	EquipmentUpper *string      `json:"equipment_upper,omitempty"`
	EquipmentLower *string      `json:"equipment_lower,omitempty"`
	TypeID         *string      `json:"type_id,omitempty"`
	TypeName       *string      `json:"type_name,omitempty"`
	BPM            *string      `json:"bpm,omitempty"`
	ExtraLoad      *string      `json:"extra_load,omitempty"`
	Notes          *string      `json:"notes,omitempty"`
	SortOrder      int          `json:"sort_order"`
	CreatedAt      time.Time    `json:"created_at"`
	UpdatedAt      time.Time    `json:"updated_at"`
	Items          []ClientItem `json:"items"`
}

type ClientItem struct {
	ID             string    `json:"id"`
	SetID          string    `json:"set_id"`
	MovementID     *string   `json:"movement_id,omitempty"`
	MovementName   *string   `json:"movement_name,omitempty"`
	BodyPart       string    `json:"body_part"`
	Equipment      *string   `json:"equipment,omitempty"`
	Reps           *int      `json:"reps,omitempty"`
	SetsCount      *int      `json:"sets_count,omitempty"`
	SortOrder      int       `json:"sort_order"`
	VideoURLMale   *string   `json:"video_url_male,omitempty"`
	VideoURLFemale *string   `json:"video_url_female,omitempty"`
	AllowedTiers   []string  `json:"allowed_tiers"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}
