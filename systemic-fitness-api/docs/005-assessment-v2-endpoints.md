# 005 — SF Assessment v2 (Endpoints)

## Why

Phase 2 menambahkan group `/api/v2/assessments` untuk konsumsi mobile (Fase 5) dan web admin viewer (Fase 3). v1 endpoints (`/api/assessments/*`) **tidak berubah**.

## What changed

### Layer baru

- [`internal/repository/assessment_v2_repo.go`](../internal/repository/assessment_v2_repo.go) — `AssessmentV2Repository` (CreateV2, GetV2ByID, LatestV2ByUser, GetActiveScoreWeights, UpdateActiveScoreWeights).
- [`internal/service/assessment_v2_service.go`](../internal/service/assessment_v2_service.go) — orchestrasi: Phase A → engine → resolve classification/specific by slug → Phase B/C jika ada → Phase B+C → System Score → persist + flags.
- [`internal/handler/assessment_v2.go`](../internal/handler/assessment_v2.go) — HTTP layer (5 endpoint).

### Wiring di [`cmd/server/main.go`](../cmd/server/main.go)

```
r.Route("/v2/assessments", func(r chi.Router) {
    r.Post("/", assessmentV2Handler.Submit)
    r.Get("/latest", assessmentV2Handler.Latest)
    r.Get("/score-weights", assessmentV2Handler.GetWeights)
    r.With(middleware.RequireRole(model.RoleOwner)).
        Patch("/score-weights", assessmentV2Handler.UpdateWeights)
    r.Get("/{id}", assessmentV2Handler.Get)
})
```

### Endpoint table

| Method | Path | Auth | Body / Query | Response |
|---|---|---|---|---|
| POST  | `/api/v2/assessments` | JWT (any logged-in role) | `{ phase_a, phase_b?, phase_c? }` | `AssessmentV2` (201) |
| GET   | `/api/v2/assessments/latest` | JWT | — | `AssessmentV2` for current user, 404 jika belum ada |
| GET   | `/api/v2/assessments/{id}` | JWT | — | `AssessmentV2`. Client hanya bisa baca milik sendiri (403 lainnya) |
| GET   | `/api/v2/assessments/score-weights` | JWT | — | `SystemScoreWeights` (default 35/35/30) |
| PATCH | `/api/v2/assessments/score-weights` | Owner only | `{ name, movement_pct, nutrition_pct, rest_pct, notes? }` (sum=100) | Updated `SystemScoreWeights` |

### Submit payload contoh

**Phase A only** (cepat lihat program type sebelum lanjut Phase B/C):
```json
{
  "phase_a": {
    "physical_status_level": "level_4_5_perf",
    "has_medical_condition": true,
    "classification_slug": "cardiorespiratory",
    "specific_condition_slug": "hipertensi",
    "primary_goal": "control_medical"
  }
}
```

Response:
```json
{
  "success": true,
  "data": {
    "id": "...",
    "version": "v2",
    "program_type": "condition_specific",
    "physical_status_level": "level_4_5_perf",
    "classification_id": "...",
    "specific_condition_id": "...",
    "flags": []
  }
}
```

**Phase A + B + C** (full submission untuk hasil komposit):
```json
{
  "phase_a": { ... },
  "phase_b": {
    "duration_hours": 7.0,
    "consistency": 2,
    "sleep_latency": 4,        // >45 mnt → trigger override
    "morning_readiness": 2,
    "wake_frequency": 2,
    "pre_sleep_habit": 2,
    "bedtime_bucket": 3,
    "wake_time_bucket": 3,
    "activity_profile": "executive",
    "dinner_time": 3
  },
  "phase_c": {
    "meal_pattern": 2,
    "food_dominance": 4,
    "hydration": 3,
    "routine_foods": ["coffee", "dairy"],
    "restrictions": [],
    "supplements": ["multivitamin"],
    "nutrition_goal": "energy_vitality"
  }
}
```

Response berisi: `rest_score`, `nutrition_score`, `system_score`, `chronobiology_window`, `flags`.

### Validation

Handler pakai `validateStruct` (`go-playground/validator`):
- Phase A: `physical_status_level` in {level_0_1, level_2_3, level_4_5_perf}, `gender` in {women, men}, `age_bucket` in {35_45, 46_60}, `primary_goal` in 3 enum, `classification_slug` & `specific_condition_slug` 2–80 char.
- Phase B: numeric ranges per spec (Q1 4–10 jam, Q2 1–3, Q3 1–4, Q4 1–3, Q5 1–4, Q6 1–3, Q7 1–5, Q8 1–5, Q9 enum 6 profil, Q10 1–5).
- Phase C: numeric ranges + `nutrition_goal` enum.

Response envelope tetap `{ success, data, message?, errors? }`.

## How to verify

```bash
cd systemic-fitness-api
go build ./... && ./bin/server &

# 1) Phase A only — Hipertensi
TOKEN="<jwt-client>"
curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
     -d '{"phase_a":{"physical_status_level":"level_4_5_perf","has_medical_condition":true,"classification_slug":"cardiorespiratory","specific_condition_slug":"hipertensi","primary_goal":"control_medical"}}' \
     http://localhost:8080/api/v2/assessments | jq
# Expect: program_type = "condition_specific", chronobiology_window = null
#         (B not submitted), flags = []

# 2) Full submission — expect chronobiology window LOCKED 15:00-17:00 + override
curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
     -d @phase-abc-hipertensi.json \
     http://localhost:8080/api/v2/assessments | jq

# 3) Latest
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v2/assessments/latest | jq

# 4) Score weights
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v2/assessments/score-weights | jq
# Expect: 35/35/30

# 5) Owner-only update weights to 40/35/25
OWNER="<jwt-owner>"
curl -X PATCH -H "Authorization: Bearer $OWNER" -H "Content-Type: application/json" \
     -d '{"name":"Custom 40/35/25","movement_pct":40,"nutrition_pct":35,"rest_pct":25}' \
     http://localhost:8080/api/v2/assessments/score-weights | jq

# 6) Negative test (sum != 100)
curl -X PATCH -H "Authorization: Bearer $OWNER" -H "Content-Type: application/json" \
     -d '{"name":"Bad","movement_pct":30,"nutrition_pct":30,"rest_pct":30}' \
     http://localhost:8080/api/v2/assessments/score-weights
# Expect 400
```

## Rollback notes

- Drop 3 file baru (repo/service/handler) + 3 baris init di `main.go` + route group `/v2/assessments`. v1 endpoints tetap utuh.
- Jika row v2 sudah dibuat di production: jangan hapus column dulu — set feature flag (belum implementasi) atau biarkan endpoint return 410 Gone.
