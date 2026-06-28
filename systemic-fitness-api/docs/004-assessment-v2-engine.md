# 004 — SF Assessment v2 (Engine & Scoring)

## Why

Engine adalah pure-function module yang bisa diuji tanpa DB. Semua formula scoring & resolver Chronobiology hidup di sini agar review klinis client (Citra Hann) bisa dilakukan dengan cara membaca 1 file kode + 1 file test.

Referensi: `SF_Master_Platform_Spec.docx` §03 (Phase B/C scoring weights), halaman 333–456 (Chronobiology Window per Kondisi), §04 (System Score 35/35/30).

## What changed

### File baru

- [`internal/model/assessment_v2.go`](../internal/model/assessment_v2.go) — types: `PhaseAInput` / `PhaseBInput` / `PhaseCInput`, `ChronobiologyWindow`, `SystemScoreWeights`, `SystemScoreV2`, `AssessmentV2`, `ProgramType` enum + helper.
- [`internal/service/assessment_v2_engine.go`](../internal/service/assessment_v2_engine.go) — pure functions (no DB, no logger).
- [`internal/service/assessment_v2_engine_test.go`](../internal/service/assessment_v2_engine_test.go) — 18 unit tests, all passing.

### Phase A — `ResolveProgramType`

Rute user setelah Q1+Q2+Q3:

```
level_0_1 / level_2_3                        → waitlist
level_4_5_perf + has_medical_condition       → condition_specific
level_4_5_perf + !has_medical + Women 35-45  → performance_women_35_45
level_4_5_perf + !has_medical + Women 46-60  → performance_women_46_60
level_4_5_perf + !has_medical + Men 35-45    → performance_men_35_45
level_4_5_perf + !has_medical + Men 46-60    → performance_men_46_60
level_4_5_perf + !has_medical + (no gender)  → preventive
```

### Phase B — `ComputeRestScore` (0..100)

| Pertanyaan | Bobot maks |
|---|---|
| B1 Durasi tidur | 22 (lihat tabel di kode) |
| B2 Konsistensi | 18 |
| B3 Sleep latency | 15 |
| B4 Morning readiness | 15 |
| B5 Wake frequency | 15 |
| B6 Pre-sleep habit | 15 |
| **Total** | **100** |

Score dihitung sebagai jumlah poin (clamp 0..100). B7–B10 dipakai untuk Chronobiology resolver, bukan score.

### Phase B — `ResolveChronobiologyWindow`

Hierarki override (sesuai spec):

1. **Base window** dari `classificationWindow(specificSlug, programType)`. Hampir semua kondisi memiliki window default; fallback Preventive = `06:30–08:30` ATAU `15:00–17:00`.
2. **B9 Activity Profile** preempt:
   - `shift_worker` → window malam `19:00–20:30` (hard cap 21:00 tetap).
   - `traveller` → anchor sore `15:00–17:00` (tidak hitung jam tidur).
3. **B3 Sleep Latency = 4 (>45 mnt)**:
   - Jika kondisi tidak hard-lock sore, geser ke `15:00–17:00`, alt = base.
   - Jika kondisi sudah hard-lock sore, tambah catatan konfirmasi.
4. **B4 Morning Readiness = 1 (lelah/pusing)**:
   - Jika kondisi tidak hard-lock sore dan window saat ini masih pagi, naikkan ke `14:00–17:00`.

Hard-lock sore (tidak bisa digeser ke pagi): hipertensi, penyakit jantung, asma, PPOK, gangguan syaraf pusat, autoimun, alergi kronis, asam urat, HNP, spondylosis, CKD, batu ginjal, hiperkalemia ringan, neuropati perifer, osteoarthritis.

### Phase C — `ComputeNutritionScore` (0..100)

Bobot per pertanyaan: C1 20%, C2 20%, C3 20%, C4 20%, C5 5% (data only), C6 5% (data only), C7 10%. Per pertanyaan diberi 0–100 lalu di-rata-ratakan. Item risiko C4 (organ_meat, seafood, alcohol, soda_energy, fried, high_salt, sweet_drinks): makin banyak, makin rendah.

### `ComputeSystemScoreV2(movement *float64, nutrition, rest, weights)`

```
total = movement * mPct + nutrition * nPct + rest * rPct
```

Movement biasanya nil saat assessment v2 dibuat (belum ada sesi). Engine reweight nutrition + rest agar tetap meaningful:

```
total = (nutrition * nPct + rest * rPct) / (nPct + rPct)
```

Default weights = 35/35/30 dari `model.DefaultSystemScoreWeights()`. Bisa diubah via `PATCH /api/v2/assessments/score-weights` (owner only).

### Flags

- `WAITLIST_LEVEL_0_3` — program type waitlist (Level 0–1 / 2–3).
- `REST_RECOVERY_ALERT` — durasi <6 jam + wake frequency ≥3.
- `META_BLOOD_SUGAR_RISK` — makan malam setelah 20:00 + sleep latency ≥30 mnt.
- `RENAL_HYDRATION_CRITICAL` — hidrasi <4 gelas + kondisi CKD/asam urat/batu ginjal.

## How to verify

```bash
cd systemic-fitness-api
go test ./internal/service/ -run "Resolve|ComputeRest|ComputeNutrition|ComputeSystemScoreV2|GenerateV2" -v
# Expect 18/18 pass

# Smoke change: edit b1Points in assessment_v2_engine.go to break a test —
# the corresponding `TestComputeRestScore_*` should fail. Revert to confirm.
```

## Rollback notes

- Engine adalah pure function, tidak ada side-effect. Hapus `assessment_v2_engine.go` + test file = rollback bersih.
- Service yang merujuk ke engine (`assessment_v2_service.go`) akan ikut perlu di-rollback.
