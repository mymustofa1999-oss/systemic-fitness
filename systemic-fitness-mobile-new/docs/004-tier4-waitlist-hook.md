# 004 — Mobile Tier 4 Waitlist Hook (Phase 6)

## Why

Phase A waitlist screen (Fase 5) punya placeholder TODO untuk endpoint waitlist. Phase 6 API sudah punya `POST /api/v2/tier4-waitlist`. Replace TODO dengan real call.

## What changed

### `lib/data/api_config.dart`

Tambah 3 endpoint:
```dart
static const String tier4Waitlist = '/v2/tier4-waitlist';
static const String labConsultations = '/v2/lab-consultations';
static String labConsultationById(String id) => '/v2/lab-consultations/$id';
```

### `lib/pages/assessment_v2/phase_a_waitlist_screen.dart`

- Convert dari `StatelessWidget` → `StatefulWidget` (perlu state `_submitting` untuk disable CTA + show loading).
- `_join()` async function: ambil user dari `PrefData.getUser()`, build body dengan `source: 'level_0_3'`, POST ke `/v2/tier4-waitlist`. Error handling dengan toast.
- CTA "Daftarkan Minat Saya" tampilkan `CircularProgressIndicator` saat submitting.

User yang udah login otomatis pakai `full_name` + `email` + `phone` dari profile. Body:
```json
{
  "full_name": "Budi Santoso",
  "email": "budi@example.com",
  "phone": "+6281200000001",
  "source": "level_0_3",
  "note": "Daftar dari mobile app — Phase A waitlist screen."
}
```

## How to verify

1. `flutter pub get && flutter analyze lib/pages/assessment_v2/phase_a_waitlist_screen.dart` — 0 error.
2. Run debug di Xiaomi → login → start asesmen → pilih Level 0–1 atau Level 2–3 → masuk waitlist screen → tap "Daftarkan Minat Saya" → toast sukses → kembali ke dashboard.
3. Cross-check di web admin `/tier4-waitlist` → entry baru dengan source `level_0_3` muncul.
4. Test error: turn off network → tap CTA → toast error tampil, button kembali enabled.

## Rollback notes

- Revert file `phase_a_waitlist_screen.dart` ke versi StatelessWidget + TODO toast.
- Hapus 3 endpoint baru di `api_config.dart`.
- Endpoint API tetap aktif (Phase 6 deployment).

## Next

Phase 6b — Lab Consultation booking screen di mobile (saat ini admin yang track via web).
