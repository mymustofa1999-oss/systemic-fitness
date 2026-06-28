-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  039: Seed CMS content from landing-page messages/{id,en}.json
--
--  Populates singleton sections (cms_content) + collections
--  (testimonials, programs, pricing_tiers) for both locales.
--  All seeded rows are immediately "published" so the public
--  /api/public/cms/landing endpoint can serve them.
-- ═══════════════════════════════════════════════════════════════════

-- ─── Singletons (cms_content) ────────────────────────────────────────

-- meta
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('meta', 'id', $J${
  "title": "Systemic Fitness — Human System Optimization",
  "description": "Prescripsi gerakan berbasis kondisi medis — dikalibrasi terhadap 4 variabel spesifik untuk tubuhmu."
}$J$::jsonb),
('meta', 'en', $J${
  "title": "Systemic Fitness — Human System Optimization",
  "description": "A condition-based movement prescription — calibrated against 4 specific variables for your body."
}$J$::jsonb);

-- nav
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('nav', 'id', $J${
  "method": "Metode",
  "programs": "Program",
  "partner": "Kemitraan",
  "pricing": "Harga",
  "cta": "Mulai Assessment"
}$J$::jsonb),
('nav', 'en', $J${
  "method": "Method",
  "programs": "Programs",
  "partner": "Partnership",
  "pricing": "Pricing",
  "cta": "Start Assessment"
}$J$::jsonb);

-- hero
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('hero', 'id', $J${
  "badge": "HUMAN SYSTEM OPTIMIZATION PLATFORM",
  "headline1": "Tubuhmu adalah sistem.",
  "headline2": "Kami",
  "headlineEm": "mengoptimalkannya.",
  "sub": "Bukan program olahraga generik. Systemic Fitness adalah prescripsi gerakan berbasis kondisi medis — dikalibrasi terhadap 4 variabel spesifik, disampaikan melalui sistem yang bekerja untuk tubuhmu secara personal.",
  "ctaPrimary": "Mulai Assessment Gratis →",
  "ctaSecondary": "Pelajari Metodenya",
  "metrics": {
    "m1Num": "4",
    "m1Label": "Variabel fisiologis\nper sesi",
    "m2Num": "3",
    "m2Label": "Program berbeda\nsatu assessment",
    "m3Num": "23+",
    "m3Label": "Kondisi kesehatan\nyang ditangani"
  }
}$J$::jsonb),
('hero', 'en', $J${
  "badge": "HUMAN SYSTEM OPTIMIZATION PLATFORM",
  "headline1": "Your body is a system.",
  "headline2": "We",
  "headlineEm": "optimize it.",
  "sub": "Not a generic workout program. Systemic Fitness is a movement prescription based on medical conditions — calibrated against 4 specific variables, delivered through a system built for your body, personally.",
  "ctaPrimary": "Start Free Assessment →",
  "ctaSecondary": "Learn the Method",
  "metrics": {
    "m1Num": "4",
    "m1Label": "Physiological variables\nper session",
    "m2Num": "3",
    "m2Label": "Distinct programs\none assessment",
    "m3Num": "23+",
    "m3Label": "Health conditions\naddressed"
  }
}$J$::jsonb);

-- signals
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('signals', 'id', $J${
  "tag": "SIAPA YANG DATANG KE SINI",
  "headline1": "Sinyal yang sering",
  "headline2": "diabaikan — tapi nyata.",
  "sub": "Jika salah satu dari ini terdengar familiar, kamu sudah di tempat yang tepat.",
  "cards": {
    "c1Title": "Tensi, kolesterol, atau gula darah mulai tidak optimal",
    "c1Desc": "Angka laboratorium mulai bergerak ke arah yang tidak diinginkan. Masih bisa diintervensi — dengan cara yang tepat.",
    "c2Title": "Ada keluhan yang mengganggu — sendi, asam urat, imun, atau kondisi kronis",
    "c2Desc": "Kondisi aktif yang butuh program gerakan yang diprescribe secara presisi, bukan gerakan generik yang bisa memperburuk.",
    "c3Title": "Hormonal tidak seimbang — PCOS, tiroid, atau perimenopause",
    "c3Desc": "Sistem hormonal yang terganggu merespons sangat spesifik terhadap jenis, waktu, dan intensitas gerakan yang tepat.",
    "c4Title": "Ingin optimalkan performa — stamina, kekuatan, dan vitalitas yang lebih konsisten",
    "c4Desc": "Masih aktif, tidak ada kondisi medis — tapi tahu ada potensi yang belum sepenuhnya dimanfaatkan dari sistem tubuh."
  }
}$J$::jsonb),
('signals', 'en', $J${
  "tag": "WHO COMES HERE",
  "headline1": "Signals that are often",
  "headline2": "overlooked — but real.",
  "sub": "If any of these sound familiar, you're already in the right place.",
  "cards": {
    "c1Title": "Blood pressure, cholesterol, or blood sugar drifting out of range",
    "c1Desc": "Lab numbers moving in the wrong direction. Still reversible — with the right intervention.",
    "c2Title": "A nagging issue — joints, uric acid, immunity, or a chronic condition",
    "c2Desc": "An active condition that needs precisely prescribed movement, not generic exercises that can make it worse.",
    "c3Title": "Hormonal imbalance — PCOS, thyroid, or perimenopause",
    "c3Desc": "A disrupted hormonal system responds very specifically to the right type, timing, and intensity of movement.",
    "c4Title": "Want to optimize performance — more consistent stamina, strength, and vitality",
    "c4Desc": "Still active, no medical condition — but aware there's untapped potential in how your body's system performs."
  }
}$J$::jsonb);

-- method
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('method', 'id', $J${
  "tag": "METODE SYSTEMIC FITNESS",
  "headline1": "Bukan olahraga.",
  "headline2": "Prescripsi fisiologis.",
  "sub": "Setiap sesi dikontrol oleh 4 variabel yang, ketika dikalibrasi terhadap kondisi spesifik, menghasilkan respons fisiologis yang ditargetkan — bukan sekadar peningkatan kebugaran umum.",
  "quote": "\"We don't train bodies. We optimize systems.\"",
  "quoteAuthor": "— Citra Hann, Founder & Human System Optimization Advisor",
  "variables": {
    "v1Name": "Load",
    "v1Desc": "Beban mekanis yang tepat mengaktifkan mekanotransduksi selular dan sintesis protein otot",
    "v2Name": "Movement Pattern",
    "v2Desc": "Pola gerakan yang dipilih menentukan sistem fisiologis mana yang diaktifkan dalam sesi",
    "v3Name": "Tempo / BPM",
    "v3Desc": "Ritme jantung yang dikendalikan menentukan respons otonom, termogenesis, dan adaptasi kardiak",
    "v4Name": "Breathing Pattern",
    "v4Desc": "Pola napas mengatur tonus vagal, kadar kortisol, dan optimasi pengiriman oksigen selular"
  },
  "pillars": {
    "fc": "Functional\nConditioning",
    "cc": "Cardiorespiratory\nConditioning",
    "mc": "Metabolic\nConditioning"
  }
}$J$::jsonb),
('method', 'en', $J${
  "tag": "THE SYSTEMIC FITNESS METHOD",
  "headline1": "Not exercise.",
  "headline2": "A physiological prescription.",
  "sub": "Every session is governed by 4 variables that, when calibrated to a specific condition, produce a targeted physiological response — not just general fitness.",
  "quote": "\"We don't train bodies. We optimize systems.\"",
  "quoteAuthor": "— Citra Hann, Founder & Human System Optimization Advisor",
  "variables": {
    "v1Name": "Load",
    "v1Desc": "The right mechanical load activates cellular mechanotransduction and muscle protein synthesis",
    "v2Name": "Movement Pattern",
    "v2Desc": "The chosen movement pattern determines which physiological system is activated in the session",
    "v3Name": "Tempo / BPM",
    "v3Desc": "A controlled cardiac rhythm governs autonomic response, thermogenesis, and cardiac adaptation",
    "v4Name": "Breathing Pattern",
    "v4Desc": "Breathing patterns regulate vagal tone, cortisol levels, and cellular oxygen delivery"
  },
  "pillars": {
    "fc": "Functional\nConditioning",
    "cc": "Cardiorespiratory\nConditioning",
    "mc": "Metabolic\nConditioning"
  }
}$J$::jsonb);

-- programs (wrapper only — cards go to cms_programs table)
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('programs', 'id', $J${
  "tag": "TIGA PROGRAM — SATU ASSESSMENT",
  "headline1": "Program yang lahir",
  "headline2": "dari kondisimu.",
  "sub": "Assessment menentukan program mana yang tepat untukmu. Tidak ada overlap, tidak ada tebakan."
}$J$::jsonb),
('programs', 'en', $J${
  "tag": "THREE PROGRAMS — ONE ASSESSMENT",
  "headline1": "Programs born",
  "headline2": "from your condition.",
  "sub": "The assessment determines which program is right for you. No overlap, no guesswork."
}$J$::jsonb);

-- score
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('score', 'id', $J${
  "word": "OPTIMAL",
  "barMove": "Gerak",
  "barNutrition": "Nutrisi",
  "barRest": "Istirahat",
  "domainExercise": "Olahraga",
  "domainExerciseDesc": "35% bobot skor",
  "domainNutrition": "Nutrisi",
  "domainNutritionDesc": "35% bobot skor",
  "domainRest": "Istirahat",
  "domainRestDesc": "30% bobot skor",
  "domainUpdate": "Update",
  "domainUpdateDesc": "Setiap sesi selesai",
  "tag": "SYSTEM SCORE",
  "headline1": "Tubuhmu punya skor.",
  "headline2": "Dari 3 dimensi nyata.",
  "sub": "Bukan motivasi. Bukan estimasi. System Score adalah angka nyata yang lahir dari keseimbangan tiga domain fisiologis yang paling menentukan kualitas hidupmu.",
  "formulaTop": "Olahraga 35% + Nutrisi 35% + Istirahat 30% = System Score",
  "formulaBottom": "Diukur dari assessment awal dan diperbarui setiap sesi selesai.",
  "cta": "Lihat System Score-mu →"
}$J$::jsonb),
('score', 'en', $J${
  "word": "OPTIMAL",
  "barMove": "Move",
  "barNutrition": "Nutrition",
  "barRest": "Rest",
  "domainExercise": "Exercise",
  "domainExerciseDesc": "35% score weight",
  "domainNutrition": "Nutrition",
  "domainNutritionDesc": "35% score weight",
  "domainRest": "Rest",
  "domainRestDesc": "30% score weight",
  "domainUpdate": "Update",
  "domainUpdateDesc": "After every session",
  "tag": "SYSTEM SCORE",
  "headline1": "Your body has a score.",
  "headline2": "From 3 real dimensions.",
  "sub": "Not motivation. Not estimation. The System Score is a real number that emerges from the balance of the three physiological domains that most shape your quality of life.",
  "formulaTop": "Exercise 35% + Nutrition 35% + Rest 30% = System Score",
  "formulaBottom": "Measured at the initial assessment and updated after every completed session.",
  "cta": "See Your System Score →"
}$J$::jsonb);

-- how
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('how', 'id', $J${
  "tag": "CARA KERJA",
  "headline1": "Dari assessment",
  "headline2": "ke program aktif.",
  "steps": {
    "s1Title": "Assessment",
    "s1Desc": "25 pertanyaan tentang kondisi gerak, kesehatan, pola tidur, dan nutrisi. Gratis, 10 menit.",
    "s2Title": "System Score",
    "s2Desc": "Platform menghitung level, program yang tepat, dan window sesi optimal berdasarkan kronobiologimu.",
    "s3Title": "Program Aktif",
    "s3Desc": "Session Card siap — dengan variabel yang sudah dikalibrasi khusus untuk kondisi dan jadwal hidupmu.",
    "s4Title": "Progres Terukur",
    "s4Desc": "System Score diperbarui setiap sesi. Program berkembang seiring kondisi tubuhmu membaik."
  }
}$J$::jsonb),
('how', 'en', $J${
  "tag": "HOW IT WORKS",
  "headline1": "From assessment",
  "headline2": "to an active program.",
  "steps": {
    "s1Title": "Assessment",
    "s1Desc": "25 questions on movement, health, sleep patterns, and nutrition. Free, 10 minutes.",
    "s2Title": "System Score",
    "s2Desc": "The platform calculates your level, the right program, and the optimal session window based on your chronobiology.",
    "s3Title": "Active Program",
    "s3Desc": "Your Session Card is ready — with variables calibrated to your specific condition and schedule.",
    "s4Title": "Measured Progress",
    "s4Desc": "The System Score updates after every session. The program evolves as your body improves."
  }
}$J$::jsonb);

-- testimonials (wrapper only — items go to cms_testimonials table)
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('testimonials', 'id', $J${
  "tag": "TESTIMONI KLIEN",
  "headline1": "Mereka sudah mulai,",
  "headline2": "dan sudah merasakan.",
  "sub": "Cerita nyata dari klien Systemic Fitness yang menjalani program presisi berbasis kondisi.",
  "ratingLabel": "5 dari 5"
}$J$::jsonb),
('testimonials', 'en', $J${
  "tag": "CLIENT TESTIMONIALS",
  "headline1": "They started —",
  "headline2": "and already feel the shift.",
  "sub": "Real stories from Systemic Fitness clients running a condition-based, precision program.",
  "ratingLabel": "5 out of 5"
}$J$::jsonb);

-- partner
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('partner', 'id', $J${
  "tag": "UNTUK MITRA MEDIS & KORPORAT",
  "headline1": "Jangkauan klinis",
  "headline2": "yang lebih luas.",
  "sub": "Systemic Fitness memperpanjang jangkauan klinis Anda ke dalam kehidupan harian pasien — dengan protokol keamanan, pemantauan real-time, dan data yang kembali kepada Anda.",
  "items": {
    "i1Title": "Untuk Dokter & Spesialis",
    "i1Desc": "Clinical Advisor atau Health Educator Partner. Prescribe outcome, pantau progres klien, eskalasi kasus kompleks.",
    "i2Title": "Untuk Program Corporate Wellness",
    "i2Desc": "Program kesehatan berbasis kondisi karyawan — bukan program fitness generik yang tidak terukur hasilnya.",
    "i3Title": "Untuk Certified Trainer",
    "i3Desc": "Bergabung sebagai eksekutor program dengan Session Card yang sudah diprescribe — jalankan dengan presisi."
  },
  "ctaText": "Tertarik berdiskusi?",
  "ctaSub": "Kami mengundang percakapan ilmiah — bukan komitmen langsung.",
  "ctaBtn": "Hubungi Kami",
  "quoteTag": "PERSPEKTIF PENDIRI",
  "quoteText": "\"Dokter tahu bahwa pasien perlu bergerak. Gap terbesar selalu ada di antara pengetahuan itu dan eksekusi yang aman dan presisi di kehidupan sehari-hari pasien.\"",
  "quoteName": "Citra Hann",
  "quoteRole": "Founder & Human System Optimization Advisor",
  "quoteCompany": "Systemic Fitness Pte. Ltd."
}$J$::jsonb),
('partner', 'en', $J${
  "tag": "FOR MEDICAL & CORPORATE PARTNERS",
  "headline1": "Broader clinical",
  "headline2": "reach.",
  "sub": "Systemic Fitness extends your clinical reach into your patients' daily lives — with safety protocols, real-time monitoring, and data that flows back to you.",
  "items": {
    "i1Title": "For Doctors & Specialists",
    "i1Desc": "As a Clinical Advisor or Health Educator Partner. Prescribe outcomes, monitor client progress, and escalate complex cases.",
    "i2Title": "For Corporate Wellness Programs",
    "i2Desc": "A health program built around employee conditions — not a generic fitness program with unmeasurable outcomes.",
    "i3Title": "For Certified Trainers",
    "i3Desc": "Join as a program executor with pre-prescribed Session Cards — run them with precision."
  },
  "ctaText": "Interested in a conversation?",
  "ctaSub": "We invite a scientific conversation — not an immediate commitment.",
  "ctaBtn": "Contact Us",
  "quoteTag": "FOUNDER'S PERSPECTIVE",
  "quoteText": "\"Doctors know their patients need to move. The biggest gap has always been between that knowledge and safe, precise execution in the patient's day-to-day life.\"",
  "quoteName": "Citra Hann",
  "quoteRole": "Founder & Human System Optimization Advisor",
  "quoteCompany": "Systemic Fitness Pte. Ltd."
}$J$::jsonb);

-- pricing (wrapper — cards go to cms_pricing_tiers)
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('pricing', 'id', $J${
  "tag": "PAKET LANGGANAN",
  "headline1": "Mulai sesuai",
  "headline2": "kondisi dan kebutuhanmu.",
  "sub": "Semua paket berbayar dilengkapi System Assessment, System Score, dan Nutrition Guidance. Minimum komitmen 3 bulan.",
  "popular": "PALING POPULER",
  "toggleMonthly": "Bulanan",
  "toggleYearly": "Tahunan",
  "toggleYearlyBadge": "–20%",
  "saveBadge": "Hemat 20%",
  "discountBanner": "Bayar tahunan, hemat hingga 20% — 2 bulan gratis"
}$J$::jsonb),
('pricing', 'en', $J${
  "tag": "SUBSCRIPTION PLANS",
  "headline1": "Start with what fits",
  "headline2": "your condition and needs.",
  "sub": "Every paid plan includes the System Assessment, System Score, and Nutrition Guidance. 3-month minimum commitment.",
  "popular": "MOST POPULAR",
  "toggleMonthly": "Monthly",
  "toggleYearly": "Yearly",
  "toggleYearlyBadge": "–20%",
  "saveBadge": "Save 20%",
  "discountBanner": "Pay yearly, save up to 20% — 2 months free"
}$J$::jsonb);

-- finalCta
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('finalCta', 'id', $J${
  "tag": "MULAI DI SINI",
  "headline1": "Temukan kondisi",
  "headline2": "sistem tubuhmu —",
  "headlineEm": "gratis.",
  "sub": "Assessment 25 pertanyaan. Tidak butuh kartu kredit. Tidak ada komitmen. Hanya data yang jujur tentang kondisi sistem tubuhmu saat ini.",
  "cta": "Mulai Assessment Gratis →",
  "download": "Unduh aplikasinya",
  "note": "Tersedia di app dan web · Gratis selamanya untuk System Check"
}$J$::jsonb),
('finalCta', 'en', $J${
  "tag": "START HERE",
  "headline1": "Discover your body",
  "headline2": "system's condition —",
  "headlineEm": "free.",
  "sub": "A 25-question assessment. No credit card required. No commitment. Just honest data about the current state of your body's system.",
  "cta": "Start Free Assessment →",
  "download": "Download the app",
  "note": "Available on app and web · Free forever for System Check"
}$J$::jsonb);

-- footer
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('footer', 'id', $J${
  "tagline": "Human System Optimization",
  "copy": "© 2026 Systemic Fitness Pte. Ltd."
}$J$::jsonb),
('footer', 'en', $J${
  "tagline": "Human System Optimization",
  "copy": "© 2026 Systemic Fitness Pte. Ltd."
}$J$::jsonb);

-- language (per-locale display of the OTHER locale's name)
INSERT INTO cms_content (section_key, locale, draft_data) VALUES
('language', 'id', $J${ "switchTo": "EN" }$J$::jsonb),
('language', 'en', $J${ "switchTo": "ID" }$J$::jsonb);


-- ─── Collections: cms_testimonials (3 items × 2 locales) ────────────

INSERT INTO cms_testimonials (locale, order_index, name, role, title, description, rating, image_url) VALUES
('id', 0, 'Arya Pramudita', 'Direktur, 52 tahun',
 'Tensi stabil tanpa tambahan obat.',
 'Setelah 3 bulan program Condition-Specific, tekanan darah dan kolesterol saya turun signifikan. Yang berbeda: setiap sesi dikalibrasi ke kondisi saya, bukan target generik.',
 5, 'testimonial-1-arya.webp'),
('id', 1, 'Rini Saputra', 'Founder, 47 tahun',
 'Hormonal saya akhirnya seimbang.',
 '5 tahun saya coba berbagai pendekatan untuk perimenopause. Systemic Fitness adalah yang pertama mengerti bahwa hormon butuh window gerakan dan intensitas yang spesifik.',
 5, 'testimonial-2-rini.webp'),
('id', 2, 'dr. Dharma Wijaya', 'Spesialis Penyakit Dalam, 45 tahun',
 'Metode yang akhirnya presisi.',
 'Sebagai dokter, saya kritis terhadap klaim fitness. Pendekatan 4 variabel ini konsisten dengan literatur fisiologi olahraga — dan saya rasakan sendiri hasilnya.',
 5, 'testimonial-3-dharma.webp'),

('en', 0, 'Arya Pramudita', 'Director, age 52',
 'Blood pressure stable — without adding medication.',
 'After 3 months on the Condition-Specific program, my blood pressure and cholesterol dropped meaningfully. What''s different: every session is calibrated to my condition, not to a generic target.',
 5, 'testimonial-1-arya.webp'),
('en', 1, 'Rini Saputra', 'Founder, age 47',
 'My hormones finally came back into balance.',
 'For 5 years I tried every approach for perimenopause. Systemic Fitness was the first to understand that hormones need a specific movement window and intensity.',
 5, 'testimonial-2-rini.webp'),
('en', 2, 'Dr. Dharma Wijaya', 'Internal Medicine Specialist, age 45',
 'A method that''s finally precise.',
 'As a physician I''m critical of fitness claims. This 4-variable approach is consistent with the exercise physiology literature — and I''ve felt the result myself.',
 5, 'testimonial-3-dharma.webp');


-- ─── Collections: cms_programs (3 items × 2 locales) ────────────────

INSERT INTO cms_programs (locale, order_index, tier_label, name, description, features, meta) VALUES
('id', 0, 'LEVEL 4–5', 'Condition-Specific Program',
 'Untuk kondisi medis aktif yang masih bisa bergerak mandiri. Program dikurasi oleh Health Consultant berdasarkan kondisi spesifik.',
 $J$["Health Consultant mengkurasi setiap Session Card","Prescripsi outcome berbasis kondisi medis","Chronobiology window per kondisi","Nutrition guidance spesifik kondisi"]$J$::jsonb,
 $J$[{"strong":"60 mnt","span":"Full 2×/minggu"},{"strong":"30 mnt","span":"Reset 2–3×/minggu"},{"strong":"Konsultan","span":"Kurasi manual"}]$J$::jsonb),
('id', 1, 'LEVEL 5', 'Preventive Optimization',
 'Tanpa kondisi medis aktif. Program otomatis penuh untuk mempertahankan dan mengoptimalkan kapasitas sistem tubuh.',
 $J$["Fully automated — tidak perlu Consultant","Session Card berbasis movement test awal","Chronobiology window personal","Performance diet guidance"]$J$::jsonb,
 $J$[{"strong":"60 mnt","span":"Full 2×/minggu"},{"strong":"30 mnt","span":"Reset 2–3×/minggu"},{"strong":"Otomatis","span":"Self-guided"}]$J$::jsonb),
('id', 2, 'ADVANCED', 'Performance 35–60',
 'Optimasi hormonal dan performa untuk pria atau wanita usia 35–60. Sub-program spesifik usia, gender, dan profil hormonal.',
 $J$["Women's Program: 35–45 dan 46–60","Men's Program: 35–45 dan 46–60","Window sesi berbasis hormonal peak","Hormonal optimization diet guidance"]$J$::jsonb,
 $J$[{"strong":"Women's","span":"35–45 / 46–60"},{"strong":"Men's","span":"35–45 / 46–60"},{"strong":"Otomatis","span":"Gender-specific"}]$J$::jsonb),

('en', 0, 'LEVEL 4–5', 'Condition-Specific Program',
 'For active medical conditions where independent movement is still possible. Programs are curated by a Health Consultant based on the specific condition.',
 $J$["Health Consultant curates every Session Card","Outcome-based prescription for the medical condition","Chronobiology window per condition","Condition-specific nutrition guidance"]$J$::jsonb,
 $J$[{"strong":"60 min","span":"Full 2×/week"},{"strong":"30 min","span":"Reset 2–3×/week"},{"strong":"Consultant","span":"Manual curation"}]$J$::jsonb),
('en', 1, 'LEVEL 5', 'Preventive Optimization',
 'No active medical condition. A fully automated program to maintain and optimize your body''s system capacity.',
 $J$["Fully automated — no Consultant needed","Session Cards based on initial movement test","Personal chronobiology window","Performance diet guidance"]$J$::jsonb,
 $J$[{"strong":"60 min","span":"Full 2×/week"},{"strong":"30 min","span":"Reset 2–3×/week"},{"strong":"Automated","span":"Self-guided"}]$J$::jsonb),
('en', 2, 'ADVANCED', 'Performance 35–60',
 'Hormonal and performance optimization for men or women aged 35–60. Sub-programs specific to age, gender, and hormonal profile.',
 $J$["Women's Program: 35–45 and 46–60","Men's Program: 35–45 and 46–60","Session window based on hormonal peak","Hormonal optimization diet guidance"]$J$::jsonb,
 $J$[{"strong":"Women's","span":"35–45 / 46–60"},{"strong":"Men's","span":"35–45 / 46–60"},{"strong":"Automated","span":"Gender-specific"}]$J$::jsonb);


-- ─── Collections: cms_pricing_tiers (4 items × 2 locales) ───────────

INSERT INTO cms_pricing_tiers (
    locale, order_index, name, for_whom,
    amount_monthly, per_monthly,
    amount_yearly, per_yearly, equiv_yearly, original_yearly, savings_yearly,
    features, cta_label, cta_style, is_featured
) VALUES
('id', 0, 'System Check', 'Kenali kondisi sistemmu dulu',
 'Gratis', '/ selamanya',
 NULL, NULL, NULL, NULL, NULL,
 $J$["SF System Assessment (25Q)","System Score awal","Chronobiology Window","Akses modul dasar"]$J$::jsonb,
 'Mulai Gratis', 'outline', FALSE),
('id', 1, 'Preventive Auto', 'Level 5 — tanpa kondisi medis',
 '399K', '/ bulan',
 '3.830K', '/ tahun', 'setara 319K/bulan', '4.788K', 'Hemat Rp 958rb/tahun',
 $J$["Program otomatis penuh","Full Program + Daily Reset","Session Card + video","Nutrition Guidance"]$J$::jsonb,
 'Mulai Assessment', 'solid', FALSE),
('id', 2, 'Performance', 'Pria atau wanita 35–60',
 '499K', '/ bulan',
 '4.790K', '/ tahun', 'setara 399K/bulan', '5.988K', 'Hemat Rp 1,2jt/tahun',
 $J$["Women's atau Men's Program","Sub-program spesifik usia","Hormonal optimization guide","Monthly program progression"]$J$::jsonb,
 'Mulai Assessment', 'solid', TRUE),
('id', 3, 'System Active', 'Level 4–5 dengan kondisi medis',
 '799K', '/ bulan',
 '7.670K', '/ tahun', 'setara 639K/bulan', '9.588K', 'Hemat Rp 1,9jt/tahun',
 $J$["Health Consultant penuh","Program dikurasi manual","Medical Flag monitoring","Lab Consultation (wajib, 350K)"]$J$::jsonb,
 'Mulai Assessment', 'gold', FALSE),

('en', 0, 'System Check', 'Know your system first',
 'Free', '/ forever',
 NULL, NULL, NULL, NULL, NULL,
 $J$["SF System Assessment (25Q)","Initial System Score","Chronobiology Window","Access to base modules"]$J$::jsonb,
 'Start Free', 'outline', FALSE),
('en', 1, 'Preventive Auto', 'Level 5 — no medical condition',
 '399K', '/ month',
 '3,830K', '/ year', 'equiv. 319K/month', '4,788K', 'Save Rp 958K/year',
 $J$["Fully automated program","Full Program + Daily Reset","Session Card + video","Nutrition Guidance"]$J$::jsonb,
 'Start Assessment', 'solid', FALSE),
('en', 2, 'Performance', 'Men or women 35–60',
 '499K', '/ month',
 '4,790K', '/ year', 'equiv. 399K/month', '5,988K', 'Save Rp 1.2M/year',
 $J$["Women's or Men's Program","Age-specific sub-program","Hormonal optimization guide","Monthly program progression"]$J$::jsonb,
 'Start Assessment', 'solid', TRUE),
('en', 3, 'System Active', 'Level 4–5 with medical condition',
 '799K', '/ month',
 '7,670K', '/ year', 'equiv. 639K/month', '9,588K', 'Save Rp 1.9M/year',
 $J$["Full Health Consultant support","Manually curated program","Medical Flag monitoring","Lab Consultation (required, 350K)"]$J$::jsonb,
 'Start Assessment', 'gold', FALSE);


-- ─── Publish all drafts atomically ───────────────────────────────────
UPDATE cms_content
SET    published_data = draft_data,
       published_at   = NOW();


-- +migrate Down
TRUNCATE cms_pricing_tiers, cms_programs, cms_testimonials, cms_content RESTART IDENTITY CASCADE;
