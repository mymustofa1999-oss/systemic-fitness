# 001 — SF Branding Tokens (Fase 0)

## Why

Spec **SF Master Platform Spec v1.0 / 2026** mengganti palet & tipografi seluruh produk. Fase 0 menambahkan token-nya **secara additive** — konstanta warna lama (`primaryColor`, `accentColor`, `category1..7`, dll.) tetap hidup sehingga screen lama tidak rusak. Onboarding v2 (Fase 4) dan assessment v2 (Fase 5) konsumsi `kSf*` + `SfTypography`.

Referensi: `SF_Master_Platform_Spec.docx` §7.1 (Palet Warna) & §7.2 (Tipografi).

## What changed

### `lib/ColorCategory.dart`

Tambahkan 9 konstanta `const Color kSf*` di header file (sebelum konstanta lama). Tidak ada penghapusan.

| Konstanta              | Hex       | Kegunaan |
|------------------------|-----------|----------|
| `kSfDeepNavy`          | `#0A1628` | onboarding background, hero |
| `kSfCharcoal`          | `#444444` | body text utama |
| `kSfMidnightBlue`      | `#1B3A5C` | section bg, secondary headers |
| `kSfSystemBlue`        | `#2E6DA4` | primary action, links |
| `kSfWarmGold`          | `#B8922E` | signature CTA |
| `kSfWarmGoldDark`      | `#A07828` | hover/pressed warmGold |
| `kSfDeepTeal`          | `#0B5C5C` | FC pillar, success |
| `kSfIceBlue`           | `#E8F0F8` | light surface, hover |
| `kSfWarmWhite`         | `#F8F6F1` | page background |

### `pubspec.yaml`

Tambahkan dependency `google_fonts: ^6.2.1` di section `dependencies`. Package ini mengambil font DM Serif Display / DM Sans / DM Mono on-demand (cached) sehingga tidak perlu bundle TTF di assets. Total tambahan ukuran APK ≈ 200KB (lib code, font di-download saat runtime). Untuk build offline, panggil `GoogleFonts.config.allowRuntimeFetching = false` dan bundle font manual — **tidak dilakukan di Fase 0**, akan di-evaluasi di Fase 8.

### `lib/util/sf_typography.dart` (baru)

Helper class `SfTypography` dengan 6 factory `TextStyle`:

- `SfTypography.headline()` — DM Serif Display 32px regular (Hero / cover)
- `SfTypography.subheadline()` — DM Sans 22px medium (section title)
- `SfTypography.body()` — DM Sans 15px regular, line-height 1.7
- `SfTypography.label()` — DM Sans 12px medium dengan letter-spacing 0.8 (badge/caption)
- `SfTypography.data()` — DM Mono 32px regular (System Score, BPM)
- `SfTypography.ctaPrimary()` — DM Sans 15px medium putih (CTA button)

Semua factory menerima override `fontSize`, `color`, `weight`, `height` agar reusable. Default color = `kSfCharcoal`.

## How to verify

1. `cd systemic-fitness-mobile-new && flutter pub get` — pastikan `google_fonts ^6.2.1` ter-resolve tanpa konflik.
2. `flutter analyze` — tidak ada error baru (warning lama yang sudah ada di project tidak diperhitungkan).
3. Buat scratch widget:
   ```dart
   Text('Tubuhmu masih aktif.', style: SfTypography.headline(fontSize: 28));
   Container(color: kSfDeepNavy, padding: const EdgeInsets.all(16), ...);
   ```
   Build `flutter run` di emulator → confirm font DM Serif Display tampil & background Deep Navy bener.
4. Tidak ada screen lama yang berubah visualnya.

## Rollback notes

- Hapus 9 konstanta `kSf*` di `ColorCategory.dart`.
- Hapus baris `google_fonts: ^6.2.1` di `pubspec.yaml`, jalankan `flutter pub get`.
- Hapus `lib/util/sf_typography.dart`.
- Tidak ada screen yang merujuk file ini di Fase 0 — rollback aman.
