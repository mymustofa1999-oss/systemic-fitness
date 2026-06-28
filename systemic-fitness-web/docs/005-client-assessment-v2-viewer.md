# 005 — Client Assessment v2 Viewer (Read-only)

## Why

Setelah klien submit Phase A/B/C dari mobile (Fase 5), Consultant/Admin perlu UI untuk membaca hasilnya — System Score komposit, Chronobiology Window, payload Phase A/B/C, dan flag klinis. Tidak ada edit/review action di Fase 3 (review session card masuk Fase 7 Consultant Dashboard).

## What changed

### API additions (minor)

- Handler baru `LatestForUser` di [`internal/handler/assessment_v2.go`](../../systemic-fitness-api/internal/handler/assessment_v2.go).
- Route baru: `GET /api/v2/assessments/user/{userId}/latest`, gated dengan `RequireMinRole(Trainer)` — admin/owner/finance/trainer dapat akses, client **tidak** (HTTP 403, sudah diuji).
- Service & repo tidak berubah — `Service.Latest(ctx, userID)` sudah generic.

### Hook
[`src/hooks/useAssessmentV2.ts`](../src/hooks/useAssessmentV2.ts) — `useLatestAssessmentV2(userId)` (GET admin endpoint) + `useAssessmentV2ById(id)` (GET single). Type definitions `AssessmentV2`, `PhaseAInput/B/C`, `ChronobiologyWindow`, `ProgramType`. `retry: false` agar 404 (klien belum punya v2) tidak retry-storm.

### Halaman baru
[`src/app/(dashboard)/clients/[userId]/assessment-v2/page.tsx`](../src/app/(dashboard)/clients/[userId]/assessment-v2/page.tsx):

- **System Score gauge** kiri (Recharts `RadialBarChart`) — angka komposit + tier label (OPTIMAL ≥80, STABLE ≥60, COMPROMISED ≥40, CRITICAL <40). Movement/Nutrition/Rest score breakdown di bawahnya.
- **Phase A summary** card — Physical Status, Program Type, Klasifikasi & Kondisi Spesifik (slug), Gender/Age, Tujuan Utama. Flag chips bila ada.
- **Chronobiology Window** card — Ideal / Alternatif / Hindari / Hard Cap dalam 4 cell warna berbeda + override_reason quote di bawah.
- **Phase B & C raw payload** — JSON pretty-print di card terpisah agar Consultant bisa cek input mentah.
- Empty state khusus untuk klien yang belum submit v2 (404 → "Belum ada Asesmen v2").

### Branding
Palette SF baru. Background halaman `bg-sf-warmWhite`, gauge card `bg-sf-deepNavy text-white`, accent `sf.warmGold`. Font lengkap (Serif/Sans/Mono).

### Tone of voice
- "Klien" (bukan "user"), "Asesmen" (bukan "tes"), "Sesi" (bukan "latihan").
- Angka & status dalam DM Mono. Nama klien render via `useUser(userId)` → `data.full_name`.

## How to verify

1. Pastikan ada klien yang sudah submit v2 (smoke test Fase 2 sudah create 4 row v2 untuk Budi).
2. Login admin → buka URL `/clients/c5776df3-0b35-43fe-8718-6ca32726a757/assessment-v2`.
3. Expected:
   - Gauge tampil dengan score (mis. 99 dari hasil Performance Men 35-45).
   - Phase A summary lengkap (level_4_5_perf, performance_men_35_45).
   - Chronobiology Window 06:00–09:00 dengan alt 15:00–17:00.
   - Phase B & C payload JSON ter-render.
4. Test 404: pakai userId yang belum punya v2 → empty state.
5. Test RBAC: login sebagai client (Budi), buka URL admin → API return 403 → halaman tampil empty state error message.

## Open questions / future work

- Tombol "Verify / Approve" untuk Tier 3 — masuk Fase 7 (Consultant Dashboard).
- Trend chart skor antar reassessment — masuk Fase 8.
- Link langsung ke Lab Consultation booking — Fase 6.

## Rollback notes

- API: revert handler `LatestForUser` + 1 baris route mount di `cmd/server/main.go`.
- Web: hapus 1 hook + 1 halaman folder.
- Tidak ada perubahan schema DB — rollback aman & instan.
