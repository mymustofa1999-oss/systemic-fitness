# 002 — SF Master: Klasifikasi & Kondisi Spesifik (Endpoints)

## Why

Phase 1 menambahkan endpoint REST untuk konsumsi Web Admin (CRUD master) dan Mobile (read-only saat Phase A assessment di Fase 5). Pattern: handler → service → repository, sama dengan modul `medicines` / `equipments` yang sudah ada.

## What changed

### Layer baru

- [`internal/model/condition.go`](../internal/model/condition.go) — type `FocusPillar` (FC/CC/MC) + `PhysicalStatusRouting`.
- [`internal/repository/condition_repo.go`](../internal/repository/condition_repo.go) — `ConditionRepository` dengan method:
  - `ListClassifications`, `GetClassificationByID`, `GetClassificationBySlug`, `Create/Update/DeleteClassification`
  - `ListSpecificConditions(filter)`, `GetSpecificByID`, `Create/Update/DeleteSpecific`
  - `ListPhysicalStatusLevels`
- [`internal/service/condition_service.go`](../internal/service/condition_service.go) — `ConditionService` thin wrapper (logger + error wrap).
- [`internal/handler/condition.go`](../internal/handler/condition.go) — `ConditionHandler` HTTP layer.

### Wiring di [`cmd/server/main.go`](../cmd/server/main.go)

Tambahan repo + service + handler init, lalu route group baru:

```
r.Route("/master", func(r chi.Router) {
    r.Route("/condition-classifications", { GET, POST(admin+), GET/{id}, PUT/{id}(admin+), DELETE/{id}(admin+) })
    r.Route("/specific-conditions",       { GET[?classification], POST(admin+), GET/{id}, PUT/{id}(admin+), DELETE/{id}(admin+) })
    r.Get("/physical-status-levels", ...)
})
```

Auth: semua endpoint butuh JWT (sudah enforced di parent group `/api`). Mutation gated dengan `RequireMinRole(RoleAdmin)`.

### Endpoint table

| Method | Path | Auth | Body / Query | Response |
|--------|------|------|--------------|----------|
| GET    | `/api/master/condition-classifications` | JWT | `?include_inactive=true` (opt) | `[ConditionClassification]` |
| POST   | `/api/master/condition-classifications` | Admin+ | `{ slug, label, description?, focus_pillar, full_program_formula?, daily_reset_formula?, sort_order?, is_active? }` | `ConditionClassification` |
| GET    | `/api/master/condition-classifications/{id}` | JWT | — | `ConditionClassification` |
| PUT    | `/api/master/condition-classifications/{id}` | Admin+ | (sama dengan POST) | `ConditionClassification` |
| DELETE | `/api/master/condition-classifications/{id}` | Admin+ | — | `{message: "Classification deleted"}` |
| GET    | `/api/master/specific-conditions` | JWT | `?classification=<slug>&include_inactive=true` | `[SpecificCondition]` (joined dgn `classification_slug`) |
| POST   | `/api/master/specific-conditions` | Admin+ | `{ classification_id, slug, label, description?, severity_default?, notes?, sort_order?, is_active? }` | `SpecificCondition` |
| GET    | `/api/master/specific-conditions/{id}` | JWT | — | `SpecificCondition` |
| PUT    | `/api/master/specific-conditions/{id}` | Admin+ | (sama dengan POST) | `SpecificCondition` |
| DELETE | `/api/master/specific-conditions/{id}` | Admin+ | — | `{message: "Specific condition deleted"}` |
| GET    | `/api/master/physical-status-levels` | JWT | `?include_inactive=true` (opt) | `[PhysicalStatusLevel]` |

Validation: handler gunakan `validateStruct` (`go-playground/validator`) — `slug` 2–80 char, `focus_pillar` ∈ {FC,CC,MC}, `severity_default` ∈ {mild,moderate,severe,monitor}, `classification_id` UUID.

Response envelope mengikuti format standar API (`{ success, data, message?, errors?, meta? }`).

## How to verify

1. Build & run:
   ```bash
   cd systemic-fitness-api
   go build ./... && ./bin/server
   ```
2. Smoke test (ganti `<JWT>` dengan token admin/owner):
   ```bash
   curl -H "Authorization: Bearer <JWT>" \
        http://localhost:8080/api/master/condition-classifications | jq
   # Expect 5 rows
   curl -H "Authorization: Bearer <JWT>" \
        "http://localhost:8080/api/master/specific-conditions?classification=cardiorespiratory" | jq
   # Expect ~7 rows
   curl -H "Authorization: Bearer <JWT>" \
        http://localhost:8080/api/master/physical-status-levels | jq
   # Expect 3 rows (level_0_1, level_2_3, level_4_5_perf)
   ```
3. Negative test:
   ```bash
   # Client role: list OK, create FORBIDDEN
   curl -X POST -H "Authorization: Bearer <CLIENT_JWT>" \
        -H "Content-Type: application/json" \
        -d '{"slug":"x","label":"y","focus_pillar":"FC"}' \
        http://localhost:8080/api/master/condition-classifications
   # Expect 403
   ```

## Rollback notes

- Hapus 4 file baru (model/repo/service/handler) + 3 baris wiring di `main.go` + route group `/master`.
- Atau set feature flag (belum implementasi) jika ingin disable temporary.
- Schema rollback lihat `001-condition-master-schema.md`.
