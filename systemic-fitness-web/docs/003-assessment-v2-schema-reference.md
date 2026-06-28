# 003 — Asesmen v2 Schema Reference (Read-only)

## Why

Plan awal Fase 3 mendeskripsikan editor pertanyaan Phase A/B/C — mengelola pertanyaan, opsi, dan branching rule lewat UI. Setelah ditelaah, kebutuhan ini **terlalu agresif untuk Rilis 1**:

- Pertanyaan & scoring formula sudah hard-coded di `assessment_v2_engine.go` agar bisa di-unit-test 1:1 dengan spec docx (lihat `systemic-fitness-api/docs/004-assessment-v2-engine.md`).
- Membuat editor full-CRUD perlu schema baru (`assessment_questions`, `assessment_options`, branching rule engine) yang akan blocking flow mobile Fase 5.
- Spec dari client masih bisa berubah; meng-edit pertanyaan via UI tanpa unit test akan sangat berisiko.

**Alternatif yang dipilih (lebih hemat & aman):** halaman **read-only Schema Reference** yang berfungsi sebagai *docs in-app*. Tujuan utamanya: tim admin/Consultant bisa menjelaskan flow ke klien tanpa perlu baca docx atau Go code, dan tahu di mana flag/override muncul. Editor full akan dipertimbangkan ulang setelah Fase 5 mobile validate flow live di prod.

## What changed

### Halaman baru

[`src/app/(dashboard)/assessments/v2-schema/page.tsx`](../src/app/(dashboard)/assessments/v2-schema/page.tsx) — single page React murni (no API calls). Menampilkan:

- **Phase A** (3 pertanyaan + branching) → output: Program Type, routing waitlist/movement_test/continue.
- **Phase B** (10 pertanyaan + bobot subtotal score 22/18/15/15/15/15) → output: Rest Score + Chronobiology Window.
- **Hierarki override Chronobiology** (4 langkah: kondisi → activity profile → B3 latency → B4 readiness).
- **Phase C** (7 pertanyaan + bobot 20/20/20/20/5/5/10) → output: Nutrition Score.
- **System Score** card (Movement/Nutrition/Rest 35/35/30 + reweight rule saat movement nil).
- **Flags klinis** (4 flag yang dimunculkan engine: WAITLIST_LEVEL_0_3, REST_RECOVERY_ALERT, META_BLOOD_SUGAR_RISK, RENAL_HYDRATION_CRITICAL).

### Branding

Halaman ini pakai palette SF baru (Phase 0): background `bg-sf-warmWhite`, headline `font-dm-serif`, body `font-dm-sans`, angka/data `font-dm-mono`. Tone formal "anda" untuk semua copy.

## How to verify

1. Login owner/admin ke web dashboard.
2. Sidebar → "SF Master" → "Skema Asesmen v2".
3. Verifikasi: 3 phase + chronobiology hierarchy + system score breakdown + 4 flag muncul lengkap.
4. Visual check: font DM Serif Display untuk headline, DM Mono untuk angka bobot.

## Update guide

Halaman ini **bukan source of truth**. Source of truth adalah:
- `systemic-fitness-api/internal/service/assessment_v2_engine.go` (formula).
- `SF_Master_Platform_Spec.docx` (copy + tabel kondisi).

Bila engine berubah:
1. Update test fixture di `assessment_v2_engine_test.go`.
2. Update 1:1 di `v2-schema/page.tsx` (object `questions` di tiap `<PhaseSection>` + `ChronobiologyHierarchy`).
3. Update `systemic-fitness-api/docs/004-assessment-v2-engine.md`.

## Rollback notes

- Hapus folder `src/app/(dashboard)/assessments/v2-schema/`.
- Hapus seed `020_seed_sf_assessment_v2_menu.sql` row dengan `code = 'sf_assessment_v2_schema'` (atau jalankan `DELETE FROM menus WHERE code='sf_assessment_v2_schema'`).
