# 004 — System Score Weights (Owner Editor)

## Why

Spec `§04` menetapkan System Score sebagai weighted average tiga dimensi:
**Movement 35% + Nutrition 35% + Rest 30%** (default). Owner perlu UI untuk
menyesuaikan bobot ini bila data lapangan menunjukkan satu dimensi terlalu
dominan/lemah. Weights live di table `system_score_weights` (Fase 2 API);
halaman ini menjadi UI yang konsumsi endpoint `PATCH /api/v2/assessments/score-weights` (owner-only).

## What changed

### Hook
[`src/hooks/useSystemScoreWeights.ts`](../src/hooks/useSystemScoreWeights.ts) — `useSystemScoreWeights()` (GET) + `useUpdateSystemScoreWeights()` (PATCH). Toast otomatis on success/error.

### Halaman baru
[`src/app/(dashboard)/system-score/page.tsx`](../src/app/(dashboard)/system-score/page.tsx) — owner editor:

- 3 slider (Movement / Nutrition / Rest) dengan number input + bar visualisasi.
- Auto-validation: sum harus 100; tombol Simpan disabled bila invalid atau form tidak dirty.
- Live preview System Score menggunakan formula yang **identik** dengan API engine: `(m*mPct + n*nPct + r*rPct) / 100` untuk skor klien hipotetis (80/70/60).
- Tombol "Reset Default" → restore 35/35/30 di form (belum simpan).
- Card preview gelap (Deep Navy + Warm Gold) menampilkan System Score real-time saat slider digerakkan.

### Branding
Palette SF baru: `bg-sf-warmWhite`, button utama `sf-cta-primary` (Warm Gold), preview card `bg-sf-deepNavy text-white`. Font DM Sans untuk body, DM Mono untuk angka.

### Menu
Seed `020_seed_sf_assessment_v2_menu.sql` menambah entry `sf_system_score_weights` di group "SF Master", **owner-only** privilege.

## How to verify

1. Login sebagai owner (`admin@fitcoach.app` / `FitCoach@2024`).
2. Sidebar → "SF Master" → "Bobot System Score".
3. Slider Movement diset 40, Nutrition 35, Rest 25 → Total: 100 ✓ (badge hijau). Tombol Simpan aktif.
4. Klik "Simpan Bobot" → toast success. Refresh → nilai persist (lihat juga `psql ... SELECT name, movement_pct, nutrition_pct, rest_pct, is_active FROM system_score_weights`).
5. Submit assessment baru via `/api/v2/assessments` → System Score akan menggunakan bobot baru.
6. Login sebagai admin (bukan owner) → menu **tidak muncul** (privilege owner-only).

## Cross-project link

API endpoint backing this page: `systemic-fitness-api/docs/005-assessment-v2-endpoints.md` § Score Weights.

## Rollback notes

- Hapus folder `src/app/(dashboard)/system-score/` + hook file.
- Hapus seed row `sf_system_score_weights` dari `menus`.
- API endpoint tetap aman (Fase 2 sudah deliver).
