# 008 — SF Phase 7c+7d: Consultant Dashboard (Web Admin)

## Why

API foundation untuk Health Consultant sudah selesai di Phase 7a (role + RBAC + seed) dan Phase 7b (queue, clients, clinical notes CRUD, lab assign endpoints). Tapi semua endpoint itu belum punya UI di web admin — consultant yang login via `admin.systemicfitnesshealth.com` tidak punya cara untuk melihat antrian review, menulis catatan, atau di-assign Lab Consultation.

Phase 7c+7d melengkapi UI:

- **7c** — Sidebar entry point + halaman list (Antrian Review + Klien Saya)
- **7d** — Detail page (Asesmen v2 summary + Lab history + Catatan Klinis editor) + Lab Consultation assign UI

Reference: per-project API docs `008-phase-7b-consultant-endpoints.md` + `SF_Master_Platform_Spec.docx` §03 (Consultant workflow).

## What changed

### Hook baru

| File | Isi |
|---|---|
| [`src/hooks/useConsultant.ts`](../src/hooks/useConsultant.ts) | `useConsultantQueue / useConsultantClients / useClinicalNotes / useClinicalNote / useCreateClinicalNote / useUpdateClinicalNote / useDeleteClinicalNote / useAssignLabConsultant` — typed dengan TypeScript interfaces yang match server response |

### Hook existing yang di-extend

- [`src/hooks/useAuth.ts`](../src/hooks/useAuth.ts) — tambah `isConsultant` boolean.

### Halaman baru (Phase 7c)

| Path | Isi |
|---|---|
| [`/consultant/queue`](../src/app/(dashboard)/consultant/queue/page.tsx) | Tabel Antrian Review — list `PendingReviewItem` dengan columns klien/email/level fisik/program/score/submisi (relative) + tombol "Tinjau" → `/consultant/clients/[id]?assessment=...` |
| [`/consultant/clients`](../src/app/(dashboard)/consultant/clients/page.tsx) | Grid card "Klien Saya" — card per-klien menampilkan note_count, lab_count, last_interaction relative |

### Halaman baru (Phase 7d)

| Path | Isi |
|---|---|
| [`/consultant/clients/[id]`](../src/app/(dashboard)/consultant/clients/[id]/page.tsx) | Detail klien: header (nama/email/phone) + 2-col (Asesmen v2 summary card + Lab history) + Catatan Klinis section (form + list dengan inline edit/delete + visibility toggle draft/published) |

### Halaman existing yang di-extend (Phase 7d)

- [`/lab-consultations`](../src/app/(dashboard)/lab-consultations/page.tsx) — tambah field "Health Consultant" di modal detail dengan SearchableSelect (option list dari `useUsers({ role: 'consultant' })`) + tombol **Assign** (panggil endpoint dedicated `/lab-consultations/{id}/assign` yang auto-bump status pending→scheduled). Tombol **Simpan** existing tetap kirim consultant_id juga, jadi assignment masih bisa via flow lama.

### API seed baru (mounted di repo `systemic-fitness-api`)

| File | Isi |
|---|---|
| `database/seeds/023_seed_sf_consultant_menu.sql` | Parent menu "Consultant" (UUID `…00c1`, icon Stethoscope, sort_order 19) + 2 children "Antrian Review" (`/consultant/queue`) + "Klien Saya" (`/consultant/clients`). Privileges: consultant + admin + owner. **Sekaligus** grant role `consultant` akses ke `sf_lab_consultations` (Phase 6 menu) supaya consultant bisa lihat antrian booking. |

## How sidebar menampilkan menu untuk consultant

`Sidebar.tsx` fetch `/api/menus/my` (existing endpoint) yang return menu tree berdasarkan role JWT. Setelah seed 023 di-apply, login sebagai `consultant.maya@fitcoach.app` → sidebar otomatis menampilkan group "Consultant" dengan 2 children + entry "Lab Consultations" dari group "SF Master".

Tidak ada client-side role gating yang perlu di-tambahkan — server-side menu privilege table sudah jadi single source of truth.

## Workflow user (consultant)

1. **Login** → sidebar punya group "Consultant"
2. **Klik "Antrian Review"** → list asesmen `submitted` yang belum di-review (FIFO oldest first)
3. **Klik "Tinjau"** di salah satu row → buka `/consultant/clients/[id]?assessment=...`
4. **Detail klien**:
   - Lihat Asesmen v2 summary (Rest/Nutrition/Movement + System Score + program type)
   - Lihat Lab history (5 terakhir, link ke /lab-consultations untuk full list)
   - Form "Tulis Catatan Baru" sudah pre-filled dengan `assessment_id` dari query string
5. **Tulis catatan** → save sebagai draft (default) atau langsung publish (`is_visible_to_client=true`)
6. **Catatan tersimpan** → invalidate query → row asesmen hilang dari Antrian Review (karena queue exclude assessment yang sudah punya note aktif)
7. **Klik "Klien Saya"** → klien yang baru di-review muncul dengan note_count=1

## Workflow user (admin/owner)

1. **Login** → sidebar punya group "Consultant" (overseer access)
2. **Buka Lab Consultations** → buka modal detail booking
3. **Pilih consultant dari dropdown** → klik **Assign** (hanya assign, status auto-bump)
   - Atau pakai tombol **Simpan** existing (assign + status + scheduled_at + result_summary sekaligus)
4. **Setelah assign** → consultant ybs akan lihat klien tersebut di "Klien Saya" mereka

## RBAC matrix (UI level)

UI tidak menambah pengaman tambahan — semua enforcement ada di server (RequireRole middleware di Phase 7a/7b). Yang di-handle di UI:

| UI element | Visible untuk |
|---|---|
| Sidebar group "Consultant" | consultant, admin, owner (lewat menu_role_privileges) |
| Sidebar entry "Lab Consultations" | consultant (baru di Phase 7c), admin, owner |
| Tombol "Tinjau" di Antrian Review | semua role yang bisa akses page |
| Tombol Edit/Hapus di NoteCard | author note (consultant_id == user.id) atau admin/owner |
| Field Assign Consultant di lab modal | siapa pun yang bisa buka modal (server tolak kalau bukan admin/owner) |

Kalau consultant non-author menekan Edit di catatan orang lain → server return 403 → toast.error otomatis tampil.

## How to verify

### Build

```bash
npx tsc --noEmit          # ✓ pass (1 unrelated pre-existing error di test setup)
npx next lint <files>     # ✓ pass
```

### Browser smoke test

```bash
# Pre-syarat:
# 1. API server jalan di :8080 dengan migration 048 + 049 + seed 022 + 023 applied
# 2. Web dev server jalan di :3000

# Login sebagai consultant
# Email: consultant.maya@fitcoach.app
# Password: Consultant@2024

# Cek:
# - Sidebar punya group "Consultant" + 2 children + "Lab Consultations" di SF Master
# - /consultant/queue → list assessment pending
# - Klik "Tinjau" → buka detail klien dengan form pre-filled
# - Tulis catatan + simpan sebagai draft → toast success
# - Toggle "Publish ke klien" + simpan → re-list note shows "Published" badge
# - Edit & delete buttons hanya muncul di catatan milik consultant ini

# Login sebagai owner (admin@fitcoach.app / FitCoach@2024)
# - /lab-consultations → klik salah satu booking
# - Pilih consultant dari dropdown → klik "Assign"
# - Toast success + modal close + list refresh menampilkan consultant_name baru
```

## CI/CD

- API seed 023 akan auto-apply lewat `ci/run-sql-dir.sh database/seeds _seed_migrations` di pipeline API. Tracker mencegah re-apply.
- Web tidak butuh extra deploy step — pages otomatis ter-build oleh `next build` di pipeline web.

## Rollback

- **Web**: `git revert <commit>` — pages hilang dari router. Sidebar tetap menampilkan "Consultant" group dari seed (route 404 saat di-klik). Aman tapi tidak rapi — kalau perlu rapi, juga revert seed 023 secara manual:
  ```sql
  DELETE FROM menu_role_privileges WHERE menu_id IN (
    SELECT id FROM menus WHERE code IN ('sf_consultant','sf_consultant_queue','sf_consultant_clients')
  );
  DELETE FROM menus WHERE code IN ('sf_consultant_queue','sf_consultant_clients','sf_consultant');
  DELETE FROM _seed_migrations WHERE filename='023_seed_sf_consultant_menu.sql';
  ```

## Next (Phase 7e + 8)

- **7e** (opsional, mobile): badge "Direview oleh Consultant" + render catatan klinis published di hasil Asesmen v2 di mobile app.
- **8**: Tone of voice sweep menyeluruh untuk halaman lama (sebagian halaman masih pakai "trainer" / "workout" yang tidak match SF tone), branding polish, deprecate v1 endpoints.
