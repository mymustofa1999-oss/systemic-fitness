# 031 — Nutrition Guidance & Monitoring Engine

Modul rule-based personalisasi nutrisi + monitoring kepatuhan harian. Berdiri sendiri (decoupled dari `nutrition_service`, `food_service`, `daily_journal_service`) dan **gated untuk customer dengan subscription berbayar aktif**.

- **Engine**: pure functions, no I/O — mirror pola [030-basic-assessment.md](030-basic-assessment.md) (`internal/service/assessment_engine.go`).
- **Tech**: Go + pgx, chi router, validator, slog.
- **Versi**: v1 (migration `034_create_nutrition_guidance.sql`).

---

## 1. Arsitektur

```
handler/nutrition_guidance.go
   ↓
service/nutrition_guidance_service.go     (orchestration + DB I/O)
   ↓
service/nutrition_engine.go               (PURE rule engine — no deps)
   ↓
repository/nutrition_guidance_repo.go     (pgx queries)
   ↓
model/models.go                           (structs + enums)
```

Subscription gate dilakukan di middleware:
[`internal/middleware/subscription.go`](../internal/middleware/subscription.go) → `RequirePaidSubscription(SubscriptionInfoFunc)`. Adapter di [`cmd/server/main.go`](../cmd/server/main.go) memetakan `ClientSubscriptionService.GetMySubscription` → `SubscriptionInfo` agar middleware tidak import service (hindari cycle).

---

## 2. Database Schema

Migration: [`database/migrations/034_create_nutrition_guidance.sql`](../database/migrations/034_create_nutrition_guidance.sql)

### `nutrition_health_profiles`
| Kolom | Tipe | Catatan |
|---|---|---|
| `user_id` | UUID PK FK→users | satu profil per user |
| `gender` | TEXT | `male` \| `female` |
| `age_group` | TEXT | `under_18` \| `18_40` \| `41_60` \| `over_60` |
| `female_condition` | TEXT NULL | `normal` \| `pregnant` \| `menopause` |
| `goal` | TEXT | `maintenance` \| `fat_loss` \| `recovery` |
| `weight_kg` | NUMERIC(5,2) | dipakai engine untuk hitung hidrasi |
| `allergies` | TEXT[] | bebas, di-strip dari semua food list |
| `conditions` | TEXT[] | `hypertension` `diabetes` `kidney` `gout` `heart` `cancer` `autoimmune` `hormonal` |
| `created_at`, `updated_at` | TIMESTAMPTZ | |

### `nutrition_daily_logs`
| Kolom | Tipe | Catatan |
|---|---|---|
| `id` | UUID PK | |
| `user_id` | UUID FK→users | |
| `log_date` | DATE | UNIQUE bersama `user_id` |
| `vegetable_intake` | BOOL | +20 |
| `protein_intake` | BOOL | +20 |
| `hydration_ok` | BOOL | +20 |
| `sugar_excess` | BOOL | -20 |
| `diet_violation` | BOOL | -20 |
| `score` | INT | hasil engine, 0..100 |
| `status` | TEXT | `stable` \| `warning` \| `risk` |
| `created_at`, `updated_at` | TIMESTAMPTZ | |

Index: `idx_nutrition_daily_logs_user_date (user_id, log_date DESC)` untuk query 3 skor terakhir cepat.

---

## 3. Rule Engine

File: [`internal/service/nutrition_engine.go`](../internal/service/nutrition_engine.go) — **dependency-free**, dapat di-unit-test (`nutrition_engine_test.go`, semua PASS).

### 3.1 Base diet (default)
- vegetables 50% / protein 25% / carbs 25%
- `hydration_ml = weight_kg * 32` (midpoint 30–35 ml/kg, fallback 2000 jika weight ≤ 0)
- `meal_frequency = "2-3"`
- `allowed_foods` default: broccoli, spinach, kale, carrot, tomato, chicken_breast, fish, egg, tofu, tempeh, brown_rice, oats, sweet_potato, apple, berries, avocado

### 3.2 Condition overlay (priority order)

Diterapkan dengan urutan **kidney → diabetes → heart → hypertension → gout → cancer → autoimmune → hormonal**. Overlay yang lebih awal dapat ditimpa overlay berikutnya untuk key yang sama.

| Condition | nutrition_rules patches | foods patches |
|---|---|---|
| `kidney` | `protein=moderate`, `sodium=low`, `potassium=controlled` | avoid: processed_meat, banana, orange · limited: dairy, nuts |
| `diabetes` | `carb_control=true`, `sugar=low`, `fiber=high` | avoid: sugar, white_rice, soda |
| `heart` | `saturated_fat=low`, `healthy_fat=high` | avoid: fried_food, butter |
| `hypertension` | `sodium_limit_mg=1500` | avoid: processed_food, high_salt |
| `gout` | `purine=low` | avoid: organ_meat, alcohol, sardines |
| `cancer` | `protein=high`, `calorie=adequate` | — |
| `autoimmune` | `profile=balanced`, `avoid=personalized_trigger` | — |
| `hormonal` | `sugar=low`, `fiber=high`, `healthy_fat=high` | — |

### 3.3 Allergy filter
Setelah overlay, semua entri di `allowed_foods` / `limited_foods` / `avoid_foods` di-strip dengan match **substring case-insensitive** terhadap setiap allergen. Mis. allergen `"nuts"` menghapus `"nuts"` dan `"peanut_butter"`.

### 3.4 Scoring & status
```
score = 20·veg + 20·protein + 20·hydration − 20·sugar_excess − 20·diet_violation
score ∈ [0, 100]   (clamped)

status:
  score ≥ 80 → stable
  score ≥ 60 → warning
  score < 60 → risk
```

### 3.5 Alert
Trigger jika **3 skor terbaru (descending log_date)** semua < 60. Response:
```json
{ "alert": true, "message": "consult professional" }
```

### 3.6 Insight
`BuildNutritionInsights(profile, score)` mengembalikan array string Bahasa Indonesia kombinasi status + per-condition tips + (opsional) tips untuk `pregnant`.

---

## 4. API Contract

Base path: `/api/v1/nutrition-guidance`
Middleware (urut): `Authenticate` → `RequirePaidSubscription`.
Semua respons memakai envelope standar `pkg/response`.

### 4.1 `POST /profile` — Upsert health profile

**Request**
```json
{
  "gender": "male",
  "age_group": "18_40",
  "female_condition": "normal",
  "goal": "fat_loss",
  "weight_kg": 70,
  "allergies": ["peanut"],
  "conditions": ["diabetes", "hypertension"]
}
```

Validasi (`go-playground/validator`):
- `gender` required, `oneof=male female`
- `age_group` required, `oneof=under_18 18_40 41_60 over_60`
- `female_condition` opsional, `oneof=normal pregnant menopause`
- `goal` required, `oneof=maintenance fat_loss recovery`
- `weight_kg` `gt=0,lte=500`
- `conditions[]` `oneof=hypertension diabetes kidney gout heart cancer autoimmune hormonal`

**Response 201**
```json
{
  "success": true,
  "data": {
    "user_id": "…",
    "gender": "male",
    "age_group": "18_40",
    "female_condition": "normal",
    "goal": "fat_loss",
    "weight_kg": 70,
    "allergies": ["peanut"],
    "conditions": ["diabetes", "hypertension"],
    "created_at": "…",
    "updated_at": "…"
  }
}
```

### 4.2 `GET /plan` — Personalised plan + today's score

**Response 200**
```json
{
  "success": true,
  "data": {
    "diet_plan": {
      "allowed_foods": ["broccoli","spinach","chicken_breast","brown_rice","apple"],
      "limited_foods": ["dairy","nuts"],
      "avoid_foods":   ["processed_food","high_salt","sugar","white_rice","soda"]
    },
    "nutrition_rules": {
      "vegetables_pct": 50, "protein_pct": 25, "carbs_pct": 25,
      "hydration_ml": 2240, "meal_frequency": "2-3",
      "carb_control": true, "sugar": "low", "fiber": "high",
      "sodium_limit_mg": 1500
    },
    "daily_score": 80,
    "status": "stable",
    "insight": [
      "Pertahankan pola makan saat ini, kondisi stabil.",
      "Kontrol karbohidrat dan tingkatkan serat.",
      "Batasi natrium di bawah 1500 mg per hari."
    ]
  }
}
```

**404** — bila profile belum dibuat:
```json
{ "success": false, "message": "Nutrition profile not set. Please complete your health profile first." }
```

### 4.3 `POST /daily/log` — Submit today's intake

**Request**
```json
{
  "log_date": "2026-04-09",
  "vegetable_intake": true,
  "protein_intake": true,
  "hydration_ok": false,
  "sugar_excess": true,
  "diet_violation": true
}
```

`log_date` wajib format `YYYY-MM-DD`. Upsert by `(user_id, log_date)`.

**Response 201**
```json
{
  "success": true,
  "data": {
    "log_date": "2026-04-09",
    "daily_score": 0,
    "status": "risk",
    "alert": { "alert": true, "message": "consult professional" }
  }
}
```

### 4.4 `GET /daily/result?date=YYYY-MM-DD` — Lookup result

`date` opsional → default `today (UTC)`. Bila tidak ada log untuk tanggal tersebut, response score 0 / status `stable` (tanpa alert).

```json
{
  "success": true,
  "data": {
    "log_date": "2026-04-09",
    "daily_score": 60,
    "status": "warning",
    "alert": null
  }
}
```

### 4.5 Error: subscription gate

Customer free / no-sub → semua endpoint di atas membalas:
```http
HTTP/1.1 403 Forbidden
```
```json
{ "success": false, "message": "paid subscription required" }
```

Klien Flutter mendeteksi pesan ini → throw `PaidSubscriptionRequiredException` dan redirect ke upgrade page.

---

## 5. Files

| Layer | File |
|---|---|
| Migration | [`database/migrations/034_create_nutrition_guidance.sql`](../database/migrations/034_create_nutrition_guidance.sql) |
| Model | [`internal/model/models.go`](../internal/model/models.go) (section *Nutrition Guidance & Monitoring Engine*) |
| Repository | [`internal/repository/nutrition_guidance_repo.go`](../internal/repository/nutrition_guidance_repo.go) |
| Engine (pure) | [`internal/service/nutrition_engine.go`](../internal/service/nutrition_engine.go) |
| Engine tests | [`internal/service/nutrition_engine_test.go`](../internal/service/nutrition_engine_test.go) |
| Service | [`internal/service/nutrition_guidance_service.go`](../internal/service/nutrition_guidance_service.go) |
| Handler | [`internal/handler/nutrition_guidance.go`](../internal/handler/nutrition_guidance.go) |
| Middleware | [`internal/middleware/subscription.go`](../internal/middleware/subscription.go) |
| Wiring | [`cmd/server/main.go`](../cmd/server/main.go) — repo, service, handler, route group `/api/v1/nutrition-guidance`, adapter `subscriptionInfoFn` |

---

## 6. Testing

### Unit (engine)
```bash
go test ./internal/service/ -run "ComputeDailyScore|ClassifyNutrition|EvaluateNutritionAlert|BuildDietPlan|BaseRulesHydration" -v
```
Coverage rule yang penting:
- score ranges & clamp
- status thresholds 80 / 60
- alert triggers only when 3 latest < 60
- condition priority order (kidney applied before hypertension; both rules co-exist)
- allergy substring filter strips from all 3 lists

### End-to-end (manual / curl)

```bash
TOKEN=...   # JWT customer dengan subscription paid aktif

# 1. Upsert profile
curl -X POST http://localhost:8080/api/v1/nutrition-guidance/profile \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"gender":"male","age_group":"18_40","goal":"fat_loss","weight_kg":70,"allergies":["peanut"],"conditions":["diabetes","hypertension"]}'

# 2. Get personalised plan
curl http://localhost:8080/api/v1/nutrition-guidance/plan -H "Authorization: Bearer $TOKEN"

# 3. Log 3 hari berturut score < 60 untuk trigger alert
for d in 2026-04-07 2026-04-08 2026-04-09; do
  curl -X POST http://localhost:8080/api/v1/nutrition-guidance/daily/log \
    -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -d "{\"log_date\":\"$d\",\"sugar_excess\":true,\"diet_violation\":true}"
done

# 4. Lookup result
curl "http://localhost:8080/api/v1/nutrition-guidance/daily/result?date=2026-04-09" \
  -H "Authorization: Bearer $TOKEN"
```

Subscription gate:
```bash
# Customer free → 403
curl -i http://localhost:8080/api/v1/nutrition-guidance/plan -H "Authorization: Bearer $FREE_TOKEN"
# HTTP/1.1 403 Forbidden
# {"success":false,"message":"paid subscription required"}
```

---

## 7. Constraint Design

- **Pure rule-based** — tanpa AI/ML, deterministik, mudah audit & test.
- **Decoupled** — modul berdiri sendiri tanpa menyentuh `nutrition_service.go` atau `daily_journal_service.go` existing.
- **Mobile-friendly** — single `GET /plan` mengembalikan semua yang dibutuhkan UI (diet, rules, score, status, insight); tidak perlu beberapa round-trip.
- **Server-side gate** = source of truth. Klien (Flutter `subscription_helper.dart`) hanya UX hint.
- **Scalable** — overlay rules bisa ditambah dengan menulis fungsi `overlayX` baru + entry di `nutritionConditionPriority` map; tidak ada perubahan storage.
