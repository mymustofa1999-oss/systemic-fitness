# 006 — Tone of Voice Style Guide (SF v2)

Style guide ini diberlakukan untuk **halaman SF baru** (mulai Fase 3). Halaman lama (medicines, exercises, payments, dll.) **tidak disentuh** di rilis ini — sweep menyeluruh dijadwalkan di Fase 8.

Referensi: `SF_Master_Platform_Spec.docx` §08 (Tone of Voice).

## Karakter suara

| Dimensi | SYSTEMIC FITNESS adalah… | SYSTEMIC FITNESS bukan… |
|---|---|---|
| Otoritas | Percaya diri berdasarkan ilmu. Tidak perlu menjelaskan berlebihan. | Defensif, terlalu banyak disclaimer, meminta maaf. |
| Kehangatan | Peduli seperti dokter yang kenal pasiennya. Personal tapi profesional. | Gembira berlebihan, emoji di mana-mana, terlalu kasual. |
| Presisi | Spesifik & terukur. "Sesi 60 menit" bukan "latihan sebentar". | Samar, motivasional tanpa substansi, cliché. |
| Pemberdayaan | "Kamu yang memutuskan, kami yang memastikan ini benar." | Menggurui, menakut-nakuti. |
| Inklusif | Tidak ada "tubuh ideal". Ada "sistem yang optimal". | Body-focused, performance-obsessed, eksklusif. |

## Do &amp; Don't

| ❌ Jangan | ✓ Pakai ini |
|---|---|
| Olahraga / Workout | Sesi / Program gerak / Sesi Systemic |
| Trainer / Coach | Certified Trainer / Health Consultant |
| Mulai latihan | Mulai sesi |
| User | Klien (untuk admin), anda (untuk klien) |
| Kamu | Anda (formal-warm) |
| Bakar kalori | Aktifkan respons metabolik |
| Tetap termotivasi! | Konsistensi adalah kunci. |
| Capek itu tanda kemajuan! | Sistem tubuh anda sedang beradaptasi. |
| Transformasi tubuhmu | Optimasi sistem tubuh anda |

## Halaman baru yang sudah pakai tone ini (Fase 3)

| Halaman | File | Cek list tone |
|---|---|---|
| Bobot System Score | `src/app/(dashboard)/system-score/page.tsx` | "anda" tidak dipakai (admin-facing); "Bobot System Score" / "klien" |
| Skema Asesmen v2 | `src/app/(dashboard)/assessments/v2-schema/page.tsx` | "asesmen" / "sesi" / "Consultant" |
| Viewer Asesmen v2 klien | `src/app/(dashboard)/clients/[userId]/assessment-v2/page.tsx` | "Klien", "Hasil Asesmen v2", "Health Consultant" |

## Halaman SF baru di Fase berikutnya — checklist

- [ ] Heading pakai DM Serif Display (`sf-headline` class).
- [ ] Body pakai DM Sans (`sf-body` atau `font-dm-sans`).
- [ ] Angka/data pakai DM Mono (`sf-data` atau `font-dm-mono`).
- [ ] Background `bg-sf-warmWhite` untuk halaman utama, `bg-sf-deepNavy text-white` untuk hero/score card.
- [ ] CTA primary pakai class `sf-cta-primary` (Warm Gold). Tidak pakai `btn-primary` indigo lama.
- [ ] Copy teks: "anda" (formal), "sesi", "asesmen", "Health Consultant" / "Certified Trainer". Tidak ada "olahraga", "workout", "kamu".
- [ ] Tidak ada emoji.
- [ ] Tidak ada gradient warna terang/neon.
- [ ] Tidak ada foto pria berotot atau imagery gym.

## Phrase library — copy ready-to-use

- Onboarding CTA: **"Temukan Level Saya →"** (mobile Fase 4).
- Post-assessment Level 4: "Berdasarkan kondisi tubuh anda, anda membutuhkan program yang dirancang khusus oleh konsultan kami."
- Pre-sesi reminder: "Sesi terbaik untuk anda hari ini: 15.30 — tepat 5 jam sebelum waktu tidur anda yang ideal."
- Post-sesi: "Sesi selesai. Dalam 3–5 jam ke depan, tubuh anda akan memasuki fase recovery aktif. Pertahankan hidrasi."
- Waitlist (Level 0–3): "Program Systemic Fitness sedang kami kembangkan untuk kondisi anda. Anda adalah alasan kami membangun platform ini lebih cepat."
- Error koneksi: "Sesi tidak bisa dimuat saat ini. Coba lagi dalam beberapa saat — program anda tetap tersimpan."
