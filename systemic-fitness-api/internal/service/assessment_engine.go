package service

// ════════════════════════════════════════════════════════════════════
//  Assessment Engine — pure, deterministic scoring functions.
//
//  This file MUST remain dependency-free (no DB, no logger, no I/O)
//  so the formulas can be unit-tested in isolation and reused from
//  free, paid, and trainer-review code paths without duplication.
//
//  All formulas are taken verbatim from the Basic Assessment spec
//  (see docs/assessment.md). Any formula change requires updating
//  both this file and assessment_engine_test.go.
// ════════════════════════════════════════════════════════════════════

import (
	"github.com/fitcoach/api/internal/model"
)

// ─── Sleep ─────────────────────────────────────────────────────────

func sleepDurationPoints(hours float64) int {
	switch {
	case hours >= 7:
		return 25
	case hours >= 6:
		return 18
	default:
		return 10
	}
}

func sleepLatencyPoints(minutes int) int {
	switch {
	case minutes <= 15:
		return 15
	case minutes <= 30:
		return 10
	default:
		return 5
	}
}

func sleepWakePoints(wakeCount int) int {
	switch {
	case wakeCount == 0:
		return 15
	case wakeCount <= 2:
		return 10
	default:
		return 5
	}
}

// ComputeSleepScore returns the Sleep Score (0–100).
func ComputeSleepScore(in model.SleepInput) int {
	score := sleepDurationPoints(in.DurationHours) +
		(in.Consistency * 10) +
		sleepLatencyPoints(in.LatencyMinutes) +
		sleepWakePoints(in.WakeFrequency) +
		(in.PreSleepHabit * 5)
	return clampScore(score)
}

// ComputeRecoveryScore mirrors the Recovery Score formula from the spec.
func ComputeRecoveryScore(in model.SleepInput) int {
	score := (in.MorningReadiness * 20) +
		sleepWakePoints(in.WakeFrequency) +
		sleepLatencyPoints(in.LatencyMinutes) +
		sleepDurationPoints(in.DurationHours)
	return clampScore(score)
}

// ─── Movement ──────────────────────────────────────────────────────

// ComputeMovementScore returns the Movement Score (0–100).
//
// Spec formula: (squat*30 + hinge*35 + overhead*35) / 3
func ComputeMovementScore(in model.MovementInput) int {
	weighted := (in.Squat * 30) + (in.HipHinge * 35) + (in.Overhead * 35)
	return clampScore(weighted / 3)
}

// ─── Metabolic ─────────────────────────────────────────────────────

func metabolicHbA1cPoints(v float64) int {
	switch {
	case v <= 5.6:
		return 35
	case v <= 6.4:
		return 20
	default:
		return 10
	}
}

func metabolicLDLPoints(v float64) int {
	switch {
	case v < 100:
		return 30
	case v < 130:
		return 20
	default:
		return 10
	}
}

func metabolicTriglyceridePoints(v float64) int {
	switch {
	case v < 150:
		return 35
	case v < 200:
		return 20
	default:
		return 10
	}
}

// ComputeMetabolicScore returns the Metabolic Score (0–100).
func ComputeMetabolicScore(in model.MetabolicInput) int {
	score := metabolicHbA1cPoints(in.HbA1c) +
		metabolicLDLPoints(in.LDL) +
		metabolicTriglyceridePoints(in.Triglyceride)
	return clampScore(score)
}

// ─── System Score ──────────────────────────────────────────────────

// ComputeSystemScore returns the weighted total system score.
//
// Free tier (metabolic == nil):  sleep*0.5 + movement*0.5
// Paid tier (metabolic != nil):  sleep*0.4 + movement*0.3 + metabolic*0.3
func ComputeSystemScore(sleep, movement int, metabolic *int) int {
	if metabolic == nil {
		return clampScore(int((float64(sleep) * 0.5) + (float64(movement) * 0.5)))
	}
	return clampScore(int(
		(float64(sleep) * 0.4) +
			(float64(movement) * 0.3) +
			(float64(*metabolic) * 0.3),
	))
}

// ─── Classification ────────────────────────────────────────────────

// ClassifySleep maps a sleep score to its classification label.
func ClassifySleep(score int) model.Classification {
	switch {
	case score >= 80:
		return model.ClassOptimal
	case score >= 60:
		return model.ClassCompromised
	default:
		return model.ClassCritical
	}
}

// ClassifyMovement maps a movement score to its classification label.
func ClassifyMovement(score int) model.Classification {
	switch {
	case score >= 80:
		return model.ClassStable
	case score >= 60:
		return model.ClassCompensation
	default:
		return model.ClassDysfunction
	}
}

// ClassifyMetabolic maps a metabolic score to its classification label.
func ClassifyMetabolic(score int) model.Classification {
	switch {
	case score >= 80:
		return model.ClassEfficient
	case score >= 60:
		return model.ClassAtRisk
	default:
		return model.ClassDysregulated
	}
}

// ─── Risk Flags ────────────────────────────────────────────────────

const (
	FlagHighInjuryRisk    = "HIGH_INJURY_RISK"
	FlagRecoveryAlert     = "RECOVERY_ALERT"
	FlagMetabolicRedFlag  = "METABOLIC_RED_FLAG"
)

// GenerateFlags returns all risk flags triggered by the inputs.
func GenerateFlags(sleep model.SleepInput, mv model.MovementInput, met *model.MetabolicInput) []string {
	flags := make([]string, 0, 3)

	if mv.Squat == 1 {
		flags = append(flags, FlagHighInjuryRisk)
	}
	if sleep.DurationHours < 6 && sleep.WakeFrequency > 2 {
		flags = append(flags, FlagRecoveryAlert)
	}
	if met != nil && met.HbA1c > 6.5 {
		flags = append(flags, FlagMetabolicRedFlag)
	}

	return flags
}

// ─── Insight & Recommendations ─────────────────────────────────────

const (
	InsightRecoveryDysfunction  = "Primary Issue: Recovery Dysfunction"
	InsightMovementDysfunction  = "Primary Issue: Movement Dysfunction"
	InsightMetabolicDysfunction = "Primary Issue: Metabolic Dysfunction"
	InsightSystemStable         = "System Stable"

	RecRecovery  = "Sleep optimization + nervous system reset"
	RecMovement  = "Mobility + corrective training"
	RecMetabolic = "Conditioning + nutrition strategy"
)

// GenerateInsight returns the primary issue label according to the
// scoring spec. Sleep is checked first, then movement, then metabolic.
func GenerateInsight(scores model.AssessmentScores) string {
	if scores.Sleep < 60 {
		return InsightRecoveryDysfunction
	}
	if scores.Movement < 60 {
		return InsightMovementDysfunction
	}
	if scores.Metabolic != nil && *scores.Metabolic < 60 {
		return InsightMetabolicDysfunction
	}
	return InsightSystemStable
}

// GenerateRecommendations returns every applicable recommendation.
// Multiple issues can produce multiple recommendations.
func GenerateRecommendations(scores model.AssessmentScores) []string {
	recs := make([]string, 0, 3)
	if scores.Sleep < 60 {
		recs = append(recs, RecRecovery)
	}
	if scores.Movement < 60 {
		recs = append(recs, RecMovement)
	}
	if scores.Metabolic != nil && *scores.Metabolic < 60 {
		recs = append(recs, RecMetabolic)
	}
	return recs
}

// ─── Helpers ───────────────────────────────────────────────────────

func clampScore(v int) int {
	if v < 0 {
		return 0
	}
	if v > 100 {
		return 100
	}
	return v
}
