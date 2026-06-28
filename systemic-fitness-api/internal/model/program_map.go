package model

// SequenceFormula represents the recommended conditioning duration (in minutes)
// based on the client's medical condition.
type SequenceFormula struct {
	FCMins int    `json:"fc_mins"`
	CCMins int    `json:"cc_mins"`
	MCMins int    `json:"mc_mins"`
	Notes  string `json:"notes,omitempty"`
}

// LoadWeight represents the recommended weight load (in kg) for upper and lower body
// exercises based on the client's gender, age, and height.
type LoadWeight struct {
	UpperBodyKg float64 `json:"upper_body_kg"`
	LowerBodyKg float64 `json:"lower_body_kg"`
}

// ProgramMapRecommendation groups the formula and the load weight together.
type ProgramMapRecommendation struct {
	Formula    SequenceFormula `json:"formula"`
	CardioLoad LoadWeight      `json:"cardio_load"`
	MetabLoad  LoadWeight      `json:"metabolic_load"`
}
