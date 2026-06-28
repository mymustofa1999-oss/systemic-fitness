# 007 — SF Phase 6: Tier 4 Waitlist + Lab Consultations Admin

## Why

Phase 6 menghadirkan 2 entitas baru yang perlu dikelola admin:
- **Tier 4 Waitlist** — daftar minat klien (tier 4 belum dibuka, plus level 0–3 yang program belum tersedia). Admin perlu hubungi → mark contacted → convert/closed.
- **Lab Consultations** — booking pembacaan biomarker. Admin assign consultant → schedule → fill ringkasan hasil.

## What changed

### Hook
[`src/hooks/usePhaseSix.ts`](../src/hooks/usePhaseSix.ts):
- `useTier4Waitlist({ status, source })` + `useUpdateTier4WaitlistStatus`
- `useLabConsultations({ status, user_id })` + `useUpdateLabConsultation` + `useBookLabConsultation`

### Halaman baru

**[`/dashboard/tier4-waitlist`](../src/app/(dashboard)/tier4-waitlist/page.tsx)** — list + filter (status / source) + click row → modal status update + admin note. Status colored chip: new (amber), contacted (sky), converted (emerald), closed (slate).

**[`/dashboard/lab-consultations`](../src/app/(dashboard)/lab-consultations/page.tsx)** — list + filter status + click row → modal update (status, scheduled_at datetime-local, result_summary text). Auto-fill `completed_at = now()` saat status diubah ke `completed`.

### Menu sidebar (seed `021_seed_sf_phase6_menu.sql` di API repo)

Tambah 2 child di group "SF Master":
- Lab Consultations → `/lab-consultations`
- Tier 4 Waitlist → `/tier4-waitlist`

Privilege: owner + admin.

### Branding

Halaman pakai palette SF baru (`bg-sf-warmWhite` + DM fonts + `sf-cta-primary` Warm Gold).

## How to verify

1. Login owner di `https://admin.systemicfitnesshealth.com`.
2. Sidebar → "SF Master" → 6 children (4 dari fase sebelumnya + 2 baru).
3. Buka **Tier 4 Waitlist** → list (kosong kalau belum ada submission) → coba submit dari mobile (Level 0–1 → Daftarkan Minat) → refresh → entry muncul → click row → ubah status ke "contacted" + isi admin note → save.
4. Buka **Lab Consultations** → coba book via curl client JWT:
   ```bash
   curl -X POST -H "Authorization: Bearer $T" -H "Content-Type: application/json" \
        -d '{"booking_note":"Test"}' \
        https://api.systemicfitnesshealth.com/api/v2/lab-consultations
   ```
   → refresh halaman → entry muncul → click row → ubah status `scheduled` + datetime + save → ubah ke `completed` + isi result_summary → save.
5. Login admin (`denny@fitcoach.app`) → kedua menu tetap muncul (admin role).
6. Login client (`budi@example.com`) → menu **tidak muncul** (privilege owner+admin only).

## Rename tier

Existing `PUT /api/payments/plans/{id}` (admin) sudah handle rename. UI di `/dashboard/payments/plans` (page existing) — admin edit plan, ganti `name` field, save. Field `tier` slug fixed (jangan diubah, dipakai engine routing).

## Rollback notes

- Hapus folder `src/app/(dashboard)/tier4-waitlist/` + `lab-consultations/`.
- Hapus `src/hooks/usePhaseSix.ts`.
- Sidebar: hapus seed row `sf_lab_consultations` + `sf_tier4_waitlist`.
