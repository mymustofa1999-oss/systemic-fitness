package service

// ════════════════════════════════════════════════════════════════════
//  Nutrition Engine — pure, deterministic rule-based functions.
//
//  This file MUST remain dependency-free (no DB, no logger, no I/O)
//  so the rule overlays and scoring formulas can be unit-tested in
//  isolation. All rules are taken verbatim from the Nutrition Guidance
//  & Monitoring Engine spec. Changes here require updating
//  nutrition_engine_test.go in the same commit.
// ════════════════════════════════════════════════════════════════════

import (
	"sort"
	"strings"

	"github.com/fitcoach/api/internal/model"
)

// Priority order for condition overlays (lower = applied first / higher precedence).
// kidney > diabetes > heart > hypertension > others.
var nutritionConditionPriority = map[string]int{
	model.ConditionKidney:       1,
	model.ConditionDiabetes:     2,
	model.ConditionHeart:        3,
	model.ConditionHypertension: 4,
	model.ConditionGout:         5,
	model.ConditionCancer:       6,
	model.ConditionAutoimmune:   7,
	model.ConditionHormonal:     8,
}

// ─── Base diet ──────────────────────────────────────────────────────

func baseDietPlan() model.DietPlan {
	return model.DietPlan{
		AllowedFoods: []string{
			"broccoli", "spinach", "kale", "carrot", "tomato",
			"chicken_breast", "fish", "egg", "tofu", "tempeh",
			"brown_rice", "oats", "sweet_potato",
			"apple", "berries", "avocado",
		},
		LimitedFoods: []string{},
		AvoidFoods:   []string{},
	}
}

func baseRules(weightKg float64) model.NutritionRules {
	hydration := int(weightKg * 32) // 30–35 ml/kg, use midpoint
	if hydration <= 0 {
		hydration = 2000
	}
	return model.NutritionRules{
		"vegetables_pct": 50,
		"protein_pct":    25,
		"carbs_pct":      25,
		"hydration_ml":   hydration,
		"meal_frequency": "2-3",
	}
}

// ─── Per-condition overlays ────────────────────────────────────────

func overlayKidney(p *model.DietPlan, r model.NutritionRules) {
	r["protein"] = "moderate"
	r["sodium"] = "low"
	r["potassium"] = "controlled"
	p.AvoidFoods = append(p.AvoidFoods, "processed_meat", "banana", "orange")
	p.LimitedFoods = append(p.LimitedFoods, "dairy", "nuts")
}

func overlayDiabetes(p *model.DietPlan, r model.NutritionRules) {
	r["carb_control"] = true
	r["sugar"] = "low"
	r["fiber"] = "high"
	p.AvoidFoods = append(p.AvoidFoods, "sugar", "white_rice", "soda")
}

func overlayHeart(p *model.DietPlan, r model.NutritionRules) {
	r["saturated_fat"] = "low"
	r["healthy_fat"] = "high"
	p.AvoidFoods = append(p.AvoidFoods, "fried_food", "butter")
}

func overlayHypertension(p *model.DietPlan, r model.NutritionRules) {
	r["sodium_limit_mg"] = 1500
	p.AvoidFoods = append(p.AvoidFoods, "processed_food", "high_salt")
}

func overlayGout(p *model.DietPlan, r model.NutritionRules) {
	r["purine"] = "low"
	p.AvoidFoods = append(p.AvoidFoods, "organ_meat", "alcohol", "sardines")
}

func overlayCancer(p *model.DietPlan, r model.NutritionRules) {
	r["protein"] = "high"
	r["calorie"] = "adequate"
}

func overlayAutoimmune(p *model.DietPlan, r model.NutritionRules) {
	r["profile"] = "balanced"
	r["avoid"] = "personalized_trigger"
}

func overlayHormonal(p *model.DietPlan, r model.NutritionRules) {
	r["sugar"] = "low"
	r["fiber"] = "high"
	r["healthy_fat"] = "high"
}

// sortConditionsByPriority returns conditions sorted ascending by priority weight.
func sortConditionsByPriority(conditions []string) []string {
	out := make([]string, len(conditions))
	copy(out, conditions)
	sort.SliceStable(out, func(i, j int) bool {
		pi, oki := nutritionConditionPriority[out[i]]
		pj, okj := nutritionConditionPriority[out[j]]
		if !oki {
			pi = 999
		}
		if !okj {
			pj = 999
		}
		return pi < pj
	})
	return out
}

// removeAllergens strips any food matching (substring, case-insensitive)
// the user's allergens from all three diet lists.
func removeAllergens(plan model.DietPlan, allergens []string) model.DietPlan {
	if len(allergens) == 0 {
		return plan
	}
	norm := make([]string, 0, len(allergens))
	for _, a := range allergens {
		a = strings.ToLower(strings.TrimSpace(a))
		if a != "" {
			norm = append(norm, a)
		}
	}
	filter := func(list []string) []string {
		out := make([]string, 0, len(list))
		for _, food := range list {
			food = strings.TrimSpace(food)
			lower := strings.ToLower(food)
			contaminated := false
			for _, a := range norm {
				if strings.Contains(lower, a) {
					contaminated = true
					break
				}
			}
			if !contaminated {
				out = append(out, food)
			}
		}
		return out
	}
	return model.DietPlan{
		AllowedFoods: filter(plan.AllowedFoods),
		LimitedFoods: filter(plan.LimitedFoods),
		AvoidFoods:   filter(plan.AvoidFoods),
	}
}

func dedupe(list []string) []string {
	seen := make(map[string]struct{}, len(list))
	out := make([]string, 0, len(list))
	for _, v := range list {
		if _, ok := seen[v]; ok {
			continue
		}
		seen[v] = struct{}{}
		out = append(out, v)
	}
	return out
}

// ─── Main engine functions ─────────────────────────────────────────

// BuildDietPlan composes the personalised diet plan + nutrition rules
// based on the user's health profile. Pure function.
func BuildDietPlan(profile model.NutritionHealthProfile) (model.DietPlan, model.NutritionRules) {
	plan := baseDietPlan()
	rules := baseRules(profile.WeightKg)

	for _, c := range sortConditionsByPriority(profile.Conditions) {
		switch c {
		case model.ConditionKidney:
			overlayKidney(&plan, rules)
		case model.ConditionDiabetes:
			overlayDiabetes(&plan, rules)
		case model.ConditionHeart:
			overlayHeart(&plan, rules)
		case model.ConditionHypertension:
			overlayHypertension(&plan, rules)
		case model.ConditionGout:
			overlayGout(&plan, rules)
		case model.ConditionCancer:
			overlayCancer(&plan, rules)
		case model.ConditionAutoimmune:
			overlayAutoimmune(&plan, rules)
		case model.ConditionHormonal:
			overlayHormonal(&plan, rules)
		}
	}

	plan.AllowedFoods = dedupe(plan.AllowedFoods)
	plan.LimitedFoods = dedupe(plan.LimitedFoods)
	plan.AvoidFoods = dedupe(plan.AvoidFoods)

	return removeAllergens(plan, profile.Allergies), rules
}

func clampScoreNutrition(s int) int {
	if s < 0 {
		return 0
	}
	if s > 100 {
		return 100
	}
	return s
}

// ComputeDailyScore evaluates the daily intake log and returns a 0–100 score.
func ComputeDailyScore(in model.NutritionDailyLogInput) int {
	s := 0
	if in.VegetableIntake {
		s += 20
	}
	if in.ProteinIntake {
		s += 20
	}
	if in.HydrationOK {
		s += 20
	}
	if in.SugarExcess {
		s -= 20
	}
	if in.DietViolation {
		s -= 20
	}
	return clampScoreNutrition(s)
}

// ClassifyNutritionStatus maps a score to a status string.
//   80–100 → stable, 60–79 → warning, <60 → risk.
func ClassifyNutritionStatus(score int) string {
	switch {
	case score >= 80:
		return model.NutritionStatusStable
	case score >= 60:
		return model.NutritionStatusWarning
	default:
		return model.NutritionStatusRisk
	}
}

// EvaluateNutritionAlert returns an alert when the most recent 3 scores
// (slice should be ordered DESC by log_date) are all below 60.
func EvaluateNutritionAlert(recentScores []int) *model.NutritionAlert {
	if len(recentScores) < 3 {
		return nil
	}
	for _, s := range recentScores[:3] {
		if s >= 60 {
			return nil
		}
	}
	return &model.NutritionAlert{
		Triggered: true,
		Message:   "consult professional",
	}
}

// BuildNutritionInsights returns rule-based, human-readable hints.
func BuildNutritionInsights(profile model.NutritionHealthProfile, score int) []string {
	out := make([]string, 0, 4)
	switch ClassifyNutritionStatus(score) {
	case model.NutritionStatusStable:
		out = append(out, "Pertahankan pola makan saat ini, kondisi stabil.")
	case model.NutritionStatusWarning:
		out = append(out, "Perhatikan asupan harian, ada area yang perlu diperbaiki.")
	case model.NutritionStatusRisk:
		out = append(out, "Skor harian rendah, segera evaluasi pola makan.")
	}
	for _, c := range profile.Conditions {
		switch c {
		case model.ConditionHypertension:
			out = append(out, "Batasi natrium di bawah 1500 mg per hari.")
		case model.ConditionDiabetes:
			out = append(out, "Kontrol karbohidrat dan tingkatkan serat.")
		case model.ConditionKidney:
			out = append(out, "Jaga asupan protein moderat dan rendah kalium.")
		case model.ConditionHeart:
			out = append(out, "Hindari lemak jenuh, perbanyak lemak sehat.")
		case model.ConditionGout:
			out = append(out, "Hindari makanan tinggi purin dan alkohol.")
		case model.ConditionHormonal:
			out = append(out, "Tingkatkan serat dan kurangi gula sederhana.")
		}
	}
	if profile.FemaleCondition != nil && *profile.FemaleCondition == model.FemPregnant {
		out = append(out, "Pastikan kebutuhan zat besi dan asam folat tercukupi.")
	}
	return out
}
