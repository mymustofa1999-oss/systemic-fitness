# 003 — Mobile Assessment v2 Flow (Phase 5)

## Why

API `/api/v2/assessments` + master condition + score weights sudah live di production sejak Fase 1–3. Mobile masih pakai flow v1 lama (sleep/movement/metabolic, 10–14 step). Fase 5 = ganti UI mobile dengan flow Phase A/B/C yang konsumsi API v2 + brand SF baru, sambil mempertahankan flow v1 sebagai fallback.

Reference: `SF_Master_Platform_Spec.docx` §03 (Assessment Flow), halaman 154–155 (Waitlist Level 0–3), halaman 158 (Basic Movement Test).

## What changed

### Models & API
- [`lib/online_models/AssessmentV2Models.dart`](../lib/online_models/AssessmentV2Models.dart) — manual JSON serialization (sesuai pattern existing project): `ConditionClassificationModel`, `SpecificConditionModel`, `PhysicalStatusLevelModel`, `PhaseAInput` (+ `PhaseAMovementTest`), `PhaseBInput`, `PhaseCInput`, `ChronobiologyWindow`, `AssessmentV2Result` (+ `prettyProgramType` & `scoreTier` helpers).
- [`lib/data/api_config.dart`](../lib/data/api_config.dart) — endpoint baru: `assessmentV2`, `assessmentV2Latest`, `assessmentV2ById(id)`, `assessmentV2ScoreWeights`, `masterConditionClassifications`, `masterSpecificConditions`, `masterPhysicalStatusLevels`.

### Folder baru `lib/pages/assessment_v2/` (8 file + 3 widget)

| File | Isi |
|---|---|
| `assessment_v2_intro_screen.dart` | Landing 3-phase (A/B/C) + estimasi 7 menit + CTA "Mulai Asesmen" |
| `assessment_v2_draft.dart` | In-memory singleton untuk hold input antar screens |
| `phase_a_screen.dart` | 3 pertanyaan dengan reveal-progressively + branching (medical Y → klasifikasi+spesifik+goal; medical N → gender+age) |
| `phase_a_waitlist_screen.dart` | Level 0–1/2–3 → waitlist hero + CTA "Daftarkan Minat Saya" (TODO endpoint Phase 6) |
| `phase_a_movement_test_screen.dart` | Preventive path: 3 gerakan self-report (squat/hip hinge/overhead) skor 0–2, total <4 → toast saran konsultasi gratis |
| `phase_b_screen.dart` | 10 pertanyaan tidur — B1 slider 4–10 jam, B2–B10 single-select |
| `phase_c_screen.dart` | 7 pertanyaan nutrisi — C1/C2/C3/C7 single-select wajib, C4/C5/C6 multi-select + open text. Submit `POST /api/v2/assessments` di akhir |
| `assessment_v2_result_screen.dart` | Hero gauge System Score + 3 progress bar + Phase A summary + Chronobiology Window 4 cell + flags klinis |
| `widgets/phase_progress_indicator.dart` | `PhaseHeader`, `V2SelectCard<T>`, `V2MultiChip`, `V2BottomCta` |
| `widgets/condition_picker.dart` | Modal bottom sheet untuk pilih klasifikasi + kondisi spesifik (load dari `/api/master/*`) |
| `widgets/system_score_gauge.dart` | `SystemScoreGauge` (fl_chart PieChart radial) + `ScoreBreakdownBar` |

### Router
[`lib/router/app_router.dart`](../lib/router/app_router.dart) — 7 konstanta + 7 GoRoute mounts:
- `/assessment-v2/intro`
- `/assessment-v2/phase-a`
- `/assessment-v2/waitlist`
- `/assessment-v2/movement-test`
- `/assessment-v2/phase-b`
- `/assessment-v2/phase-c`
- `/assessment-v2/result/:id`

### Entry-point updates
- [`lib/pages/splash_page.dart`](../lib/pages/splash_page.dart) — kalau user belum complete assessment → arahkan ke `/assessment-v2/intro` (sebelumnya `/assessment/intro` v1).
- [`lib/pages/auth/register_page.dart`](../lib/pages/auth/register_page.dart) — setelah register sukses → `/assessment-v2/intro`.
- [`lib/pages/home/dashboard_tab.dart`](../lib/pages/home/dashboard_tab.dart) — assessment banner card tap → `/assessment-v2/intro`.
- Flow v1 lama (`/assessment/intro`, `/assessment/free`, `/assessment/paid`) **tidak dihapus** — tetap accessible via direct URL untuk user lama yang sudah submit data v1.

## Branching logic Phase A

```
Q1 Physical Status:
  level_0_1 / level_2_3 → push /assessment-v2/waitlist (program belum tersedia)
  level_4_5_perf        → reveal Q2

Q2 Has Medical Condition:
  Yes → reveal classification picker + specific condition picker + Q3
        → continue to /assessment-v2/phase-b (skip movement test)
  No  → reveal gender (women/men) + age_bucket (35_45/46_60)
        → push /assessment-v2/movement-test → /assessment-v2/phase-b

Q3 Primary Goal (only when has_medical = true):
  control_medical / hormonal_feminine / stamina_masculine
```

## Submit payload & response

`POST /api/v2/assessments`:
```json
{
  "phase_a": { ... },
  "phase_b": { ... },   // optional, ada kalau lulus movement test (skor ≥4) atau condition-specific path
  "phase_c": { ... }
}
```

Response → `AssessmentV2Result`:
- `program_type` (condition_specific / preventive / performance_*) — drive UI tier rekomendasi
- `chronobiology_window { ideal_start, ideal_end, alt_start, alt_end, avoid, override_reason, hard_cap }` — ditampilkan sebagai 4-cell card di result screen
- `rest_score`, `nutrition_score`, `system_score` — System Score gauge + 3 breakdown bar (Movement nil → "Movement Score akan terisi saat anda mulai sesi pertama")
- `flags[]` — clinical alerts diterjemahkan ke human-readable (mis. `WAITLIST_LEVEL_0_3` → "Akses program belum dibuka untuk kondisi mobilitas anda — masuk waitlist.")

## How to verify

1. `flutter pub get && flutter analyze lib/pages/assessment_v2/` — 0 error.
2. Run debug build di Xiaomi (`SF Mobile - Xiaomi 23049PCD8G (Debug)`) — config default arah ke production API yang sudah punya master + score weights.
3. Test scenarios:
   - **Waitlist:** Level 0–1 → langsung waitlist screen → "Lain kali saja" kembali ke dashboard.
   - **Condition-specific:** Level 4–5 + Ya kondisi → pilih Cardiorespiratory + Hipertensi + control_medical → Phase B (semua 10) → Phase C (4 wajib) → submit → result dengan window LOCK SORE 15.00–17.00.
   - **Preventive:** Level 4–5 + Tidak ada medical + Wanita 35–45 → movement test (skor ≥4) → Phase B → Phase C → result Performance Women 35–45 dengan window 06.00–09.00.
4. Hasil: row `assessments` di prod DB punya `version='v2'`, payload Phase A/B/C lengkap, classification_id terisi.
5. Cross-check via web admin: `/clients/<userId>/assessment-v2` menampilkan hasil yang sama.

## Catatan implementasi

- **In-memory draft** (`AssessmentV2Draft.instance`) dipakai untuk pass state antar screens. Kalau app di-kill di tengah, flow ulang dari awal — assessment <7 menit, persistence via SharedPreferences over-engineering untuk Rilis 1.
- **Movement test < 4** tidak block flow — hanya tampilkan toast saran konsultasi gratis 15 menit. Endpoint booking konsultasi belum ada (akan di Phase 6 bersama Lab Consultation).
- **Master endpoint** dipanggil 2x saat condition-picker dibuka (sekali per modal). Cache via `ApiService.getWithRetry` retry mechanism — bukan persistent cache.
- Semua screen pakai SF brand (Deep Navy / Warm Gold / Warm White / DM Serif Display / DM Sans / DM Mono) — konsisten dengan onboarding v2.
- Bottom CTA pakai `V2BottomCta` reusable yang handle disabled state + loading + hint text.

## Rollback notes

- Hapus folder `lib/pages/assessment_v2/`.
- Revert imports + 7 GoRoute mounts + 7 konstanta route di `app_router.dart`.
- Revert 3 entry-point edits (splash/dashboard/register) — kembalikan `AppRoutes.assessmentIntro`.
- API endpoint v2 tetap aktif (deployment Fase 1-3 tidak berubah).
- Flow v1 lama (`/assessment/intro` dst.) tetap utuh.
