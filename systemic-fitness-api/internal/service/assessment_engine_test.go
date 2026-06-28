package service

import (
	"testing"

	"github.com/fitcoach/api/internal/model"
)

// ════════════════════════════════════════════════════════════════════
//  Assessment Engine Tests
//
//  These tests pin every formula in the spec. If a formula needs to
//  change, update both assessment_engine.go AND the matching test.
// ════════════════════════════════════════════════════════════════════

func ptrInt(v int) *int { return &v }

func TestComputeSleepScore_Optimal(t *testing.T) {
	in := model.SleepInput{
		DurationHours:    8,    // 25
		Consistency:      3,    // 30
		LatencyMinutes:   10,   // 15
		MorningReadiness: 3,    // (used by recovery)
		WakeFrequency:    0,    // 15
		PreSleepHabit:    3,    // 15
	}
	got := ComputeSleepScore(in)
	want := 100
	if got != want {
		t.Fatalf("ComputeSleepScore optimal: got=%d want=%d", got, want)
	}
}

func TestComputeSleepScore_Critical(t *testing.T) {
	in := model.SleepInput{
		DurationHours:    4,    // 10
		Consistency:      1,    // 10
		LatencyMinutes:   60,   // 5
		MorningReadiness: 1,
		WakeFrequency:    5,    // 5
		PreSleepHabit:    1,    // 5
	}
	got := ComputeSleepScore(in)
	want := 35
	if got != want {
		t.Fatalf("ComputeSleepScore critical: got=%d want=%d", got, want)
	}
}

func TestComputeRecoveryScore(t *testing.T) {
	in := model.SleepInput{
		DurationHours:    7,  // duration_pts = 25
		Consistency:      2,  // not used
		LatencyMinutes:   15, // 15
		MorningReadiness: 3,  // 60
		WakeFrequency:    0,  // 15
		PreSleepHabit:    2,  // not used
	}
	got := ComputeRecoveryScore(in)
	want := 100 // 60+15+15+25 = 115 -> clamped to 100
	if got != want {
		t.Fatalf("ComputeRecoveryScore: got=%d want=%d", got, want)
	}
}

func TestComputeMovementScore_Stable(t *testing.T) {
	in := model.MovementInput{Squat: 3, HipHinge: 3, Overhead: 3}
	// (90+105+105)/3 = 100
	if got := ComputeMovementScore(in); got != 100 {
		t.Fatalf("ComputeMovementScore stable: got=%d want=100", got)
	}
}

func TestComputeMovementScore_Dysfunction(t *testing.T) {
	in := model.MovementInput{Squat: 1, HipHinge: 1, Overhead: 1}
	// (30+35+35)/3 = 33
	if got := ComputeMovementScore(in); got != 33 {
		t.Fatalf("ComputeMovementScore dysfunction: got=%d want=33", got)
	}
}

func TestComputeMetabolicScore_Efficient(t *testing.T) {
	in := model.MetabolicInput{HbA1c: 5.2, LDL: 90, Triglyceride: 120}
	// 35+30+35 = 100
	if got := ComputeMetabolicScore(in); got != 100 {
		t.Fatalf("ComputeMetabolicScore efficient: got=%d want=100", got)
	}
}

func TestComputeMetabolicScore_Dysregulated(t *testing.T) {
	in := model.MetabolicInput{HbA1c: 7.2, LDL: 160, Triglyceride: 250}
	// 10+10+10 = 30
	if got := ComputeMetabolicScore(in); got != 30 {
		t.Fatalf("ComputeMetabolicScore dysregulated: got=%d want=30", got)
	}
}

func TestComputeSystemScore_Free(t *testing.T) {
	// sleep=80, movement=60 -> 80*0.5 + 60*0.5 = 70
	if got := ComputeSystemScore(80, 60, nil); got != 70 {
		t.Fatalf("ComputeSystemScore free: got=%d want=70", got)
	}
}

func TestComputeSystemScore_Paid(t *testing.T) {
	// sleep=80, movement=60, met=100
	// 80*0.4 + 60*0.3 + 100*0.3 = 32 + 18 + 30 = 80
	met := 100
	if got := ComputeSystemScore(80, 60, &met); got != 80 {
		t.Fatalf("ComputeSystemScore paid: got=%d want=80", got)
	}
}

func TestClassifySleep(t *testing.T) {
	cases := map[int]model.Classification{
		100: model.ClassOptimal,
		80:  model.ClassOptimal,
		79:  model.ClassCompromised,
		60:  model.ClassCompromised,
		59:  model.ClassCritical,
		0:   model.ClassCritical,
	}
	for score, want := range cases {
		if got := ClassifySleep(score); got != want {
			t.Errorf("ClassifySleep(%d): got=%s want=%s", score, got, want)
		}
	}
}

func TestClassifyMovement(t *testing.T) {
	if ClassifyMovement(85) != model.ClassStable {
		t.Errorf("expected stable for 85")
	}
	if ClassifyMovement(70) != model.ClassCompensation {
		t.Errorf("expected compensation for 70")
	}
	if ClassifyMovement(40) != model.ClassDysfunction {
		t.Errorf("expected dysfunction for 40")
	}
}

func TestClassifyMetabolic(t *testing.T) {
	if ClassifyMetabolic(90) != model.ClassEfficient {
		t.Errorf("expected efficient for 90")
	}
	if ClassifyMetabolic(65) != model.ClassAtRisk {
		t.Errorf("expected at_risk for 65")
	}
	if ClassifyMetabolic(45) != model.ClassDysregulated {
		t.Errorf("expected dysregulated for 45")
	}
}

func TestGenerateFlags_HighInjuryRisk(t *testing.T) {
	flags := GenerateFlags(
		model.SleepInput{DurationHours: 8, Consistency: 3, MorningReadiness: 3, PreSleepHabit: 3},
		model.MovementInput{Squat: 1, HipHinge: 2, Overhead: 2},
		nil,
	)
	if len(flags) != 1 || flags[0] != FlagHighInjuryRisk {
		t.Fatalf("expected HIGH_INJURY_RISK only, got %v", flags)
	}
}

func TestGenerateFlags_RecoveryAlert(t *testing.T) {
	flags := GenerateFlags(
		model.SleepInput{DurationHours: 5, Consistency: 1, MorningReadiness: 1, WakeFrequency: 3, PreSleepHabit: 1},
		model.MovementInput{Squat: 2, HipHinge: 2, Overhead: 2},
		nil,
	)
	found := false
	for _, f := range flags {
		if f == FlagRecoveryAlert {
			found = true
		}
	}
	if !found {
		t.Fatalf("expected RECOVERY_ALERT, got %v", flags)
	}
}

func TestGenerateFlags_MetabolicRedFlag(t *testing.T) {
	met := model.MetabolicInput{HbA1c: 7.0, LDL: 150, Triglyceride: 180}
	flags := GenerateFlags(
		model.SleepInput{DurationHours: 8, Consistency: 3, MorningReadiness: 3, PreSleepHabit: 3},
		model.MovementInput{Squat: 2, HipHinge: 2, Overhead: 2},
		&met,
	)
	found := false
	for _, f := range flags {
		if f == FlagMetabolicRedFlag {
			found = true
		}
	}
	if !found {
		t.Fatalf("expected METABOLIC_RED_FLAG, got %v", flags)
	}
}

func TestGenerateInsight_Recovery(t *testing.T) {
	scores := model.AssessmentScores{Sleep: 50, Movement: 90, Metabolic: ptrInt(90), System: 70}
	if got := GenerateInsight(scores); got != InsightRecoveryDysfunction {
		t.Errorf("got=%q want=%q", got, InsightRecoveryDysfunction)
	}
}

func TestGenerateInsight_Movement(t *testing.T) {
	scores := model.AssessmentScores{Sleep: 90, Movement: 50, Metabolic: ptrInt(90), System: 70}
	if got := GenerateInsight(scores); got != InsightMovementDysfunction {
		t.Errorf("got=%q want=%q", got, InsightMovementDysfunction)
	}
}

func TestGenerateInsight_Metabolic(t *testing.T) {
	scores := model.AssessmentScores{Sleep: 90, Movement: 90, Metabolic: ptrInt(40), System: 70}
	if got := GenerateInsight(scores); got != InsightMetabolicDysfunction {
		t.Errorf("got=%q want=%q", got, InsightMetabolicDysfunction)
	}
}

func TestGenerateInsight_Stable(t *testing.T) {
	scores := model.AssessmentScores{Sleep: 90, Movement: 90, Metabolic: ptrInt(90), System: 90}
	if got := GenerateInsight(scores); got != InsightSystemStable {
		t.Errorf("got=%q want=%q", got, InsightSystemStable)
	}
}

func TestGenerateRecommendations_Multiple(t *testing.T) {
	scores := model.AssessmentScores{Sleep: 50, Movement: 50, Metabolic: ptrInt(50), System: 50}
	recs := GenerateRecommendations(scores)
	if len(recs) != 3 {
		t.Fatalf("expected 3 recommendations, got %d: %v", len(recs), recs)
	}
}

func TestGenerateRecommendations_None(t *testing.T) {
	scores := model.AssessmentScores{Sleep: 90, Movement: 90, Metabolic: ptrInt(90), System: 90}
	recs := GenerateRecommendations(scores)
	if len(recs) != 0 {
		t.Fatalf("expected 0 recommendations, got %d", len(recs))
	}
}
