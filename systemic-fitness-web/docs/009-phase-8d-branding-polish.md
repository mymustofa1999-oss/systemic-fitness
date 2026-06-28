# 009 — SF Phase 8d: Branding Polish (legacy `brand-*` → SF tokens)

## Why

Phase 0 menambah palette SF (`sf-deepNavy`, `sf-warmGold`, `sf-iceBlue`, dll.) sebagai **additive** — palette lama `brand-*` (indigo) sengaja dipertahankan supaya halaman lama tidak pecah saat rebrand. Setelah Phase 1–8c selesai, banyak halaman SF baru sudah konsisten pakai `sf-*`. Tapi 60 file lain masih pakai `brand-*` indigo di-mix dengan `sf-*` navy → visual inkonsisten antara halaman.

Phase 8d: bulk migrate inline `text-brand-*` / `bg-brand-*` / `border-brand-*` / `ring-brand-*` ke equivalent SF token.

**Yang TIDAK di-migrate:**
- `globals.css` — `.btn-primary`, `.input` legacy class. Tetap pakai `brand-600` sebagai bridge supaya semua tombol legacy tetap berfungsi (sama dengan keputusan Phase 0). SF baru pakai `.sf-cta-primary` dengan `bg-sf-warmGold`.
- `tailwind.config.ts` — `brand` palette tetap di-define, additive coexistence.
- `sidebar-bg/hover/active/text/muted` token — separate theme system.

## Mapping yang dipakai

| Old | New | Rasional |
|---|---|---|
| `text-brand-50/100/200` | `text-sf-iceBlue` | Light text varian (jarang dipakai, biasanya inverted) |
| `text-brand-300/400` | `text-sf-systemBlue` (`/40` untuk 300) | Medium text |
| `text-brand-500..950` | `text-sf-deepNavy` | Primary action / link color |
| `bg-brand-50` | `bg-sf-iceBlue/40` | Hover states, very light bg |
| `bg-brand-100..200` | `bg-sf-iceBlue` | Light bg, badge bg |
| `bg-brand-300/400` | `bg-sf-systemBlue/40` atau `/30` | Medium info bg |
| `bg-brand-500..900` | `bg-sf-deepNavy` | Primary button bg, dark sections |
| `border-brand-50..200` | `border-sf-iceBlue` | Subtle dividers |
| `border-brand-300/400` | `border-sf-systemBlue/40` | Medium emphasis |
| `border-brand-500..950` | `border-sf-deepNavy` | Strong emphasis |
| `ring-brand-200..700` | `ring-sf-warmGold/{20,30,40,50}` | Focus rings — gold konvensi SF (existing pattern) |

`fill-brand-*` dan `stroke-brand-*` ikut mapping yang sama (untuk SVG/chart elements).

## What changed

- **59 file** ter-edit (semua `src/app/**` + `src/components/**` yang punya `brand-*` inline class). 1 file (`globals.css`) sengaja di-skip.
- **Net diff**: ~238 insertion / 238 deletion (1:1 substitution, line count tetap).

Eksekusi pakai `perl -i` mass replacement dengan regex word-boundary (BSD sed di macOS tidak handle `\b` reliable):

```bash
perl -i -pe '
  s/\b(text|bg|border|fill|stroke)-brand-50\b/$1-sf-iceBlue/g;
  ...
  s/\bring-brand-500\b/ring-sf-warmGold\/40/g;
' <files>
```

## How to verify

### Build / lint

```bash
npx tsc --noEmit          # ✓ pass (1 pre-existing test setup error)
npx next lint             # ✓ no new errors; pre-existing warnings only
```

### Dev server compile

```bash
curl -o /dev/null -w "%{http_code}" http://localhost:3000/login
# → 200 (compiles + renders)

curl -o /dev/null -w "%{http_code}" http://localhost:3000/workouts
# → 307 (auth redirect — page handler compiled OK)
```

### Sisa `brand-*` di codebase

```bash
grep -rEho 'brand-(50|100|200|300|400|500|600|700|800|900|950)' src/ | sort -u
# Output: hanya yang di globals.css (legacy class definitions)
```

## Visual diff (perlu manual review)

Substitusi indigo → navy berarti **tampilan banyak halaman akan berubah**:
- Tombol legacy `bg-brand-600` (indigo) → `bg-sf-deepNavy` (lebih gelap, lebih biru-hitam)
- Badge / hover `bg-brand-50` (indigo tipis) → `bg-sf-iceBlue/40` (biru ice tipis)
- Focus ring indigo → gold

Kalau ada halaman yang look-nya pecah atau kontras tidak cukup setelah deploy, lapor ke maintainer dengan path:line + screenshot — bisa di-roll back per file pakai `git checkout origin/main~1 -- <file>`.

## Rollback

Per-file: `git checkout <prev-commit> -- <file>` untuk restore brand-* di file tertentu.

Full revert: `git revert <commit-hash>` — semua 59 file balik ke brand-*. Tidak ada breaking change DB / API, aman.

## Next

Phase 8 secara substansi selesai (8a audit + 8b/8c tone sweep + 8d branding polish + 8e v1 deprecation). **Phase 9** menunggu telemetri 8e (30 hari konsekutif zero traffic ke `/api/assessments/*`) sebelum hard-remove v1 endpoints.
