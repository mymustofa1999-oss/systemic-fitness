package handler

import (
	"net/http"

	"github.com/fitcoach/api/pkg/response"
)

// ════════════════════════════════════════════════════════════════════
//  Assessment Schema (single source of truth for the composition)
//
//  This file describes WHAT the customer fills in for the free and
//  paid assessments, plus the scoring rules, classification bands,
//  and risk flags. The numbers MUST match
//  internal/service/assessment_engine.go exactly — if you change
//  the engine, you must mirror the change here.
//
//  Consumed by:
//    - systemic-fitness-web admin → /assessments/composition page
//    - (future) systemic-fitness-mobile-new → dynamic free wizard
//
//  Endpoint: GET /api/assessments/schema  (auth required, any role)
// ════════════════════════════════════════════════════════════════════

type schemaOption struct {
	Label  string `json:"label"`
	Value  any    `json:"value"`
	Points string `json:"points,omitempty"`
}

type schemaQuestion struct {
	Key        string         `json:"key"`
	Title      string         `json:"title"`
	Subtitle   string         `json:"subtitle,omitempty"`
	InputType  string         `json:"input_type"` // "number" | "options"
	Unit       string         `json:"unit,omitempty"`
	Options    []schemaOption `json:"options,omitempty"`
	PointsRule string         `json:"points_rule,omitempty"`
}

type schemaSection struct {
	Key         string           `json:"key"`
	Title       string           `json:"title"`
	Icon        string           `json:"icon"`
	Description string           `json:"description"`
	MaxScore    string           `json:"max_score"`
	Formula     string           `json:"formula"`
	Questions   []schemaQuestion `json:"questions"`
}

type schemaPhysicalGroup struct {
	Title string   `json:"title"`
	Items []string `json:"items"`
}

type schemaFlag struct {
	Key   string `json:"key"`
	Label string `json:"label"`
	Color string `json:"color"`
	Rule  string `json:"rule"`
}

type schemaBand struct {
	Label string `json:"label"`
	Range string `json:"range"`
	Color string `json:"color"`
}

type schemaClassification struct {
	Score string       `json:"score"`
	Bands []schemaBand `json:"bands"`
}

type schemaTier struct {
	SystemScoreFormula string          `json:"system_score_formula"`
	Sections           []schemaSection `json:"sections"`
}

type assessmentSchema struct {
	Version         string                `json:"version"`
	Free            schemaTier            `json:"free"`
	Paid            schemaTier            `json:"paid"`
	PhysicalGroups  []schemaPhysicalGroup `json:"physical_groups"`
	Flags           []schemaFlag          `json:"flags"`
	Classifications []schemaClassification `json:"classifications"`
}

// ─── Section builders ─────────────────────────────────────────────

func sleepSection() schemaSection {
	return schemaSection{
		Key:         "sleep",
		Title:       "Sleep & Recovery",
		Icon:        "moon",
		Description: "Mengukur kuantitas, kualitas, dan efisiensi tidur klien. 6 pertanyaan, di-input mandiri oleh klien.",
		MaxScore:    "0–100 (clamped)",
		Formula:     "duration_pts + (consistency × 10) + latency_pts + (morning_readiness × 10) + wake_pts + (pre_sleep_habit × 5)",
		Questions: []schemaQuestion{
			{
				Key:        "duration_hours",
				Title:      "Rata-rata durasi tidur",
				Subtitle:   "Berapa jam rata-rata kamu tidur per malam?",
				InputType:  "number",
				Unit:       "jam",
				PointsRule: "≥7 jam → 25 pts · ≥6 jam → 18 pts · <6 jam → 10 pts",
			},
			{
				Key:       "consistency",
				Title:     "Konsistensi tidur",
				Subtitle:  "Seberapa konsisten jam tidur dan bangun kamu?",
				InputType: "options",
				Options: []schemaOption{
					{Label: "Sangat tidak teratur", Value: 1, Points: "10 pts"},
					{Label: "Kadang berubah", Value: 2, Points: "20 pts"},
					{Label: "Teratur setiap hari", Value: 3, Points: "30 pts"},
				},
				PointsRule: "value × 10",
			},
			{
				Key:       "latency_minutes",
				Title:     "Sleep latency",
				Subtitle:  "Berapa lama biasanya kamu butuh untuk tertidur?",
				InputType: "options",
				Options: []schemaOption{
					{Label: "< 15 menit", Value: 10, Points: "15 pts"},
					{Label: "15–30 menit", Value: 25, Points: "10 pts"},
					{Label: "> 45 menit", Value: 60, Points: "5 pts"},
				},
				PointsRule: "≤15 → 15 · ≤30 → 10 · >30 → 5",
			},
			{
				Key:       "morning_readiness",
				Title:     "Morning readiness",
				Subtitle:  "Bagaimana rasanya saat kamu bangun pagi?",
				InputType: "options",
				Options: []schemaOption{
					{Label: "Lelah / pusing", Value: 1, Points: "10 pts"},
					{Label: "Biasa saja", Value: 2, Points: "20 pts"},
					{Label: "Segar & bertenaga", Value: 3, Points: "30 pts"},
				},
				PointsRule: "value × 10",
			},
			{
				Key:       "wake_frequency",
				Title:     "Wake frequency",
				Subtitle:  "Berapa kali kamu terbangun di tengah malam?",
				InputType: "options",
				Options: []schemaOption{
					{Label: "Tidak pernah", Value: 0, Points: "15 pts"},
					{Label: "1–2 kali", Value: 2, Points: "10 pts"},
					{Label: "Lebih dari 2x", Value: 4, Points: "5 pts"},
				},
				PointsRule: "0 → 15 · ≤2 → 10 · >2 → 5",
			},
			{
				Key:       "pre_sleep_habit",
				Title:     "Kebiasaan sebelum tidur",
				Subtitle:  "Apa yang biasanya kamu lakukan sebelum tidur?",
				InputType: "options",
				Options: []schemaOption{
					{Label: "Gadget / makan berat / pikiran sibuk", Value: 1, Points: "5 pts"},
					{Label: "Campuran", Value: 2, Points: "10 pts"},
					{Label: "Rutinitas relaksasi", Value: 3, Points: "15 pts"},
				},
				PointsRule: "value × 5",
			},
		},
	}
}

func movementSection() schemaSection {
	return schemaSection{
		Key:         "movement",
		Title:       "Basic Movement Screening",
		Icon:        "activity",
		Description: "Self-test gerakan dasar tanpa beban. 3 pertanyaan, di-input mandiri oleh klien.",
		MaxScore:    "0–100 (clamped)",
		Formula:     "(squat × 30 + hip_hinge × 35 + overhead × 35) ÷ 3",
		Questions: []schemaQuestion{
			{
				Key:       "squat",
				Title:     "Bodyweight Squat",
				Subtitle:  "Bagaimana hasil squat tanpa beban kamu?",
				InputType: "options",
				Options: []schemaOption{
					{Label: "Tidak mampu / nyeri", Value: 1, Points: "30 pts (raw)"},
					{Label: "Bisa, tapi ada kompensasi", Value: 2, Points: "60 pts (raw)"},
					{Label: "Mampu squat penuh", Value: 3, Points: "90 pts (raw)"},
				},
				PointsRule: "value × 30",
			},
			{
				Key:       "hip_hinge",
				Title:     "Hip Hinge",
				Subtitle:  "Bagaimana saat membungkuk dengan punggung lurus?",
				InputType: "options",
				Options: []schemaOption{
					{Label: "Punggung melengkung", Value: 1, Points: "35 pts (raw)"},
					{Label: "Hamstring kaku", Value: 2, Points: "70 pts (raw)"},
					{Label: "Punggung netral lurus", Value: 3, Points: "105 pts (raw)"},
				},
				PointsRule: "value × 35",
			},
			{
				Key:       "overhead",
				Title:     "Overhead Reach",
				Subtitle:  "Saat kedua tangan diangkat lurus ke atas?",
				InputType: "options",
				Options: []schemaOption{
					{Label: "Bahu shrug / tertahan di depan", Value: 1, Points: "35 pts (raw)"},
					{Label: "Bisa lurus dengan usaha", Value: 2, Points: "70 pts (raw)"},
					{Label: "Lurus di samping telinga", Value: 3, Points: "105 pts (raw)"},
				},
				PointsRule: "value × 35",
			},
		},
	}
}

func metabolicSection() schemaSection {
	return schemaSection{
		Key:         "metabolic",
		Title:       "Clinical Baseline (Metabolic)",
		Icon:        "flask",
		Description: "Lab values yang di-input oleh trainer/admin saat melakukan review. Hanya 3 nilai ini yang masuk ke scoring engine.",
		MaxScore:    "0–100 (clamped)",
		Formula:     "hba1c_pts + ldl_pts + triglyceride_pts",
		Questions: []schemaQuestion{
			{
				Key:        "hba1c",
				Title:      "HbA1c (NGSP)",
				Subtitle:   "Glycated hemoglobin, indikator gula darah rata-rata 3 bulan.",
				InputType:  "number",
				Unit:       "%",
				PointsRule: "≤5.6 → 35 pts · ≤6.4 → 20 pts · >6.4 → 10 pts",
			},
			{
				Key:        "ldl",
				Title:      "LDL Cholesterol",
				Subtitle:   "Low-density lipoprotein.",
				InputType:  "number",
				Unit:       "mg/dL",
				PointsRule: "<100 → 30 pts · <130 → 20 pts · ≥130 → 10 pts",
			},
			{
				Key:        "triglyceride",
				Title:      "Trigliserida",
				InputType:  "number",
				Unit:       "mg/dL",
				PointsRule: "<150 → 35 pts · <200 → 20 pts · ≥200 → 10 pts",
			},
		},
	}
}

func physicalGroups() []schemaPhysicalGroup {
	return []schemaPhysicalGroup{
		{
			Title: "A. Vital Signs & Respiratory",
			Items: []string{
				"Tekanan Darah (mmHg)",
				"Resting Heart Rate",
				"Saturasi Oksigen / SpO2 (%)",
				"Pola Pernapasan: Diaphragm / Chest / Shallow",
			},
		},
		{
			Title: "B. Circulation & Physical Observation",
			Items: []string{
				"Edema / Water Retention (lokasi: pergelangan kaki/tangan/wajah)",
				"Warna kulit / pucat / sianosis (muka, bibir, ujung jari, kuku)",
				"Keseimbangan berdiri mata terbuka (stabil / goyang)",
			},
		},
		{
			Title: "C. Static Posture Analysis",
			Items: []string{
				"Kepala & Leher: Forward Head, Miring kiri/kanan",
				"Bahu: Rounded, Elevated",
				"Tulang Belakang: Kyphosis, Lordosis, indikasi Scoliosis",
				"Panggul: Anterior Tilt, Posterior Tilt",
				"Lutut: Valgus (X), Varus (O)",
			},
		},
		{
			Title: "D. Basic Movement Screening (detail)",
			Items: []string{
				"Bodyweight Squat — heels lift, knee valgus, nyeri",
				"Hip Hinge — punggung netral / rounding / hamstring kaku",
				"Overhead Reach — lengan lurus / tertahan / shrug",
			},
		},
		{
			Title: "E. Sleep & Recovery Audit (full)",
			Items: []string{
				"Durasi tidur, jam tidur, jam bangun (deskriptif)",
				"Konsistensi (3 level)",
				"Sleep latency, morning readiness, gangguan tengah malam",
				"Kondisi sebelum tidur (4 checkbox: makan berat, gadget, kamar terang, pikiran sibuk)",
			},
		},
		{
			Title: "F. Kesimpulan & Rekomendasi",
			Items: []string{
				"Masalah utama: pernafasan / sirkulasi / metabolisme / inflamasi",
				"Konsumsi obat: Statin, CCB, Beta Blocker, Metformin",
				"Modifikasi program & prioritas",
				"Rekomendasi jam latihan, jam makan terakhir, lifestyle",
			},
		},
	}
}

func flagRules() []schemaFlag {
	return []schemaFlag{
		{
			Key:   "HIGH_INJURY_RISK",
			Label: "High Injury Risk",
			Color: "red",
			Rule:  "movement.squat = 1 (tidak mampu / nyeri)",
		},
		{
			Key:   "RECOVERY_ALERT",
			Label: "Recovery Alert",
			Color: "amber",
			Rule:  "sleep.duration_hours < 6 AND sleep.wake_frequency > 2",
		},
		{
			Key:   "METABOLIC_RED_FLAG",
			Label: "Metabolic Red Flag",
			Color: "red",
			Rule:  "metabolic.hba1c > 6.5 (paid only)",
		},
	}
}

func classificationBands() []schemaClassification {
	return []schemaClassification{
		{
			Score: "Sleep Score",
			Bands: []schemaBand{
				{Label: "Optimal", Range: "≥ 80", Color: "green"},
				{Label: "Compromised", Range: "60–79", Color: "amber"},
				{Label: "Critical", Range: "< 60", Color: "red"},
			},
		},
		{
			Score: "Movement Score",
			Bands: []schemaBand{
				{Label: "Stable", Range: "≥ 80", Color: "green"},
				{Label: "Compensation", Range: "60–79", Color: "amber"},
				{Label: "Dysfunction", Range: "< 60", Color: "red"},
			},
		},
		{
			Score: "Metabolic Score",
			Bands: []schemaBand{
				{Label: "Efficient", Range: "≥ 80", Color: "green"},
				{Label: "At Risk", Range: "60–79", Color: "amber"},
				{Label: "Dysregulated", Range: "< 60", Color: "red"},
			},
		},
	}
}

func buildSchema() assessmentSchema {
	free := schemaTier{
		SystemScoreFormula: "system_score = (sleep × 0.5) + (movement × 0.5)",
		Sections:           []schemaSection{sleepSection(), movementSection()},
	}
	paid := schemaTier{
		SystemScoreFormula: "system_score = (sleep × 0.4) + (movement × 0.3) + (metabolic × 0.3)",
		Sections:           []schemaSection{sleepSection(), movementSection(), metabolicSection()},
	}
	return assessmentSchema{
		Version:         "1.0.0",
		Free:            free,
		Paid:            paid,
		PhysicalGroups:  physicalGroups(),
		Flags:           flagRules(),
		Classifications: classificationBands(),
	}
}

// ────────────────────────────────────────────────────────────────
//  GET /api/assessments/schema
// ────────────────────────────────────────────────────────────────

func (h *AssessmentHandler) GetSchema(w http.ResponseWriter, r *http.Request) {
	response.OK(w, buildSchema())
}
