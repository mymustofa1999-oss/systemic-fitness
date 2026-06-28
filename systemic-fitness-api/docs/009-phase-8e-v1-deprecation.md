# 009 — SF Phase 8e: v1 Assessments Endpoint Deprecation

## Why

Phase 2–5 sudah build & ship Asesmen v2 (Phase A/B/C, Chronobiology, System Score 35/35/30) di route `/api/v2/assessments/*`. Endpoint v1 lama (`/api/assessments/*`) sebenarnya sudah tidak dipakai mobile baru (semua entry point sejak Fase 5 mengarah ke v2), tapi:

1. Masih ada code di mobile lama / web admin yang mungkin call v1
2. Tidak ada signal formal ke client bahwa endpoint ini akan hilang
3. Tidak ada telemetri untuk tahu siapa saja yang masih hit v1

Phase 8e menambah **deprecation marker** sesuai standar (RFC 8594 Sunset + draft `Deprecation` header) dan slog warn per-call. Removal tidak dilakukan di phase ini — itu Phase 9 setelah telemetri menunjukkan zero traffic dari client production.

Reference:
- https://datatracker.ietf.org/doc/html/rfc8594 (Sunset)
- https://datatracker.ietf.org/doc/draft-ietf-httpapi-deprecation-header (Deprecation)

## What changed

### Middleware baru

| File | Isi |
|---|---|
| [`internal/middleware/deprecation.go`](../internal/middleware/deprecation.go) | `Deprecated(successorPath, sunsetAt)` — sets `Deprecation: true`, `Sunset: <RFC 1123>`, `Link: <successor>; rel="successor-version"` headers, dan log slog.Warn per-request dengan path + method + caller user_id + user_agent |

### CORS update

| File | Isi |
|---|---|
| [`internal/middleware/cors.go`](../internal/middleware/cors.go) | `ExposedHeaders` ditambah `Deprecation` & `Sunset` supaya browser/JS client bisa baca header dari fetch response |

### Route mounting

[`cmd/server/main.go`](../cmd/server/main.go) — pasang `r.Use(middleware.Deprecated(...))` di awal route group `/assessments` (v1):

```go
r.Route("/assessments", func(r chi.Router) {
    r.Use(middleware.Deprecated(
        "/api/v2/assessments",
        time.Date(2026, 10, 27, 0, 0, 0, 0, time.UTC),
    ))
    // ... existing v1 handlers (unchanged)
})
```

**Sunset date: 2026-10-27** (~6 bulan setelah Phase 7 GA). Bisa diundur kalau telemetri masih menunjukkan traffic real saat mendekati tanggal itu.

## Affected endpoints

Semua route di bawah `/api/assessments/*` (v1) sekarang return Deprecation headers:

```
GET    /api/assessments/schema
GET    /api/assessments/latest
POST   /api/assessments/free
POST   /api/assessments/paid
GET    /api/assessments/
GET    /api/assessments/pending-review
GET    /api/assessments/all
GET    /api/assessments/{id}
GET    /api/assessments/{id}/previous
PATCH  /api/assessments/{id}/review
```

Endpoint v2 (`/api/v2/assessments/*`) **tidak** ter-mark deprecated.

## How to verify

### Curl smoke test (sudah dilakukan)

```bash
# v1 endpoint — punya deprecation headers
curl -i -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/assessments | grep -i "deprecation\|sunset\|^link"
# Output:
#   Deprecation: true
#   Link: </api/v2/assessments>; rel="successor-version"
#   Sunset: Tue, 27 Oct 2026 00:00:00 GMT

# v2 endpoint — bersih, tidak ada Deprecation header
curl -i -H "Authorization: Bearer $TOKEN" http://localhost:8080/api/v2/assessments/latest | grep -i "deprecation\|sunset"
# (no output)
```

### Slog log inspection

```bash
# Fire 1 request ke v1 endpoint, cek log:
tail -f /tmp/sf-api.log | grep "deprecated route"

# Output:
# {"level":"WARN","msg":"[deprecated route]","path":"/api/assessments",
#  "method":"GET","successor":"/api/v2/assessments",
#  "sunset":"Tue, 27 Oct 2026 00:00:00 GMT",
#  "user_id":"c5776df3-...","user_agent":"curl/8.7.1"}
```

Production: gunakan log aggregator (Grafana Loki / Vercel logs / etc.) untuk filter `msg="[deprecated route]"` dan analyze traffic per `user_agent` / `user_id`.

### Build

```bash
go build ./...           # ✓ pass
go vet ./...             # ✓ pass (implicit, no error output)
```

## Behavior notes

- Headers di-set **sebelum** handler jalan, jadi ada di response 200, 4xx, dan 5xx — semua tetap signal deprecation.
- Tidak ada perubahan response body / status code — purely additive.
- Kalau client (mobile/web) tidak peduli sama header ini, tidak ada efek functional. Tapi tooling modern (axios interceptor, fetch wrapper) bisa baca `response.headers.get('Deprecation')` dan kirim warning ke developer console.

## CI/CD

Tidak ada migration / seed baru. Pipeline biasa (build + PM2 restart) cukup untuk apply.

## Rollback

`git revert <commit>` — middleware hilang dari route group, headers tidak lagi dikirim. Tidak ada efek breaking ke client.

## Next (Phase 9 — actual removal)

Pre-condition sebelum hapus v1:

1. Telemetri 30 hari konsekutif menunjukkan **zero non-internal traffic** ke `/api/assessments/*`. Internal traffic = sumber yang kita kontrol (admin SSH, debug curl).
2. Mobile client di production tidak ada lagi yang pakai versi pre-Phase 5 (cek FCM device data / Crashlytics).
3. Web admin: cari `useAssessments` (v1 hook) di repo web — kalau masih ada, migrate dulu.

Setelah removal:
- Drop `internal/handler/assessment.go` + handler/service/repo v1 chain
- Migration baru untuk drop kolom v1-only di `assessments` table (sleep_input, movement_input, dll. yang sudah relaxed di migration 043)
- Update mobile `api_config.dart` untuk hapus `assessmentSchema/Free/Paid/...` constants
