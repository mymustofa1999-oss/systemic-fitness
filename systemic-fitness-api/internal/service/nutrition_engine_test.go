package service

import (
	"testing"

	"github.com/fitcoach/api/internal/model"
)

func TestComputeDailyScore(t *testing.T) {
	cases := []struct {
		name string
		in   model.NutritionDailyLogInput
		want int
	}{
		{"all good", model.NutritionDailyLogInput{VegetableIntake: true, ProteinIntake: true, HydrationOK: true}, 60},
		{"perfect minus violations", model.NutritionDailyLogInput{VegetableIntake: true, ProteinIntake: true, HydrationOK: true, SugarExcess: true, DietViolation: true}, 20},
		{"all penalties only", model.NutritionDailyLogInput{SugarExcess: true, DietViolation: true}, 0},
		{"empty", model.NutritionDailyLogInput{}, 0},
		{"only veg", model.NutritionDailyLogInput{VegetableIntake: true}, 20},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			if got := ComputeDailyScore(c.in); got != c.want {
				t.Fatalf("got %d want %d", got, c.want)
			}
		})
	}
}

func TestClassifyNutritionStatus(t *testing.T) {
	cases := map[int]string{
		100: model.NutritionStatusStable,
		80:  model.NutritionStatusStable,
		79:  model.NutritionStatusWarning,
		60:  model.NutritionStatusWarning,
		59:  model.NutritionStatusRisk,
		0:   model.NutritionStatusRisk,
	}
	for score, want := range cases {
		if got := ClassifyNutritionStatus(score); got != want {
			t.Errorf("score=%d got %s want %s", score, got, want)
		}
	}
}

func TestEvaluateNutritionAlert(t *testing.T) {
	if EvaluateNutritionAlert([]int{40, 50}) != nil {
		t.Error("expected nil for <3 scores")
	}
	if EvaluateNutritionAlert([]int{40, 50, 70}) != nil {
		t.Error("expected nil when one >= 60")
	}
	a := EvaluateNutritionAlert([]int{40, 50, 30, 80})
	if a == nil || !a.Triggered || a.Message != "consult professional" {
		t.Errorf("expected alert triggered, got %+v", a)
	}
}

func TestBuildDietPlanPriorityOrder(t *testing.T) {
	profile := model.NutritionHealthProfile{
		WeightKg:   70,
		Conditions: []string{model.ConditionHypertension, model.ConditionKidney, model.ConditionDiabetes},
	}
	plan, rules := BuildDietPlan(profile)

	// kidney overlay sets sodium=low, applied first; hypertension overlay sets sodium_limit_mg
	if rules["sodium"] != "low" {
		t.Errorf("expected kidney overlay applied (sodium=low), rules=%v", rules)
	}
	if rules["sodium_limit_mg"] != 1500 {
		t.Errorf("expected hypertension overlay (sodium_limit_mg=1500), rules=%v", rules)
	}
	if rules["carb_control"] != true {
		t.Errorf("expected diabetes overlay applied")
	}

	// Avoid foods should contain entries from all three overlays
	must := []string{"processed_meat", "sugar", "high_salt"}
	for _, m := range must {
		found := false
		for _, f := range plan.AvoidFoods {
			if f == m {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("expected avoid food %q, got %v", m, plan.AvoidFoods)
		}
	}
}

func TestBuildDietPlanAllergyFilter(t *testing.T) {
	profile := model.NutritionHealthProfile{
		WeightKg:   60,
		Allergies:  []string{"nuts", "fish"},
		Conditions: []string{model.ConditionKidney}, // limited has "nuts"
	}
	plan, _ := BuildDietPlan(profile)

	for _, lst := range [][]string{plan.AllowedFoods, plan.LimitedFoods, plan.AvoidFoods} {
		for _, f := range lst {
			lf := f
			if containsCI(lf, "nuts") || containsCI(lf, "fish") {
				t.Errorf("allergen %q leaked: %s", "nuts/fish", f)
			}
		}
	}
}

func containsCI(haystack, needle string) bool {
	h := []rune(haystack)
	n := []rune(needle)
	if len(n) == 0 {
		return true
	}
	if len(h) < len(n) {
		return false
	}
	for i := 0; i+len(n) <= len(h); i++ {
		match := true
		for j := 0; j < len(n); j++ {
			a := h[i+j]
			b := n[j]
			if a >= 'A' && a <= 'Z' {
				a += 32
			}
			if b >= 'A' && b <= 'Z' {
				b += 32
			}
			if a != b {
				match = false
				break
			}
		}
		if match {
			return true
		}
	}
	return false
}

func TestBaseRulesHydration(t *testing.T) {
	_, rules := BuildDietPlan(model.NutritionHealthProfile{WeightKg: 70})
	if rules["hydration_ml"] != 70*32 {
		t.Errorf("expected 2240 ml hydration, got %v", rules["hydration_ml"])
	}
}
