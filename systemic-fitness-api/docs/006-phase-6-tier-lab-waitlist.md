# 006 — SF Phase 6: Tier v2 + Lab Consultation + Tier 4 Waitlist

## Why

Phase 6 menyatukan 3 pekerjaan API yang saling terkait:

1. **Tier pricing v2** — pricing structure dari spec §05 (Free + 4 Tier + Lab Consultation add-on). Plan lama (basic/pro/elite) di-mark legacy supaya tidak muncul di subscription page baru, tapi subscription existing tetap valid.
2. **Lab Consultation** — wajib untuk Tier 3 sebelum program aktif. Booking → Consultant assign → schedule → complete dengan ringkasan hasil.
3. **Tier 4 Waitlist** — Tier 4 (Trainer on-site) belum dibuka. Sekaligus dipakai oleh Phase A waitlist screen untuk Level 0–3 mobility (program belum tersedia untuk kondisi mobilitas terbatas).

Nutrition Guidance text dihasilkan template-based via `/api/nutrition-guidance`.

Reference: `SF_Master_Platform_Spec.docx` §05 (Struktur Harga & Tier Final), halaman 154–155 (Level 0–3 waitlist).

## What changed

### Migrations baru

| File | Isi |
|---|---|
| `database/migrations/045_payment_plans_v2_tiers.sql` | Tambah kolom `is_legacy`. Mark plan basic/pro/elite jadi legacy (is_active=false). INSERT 7 plan v2: Free, Tier 1–3 monthly + quarterly (15% off), Tier 4 waitlist, Lab Consultation add-on |
| `database/migrations/046_create_lab_consultations.sql` | Table `lab_consultations` (user_id, consultant_id FK ke users, assessment_id FK, payment_id FK, status enum-via-CHECK, fee_amount default 350000, scheduled_at, completed_at, result_summary, result_payload JSONB) |
| `database/migrations/047_create_tier4_waitlist.sql` | Table `tier4_waitlist_entries` (full_name, email, phone, city, source `tier4`/`level_0_3`/`other`, status `new`/`contacted`/`converted`/`closed`, admin_note, contacted_at) |
| `database/seeds/021_seed_sf_phase6_menu.sql` | 2 menu sidebar: Lab Consultations + Tier 4 Waitlist (owner/admin) |

### Layer baru

- [`internal/repository/lab_consultation_repo.go`](../internal/repository/lab_consultation_repo.go) — Create / GetByID / List(filter user/status) / Update.
- [`internal/repository/tier4_waitlist_repo.go`](../internal/repository/tier4_waitlist_repo.go) — Create / GetByID / List(filter status/source) / UpdateStatus.
- [`internal/service/lab_consultation_service.go`](../internal/service/lab_consultation_service.go) + [`internal/service/tier4_waitlist_service.go`](../internal/service/tier4_waitlist_service.go) — thin orchestration + slog logging.
- [`internal/handler/phase_six.go`](../internal/handler/phase_six.go) — kedua handler dalam satu file (related entities Phase 6).

### Endpoint table

| Method | Path | Auth | Body / Query | Response |
|---|---|---|---|---|
| POST   | `/api/v2/tier4-waitlist` | JWT | `{ full_name, email, phone?, city?, source, assessment_id?, note? }` | `Tier4WaitlistEntry` 201 |
| GET    | `/api/v2/tier4-waitlist` | Admin+ | `?status=&source=` | `[Tier4WaitlistEntry]` |
| PATCH  | `/api/v2/tier4-waitlist/{id}/status` | Admin+ | `{ status, admin_note? }` | `{ message }` |
| POST   | `/api/v2/lab-consultations` | JWT (client books for self) | `{ assessment_id?, booking_note?, preferred_at? }` | `LabConsultation` 201 |
| GET    | `/api/v2/lab-consultations` | JWT — client sees own; admin+ sees all (or filter `?user_id=`) | `?status=&user_id=` | `[LabConsultation]` |
| GET    | `/api/v2/lab-consultations/{id}` | JWT — ownership check untuk client | — | `LabConsultation` |
| PATCH  | `/api/v2/lab-consultations/{id}` | Admin+ | `{ consultant_id?, status, scheduled_at?, completed_at?, result_summary?, result_payload? }` | `LabConsultation` |

### Wiring di [`cmd/server/main.go`](../cmd/server/main.go)

Repo + service + handler init untuk Lab + Tier4. Route group:
```
r.Route("/v2/tier4-waitlist", { POST, GET (admin+), PATCH /{id}/status (admin+) })
r.Route("/v2/lab-consultations", { POST, GET, GET /{id}, PATCH /{id} (admin+) })
```

## Tier rename support (jawaban user)

Admin **bisa rename tier** lewat endpoint existing yang sudah ada sejak Phase pre-SF:

```
PUT /api/payments/plans/{id}    (Admin role)
{
  "name": "Premium Plus",          // ← rename
  "description": "...",
  "price": 499000,
  "currency": "IDR",
  "features": [...],
  "max_clients": null,
  "is_active": true
}
```

UI: web admin → `/dashboard/payments/plans` → klik plan → edit form. Field `name`, `description`, `price`, `features` semua editable.

**JANGAN ubah field `tier`** (slug `sf_tier_1` dst.) — itu dipakai engine untuk routing program type. Display name boleh bebas, slug fixed.

## How to verify

1. Apply migrations: deploy → CI auto-run via run-sql-dir.sh.
2. Verify 4 plan v2 + 2 quarterly + 1 lab + 1 tier4 muncul:
   ```sql
   SELECT name, tier, price, billing_period, is_active, is_legacy
   FROM payment_plans
   ORDER BY sort_order;
   ```
3. Smoke test endpoint:
   ```bash
   # Client join waitlist
   curl -X POST -H "Authorization: Bearer $CLIENT_JWT" -H "Content-Type: application/json" \
        -d '{"full_name":"Budi","email":"budi@example.com","source":"level_0_3"}' \
        https://api.systemicfitnesshealth.com/api/v2/tier4-waitlist
   # Client book lab consultation
   curl -X POST -H "Authorization: Bearer $CLIENT_JWT" -H "Content-Type: application/json" \
        -d '{"booking_note":"Test booking"}' \
        https://api.systemicfitnesshealth.com/api/v2/lab-consultations
   # Admin list waitlist
   curl -H "Authorization: Bearer $ADMIN_JWT" \
        https://api.systemicfitnesshealth.com/api/v2/tier4-waitlist?status=new
   ```

## Rollback notes

- Migration 045 down: drop `is_legacy` + delete plan v2 + restore plan basic/pro/elite is_active=true. Subscription user yang sudah pakai plan baru akan break — pastikan tidak ada client active subscription ke plan v2 sebelum rollback.
- Migration 046/047 down: DROP TABLE saja (data hilang).
- Seed 021: `DELETE FROM menus WHERE code IN ('sf_lab_consultations','sf_tier4_waitlist')`.

## Next phase

Phase 7 — Consultant role enum + RBAC + Consultant Dashboard pages.
