# 001 — SF Master: Klasifikasi & Kondisi Spesifik (Schema)

## Why

Spec **SF Master Platform Spec v1.0 / 2026** memperkenalkan 5 klasifikasi induk (Imun & Inflamasi, Renal & Uric, Cardiorespiratory, Metabolic, Musculoskeletal) yang menjadi backbone Phase A assessment dan kurasi program oleh Consultant. Setiap klasifikasi punya pilar dominan (FC/CC/MC) dan formula waktu khusus untuk Full Program 60 mnt + Daily Reset 30 mnt.

Selain itu, spec juga mendefinisikan 3 buket Physical Status Level (output Phase A Q1) yang menentukan routing user (waitlist / preventive movement test / continue).

Phase 1 mengintroduksi 3 master tables ini secara additive — tidak menyentuh tabel `assessments` lama.

Referensi: `SF_Master_Platform_Spec.docx` §02 (Tiga Program Utama, formula waktu per pilar), halaman 145–158 (Phase A Q1), halaman 168–181 (Kondisi Spesifik per Klasifikasi).

## What changed

### Migrations baru

| File | Tabel | Catatan |
|------|-------|---------|
| `database/migrations/040_create_condition_classifications.sql` | `condition_classifications` | 5 baris seed (slug: `imun-inflamasi`, `renal-uric`, `cardiorespiratory`, `metabolic`, `musculoskeletal`) + ENUM `focus_pillar` (FC/CC/MC) |
| `database/migrations/041_create_specific_conditions.sql` | `specific_conditions` | ~30 baris seed kondisi spesifik, FK ke `condition_classifications`. ON DELETE RESTRICT untuk safety. |
| `database/migrations/042_create_physical_status_levels.sql` | `physical_status_levels` | 3 baris seed (`level_0_1`, `level_2_3`, `level_4_5_perf`) + kolom `routing` & `waitlist_message` |

### Seeds baru (menu admin)

`database/seeds/019_seed_sf_master_menu.sql` — group "SF Master" dengan 2 menu children (Klasifikasi Kondisi → `/master/condition-classifications`, Kondisi Spesifik → `/master/specific-conditions`) untuk role owner & admin.

### Schema highlight

```sql
CREATE TYPE focus_pillar AS ENUM ('FC', 'CC', 'MC');

condition_classifications:
  id, slug (UNIQUE), label, description, focus_pillar,
  full_program_formula JSONB,    -- e.g. {"FC":35,"CC":15,"MC":10}
  daily_reset_formula  JSONB,    -- e.g. {"FC":20,"CC":10}
  sort_order, is_active, created_at, updated_at

specific_conditions:
  id, classification_id (FK condition_classifications, RESTRICT),
  slug (UNIQUE), label, description,
  severity_default ('mild'|'moderate'|'severe'|'monitor'),
  notes JSONB,                   -- e.g. {"medical_priority":true,"lab_required":false}
  sort_order, is_active, created_at, updated_at

physical_status_levels:
  id, slug (UNIQUE), label, description,
  routing ('waitlist'|'preventive_movement_test'|'continue'),
  waitlist_message TEXT,         -- copy untuk Level 0–3 waitlist screen
  sort_order, is_active, created_at, updated_at
```

## How to verify

1. Apply migrations:
   ```bash
   cd systemic-fitness-api
   make migrate-up         # atau perintah equivalent project
   ```
2. Verifikasi seed dengan `psql`:
   ```sql
   SELECT slug, label, focus_pillar FROM condition_classifications ORDER BY sort_order;
   -- Expect 5 rows
   SELECT COUNT(*) FROM specific_conditions;
   -- Expect ~30
   SELECT slug, routing FROM physical_status_levels ORDER BY sort_order;
   -- Expect 3 rows
   ```
3. Test rollback:
   ```bash
   make migrate-down       # round-trip: turun 3 migration, lalu naik lagi
   ```

## Rollback notes

- Drop dengan urutan terbalik: `physical_status_levels` → `specific_conditions` → `condition_classifications` → `DROP TYPE focus_pillar`.
- Jika Fase 2+ sudah merujuk `classification_id` di `assessments`, drop classification akan gagal karena FK. Pastikan rollback dilakukan sebelum Fase 2 atau gunakan `CASCADE` dengan hati-hati.
- Seed menu (`019_seed_sf_master_menu.sql`) bisa di-revert dengan `DELETE FROM menus WHERE code IN ('sf_master','sf_condition_classifications','sf_specific_conditions')`.
