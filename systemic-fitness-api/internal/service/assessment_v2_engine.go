package service

// ════════════════════════════════════════════════════════════════════
//  Assessment v2 Engine — pure deterministic scoring functions.
//
//  This file MUST remain dependency-free (no DB, no logger, no I/O).
//  Implements:
//    - Phase A program-type resolver
//    - Phase B Rest Score (0–100) + Chronobiology Window resolver
//    - Phase C Nutrition Score (0–100)
//    - System Score composition (Movement / Nutrition / Rest)
//
//  Reference: SF_Master_Platform_Spec.docx §03 (Assessment Flow), §04
//  (System Score 35/35/30), halaman 337–456 (Chronobiology Window per
//  Kondisi).
//
//  Any formula change here MUST update assessment_v2_engine_test.go.
// ════════════════════════════════════════════════════════════════════

import (
	"fmt"
	"math"
	"strings"

	"github.com/fitcoach/api/internal/model"
)

// ─── Phase A: Program Type Resolver ────────────────────────────────

// ResolveProgramType picks the program slug a user routes to after
// Phase A. Returns ProgramWaitlist for level_0_1 or level_2_3 (out of
// scope for MVP launch).
func ResolveProgramType(in model.PhaseAInput) model.ProgramType {
	switch in.PhysicalStatusLevel {
	case "level_0_1", "level_2_3":
		return model.ProgramWaitlist
	}
	// level_4_5_perf
	if in.HasMedicalCondition {
		return model.ProgramConditionSpecific
	}
	if in.Gender == nil || in.AgeBucket == nil {
		// Should not happen if validation is correct, but be safe.
		return model.ProgramPreventive
	}
	switch {
	case *in.Gender == model.GenderWomen && *in.AgeBucket == model.Age35to45:
		return model.ProgramPerformanceWomen35_45
	case *in.Gender == model.GenderWomen && *in.AgeBucket == model.Age46to60:
		return model.ProgramPerformanceWomen46_60
	case *in.Gender == model.GenderMen && *in.AgeBucket == model.Age35to45:
		return model.ProgramPerformanceMen35_45
	case *in.Gender == model.GenderMen && *in.AgeBucket == model.Age46to60:
		return model.ProgramPerformanceMen46_60
	}
	return model.ProgramPreventive
}

// ─── Phase B: Rest Score ───────────────────────────────────────────
//
// Spec hal. 196–331. Bobot internal Rest Score (semua dijumlah lalu
// dinormalisasi ke 0..100):
//
//   B1 Duration         : <6=10, 6–7=18, 7–8=22, 8–9=20, >9=12  (max 22)
//   B2 Consistency      : 1=5, 2=12, 3=18                       (max 18)
//   B3 Sleep Latency    : 1=15, 2=12, 3=8, 4=4                  (max 15)
//   B4 Morning Readiness: 1=4, 2=10, 3=15                       (max 15)
//   B5 Wake Frequency   : 1=15, 2=12, 3=6, 4=2                  (max 15)
//   B6 Pre-Sleep Habit  : 1=4, 2=8, 3=15                        (max 15)
//
// Maximum subtotal = 22+18+15+15+15+15 = 100. So Rest Score = subtotal.

func b1Points(hours float64) int {
	switch {
	case hours < 6:
		return 10
	case hours < 7:
		return 18
	case hours <= 8:
		return 22
	case hours <= 9:
		return 20
	default:
		return 12
	}
}

func b2Points(c int) int {
	switch c {
	case 1:
		return 5
	case 2:
		return 12
	case 3:
		return 18
	}
	return 0
}

func b3Points(l int) int {
	switch l {
	case 1:
		return 15
	case 2:
		return 12
	case 3:
		return 8
	case 4:
		return 4
	}
	return 0
}

func b4Points(m int) int {
	switch m {
	case 1:
		return 4
	case 2:
		return 10
	case 3:
		return 15
	}
	return 0
}

func b5Points(w int) int {
	switch w {
	case 1:
		return 15
	case 2:
		return 12
	case 3:
		return 6
	case 4:
		return 2
	}
	return 0
}

func b6Points(p int) int {
	switch p {
	case 1:
		return 4
	case 2:
		return 8
	case 3:
		return 15
	}
	return 0
}

// ComputeRestScore returns a 0..100 score derived from Phase B answers.
func ComputeRestScore(b model.PhaseBInput) float64 {
	total := b1Points(b.DurationHours) +
		b2Points(b.Consistency) +
		b3Points(b.SleepLatency) +
		b4Points(b.MorningReadiness) +
		b5Points(b.WakeFrequency) +
		b6Points(b.PreSleepHabit)
	return clamp01_100(float64(total))
}

// ─── Phase B: Chronobiology Window resolver ────────────────────────

// classificationWindow returns the BASE Chronobiology Window for a
// given specific condition slug or program type. Any slug not listed
// uses the Preventive defaults (most flexible).
func classificationWindow(specificSlug *string, prog model.ProgramType) model.ChronobiologyWindow {
	slug := ""
	if specificSlug != nil {
		slug = strings.ToLower(*specificSlug)
	}

	type cw = model.ChronobiologyWindow
	const cap = "21:00"

	// 1) Specific medical conditions take priority
	switch slug {
	// Cardiorespiratory family
	case "hipertensi":
		return cw{IdealStart: "15:00", IdealEnd: "17:00", AltStart: "13:00", AltEnd: "15:00", Avoid: "Sebelum 07.30", HardCap: cap}
	case "penyakit-jantung":
		return cw{IdealStart: "15:00", IdealEnd: "17:00", AltStart: "13:00", AltEnd: "15:00", Avoid: "Sebelum 08.00", HardCap: cap}
	case "kolesterol":
		return cw{IdealStart: "06:30", IdealEnd: "08:30", AltStart: "15:00", AltEnd: "17:00", Avoid: "Setelah 21.00", HardCap: cap}
	case "asma-terkontrol", "ppok-ringan":
		return cw{IdealStart: "14:00", IdealEnd: "17:00", AltStart: "11:00", AltEnd: "13:00", Avoid: "Pagi 05.00–09.00", HardCap: cap}
	case "gangguan-syaraf-pusat":
		return cw{IdealStart: "14:00", IdealEnd: "17:00", AltStart: "10:00", AltEnd: "12:00", Avoid: "Sebelum 09.00", HardCap: cap}

	// Metabolic family
	case "diabetes-tipe-2":
		return cw{IdealStart: "07:00", IdealEnd: "09:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Malam >20.00 intensitas tinggi", HardCap: cap}
	case "pre-diabetes", "resistensi-insulin", "obesitas-metabolik":
		return cw{IdealStart: "07:00", IdealEnd: "09:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Setelah 21.00", HardCap: cap}
	case "pcos":
		return cw{IdealStart: "06:30", IdealEnd: "09:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Setelah 20.00", HardCap: cap}
	case "tiroid":
		return cw{IdealStart: "08:00", IdealEnd: "10:00", AltStart: "14:00", AltEnd: "16:00", Avoid: "Sebelum obat diminum", HardCap: cap}

	// Musculoskeletal family
	case "osteoarthritis":
		return cw{IdealStart: "10:00", IdealEnd: "12:00", AltStart: "14:00", AltEnd: "17:00", Avoid: "Pagi 05.00–08.00", HardCap: cap}
	case "osteoporosis":
		return cw{IdealStart: "14:00", IdealEnd: "17:00", AltStart: "10:00", AltEnd: "12:00", Avoid: "Sebelum 07.00", HardCap: cap}
	case "hnp", "spondylosis":
		return cw{IdealStart: "10:00", IdealEnd: "13:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Pagi 06.00–09.00", HardCap: cap}
	case "neuropati-perifer":
		return cw{IdealStart: "14:00", IdealEnd: "17:00", AltStart: "11:00", AltEnd: "13:00", Avoid: "Sebelum 09.00", HardCap: cap}
	case "frozen-shoulder", "skoliosis", "lemah-otot-pasca-imobilisasi":
		return cw{IdealStart: "10:00", IdealEnd: "12:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Pagi 05.00–08.00", HardCap: cap}

	// Renal & Uric family
	case "ckd-1-3", "batu-ginjal":
		return cw{IdealStart: "11:00", IdealEnd: "14:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Pagi sebelum 09.00", HardCap: cap}
	case "asam-urat":
		return cw{IdealStart: "11:00", IdealEnd: "15:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Pagi 06.00–09.00", HardCap: cap}
	case "hiperkalemia-ringan":
		return cw{IdealStart: "11:00", IdealEnd: "14:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Pagi sebelum 09.00", HardCap: cap}

	// Imun & Inflamasi family
	case "autoimun":
		return cw{IdealStart: "15:00", IdealEnd: "17:00", AltStart: "13:00", AltEnd: "15:00", Avoid: "Pagi 05.00–09.00", HardCap: cap}
	case "alergi-kronis":
		return cw{IdealStart: "15:00", IdealEnd: "17:00", AltStart: "11:00", AltEnd: "13:00", Avoid: "Pagi outdoor 05.00–09.00", HardCap: cap}
	case "kista", "tumor-jinak":
		return cw{IdealStart: "14:00", IdealEnd: "17:00", AltStart: "11:00", AltEnd: "13:00", Avoid: "Intensitas tinggi tanpa clearance", HardCap: cap}
	case "inflamasi-sistemik", "fibromyalgia":
		return cw{IdealStart: "15:00", IdealEnd: "17:00", AltStart: "11:00", AltEnd: "13:00", Avoid: "Pagi 05.00–09.00", HardCap: cap}
	}

	// 2) Performance / Preventive defaults
	switch prog {
	case model.ProgramPerformanceWomen35_45:
		return cw{IdealStart: "06:00", IdealEnd: "09:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Setelah 20.00", HardCap: cap}
	case model.ProgramPerformanceWomen46_60:
		return cw{IdealStart: "14:00", IdealEnd: "17:00", AltStart: "10:00", AltEnd: "12:00", Avoid: "Sebelum 08.00", HardCap: cap}
	case model.ProgramPerformanceMen35_45:
		return cw{IdealStart: "06:00", IdealEnd: "09:00", AltStart: "15:00", AltEnd: "17:00", Avoid: "Setelah 21.00", HardCap: cap}
	case model.ProgramPerformanceMen46_60:
		return cw{IdealStart: "15:00", IdealEnd: "17:00", AltStart: "11:00", AltEnd: "13:00", Avoid: "Sebelum 07.30", HardCap: cap}
	}
	// 3) Preventive (no medical, no specific perf bucket)
	return cw{IdealStart: "06:30", IdealEnd: "08:30", AltStart: "15:00", AltEnd: "17:00", Avoid: "Setelah 21.00", HardCap: cap}
}

// HARD-LOCK: certain conditions cannot be moved to morning even if Phase B
// answers suggest it. Applied AFTER classificationWindow.
func isHardLockSore(slug string) bool {
	switch slug {
	case "hipertensi", "penyakit-jantung",
		"asma-terkontrol", "ppok-ringan",
		"gangguan-syaraf-pusat",
		"autoimun", "alergi-kronis",
		"asam-urat", "hnp", "spondylosis",
		"ckd-1-3", "batu-ginjal", "hiperkalemia-ringan",
		"neuropati-perifer", "osteoarthritis":
		return true
	}
	return false
}

// ResolveChronobiologyWindow combines classification base + Phase B
// overrides per spec hierarchy:
//   1) Medical condition = BASE
//   2) B3 latency >45 mnt → shift to sore (override unless hard-locked)
//   3) B4 morning readiness "lelah/pusing" → remove morning options
//   4) B9 activity profile = modifier (shift_worker → night, traveller → afternoon anchor)
func ResolveChronobiologyWindow(
	specificSlug *string,
	prog model.ProgramType,
	b *model.PhaseBInput,
) model.ChronobiologyWindow {
	w := classificationWindow(specificSlug, prog)
	if b == nil {
		return w
	}

	slug := ""
	if specificSlug != nil {
		slug = strings.ToLower(*specificSlug)
	}
	hardLockSore := isHardLockSore(slug)

	// (4) Activity profile pre-applies (lowest priority, but easiest to express first).
	switch b.ActivityProfile {
	case "shift_worker":
		w.IdealStart, w.IdealEnd = "19:00", "20:30"
		w.AltStart, w.AltEnd = "", ""
		w.OverrideReason = "Pekerja shift: window malam terkontrol (hard cap 21:00)."
		return w
	case "traveller":
		w.IdealStart, w.IdealEnd = "15:00", "17:00"
		w.AltStart, w.AltEnd = "", ""
		w.OverrideReason = "Frequent traveller: anchor sore lokal."
		return w
	}

	// (2) B3 latency >45 mnt → wajib geser ke sore (unless lock already sore).
	if b.SleepLatency == 4 {
		if !hardLockSore && !startsAfter(w.IdealStart, "12:00") {
			w.AltStart, w.AltEnd = w.IdealStart, w.IdealEnd
			w.IdealStart, w.IdealEnd = "15:00", "17:00"
			w.OverrideReason = "Sleep latency >45 mnt: window digeser ke sore."
		} else if hardLockSore {
			w.OverrideReason = "Sleep latency >45 mnt mengkonfirmasi lock sore."
		}
	}

	// (3) B4 lelah/pusing → hapus opsi pagi.
	if b.MorningReadiness == 1 && !hardLockSore && !startsAfter(w.IdealStart, "10:00") {
		// promote alt window if it exists & is afternoon, otherwise default 14-17.
		if startsAfter(w.AltStart, "10:00") {
			w.IdealStart, w.IdealEnd = w.AltStart, w.AltEnd
			w.AltStart, w.AltEnd = "", ""
		} else {
			w.IdealStart, w.IdealEnd = "14:00", "17:00"
		}
		if w.OverrideReason == "" {
			w.OverrideReason = "Morning readiness lelah/pusing: opsi pagi dihapus."
		} else {
			w.OverrideReason += " | Morning readiness lelah."
		}
	}

	return w
}

// startsAfter compares "HH:MM" strings; empty string → false.
func startsAfter(a, threshold string) bool {
	if a == "" {
		return false
	}
	return a >= threshold
}

// ─── Phase C: Nutrition Score ──────────────────────────────────────
//
// Spec §03/C (hal. 460–768) mendefinisikan bobot nominal:
//   C1 20%, C2 20%, C3 20%, C4 20%, C5 5%, C6 5%, C7 10%
// C5 & C6 hanya filter untuk guidance teks → 0 poin di score
// (tetap kita beri kontribusi penuh sebagai 'data lengkap = 100% bobot').
//
// Per pertanyaan kita beri poin 0–100 lalu dirata-ratakan dengan bobot.

func c1Points(p int) int {
	switch p {
	case 1:
		return 80 // 3 kali besar — OK tapi kurang frekuensi
	case 2:
		return 100 // 4-5 kali kecil — ideal
	case 3:
		return 30 // skip irregular
	case 4:
		return 90 // IF terencana
	case 5:
		return 40 // tidak menentu
	}
	return 0
}

func c2Points(p int) int {
	switch p {
	case 1:
		return 50 // karbo dominan
	case 2:
		return 80 // protein fokus
	case 3:
		return 90 // sayur dominan
	case 4:
		return 100 // campuran seimbang
	case 5:
		return 30 // ultraprocessed
	}
	return 0
}

func c3Points(h int) int {
	switch h {
	case 1:
		return 25
	case 2:
		return 55
	case 3:
		return 85
	case 4:
		return 100
	}
	return 0
}

// c4Points: lebih banyak item risiko = poin makin rendah.
// Risiko tinggi: organ_meat, seafood, fried, alcohol, soda_energy, sweet_drinks, high_salt.
// Netral/positif: coffee (1 cup), dairy moderate, fermented.
func c4Points(items []string) int {
	if len(items) == 0 {
		return 100
	}
	risk := 0
	for _, it := range items {
		switch strings.ToLower(it) {
		case "organ_meat", "seafood", "alcohol", "soda_energy", "fried", "high_salt", "sweet_drinks":
			risk++
		}
	}
	switch {
	case risk == 0:
		return 95
	case risk == 1:
		return 80
	case risk == 2:
		return 60
	case risk == 3:
		return 40
	default:
		return 20
	}
}

// c7 (alignment with goal) is a flat 100 — actual alignment text is
// handled in guidance generator (Phase 6 work). Score itself doesn't
// penalise "wrong goal".
func c7Points(_ string) int { return 100 }

// ComputeNutritionScore returns a 0..100 score derived from Phase C.
func ComputeNutritionScore(c model.PhaseCInput) float64 {
	subtotal :=
		float64(c1Points(c.MealPattern)) * 0.20 +
			float64(c2Points(c.FoodDominance)) * 0.20 +
			float64(c3Points(c.Hydration)) * 0.20 +
			float64(c4Points(c.RoutineFoods)) * 0.20 +
			// C5 & C6 = data only (5% each) — full credit when answered.
			100.0 * 0.05 +
			100.0 * 0.05 +
			float64(c7Points(c.NutritionGoal)) * 0.10
	return clamp01_100(subtotal)
}

// ─── System Score Composition ──────────────────────────────────────

// ComputeSystemScoreV2 composes Movement / Nutrition / Rest using the
// configured weights. If movement is nil (no sessions logged yet), it
// falls back to a reweighted average of nutrition + rest only — the
// dashboard then shows movement as "—".
func ComputeSystemScoreV2(
	movement *float64, nutrition, rest float64,
	w model.SystemScoreWeights,
) (total float64, breakdown model.SystemScoreV2) {
	mPct := float64(w.MovementPct) / 100.0
	nPct := float64(w.NutritionPct) / 100.0
	rPct := float64(w.RestPct) / 100.0

	if movement == nil {
		// Reweight nutrition + rest to fill the missing movement portion.
		denom := nPct + rPct
		if denom == 0 {
			return 0, model.SystemScoreV2{Nutrition: nutrition, Rest: rest, Weights: w}
		}
		total = (nutrition*nPct + rest*rPct) / denom
		total = clamp01_100(round2(total))
		return total, model.SystemScoreV2{
			Nutrition: round2(nutrition),
			Rest:      round2(rest),
			Total:     total,
			Weights:   w,
		}
	}

	mv := *movement
	total = mv*mPct + nutrition*nPct + rest*rPct
	total = clamp01_100(round2(total))
	return total, model.SystemScoreV2{
		Movement:  ptrFloat64(round2(mv)),
		Nutrition: round2(nutrition),
		Rest:      round2(rest),
		Total:     total,
		Weights:   w,
	}
}

// ─── Program Map (Formula Sequence & Load Weight) ──────────────────

// ResolveSequenceFormula returns the recommended conditioning durations based on the specific condition.
func ResolveSequenceFormula(specificSlug *string) *model.ProgramMapRecommendation {
	slug := ""
	if specificSlug != nil {
		slug = strings.ToLower(*specificSlug)
	}

	// Default Preventive (if no condition)
	f := model.SequenceFormula{FCMins: 10, CCMins: 20, MCMins: 30}

	switch slug {
	// ─── Imun & Inflamasi ───
	case "autoimun":
		f = model.SequenceFormula{FCMins: 15, CCMins: 30, MCMins: 15, Notes: "Full Program (60 Menit)"}
	case "alergi-kronis":
		f = model.SequenceFormula{FCMins: 15, CCMins: 30, MCMins: 15, Notes: "Full Program (60 Menit) - 30 Menit CC"}
	case "inflamasi-sistemik", "fibromyalgia":
		f = model.SequenceFormula{FCMins: 25, CCMins: 25, MCMins: 10, Notes: "Full Program (60 Menit) - 10 Menit MC"}
	case "kista", "tumor-jinak":
		f = model.SequenceFormula{FCMins: 10, CCMins: 20, MCMins: 0, Notes: "Daily Reset (30 Menit)"}

	// ─── Renal & Uric System ───
	case "gangguan-ginjal", "ckd-1-3":
		f = model.SequenceFormula{FCMins: 10, CCMins: 35, MCMins: 15, Notes: "Full Program (60 Menit) - 10 Menit FC"}
	case "asam-urat":
		f = model.SequenceFormula{FCMins: 10, CCMins: 35, MCMins: 15, Notes: "Full Program (60 Menit) - 35 Menit CC"}
	case "gagal-ginjal":
		f = model.SequenceFormula{FCMins: 10, CCMins: 35, MCMins: 15, Notes: "Full Program (60 Menit) - 15 Menit MC"}
	case "batu-ginjal", "hiperkalemia-ringan":
		f = model.SequenceFormula{FCMins: 10, CCMins: 20, MCMins: 0, Notes: "Daily Reset (30 Menit)"}

	// ─── Cardiorespiratory ───
	case "penyakit-jantung":
		f = model.SequenceFormula{FCMins: 10, CCMins: 35, MCMins: 15, Notes: "Full Program (60 Menit) - 10 Menit FC"}
	case "gangguan-pernapasan", "asma-terkontrol", "ppok-ringan":
		f = model.SequenceFormula{FCMins: 10, CCMins: 35, MCMins: 15, Notes: "Full Program (60 Menit) - 35 Menit CC"}
	case "hipertensi", "tekanan-darah":
		f = model.SequenceFormula{FCMins: 10, CCMins: 35, MCMins: 15, Notes: "Full Program (60 Menit) - 15 Menit MC"}
	case "kolesterol":
		f = model.SequenceFormula{FCMins: 0, CCMins: 20, MCMins: 10, Notes: "Daily Reset (30 Menit)"}
	case "gangguan-syaraf-pusat":
		f = model.SequenceFormula{FCMins: 0, CCMins: 20, MCMins: 10, Notes: "Daily Reset (30 Menit)"}

	// ─── Metabolic ───
	case "diabetes-tipe-2", "pre-diabetes", "resistensi-insulin", "obesitas-metabolik":
		f = model.SequenceFormula{FCMins: 10, CCMins: 15, MCMins: 35, Notes: "Full Program (60 Menit) - 10 Menit FC"}
	case "pcos", "gangguan-hormon":
		f = model.SequenceFormula{FCMins: 10, CCMins: 15, MCMins: 35, Notes: "Full Program (60 Menit) - 15 Menit CC"}
	case "tiroid":
		f = model.SequenceFormula{FCMins: 10, CCMins: 15, MCMins: 35, Notes: "Full Program (60 Menit) - 35 Menit MC"}
	// Assuming other metabolic conditions go to daily reset
	case "metabolic-daily-reset":
		f = model.SequenceFormula{FCMins: 0, CCMins: 10, MCMins: 20, Notes: "Daily Reset (30 Menit)"}

	// ─── Musculoskeletal ───
	case "osteoarthritis", "persendian":
		f = model.SequenceFormula{FCMins: 10, CCMins: 15, MCMins: 35, Notes: "Full Program (60 Menit) - 10 Menit FC"}
	case "skoliosis", "postur-tubuh":
		f = model.SequenceFormula{FCMins: 10, CCMins: 15, MCMins: 35, Notes: "Full Program (60 Menit) - 15 Menit CC"}
	case "gangguan-gerak", "hnp", "spondylosis":
		f = model.SequenceFormula{FCMins: 10, CCMins: 15, MCMins: 35, Notes: "Full Program (60 Menit) - 35 Menit MC"}
	case "neuropati-perifer", "gangguan-syaraf-tepi":
		f = model.SequenceFormula{FCMins: 10, CCMins: 0, MCMins: 20, Notes: "Daily Reset (30 Menit)"}
	case "frozen-shoulder", "lemah-otot-pasca-imobilisasi":
		f = model.SequenceFormula{FCMins: 10, CCMins: 0, MCMins: 20, Notes: "Daily Reset (30 Menit)"}
	}

	return &model.ProgramMapRecommendation{
		Formula: f,
	}
}

// ResolveLoadWeight fills in the CardioLoad and MetabLoad for the recommendation.
// age in years, height in cm.
func ResolveLoadWeight(rec *model.ProgramMapRecommendation, gender string, age int, height float64) {
	isWoman := strings.ToLower(gender) == "women" || strings.ToLower(gender) == "female"
	
	// Default values
	var cardioUpper, cardioLower, metabUpper, metabLower float64

	if isWoman {
		if age <= 20 {
			cardioUpper, cardioLower = 0.25, 0.75
			metabUpper, metabLower = 1.0, 1.5
		} else if height > 175 {
			cardioUpper, cardioLower = 0.75, 1.5
			metabUpper, metabLower = 2.0, 2.5
		} else {
			// Adult women <= 175 (baseline 155-175)
			cardioUpper, cardioLower = 0.5, 1.0
			metabUpper, metabLower = 1.5, 2.0
		}
	} else {
		// Man
		if age <= 20 {
			cardioUpper, cardioLower = 0.5, 1.5
			metabUpper, metabLower = 2.0, 2.0
		} else if height > 185 {
			cardioUpper, cardioLower = 1.5, 3.0
			metabUpper, metabLower = 4.0, 4.0
		} else {
			// Adult men <= 185 (baseline 160-185)
			cardioUpper, cardioLower = 1.0, 2.0
			metabUpper, metabLower = 3.0, 3.0
		}
	}

	rec.CardioLoad = model.LoadWeight{UpperBodyKg: cardioUpper, LowerBodyKg: cardioLower}
	rec.MetabLoad = model.LoadWeight{UpperBodyKg: metabUpper, LowerBodyKg: metabLower}
}

// ─── Flags & Recommendations ───────────────────────────────────────

const (
	FlagV2RecoveryAlert = "REST_RECOVERY_ALERT"      // B1<6h + B5≥3
	FlagV2BloodSugar    = "META_BLOOD_SUGAR_RISK"    // B10 setelah 20:00 + B3>30 mnt
	FlagV2KidneyHydra   = "RENAL_HYDRATION_CRITICAL" // C3<4 gelas + ginjal/asam urat
	FlagV2WaitlistLevel = "WAITLIST_LEVEL_0_3"
)

// GenerateV2Flags surfaces ringkas clinical/system flags that the
// Consultant queue should pay attention to.
func GenerateV2Flags(
	a model.PhaseAInput, b *model.PhaseBInput, c *model.PhaseCInput,
	prog model.ProgramType,
) []string {
	flags := []string{}
	if prog == model.ProgramWaitlist {
		flags = append(flags, FlagV2WaitlistLevel)
	}
	if b != nil {
		if b.DurationHours < 6 && b.WakeFrequency >= 3 {
			flags = append(flags, FlagV2RecoveryAlert)
		}
		if b.DinnerTime == 4 && b.SleepLatency >= 3 {
			flags = append(flags, FlagV2BloodSugar)
		}
	}
	if c != nil && c.Hydration == 1 {
		// Hydration critical for renal/uric users
		if a.SpecificConditionSlug != nil {
			s := strings.ToLower(*a.SpecificConditionSlug)
			if s == "ckd-1-3" || s == "asam-urat" || s == "batu-ginjal" {
				flags = append(flags, FlagV2KidneyHydra)
			}
		}
	}
	return flags
}

// ─── Helpers ───────────────────────────────────────────────────────

func clamp01_100(v float64) float64 {
	if v < 0 {
		return 0
	}
	if v > 100 {
		return 100
	}
	return v
}

func round2(v float64) float64 { return math.Round(v*100) / 100 }

func ptrFloat64(v float64) *float64 { return &v }

// errMissingPhase is returned by ComputeSystemForResult when a required
// phase hasn't been submitted yet.
type errMissingPhase struct{ Phase string }

func (e *errMissingPhase) Error() string {
	return fmt.Sprintf("v2 engine: phase %s payload required", e.Phase)
}
