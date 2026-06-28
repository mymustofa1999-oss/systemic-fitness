# 002 — SF Onboarding v2 (Mobile)

## Why

Spec `SF Master Platform Spec v1.0 / 2026` mendefinisikan onboarding 4 slide baru sebagai *first impression* brand: Deep Navy bg, Warm Gold accent, font DM Serif Display, tone formal-warm. Onboarding lama (`guide_intro_page.dart`) bertema fitness app generik — tidak align dengan posisi *Human System Optimization Platform*.

Mockup referensi: `fitcoach-platform/WhatsApp Image 2026-04-20 at 07.32.19*.jpeg`.

## What changed

### Folder baru: `lib/pages/onboarding_v2/`

| File | Isi |
|---|---|
| `onboarding_v2_screen.dart` | Wrapper: `StatefulWidget` + `PageController` + dot indicator + CTA button. Background `kSfDeepNavy`. |
| `slide_1_signal.dart` | Slide 1/4: pill "SYSTEMIC FITNESS" gold + headline "Tubuhmu masih aktif. Tapi ada **sinyal** yang perlu didengar." + 4 bullet card kondisi. |
| `slide_2_method.dart` | Slide 2/4: hero card "Bukan olahraga. Prescripsi fisiologis." + grid 2×2 metode (Load, Movement Pattern, Tempo/BPM, Breathing Pattern) + sequence info FC→CC→MC. |
| `slide_3_programs.dart` | Slide 3/4: 3 program card (Condition-Specific Level 4–5, Preventive Optimization Level 5, Performance 35–60). Tiap card: judul + tag + 3 chip metadata. |
| `slide_4_score.dart` | Slide 4/4: gauge System Score 81 OPTIMAL (`fl_chart` PieChart) + 3 progress bar dimensi (Gerak/Nutrisi/Istirahat) + grid 2×2 mini-card (35/35/30 + "Update tiap sesi selesai"). |

### Wiring router

- [`lib/router/app_router.dart`](../lib/router/app_router.dart) — tambah konstanta `AppRoutes.onboardingV2 = '/onboarding-v2'`, `GoRoute` ke `OnboardingV2Screen`, dan masukkan route ini ke `isAuthRoute` allowlist agar tidak di-redirect ke login.
- Legacy `/guide` (`GuideIntroPage`) **tidak dihapus** — kept untuk rollback safety. Tidak lagi dipanggil dari splash.

### Splash redirect ([`lib/pages/splash_page.dart`](../lib/pages/splash_page.dart))

- Branch `if (isIntro)` sekarang arahkan ke `/onboarding-v2` (sebelumnya `/guide`).
- Body splash di-rebuild ke palette baru: bg `kSfDeepNavy`, headline `SfTypography.headline()`, subline gold "Human System Optimization", spinner gold tipis. Hapus impor `ConstantWidget` (tidak dipakai lagi).

### Persistence

Pakai `PrefData.setIsIntro(false)` yang **sudah ada** — tidak perlu flag baru. CTA terakhir slide 4 ("Temukan Program Saya →") atau tombol "Lewati" set flag ini, lalu navigate ke `/login`. Setelah login, splash logic akan arahkan ke `/assessment/intro` (untuk Phase 5 nanti) atau `/dashboard`.

### Critical-path branding migration

| File | Perubahan |
|---|---|
| `lib/pages/home/home_page.dart` | `bgDarkWhite → kSfWarmWhite` (page bg & app bar), `accentColor (Black) → kSfWarmGold` (active tab + title), `textColor → kSfCharcoal` (inactive tab). 4 entry bottom nav update. |
| `lib/pages/auth/login_page.dart` | `bgDarkWhite → kSfWarmWhite`, `blueButton → kSfWarmGold` (CTA Login + Create New Account), `accentColor → kSfWarmGold` (loader). |
| `lib/pages/auth/register_page.dart` | `bgDarkWhite → kSfWarmWhite`, `accentColor → kSfWarmGold` (CTA Sign Up + loader). |
| `lib/pages/auth/forgot_password_page.dart` | `bgDarkWhite → kSfWarmWhite`, `accentColor → kSfWarmGold` (CTA Send Reset Link + Back to Login + loader), `blueButton → kSfSystemBlue` (link "Back to Login" di state else). |

UI struktur, helper widget (ConstantWidget.getButtonWidget, dll.), dan teks **tidak berubah** — full text refactor & DM font migration diundur ke Fase 8 sweep menyeluruh per plan.

## How to verify

1. `cd systemic-fitness-mobile-new && flutter pub get && flutter analyze lib/pages/onboarding_v2/ lib/pages/splash_page.dart lib/pages/home/home_page.dart lib/pages/auth/ lib/router/app_router.dart`. Output: 37 info-level deprecation warning `withOpacity` (sama dengan codebase existing). 0 error, 0 warning.
2. Fresh install simulator → splash Deep Navy → 4 slide onboarding (Lanjut → ... → "Temukan Program Saya →") → login.
3. Re-launch app → splash → langsung login (intro flag = false).
4. Visual diff dengan 4 mockup JPEG di `fitcoach-platform/`.
5. Tap "Lewati" di slide 1–3 → langsung ke login. Flag tetap di-set false (tidak ulang).

## Catatan tone

- Slide 1 mengikuti mockup pakai "Tubuhmu" dan "perlu didengar" — ini **disengaja** untuk emotional hook awal.
- Slide 2/3/4 dan halaman lain pakai "anda" formal-warm.
- Login/Register/Forgot copy belum diganti (masih "Welcome back!" dll. dalam English) — masuk Fase 8 tone sweep.

## Rollback notes

- Hapus folder `lib/pages/onboarding_v2/`.
- Revert konstanta `onboardingV2` + `GoRoute` di `app_router.dart`. Hapus baris dari `isAuthRoute`.
- Revert splash: balik ke pemanggilan `AppRoutes.guide` + body lama (Constants.assetsImagePath splash icon).
- Critical-path screens (home/login/register/forgot): restore `bgDarkWhite`, `accentColor`, `blueButton` lewat git revert. Branding lama akan kembali aktif.
