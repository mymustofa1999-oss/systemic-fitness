# Image Assets — Systemic Fitness Landing Page

Simpan gambar di folder ini dengan nama file **persis seperti di kolom "File"**. Saat file ada, `<ImagePlaceholder src="...">` akan otomatis render gambar tersebut; kalau file belum ada, akan muncul placeholder dengan spec.

## Brand Direction
- **Tone**: editorial-medical, premium, clinical. Bukan fitness loud/flexy.
- **Referensi mood**: Bloomberg editorial + Eight Sleep + NEJM (clinical trust).
- **Palet**: dominan navy + warm-white; gold sebagai accent.
- **Hindari**: stok gym klise (orang angkat barbel dengan ekspresi tegang), filter warna neon, model ber-pose "fitfluencer".

## Image Specs

| # | File | Section | Aspect | Specs & Mood |
|---|---|---|---|---|
| 1 | `hero-background.webp` | Hero (background decorative) | 16:9 / full-bleed | Abstraksi biomedical: close-up skin texture, low-light gym equipment, atau abstract data-on-body. **Navy tone**, high contrast dengan gold accent lighting. 2400×1600px, < 400KB. |
| 2 | `hero-figure.webp` | Hero (right side portrait) | 4/5 portrait | Single subject (laki/perempuan, usia 35-55), side profile, natural light, concentrated expression. Outfit neutral (abu-abu/navy/cream). Bukan senyum iklan — introspective. 1200×1500px. |
| 3 | `signal-1-labs.webp` | Signals card 1: lab metrics | 16/10 | Close-up lab report / vial darah / monitor angka. Macro focus, warm clinical light, subtle orange accent tone. 1600×1000px. |
| 4 | `signal-2-joint.webp` | Signals card 2: joint & chronic | 16/10 | Subject 45-60 dengan tangan di lutut atau physio-style treatment. Natural light, blue/navy tone. 1600×1000px. |
| 5 | `signal-3-hormonal.webp` | Signals card 3: hormonal balance | 16/10 | Subject 35-50 (umumnya perempuan) dalam pose refleksi, dekat jendela/natural light. Soft warm, purple/mauve undertone. 1600×1000px. |
| 6 | `signal-4-performance.webp` | Signals card 4: performance optimizer | 16/10 | Mature athlete mid-functional-movement. Studio atau modern gym, composed — bukan struggling. Gold undertone. 1600×1000px. |
| 7 | `method-anatomical.webp` | Method section (below founder quote) | 16/10 landscape | Ilustrasi anatomical/biomechanic line-drawing: cross-section muscle fiber, cardio-respiratory diagram, mechanotransduction, atau body-system overlay. **Gold + teal line art on dark navy bg**. Vector feel, bukan foto. 1600×1000px. |
| 8 | `program-1-condition.webp` | Programs card: Condition-Specific | 3/4 | Person (40-60 usia) melakukan controlled movement (stretch, breath work, low-impact), lingkungan rumah/klinik. Warm natural light, **bukan** gym. 900×1200px. |
| 9 | `program-2-preventive.webp` | Programs card: Preventive Optimization | 3/4 | Person (30-45) jogging early morning atau functional movement outdoor. Morning mist, natural. 900×1200px. |
| 10 | `program-3-performance.webp` | Programs card: Performance 35-60 | 3/4 | Mature athlete (45-60), strength training dengan composure — bukan struggling, tetapi confident. Studio atau modern gym. 900×1200px. |
| 11 | `partner-founder.webp` | Partner section: founder quote card | 1/1 | Professional portrait Citra Hann (founder). Ruang kerja/klinik, hands visible, eye contact dengan kamera, editorial. 1200×1200px. **Tanyakan foto resmi ke tim**. |
| 12 | `partner-clinical.webp` | Partner section (optional inline) | 16:9 | Dokter + tablet atau konsultasi hybrid (physical + digital overlay). Editorial, warm-bright. 1600×900px. |
| 13 | `score-dashboard.webp` | System Score section (replace mock card) | 4/3 | Screenshot UI aplikasi Systemic Fitness (mobile/desktop) memperlihatkan skor 81 + 3 domain bars. Rendered dari Figma/design tool. 1600×1200px. Transparent atau warm-white bg. |
| 14 | `testimonial-1-arya.webp` | Testimonials card 1 (Arya Pramudita) | 4/3 | Portrait pria 50-55 tahun. Editorial serius, warm natural light. Outfit smart casual (navy/cream/abu-abu). Bukan "smiling corporate", **composed & introspective**. 1600×1200px. |
| 15 | `testimonial-2-rini.webp` | Testimonials card 2 (Rini Saputra) | 4/3 | Portrait perempuan 45-50 tahun. Ruang kerja atau natural light dari jendela. Outfit neutral (cream/camel/navy). Composed, confident. 1600×1200px. |
| 16 | `testimonial-3-dharma.webp` | Testimonials card 3 (dr. Dharma) | 4/3 | Portrait pria 40-50 tahun dalam konteks medis. Stethoscope, lab coat, atau ruang klinik. Editorial warm. 1600×1200px. |
| 17 | `final-cta-background.webp` | Final CTA (full-bleed background) | 21/9 ultra-wide | Abstract atmosphere: rays of light through translucent medium, body-scan glow, atau minimalist gradient skyline. Very dark navy, small gold highlights. Min 2560×1100px, < 500KB. |
| 18 | `og-image.webp` | Open Graph / social share | 1200×630 | Composite: logo + headline + subtle brand imagery. 1200×630px, < 300KB. |

## Technical Requirements
- **Format**: `.webp` (compressed) atau `.avif`. Fallback `.jpg` OK jika < 300KB.
- **Optimasi**: Jalankan lewat [squoosh.app](https://squoosh.app) atau `next/image` auto-optimization.
- **Naming**: lowercase, kebab-case, **sesuai tabel di atas**.
- **Tanpa spasi** di nama file.

## Cara Pakai di Code
Setelah menaruh file di folder ini, update section yang relevan:

```tsx
// Contoh di Hero.tsx
<ImagePlaceholder
  src="hero-figure.webp"        // <- cukup nama file
  alt="Professional portrait"
  spec="4/5 portrait ..."
  aspect="aspect-[4/5]"
/>
```

Kalau `src` kosong / file tidak ada, placeholder dengan spec akan muncul secara otomatis — jadi aman untuk development.

## License & Sourcing
Gunakan sumber legal:
- Commercial license: Unsplash+ / Pexels / Getty iStock (untuk B2B safe)
- Editorial commissioned: Fotografer lokal (recommended untuk foto founder + partner section)
- Ilustrasi anatomy: Envato Elements / Blush / custom illustrator

**Jangan** pakai gambar dari Google Images random — risiko DMCA.
