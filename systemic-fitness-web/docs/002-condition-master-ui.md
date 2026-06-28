# 002 — SF Master: Klasifikasi & Kondisi Spesifik (Web Admin UI)

## Why

Phase 1 menambahkan halaman master CRUD untuk Owner/Admin mengelola 5 klasifikasi induk + kondisi spesifik per klasifikasi. Sumber data: spec docx halaman 168–181. Halaman ini menjadi prerequisite untuk editor assessment v2 (Fase 3) dan flow assessment mobile (Fase 5).

## What changed

### Hook baru

- [`src/hooks/useConditionMaster.ts`](../src/hooks/useConditionMaster.ts) — React Query hooks:
  - `useConditionClassifications(includeInactive?)`, `useConditionClassification(id)`, `useCreate/Update/DeleteConditionClassification`
  - `useSpecificConditions({classification?, includeInactive?})`, `useSpecificCondition(id)`, `useCreate/Update/DeleteSpecificCondition`
  - `usePhysicalStatusLevels()`
  - Type exports: `ConditionClassification`, `SpecificCondition`, `PhysicalStatusLevel`, `FocusPillar`.

### Halaman baru

- [`src/app/(dashboard)/master/condition-classifications/page.tsx`](../src/app/(dashboard)/master/condition-classifications/page.tsx) — List + modal-based CRUD. Form mendukung edit formula `Full Program 60 mnt` (FC/CC/MC) dan `Daily Reset 30 mnt` dengan validator visual (warna teks merah saat sum ≠ target).
- [`src/app/(dashboard)/master/specific-conditions/page.tsx`](../src/app/(dashboard)/master/specific-conditions/page.tsx) — List + filter klasifikasi (pakai `SearchableSelect`) + modal CRUD. Severity dipilih lewat dropdown.

Keputusan deviasi dari plan: pattern modal-based single-page **dipakai konsisten** dengan halaman `medicines` / `equipments` yang sudah ada (bukan `[id]/page.tsx` sub-route). Lebih ringkas dan match dengan codebase existing.

### Sidebar update

- [`src/components/layout/Sidebar.tsx`](../src/components/layout/Sidebar.tsx) — registrasi icon `HeartPulse`, `Stethoscope` di `iconMap` agar menu seed render benar.
- Menu entries di-seed lewat backend SQL `database/seeds/019_seed_sf_master_menu.sql` (group "SF Master" + 2 children, role owner & admin).

### Komponen reusable yang dipakai

- [`SearchableSelect`](../src/components/shared/SearchableSelect.tsx) — semua dropdown (filter klasifikasi, pilar, severity, klasifikasi parent saat tambah kondisi spesifik).
- [`EmptyState`](../src/components/shared/EmptyState.tsx) — saat data kosong.
- [`ConfirmDialog`](../src/components/shared/ConfirmDialog.tsx) — konfirmasi delete dengan variant `danger`.
- `cn`, `toast` — utility umum project.

## How to verify

1. Pastikan API Phase 1 sudah running (`go build ./... && ./bin/server`).
2. Apply seed menu: `psql ... -f database/seeds/019_seed_sf_master_menu.sql`.
3. Web:
   ```bash
   cd systemic-fitness-web
   npm run dev
   ```
4. Login sebagai owner/admin → sidebar muncul group "SF Master" dengan 2 children.
5. Klik "Klasifikasi Kondisi" → 5 baris seed muncul → Edit "Cardiorespiratory" → ubah daily_reset_formula CC dari 20 → 25 → save → verifikasi via `psql` atau refresh.
6. Klik "Kondisi Spesifik" → filter klasifikasi "Metabolic" → expect 6 kondisi (Diabetes, Pre-diabetes, PCOS, Tiroid, Resistensi insulin, Obesitas metabolik).
7. Test Tambah → buat kondisi baru → reload → muncul di list. Hapus → konfirmasi → hilang.
8. Login sebagai role `client` → tombol "Tambah" tidak dapat dipakai (API akan reject 403, hook `toast.error`).

## Rollback notes

- Hapus 2 folder halaman + 1 file hook.
- Hapus 2 baris import + 2 entry `iconMap` di Sidebar.
- API endpoints tetap aman (lihat `systemic-fitness-api/docs/001-condition-master-schema.md`).
- Tidak ada visual regression di halaman lain — palette/font lama belum diganti (Fase 0 hanya additive).
