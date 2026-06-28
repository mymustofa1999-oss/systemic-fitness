package model

// SF Master — Klasifikasi Kondisi Fisik & Kondisi Spesifik (Phase 1).
// Reference: SF_Master_Platform_Spec.docx §02 + halaman 168–181.

// FocusPillar enumerates the 3 SF training pillars.
type FocusPillar string

const (
	PillarFunctional        FocusPillar = "FC" // Functional Conditioning
	PillarCardiorespiratory FocusPillar = "CC" // Cardiorespiratory Conditioning
	PillarMetabolic         FocusPillar = "MC" // Metabolic Conditioning
)

func (p FocusPillar) IsValid() bool {
	switch p {
	case PillarFunctional, PillarCardiorespiratory, PillarMetabolic:
		return true
	}
	return false
}

// PhysicalStatusRouting describes what to do after Phase A Q1.
type PhysicalStatusRouting string

const (
	RoutingWaitlist                 PhysicalStatusRouting = "waitlist"
	RoutingPreventiveMovementTest   PhysicalStatusRouting = "preventive_movement_test"
	RoutingContinue                 PhysicalStatusRouting = "continue"
)

func (r PhysicalStatusRouting) IsValid() bool {
	switch r {
	case RoutingWaitlist, RoutingPreventiveMovementTest, RoutingContinue:
		return true
	}
	return false
}
