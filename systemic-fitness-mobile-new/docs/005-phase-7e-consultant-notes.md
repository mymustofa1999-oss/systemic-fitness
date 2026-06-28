# 005 — SF Phase 7e: Consultant Notes di Hasil Asesmen v2

## Why

Phase 7c+7d sudah memberi consultant kemampuan menulis catatan klinis lewat web admin dan men-toggle visibility (`is_visible_to_client`). Tapi tanpa Phase 7e, klien di mobile tidak punya cara untuk **membaca** catatan tersebut — toggle "Publish ke klien" jadi placebo.

Phase 7e menyambungkan loop: di hasil Asesmen v2 mobile, kalau ada catatan klinis yang sudah di-publish, tampilkan section "Catatan dari Health Consultant" lengkap dengan nama konsultan & tanggal.

## What changed

### Endpoint constant baru

- [`lib/data/api_config.dart`](../lib/data/api_config.dart) — tambah `static const String clinicalNotes = '/v2/clinical-notes';`

### Model baru

- [`lib/online_models/ClinicalNoteModel.dart`](../lib/online_models/ClinicalNoteModel.dart) — manual `fromJson`, sesuai konvensi mobile-new (tidak pakai json_serializable / freezed). Field-field yang relevan untuk display klien: `id`, `assessmentId`, `clientId`, `consultantId`, `title`, `content`, `isVisibleToClient`, `createdAt`, `updatedAt`, `consultantName` (joined).

### Result screen yang di-extend

[`lib/pages/assessment_v2/assessment_v2_result_screen.dart`](../lib/pages/assessment_v2/assessment_v2_result_screen.dart):

1. State baru: `List<ClinicalNoteModel> _publishedNotes = const [];`
2. `_load()` setelah ambil asesmen, panggil `_loadPublishedNotes(assessment.id)` — query `?assessment_id=...&only_published=true`. Server-side ACL sudah men-block client melihat draft, jadi `only_published=true` adalah lapisan ekstra (dan boleh karena GET `/clinical-notes/{id}` ACL-nya per-row).
3. Failure di-handle silent (catatan klinis = nice-to-have, jangan blok render asesmen).
4. Render `_ConsultantNotesCard` di antara FlagsCard dan footer "Disubmit ..." (hanya kalau list tidak kosong).

### Card design

`_ConsultantNotesCard`:
- Border-left `kSfWarmGold` 3px (mark visual "rekomendasi otoritatif")
- Header: ikon `medical_information_outlined` + "Catatan dari Health Consultant" (atau "(N)" kalau >1)
- Subtext: "Sudah ditinjau oleh tim klinis Systemic Fitness."
- Setiap entry: title (kalau ada) + content (multi-line, 1.5 line height) + footer "{consultant_name} · {tanggal}"

## How to verify

### Local

```bash
# 1. Pastikan API server jalan (production atau local) dengan migration 048+049
#    & seed 022 applied + minimal 1 catatan klinis published untuk asesmen klien.

# 2. Login sebagai consultant via web admin (admin.systemicfitnesshealth.com),
#    tulis catatan klinis untuk asesmen klien Budi, toggle "Publish ke klien".

# 3. Login sebagai Budi (budi@example.com) di mobile.

# 4. Buka hasil asesmen v2 yang baru di-publish notenya.
#    Expected: muncul section "Catatan dari Health Consultant" dengan
#    border kuning + nama dr. Maya + isi catatan + tanggal.

# 5. Hapus / un-publish catatan via web → re-buka hasil asesmen di mobile
#    → section hilang.
```

### Static checks

```bash
flutter analyze lib/pages/assessment_v2/assessment_v2_result_screen.dart \
                lib/online_models/ClinicalNoteModel.dart \
                lib/data/api_config.dart
# ✓ pass (0 errors; hanya info-level withOpacity deprecation pre-existing)
```

## Behavior notes

- **Klien bukan owner asesmen tidak akan dapat data** — server-side ACL
  pakai `service.CanRead` yang otomatis filter `client_id == callerID` untuk
  role client.
- **Kalau API gagal (network / 5xx)**: `_loadPublishedNotes` return list
  kosong → section tidak muncul. Hasil asesmen tetap render normal.
- **Markdown / formatting**: untuk MVP, content di-render sebagai plain
  text dengan `whiteSpace: pre-wrap` style implicit (Text widget). Kalau
  consultant butuh bullet list / heading nanti, bisa add `flutter_markdown`
  package.

## Rollback

`git revert <commit>` cukup — section akan hilang dari hasil asesmen.
Endpoint API + table `clinical_notes` tetap stand-alone (tidak ada FK
breaking). Web admin masih bisa CRUD note seperti biasa, hanya tidak
ditampilkan ke klien lewat mobile.

## Next

Phase 7 selesai. Lanjut ke **Phase 8** (tone of voice sweep, branding
polish, deprecate v1 endpoints) — multi-project dan akan di-breakdown lagi
karena scope-nya lebar.
