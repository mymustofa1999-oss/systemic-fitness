# 001 — SF Branding Tokens (Fase 0)

## Why

Spec **SF Master Platform Spec v1.0 / 2026** mengganti arah brand dari "fitness app" indigo+green ke *Human System Optimization Platform* dengan palet Deep Navy + Warm Gold + Charcoal dan tipografi DM Serif Display / DM Sans / DM Mono. Fase 0 mengintroduksi token-nya **secara additive** — token lama (`brand.*`, `accent.*`, `sidebar.*`) tetap hidup sehingga halaman lama tidak rusak. Halaman baru di fase berikut konsumsi token `sf.*` dan utility `font-dm-*`.

Referensi: `SF_Master_Platform_Spec.docx` §7.1 (Palet Warna) & §7.2 (Tipografi).

## What changed

### `tailwind.config.ts`

Tambah `colors.sf` dan font family `dm-serif` / `dm-sans` / `dm-mono` di `theme.extend`. Token sf:

| Token            | Hex       | Kegunaan |
|------------------|-----------|----------|
| `sf.deepNavy`    | `#0A1628` | onboarding background, hero sections |
| `sf.charcoal`    | `#444444` | body text utama (lebih hangat dari hitam murni) |
| `sf.midnightBlue`| `#1B3A5C` | section bg, secondary headers |
| `sf.systemBlue`  | `#2E6DA4` | primary action, links, icon aktif |
| `sf.warmGold`    | `#B8922E` | signature CTA, brand highlights |
| `sf.warmGoldDark`| `#A07828` | hover/pressed state of warmGold |
| `sf.deepTeal`    | `#0B5C5C` | FC pillar, success/recovery state |
| `sf.iceBlue`     | `#E8F0F8` | light surface, hover state |
| `sf.warmWhite`   | `#F8F6F1` | page background utama (bukan putih murni) |

### `src/app/layout.tsx`

Register **DM Sans** (400/500/700), **DM Serif Display** (400), **DM Mono** (400/500) lewat `next/font/google` dan expose CSS variables `--font-dm-sans`, `--font-dm-serif`, `--font-dm-mono` di `<html>`. Tailwind tokens `font-dm-*` membaca variable ini.

### `src/app/globals.css`

Tambah utility class:

- `.sf-headline` — DM Serif Display, tracking-tight, charcoal
- `.sf-body` — DM Sans, charcoal
- `.sf-data` — DM Mono, charcoal
- `.sf-cta-primary` — Warm Gold button + hover Warm Gold Dark
- `.sf-cta-secondary` — outline System Blue + hover Ice Blue

Default body & heading **tidak** diubah — masih pakai Plus Jakarta Sans / Inter dari sebelumnya.

## How to verify

1. `cd systemic-fitness-web && npm run dev` — pastikan halaman dashboard, login, master pages tetap render normal (tidak ada visual regression).
2. Di browser devtools, inspect `<html>` → confirm class `__variable_xxx` (next/font fingerprint) untuk tiga DM fonts hadir.
3. Buka file scratch, ujicoba `<button className="sf-cta-primary">Temukan Program Saya</button>` — harus tampil dengan background `#B8922E` + font DM Sans.
4. `npm run build` sukses tanpa warning soal token tidak dikenal.

## Rollback notes

- Hapus blok `sf:` di `tailwind.config.ts` colors, hapus 3 entry `dm-*` di fontFamily.
- Hapus 3 import `next/font/google` di `layout.tsx`, kembalikan `<html lang="en">` tanpa `className`.
- Hapus blok `.sf-*` utility di `globals.css`.
- Token lama tidak terganggu — rollback aman & instan.
