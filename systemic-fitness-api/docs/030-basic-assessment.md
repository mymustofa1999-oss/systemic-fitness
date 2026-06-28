# 030 — Basic Assessment (Free + Paid)

## Overview

Basic Assessment adalah fitur onboarding evaluasi sistemik yang dijalankan **setelah user register**. Sumber datanya dari `Basic Assessment Systemic Fitness.xlsx` (sheet *Clinical Baseline* + *Physical Screening*).

Tujuannya:

1. Mengevaluasi 3 sistem inti — **Recovery (sleep)**, **Movement**, dan **Metabolic** — untuk setiap user.
2. Menghasilkan **score**, **classification**, **risk flags**, **insight**, dan **recommendation** secara otomatis tanpa intervensi manual (deterministic engine di server).
3. Mendukung dua tier:
   - **Free** — bisa diakses publik (lead generation) **dan** authenticated user.
   - **Paid** — wajib login, menambahkan lab values (HbA1c, LDL, Trigliserida), dan **direview oleh trainer** sebelum dianggap final.

## Tier Comparison

| Aspek | Free | Paid |
|---|---|---|
| Auth | Publik atau auth | Wajib auth |
| Sleep input | ✅ | ✅ |
| Movement input | ✅ | ✅ |
| Metabolic input (lab) | ❌ | ✅ |
| Sleep score | ✅ | ✅ |
| Recovery score | ✅ | ✅ |
| Movement score | ✅ | ✅ |
| Metabolic score | ❌ | ✅ |
| System score | sleep·0.5 + movement·0.5 | sleep·0.4 + movement·0.3 + metabolic·0.3 |
| Trainer review | ❌ | ✅ (status `submitted` → `verified`/`revised`) |
| Re-take | Unlimited (tersimpan sebagai histori penuh) | Unlimited |

## Database Schema

### Table: `assessments`

| Column | Type | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID | PK, auto | ID unik |
| `user_id` | UUID | FK → users, nullable | NULL untuk submission anonim publik |
| `tier` | `assessment_tier` | NOT NULL | `free` atau `paid` |
| `status` | `assessment_status` | NOT NULL, default `submitted` | `submitted` / `verified` / `revised` |
| `sleep_input` | JSONB | NOT NULL | Raw sleep input (audit) |
| `movement_input` | JSONB | NOT NULL | Raw movement input |
| `metabolic_input` | JSONB | nullable | Lab values (paid only) |
| `sleep_score` | SMALLINT | NOT NULL | 0–100 |
| `recovery_score` | SMALLINT | NOT NULL | 0–100 |
| `movement_score` | SMALLINT | NOT NULL | 0–100 |
| `metabolic_score` | SMALLINT | nullable | 0–100, paid only |
| `system_score` | SMALLINT | NOT NULL | Total weighted |
| `sleep_class` | `assessment_classification` | NOT NULL | `optimal`/`compromised`/`critical` |
| `movement_class` | `assessment_classification` | NOT NULL | `stable`/`compensation`/`dysfunction` |
| `metabolic_class` | `assessment_classification` | nullable | `efficient`/`at_risk`/`dysregulated` |
| `flags` | TEXT[] | NOT NULL, default `{}` | Risk flag identifiers |
| `insight` | TEXT | NOT NULL | Auto-generated primary issue |
| `recommendations` | TEXT[] | NOT NULL, default `{}` | Auto-generated recommendation list |
| `reviewed_by` | UUID | FK → users, nullable | Trainer reviewer (paid) |
| `reviewed_at` | TIMESTAMPTZ | nullable | Saat review dilakukan |
| `reviewer_notes` | TEXT | nullable | Catatan trainer |
| `created_at` | TIMESTAMPTZ | NOT NULL, auto | |
| `updated_at` | TIMESTAMPTZ | NOT NULL, auto | |

**Constraint:** `tier='paid' → metabolic_input IS NOT NULL`

**Indexes:**
- `idx_assessments_user_created` — `(user_id, created_at DESC) WHERE user_id IS NOT NULL` (history queries)
- `idx_assessments_pending_review` — `(created_at DESC) WHERE tier='paid' AND status='submitted'`
- `idx_assessments_tier`, `idx_assessments_status`

### Table: `assessment_leads`

Capture lead info untuk submission anonim publik. Saat user dengan email yang sama register, baris ini di-link ke user_id baru via `LinkLeadToUser`.

| Column | Type | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID | PK | |
| `assessment_id` | UUID | FK → assessments, NOT NULL | |
| `email` | VARCHAR(255) | NOT NULL, regex check | |
| `full_name` | VARCHAR(100) | nullable | |
| `phone` | VARCHAR(20) | nullable | |
| `source` | VARCHAR(50) | nullable | `web`, `landing-x`, dll |
| `converted_user_id` | UUID | FK → users, nullable | Diisi saat user register |
| `created_at` | TIMESTAMPTZ | NOT NULL, auto | |

### ENUM types

```sql
CREATE TYPE assessment_tier   AS ENUM ('free', 'paid');
CREATE TYPE assessment_status AS ENUM ('submitted', 'verified', 'revised');
CREATE TYPE assessment_classification AS ENUM (
    'optimal', 'compromised', 'critical',
    'stable',  'compensation', 'dysfunction',
    'efficient', 'at_risk', 'dysregulated'
);
```

Migration file: [`database/migrations/030_create_assessments.sql`](../database/migrations/030_create_assessments.sql).

---

## Scoring Engine (Single Source of Truth)

Semua rumus diimplementasi di [`internal/service/assessment_engine.go`](../internal/service/assessment_engine.go) sebagai **pure functions** (zero deps) supaya unit-testable. Semua submit handler — public, free authed, paid, dan trainer review — memanggil engine yang sama. **Tidak ada engine duplikat di mobile.**

### Sleep Score (0–100)

```
duration_pts:
  hours >= 7  -> 25
  hours >= 6  -> 18
  else        -> 10
consistency_pts = consistency_value * 10        (value: 1..3)
latency_pts:
  minutes <= 15 -> 15
  minutes <= 30 -> 10
  else          -> 5
wake_pts:
  wake_count == 0 -> 15
  wake_count <= 2 -> 10
  else            -> 5
pre_sleep_pts = pre_sleep_value * 5             (value: 1..3)

sleep_score = duration_pts + consistency_pts + latency_pts + wake_pts + pre_sleep_pts
```

### Recovery Score (0–100)

```
morning_pts  = morning_readiness * 20           (value: 1..3, max 60)
wake_pts     = (sama dengan sleep wake_pts)
latency_pts  = (sama dengan sleep latency_pts)
duration_pts = (sama dengan sleep duration_pts)

recovery_score = clamp(morning_pts + wake_pts + latency_pts + duration_pts, 0, 100)
```

### Movement Score (0–100)

```
squat_pts    = squat * 30        (value: 1..3)
hinge_pts    = hinge * 35
overhead_pts = overhead * 35

movement_score = (squat_pts + hinge_pts + overhead_pts) / 3
```

### Metabolic Score (0–100, paid only)

```
hba1c_pts:
  hba1c <= 5.6 -> 35
  hba1c <= 6.4 -> 20
  else         -> 10
ldl_pts:
  ldl < 100 -> 30
  ldl < 130 -> 20
  else      -> 10
trig_pts:
  trig < 150 -> 35
  trig < 200 -> 20
  else       -> 10

metabolic_score = hba1c_pts + ldl_pts + trig_pts
```

### System Score (Weighted Total)

```
free:  system_score = sleep * 0.5 + movement * 0.5
paid:  system_score = sleep * 0.4 + movement * 0.3 + metabolic * 0.3
```

### Classification Thresholds

| Pillar | ≥ 80 | ≥ 60 | < 60 |
|---|---|---|---|
| Sleep | `optimal` | `compromised` | `critical` |
| Movement | `stable` | `compensation` | `dysfunction` |
| Metabolic | `efficient` | `at_risk` | `dysregulated` |

### Risk Flags

| Flag | Trigger |
|---|---|
| `HIGH_INJURY_RISK` | `squat == 1` |
| `RECOVERY_ALERT` | `sleep_hours < 6 AND wake > 2` |
| `METABOLIC_RED_FLAG` | `hba1c > 6.5` (paid only) |

### Auto Insight

```
sleep < 60      -> "Primary Issue: Recovery Dysfunction"
movement < 60   -> "Primary Issue: Movement Dysfunction"
metabolic < 60  -> "Primary Issue: Metabolic Dysfunction"   (paid only)
else            -> "System Stable"
```

### Auto Recommendations

```
recovery issue  -> "Sleep optimization + nervous system reset"
movement issue  -> "Mobility + corrective training"
metabolic issue -> "Conditioning + nutrition strategy"
```

Multiple recommendations bisa muncul bersamaan; engine return slice.

---

## API Endpoints

### 1. Submit Free Assessment (Public)

```
POST /api/public/assessments/free
```

Tidak butuh auth. Capture lead info via email + optional contact.

**Body:**

```json
{
  "email": "lead@example.com",
  "full_name": "Jane Doe",
  "phone": "+628123456789",
  "source": "landing-page-x",
  "sleep": {
    "duration_hours": 7.5,
    "consistency": 3,
    "latency_minutes": 12,
    "morning_readiness": 3,
    "wake_frequency": 0,
    "pre_sleep_habit": 3
  },
  "movement": {
    "squat": 3,
    "hip_hinge": 2,
    "overhead": 2
  }
}
```

**Response (201):**

```json
{
  "success": true,
  "message": "Assessment submitted",
  "data": {
    "id": "5ab8a3a0-...",
    "user_id": null,
    "tier": "free",
    "status": "submitted",
    "scores": {
      "sleep_score": 90,
      "recovery_score": 100,
      "movement_score": 80,
      "system_score": 85
    },
    "sleep_class": "optimal",
    "movement_class": "stable",
    "flags": [],
    "insight": "System Stable",
    "recommendations": [],
    "created_at": "2026-04-08T07:00:00Z",
    "updated_at": "2026-04-08T07:00:00Z"
  }
}
```

### 2. Submit Free Assessment (Authenticated)

```
POST /api/assessments/free
Authorization: Bearer <token>
```

**Body:**

```json
{
  "sleep": { /* same as above */ },
  "movement": { /* same as above */ }
}
```

Response sama dengan endpoint publik, tapi `user_id` terisi.

### 3. Submit Paid Assessment

```
POST /api/assessments/paid
Authorization: Bearer <token>
```

**Body:**

```json
{
  "sleep": { /* ... */ },
  "movement": { /* ... */ },
  "metabolic": {
    "hba1c": 5.4,
    "ldl": 95,
    "triglyceride": 130,
    "medications": ["Metformin"]
  }
}
```

**Response (201):** result dengan `tier: "paid"`, `status: "submitted"`, `metabolic_score`, dan `metabolic_class` terisi.

### 4. List My Assessments (History)

```
GET /api/assessments?page=1&limit=20
Authorization: Bearer <token>
```

Returns paginated list of all assessments milik user (free + paid) ordered by `created_at DESC`.

### 5. Get Assessment by ID

```
GET /api/assessments/{id}
Authorization: Bearer <token>
```

**RBAC:**
- `client` → hanya bisa lihat miliknya sendiri (`user_id == caller`)
- `trainer`+ → bisa lihat semua

### 6. List Pending Review (Trainer+)

```
GET /api/assessments/pending-review?page=1&limit=20
Authorization: Bearer <trainer_token>
```

Returns paid assessments dengan `status='submitted'` ordered by `created_at ASC` (oldest first).

### 7. Apply Trainer Review (Trainer+)

```
PATCH /api/assessments/{id}/review
Authorization: Bearer <trainer_token>
```

**Body:**

```json
{
  "status": "verified",
  "reviewer_notes": "Lab values checked against original report. Approved.",
  "metabolic": {
    "hba1c": 5.5,
    "ldl": 96,
    "triglyceride": 132,
    "medications": ["Metformin"]
  }
}
```

- Jika `metabolic` diberikan, scores akan **dihitung ulang** menggunakan engine sebelum disimpan.
- `status` harus salah satu dari `verified` atau `revised`.
- Hanya berlaku untuk `tier='paid'`.

---

## Lead Linking Flow

```
1. Visitor mengisi free assessment di landing page (anonim).
   → POST /api/public/assessments/free
   → Row dibuat di assessments (user_id = NULL)
   → Row dibuat di assessment_leads (email tersimpan)

2. Beberapa hari kemudian visitor register di mobile app.
   → POST /api/auth/register
   → AuthService.Register() membuat user
   → Setelah profile dibuat, hook AssessmentRepository.LinkLeadToUser dijalankan:
     a) UPDATE assessment_leads SET converted_user_id = <new user_id>
        WHERE LOWER(email) = LOWER(<reg email>) AND converted_user_id IS NULL
     b) UPDATE assessments SET user_id = <new user_id>
        WHERE id = ANY(matched ids) AND user_id IS NULL

3. User langsung punya histori assessment di /api/assessments.
```

Hook ini **best-effort** — jika gagal, registrasi tetap sukses dan error hanya di-log.

---

## Mobile Integration (systemic-fitness-mobile-new)

| File | Tujuan |
|---|---|
| `lib/data/api_config.dart` | Endpoint constants (`assessmentFreePublic`, `assessmentFree`, `assessmentPaid`, `assessmentsMine`, `assessmentById`) |
| `lib/data/pref_data.dart` | `setHasCompletedAssessment` / `getAssessmentSkipped` |
| `lib/online_models/AssessmentModels.dart` | Input + result model dengan manual `fromJson` |
| `lib/pages/assessment/assessment_intro_page.dart` | Landing setelah register dengan CTA Mulai/Skip |
| `lib/pages/assessment/free_assessment_page.dart` | 9-step PageView wizard |
| `lib/pages/assessment/paid_assessment_page.dart` | Form dengan lab values + sleep/movement detail |
| `lib/pages/assessment/assessment_result_page.dart` | Score ring + pillar bars + flags + recommendations |
| `lib/pages/assessment/assessment_history_page.dart` | List histori user |
| `lib/router/app_router.dart` | Routes `/assessment/intro`, `/assessment/free`, `/assessment/paid`, `/assessment/result/:id`, `/assessment/history` |
| `lib/pages/splash_page.dart` | Cek `hasCompletedAssessment` & `assessmentSkipped` |
| `lib/pages/auth/register_page.dart` | Setelah sukses register → `context.go(AppRoutes.assessmentIntro)` |
| `lib/pages/home/dashboard_tab.dart` | Banner CTA "Complete your Basic Assessment" jika belum |

---

## Smoke Testing (curl)

### Setup

```bash
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"client@example.com","password":"password123"}' \
  | jq -r '.data.tokens.access_token')

TRAINER_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"trainer@example.com","password":"password123"}' \
  | jq -r '.data.tokens.access_token')
```

### 1. Public free submission

```bash
curl -X POST http://localhost:8080/api/public/assessments/free \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "lead@example.com",
    "full_name": "Test Lead",
    "sleep": {"duration_hours": 7.5, "consistency": 3, "latency_minutes": 10, "morning_readiness": 3, "wake_frequency": 0, "pre_sleep_habit": 3},
    "movement": {"squat": 3, "hip_hinge": 3, "overhead": 3}
  }' | jq
```

### 2. Authenticated free

```bash
curl -X POST http://localhost:8080/api/assessments/free \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "sleep": {"duration_hours": 6.5, "consistency": 2, "latency_minutes": 25, "morning_readiness": 2, "wake_frequency": 1, "pre_sleep_habit": 2},
    "movement": {"squat": 2, "hip_hinge": 2, "overhead": 2}
  }' | jq
```

### 3. Paid

```bash
ASSESSMENT_ID=$(curl -s -X POST http://localhost:8080/api/assessments/paid \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "sleep": {"duration_hours": 7.0, "consistency": 2, "latency_minutes": 18, "morning_readiness": 2, "wake_frequency": 1, "pre_sleep_habit": 2},
    "movement": {"squat": 2, "hip_hinge": 2, "overhead": 2},
    "metabolic": {"hba1c": 5.8, "ldl": 110, "triglyceride": 160}
  }' | jq -r '.data.id')

echo "Created assessment: $ASSESSMENT_ID"
```

### 4. List my assessments

```bash
curl "http://localhost:8080/api/assessments?page=1&limit=10" \
  -H "Authorization: Bearer $TOKEN" | jq
```

### 5. Trainer review

```bash
curl -X PATCH "http://localhost:8080/api/assessments/$ASSESSMENT_ID/review" \
  -H "Authorization: Bearer $TRAINER_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "status": "verified",
    "reviewer_notes": "Lab values match the report"
  }' | jq
```

### 6. Lead linking verification

```bash
# Submit anonymous
curl -X POST http://localhost:8080/api/public/assessments/free \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "newuser@example.com",
    "sleep": {"duration_hours": 8, "consistency": 3, "latency_minutes": 10, "morning_readiness": 3, "wake_frequency": 0, "pre_sleep_habit": 3},
    "movement": {"squat": 3, "hip_hinge": 3, "overhead": 3}
  }'

# Then register with the same email
curl -X POST http://localhost:8080/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "newuser@example.com",
    "password": "supersecure",
    "full_name": "New User",
    "role": "client"
  }'

# Verify linking in psql
psql -d fitcoach -c "
  SELECT a.id, a.user_id, l.email, l.converted_user_id
  FROM assessments a
  JOIN assessment_leads l ON l.assessment_id = a.id
  WHERE l.email = 'newuser@example.com';
"
```

Both `user_id` and `converted_user_id` should now be populated.

---

## Engine Unit Tests

Run the dedicated engine tests:

```bash
cd systemic-fitness-api
go test ./internal/service -run "TestCompute|TestClassify|TestGenerate" -v
```

Expected output: 21 passing tests covering every formula in the spec, all classification thresholds, every flag, and every insight/recommendation branch. See [`assessment_engine_test.go`](../internal/service/assessment_engine_test.go) for the cases.

---

## Out-of-Scope (Future Work)

- **Web admin UI** (`systemic-fitness-web`) untuk trainer review queue & detail page — endpoint backend `GET /assessments/pending-review` dan `PATCH /assessments/{id}/review` sudah siap.
- **Email notification ke trainer** saat ada paid assessment baru — bisa di-extend lewat existing notification service.
- **PDF export** hasil assessment untuk shared dengan klien.
- **Trend chart** di dashboard (history visualization, line chart system score over time).
