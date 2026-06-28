package service

import (
	"testing"

	"github.com/fitcoach/api/internal/model"
)

// ════════════════════════════════════════════════════════════════════
//  Assessment v2 Engine Tests
//  Pin every formula in §03/§04 of the SF Master Spec. If a formula
//  changes, update both engine + this file.
// ════════════════════════════════════════════════════════════════════

func ptrStr(s string) *string                    { return &s }
func ptrGoal(g model.PhaseAGoal) *model.PhaseAGoal { return &g }
func ptrGender(g model.PhaseAGender) *model.PhaseAGender { return &g }
func ptrAge(a model.PhaseAAgeBucket) *model.PhaseAAgeBucket { return &a }

// ─── Phase A program type ──────────────────────────────────────────

func TestResolveProgramType_Waitlist(t *testing.T) {
	got := ResolveProgramType(model.PhaseAInput{PhysicalStatusLevel: "level_2_3"})
	if got != model.ProgramWaitlist {
		t.Fatalf("expected waitlist for level_2_3, got %q", got)
	}
}

func TestResolveProgramType_ConditionSpecific(t *testing.T) {
	got := ResolveProgramType(model.PhaseAInput{
		PhysicalStatusLevel: "level_4_5_perf",
		HasMedicalCondition: true,
		ClassificationSlug:  ptrStr("cardiorespiratory"),
		SpecificConditionSlug: ptrStr("hipertensi"),
		PrimaryGoal:         ptrGoal(model.GoalControlMedical),
	})
	if got != model.ProgramConditionSpecific {
		t.Fatalf("expected condition_specific, got %q", got)
	}
}

func TestResolveProgramType_PerformanceWomen35_45(t *testing.T) {
	got := ResolveProgramType(model.PhaseAInput{
		PhysicalStatusLevel: "level_4_5_perf",
		Gender:              ptrGender(model.GenderWomen),
		AgeBucket:           ptrAge(model.Age35to45),
	})
	if got != model.ProgramPerformanceWomen35_45 {
		t.Fatalf("expected performance_women_35_45, got %q", got)
	}
}

func TestResolveProgramType_PerformanceMen46_60(t *testing.T) {
	got := ResolveProgramType(model.PhaseAInput{
		PhysicalStatusLevel: "level_4_5_perf",
		Gender:              ptrGender(model.GenderMen),
		AgeBucket:           ptrAge(model.Age46to60),
	})
	if got != model.ProgramPerformanceMen46_60 {
		t.Fatalf("expected performance_men_46_60, got %q", got)
	}
}

// ─── Phase B Rest Score ────────────────────────────────────────────

func TestComputeRestScore_Optimal(t *testing.T) {
	in := model.PhaseBInput{
		DurationHours:    7.5, // b1 22
		Consistency:      3,   // b2 18
		SleepLatency:     1,   // b3 15
		MorningReadiness: 3,   // b4 15
		WakeFrequency:    1,   // b5 15
		PreSleepHabit:    3,   // b6 15
		BedtimeBucket:    3, WakeTimeBucket: 3, ActivityProfile: "executive", DinnerTime: 1,
	}
	got := ComputeRestScore(in)
	if got != 100 {
		t.Fatalf("rest score optimal: got %v want 100", got)
	}
}

func TestComputeRestScore_Critical(t *testing.T) {
	in := model.PhaseBInput{
		DurationHours:    5,   // b1 10
		Consistency:      1,   // b2 5
		SleepLatency:     4,   // b3 4
		MorningReadiness: 1,   // b4 4
		WakeFrequency:    4,   // b5 2
		PreSleepHabit:    1,   // b6 4
		BedtimeBucket:    5, WakeTimeBucket: 1, ActivityProfile: "shift_worker", DinnerTime: 4,
	}
	got := ComputeRestScore(in)
	want := 29.0 // 10+5+4+4+2+4
	if got != want {
		t.Fatalf("rest score critical: got %v want %v", got, want)
	}
}

// ─── Chronobiology Window resolver ─────────────────────────────────

func TestResolveChronobiology_HipertensiLockSore(t *testing.T) {
	w := ResolveChronobiologyWindow(
		ptrStr("hipertensi"),
		model.ProgramConditionSpecific,
		&model.PhaseBInput{DurationHours: 7, Consistency: 3, SleepLatency: 4, MorningReadiness: 3, WakeFrequency: 2, PreSleepHabit: 2, BedtimeBucket: 3, WakeTimeBucket: 3, ActivityProfile: "executive", DinnerTime: 2},
	)
	if w.IdealStart != "15:00" || w.IdealEnd != "17:00" {
		t.Fatalf("hipertensi must lock 15:00-17:00, got %s-%s", w.IdealStart, w.IdealEnd)
	}
	if w.OverrideReason == "" {
		t.Fatalf("expected override_reason mentioning latency, got empty")
	}
}

func TestResolveChronobiology_PreventiveB3OverrideToSore(t *testing.T) {
	w := ResolveChronobiologyWindow(
		nil,
		model.ProgramPreventive,
		&model.PhaseBInput{DurationHours: 7, Consistency: 2, SleepLatency: 4, MorningReadiness: 3, WakeFrequency: 1, PreSleepHabit: 2, BedtimeBucket: 3, WakeTimeBucket: 3, ActivityProfile: "executive", DinnerTime: 2},
	)
	if w.IdealStart != "15:00" || w.IdealEnd != "17:00" {
		t.Fatalf("preventive + B3=4 must shift to 15:00-17:00, got %s-%s", w.IdealStart, w.IdealEnd)
	}
}

func TestResolveChronobiology_PreventiveB4LelahHapusPagi(t *testing.T) {
	w := ResolveChronobiologyWindow(
		nil,
		model.ProgramPreventive,
		&model.PhaseBInput{DurationHours: 7, Consistency: 3, SleepLatency: 1, MorningReadiness: 1, WakeFrequency: 1, PreSleepHabit: 2, BedtimeBucket: 3, WakeTimeBucket: 3, ActivityProfile: "executive", DinnerTime: 2},
	)
	// Preventive base ideal = 06:30-08:30. After B4=1 → should not start <10:00.
	if w.IdealStart < "10:00" {
		t.Fatalf("B4 lelah must remove morning, got %s", w.IdealStart)
	}
}

func TestResolveChronobiology_ShiftWorkerOverrideMalam(t *testing.T) {
	w := ResolveChronobiologyWindow(
		nil, model.ProgramPreventive,
		&model.PhaseBInput{DurationHours: 7, Consistency: 3, SleepLatency: 1, MorningReadiness: 3, WakeFrequency: 1, PreSleepHabit: 2, BedtimeBucket: 3, WakeTimeBucket: 3, ActivityProfile: "shift_worker", DinnerTime: 2},
	)
	if w.IdealStart != "19:00" || w.IdealEnd != "20:30" {
		t.Fatalf("shift_worker must lock 19:00-20:30, got %s-%s", w.IdealStart, w.IdealEnd)
	}
}

func TestResolveChronobiology_AsmaLockSoreEvenWithB4Segar(t *testing.T) {
	w := ResolveChronobiologyWindow(
		ptrStr("asma-terkontrol"),
		model.ProgramConditionSpecific,
		&model.PhaseBInput{DurationHours: 8, Consistency: 3, SleepLatency: 1, MorningReadiness: 3, WakeFrequency: 1, PreSleepHabit: 3, BedtimeBucket: 3, WakeTimeBucket: 3, ActivityProfile: "executive", DinnerTime: 2},
	)
	if w.IdealStart < "11:00" {
		t.Fatalf("asma hard-lock must stay afternoon, got %s", w.IdealStart)
	}
}

// ─── Phase C Nutrition Score ───────────────────────────────────────

func TestComputeNutritionScore_Healthy(t *testing.T) {
	got := ComputeNutritionScore(model.PhaseCInput{
		MealPattern: 2, FoodDominance: 4, Hydration: 4,
		RoutineFoods: []string{"coffee"},
		NutritionGoal: "energy_vitality",
	})
	if got < 90 {
		t.Fatalf("healthy nutrition expected >=90, got %v", got)
	}
}

func TestComputeNutritionScore_Risky(t *testing.T) {
	got := ComputeNutritionScore(model.PhaseCInput{
		MealPattern: 3, FoodDominance: 5, Hydration: 1,
		RoutineFoods: []string{"organ_meat", "alcohol", "fried", "soda_energy"},
		NutritionGoal: "blood_sugar",
	})
	if got > 50 {
		t.Fatalf("risky nutrition expected <=50, got %v", got)
	}
}

// ─── System Score composition ──────────────────────────────────────

func TestComputeSystemScoreV2_DefaultWeights(t *testing.T) {
	w := model.DefaultSystemScoreWeights()
	mv := 80.0
	total, br := ComputeSystemScoreV2(&mv, 70, 60, w)
	// 80*.35 + 70*.35 + 60*.30 = 28 + 24.5 + 18 = 70.5
	if total != 70.5 {
		t.Fatalf("expected 70.5, got %v", total)
	}
	if br.Movement == nil || *br.Movement != 80 {
		t.Fatalf("breakdown movement must be 80, got %+v", br.Movement)
	}
	if br.Nutrition != 70 || br.Rest != 60 {
		t.Fatalf("breakdown nutrition/rest mismatch, got %+v", br)
	}
}

func TestComputeSystemScoreV2_NoMovementReweight(t *testing.T) {
	w := model.DefaultSystemScoreWeights() // 35/35/30
	total, br := ComputeSystemScoreV2(nil, 80, 60, w)
	// reweight nutrition+rest to fill movement portion.
	// (80*.35 + 60*.30) / (.35 + .30) = (28 + 18) / 0.65 = 70.7692... → 70.77
	if total != 70.77 {
		t.Fatalf("expected 70.77, got %v", total)
	}
	if br.Movement != nil {
		t.Fatalf("movement should be nil when reweighted, got %v", *br.Movement)
	}
}

// ─── Flags ─────────────────────────────────────────────────────────

func TestGenerateV2Flags_RecoveryAlert(t *testing.T) {
	flags := GenerateV2Flags(
		model.PhaseAInput{PhysicalStatusLevel: "level_4_5_perf"},
		&model.PhaseBInput{DurationHours: 5, Consistency: 2, SleepLatency: 1, MorningReadiness: 1, WakeFrequency: 3, PreSleepHabit: 2, BedtimeBucket: 3, WakeTimeBucket: 3, ActivityProfile: "executive", DinnerTime: 2},
		nil, model.ProgramPreventive,
	)
	if !contains(flags, FlagV2RecoveryAlert) {
		t.Fatalf("expected REST_RECOVERY_ALERT, got %v", flags)
	}
}

func TestGenerateV2Flags_KidneyHydration(t *testing.T) {
	flags := GenerateV2Flags(
		model.PhaseAInput{
			PhysicalStatusLevel:   "level_4_5_perf",
			HasMedicalCondition:   true,
			ClassificationSlug:    ptrStr("renal-uric"),
			SpecificConditionSlug: ptrStr("ckd-1-3"),
		},
		nil,
		&model.PhaseCInput{MealPattern: 1, FoodDominance: 4, Hydration: 1, NutritionGoal: "organ_health"},
		model.ProgramConditionSpecific,
	)
	if !contains(flags, FlagV2KidneyHydra) {
		t.Fatalf("expected RENAL_HYDRATION_CRITICAL, got %v", flags)
	}
}

func TestGenerateV2Flags_WaitlistLevel(t *testing.T) {
	flags := GenerateV2Flags(
		model.PhaseAInput{PhysicalStatusLevel: "level_2_3"},
		nil, nil, model.ProgramWaitlist,
	)
	if !contains(flags, FlagV2WaitlistLevel) {
		t.Fatalf("expected WAITLIST_LEVEL_0_3, got %v", flags)
	}
}

// ─── helper ────────────────────────────────────────────────────────

func contains(slice []string, target string) bool {
	for _, s := range slice {
		if s == target {
			return true
		}
	}
	return false
}
