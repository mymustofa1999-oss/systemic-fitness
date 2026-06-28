# 003 — SF Assessment v2 (Schema)

## Why

Spec **SF Master Platform Spec v1.0 / 2026** §03 mengubah assessment menjadi 3 phase berurutan (~25–30 pertanyaan): Phase A (Level + klasifikasi + program type), Phase B (10Q rest audit + Chronobiology Window), Phase C (7Q nutrition). Output utama: Rest Score, Nutrition Score, Movement Score, dan System Score komposit (Movement 35% + Nutrition 35% + Rest 30%, owner-tunable).

**Strategi: coexist** — flow lama (free 10-step, paid 14-step) tetap hidup. Row baru di table `assessments` ditandai `version = 'v2'`; row lama tetap `version = 'v1'`.

Referensi: `SF_Master_Platform_Spec.docx` §03–§04, halaman 333–456 (Chronobiology Window per Kondisi).

## What changed

### Migration `database/migrations/043_assessment_v2_columns.sql`

Additive ALTER TABLE:

| Kolom baru | Tipe | Kegunaan |
|---|---|---|
| `version` | `VARCHAR(8) NOT NULL DEFAULT 'v1'` | Penanda v1/v2; existing rows otomatis 'v1' |
| `phase_a_payload` | `JSONB` | Input Q1+Q2+Q3 + movement test (jika preventive) |
| `phase_b_payload` | `JSONB` | Input 10 pertanyaan rest audit |
| `phase_c_payload` | `JSONB` | Input 7 pertanyaan nutrition |
| `rest_score` | `NUMERIC(5,2)` | Output Phase B (0–100) |
| `nutrition_score` | `NUMERIC(5,2)` | Output Phase C (0–100) |
| `movement_score_v2` | `NUMERIC(5,2)` | Akumulasi dari sesi (Phase 5+) |
| `system_score_v2` | `NUMERIC(5,2)` | Komposit 35/35/30 |
| `chronobiology_window` | `JSONB` | `{ideal_start, ideal_end, alt_start, alt_end, avoid, override_reason, hard_cap}` |
| `classification_id` | `UUID FK condition_classifications` | Denormalized output Phase A |
| `specific_condition_id` | `UUID FK specific_conditions` | Denormalized |
| `physical_status_level` | `VARCHAR(16)` | `level_0_1` / `level_2_3` / `level_4_5_perf` |
| `program_type` | `VARCHAR(40)` | Hasil engine: `condition_specific` / `preventive` / `performance_*_*_*` / `waitlist` |

Constraint baru: `chk_assessments_version_payload` — v1 wajib `sleep_input` & `movement_input`, v2 wajib `phase_a_payload`. NOT NULL pada kolom v1 (sleep_input, movement_input, sleep_score, recovery_score, movement_score, system_score, sleep_class, movement_class, insight) **direlaksasi** menjadi nullable supaya v2 row tidak harus mengisinya. Constraint baru memastikan tidak ada row hybrid yang tidak konsisten.

Index baru: `idx_assessments_version_v2` (partial, untuk queue v2), `idx_assessments_classification`.

### Migration `database/migrations/044_system_score_weights.sql`

Tabel baru `system_score_weights` (id, name, movement_pct, nutrition_pct, rest_pct, is_active, notes, created_by, timestamps). Constraint sum=100 + nonneg. Partial unique index: hanya 1 baris boleh `is_active = TRUE`.

Seed: 1 baris **SF Default** dengan 35/35/30, aktif.

## How to verify

```bash
cd systemic-fitness-api
make migrate-up

# Cek schema
psql -c "\d assessments" | grep -E "version|phase_|score|chronobiology|classification_id|program_type"
# Cek seed weights
psql -c "SELECT name, movement_pct, nutrition_pct, rest_pct, is_active FROM system_score_weights;"
# Existing v1 rows tetap pakai version='v1'
psql -c "SELECT version, COUNT(*) FROM assessments GROUP BY version;"

# Round-trip rollback
make migrate-down  # turun 044, 043
make migrate-up    # naik lagi
```

## Rollback notes

- `043_down`: drop semua constraint baru + 13 kolom baru, restore NOT NULL kolom v1. **Data v2 hilang** — pastikan tidak ada production row v2 sebelum rollback.
- `044_down`: drop table `system_score_weights`. Engine fallback ke `model.DefaultSystemScoreWeights()` (35/35/30) jika tidak ada row aktif.
- Engine code tetap kompatibel: jika `system_score_weights` table tidak ada, `GetActiveScoreWeights` akan error → service catch sebagai warning dan pakai default.
