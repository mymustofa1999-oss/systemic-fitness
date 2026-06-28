-- +migrate Up
-- ════════════════════════════════════════════════════════════════════
--  054: SF Payment Plans v3 — Update descriptions and prices
-- ════════════════════════════════════════════════════════════════════

-- 1. Deactivate Tier 1 and Tier 4 plans
UPDATE payment_plans
SET is_active = FALSE
WHERE tier IN ('sf_tier_1', 'sf_tier_4_waitlist');

-- 2. Update Tier 2 Monthly Plan (499rb)
UPDATE payment_plans
SET name = 'SF Tier 2 — Level 5 & 6 (Dinamis)',
    description = 'Program latihan otomatis untuk Level 5 & 6 (bisa jalan dan bergerak dinamis) dengan training card otomatis sesuai kondisi medis, durasi sequence teratur, movement dasar, hitungan beban otomatis, breathing pattern, dan panduan gizi/olahraga terbatas (hipertensi).',
    price = 499000.00,
    features = '["Otomatis: Level 5 & 6 (bisa jalan & bergerak dinamis)", "Training card otomatis sesuai 1 kondisi medis (5 klasifikasi)", "Sequence durasi otomatis sesuai klasifikasi (maksimal 2 kartu)", "Full program dan daily reset", "Movement dasar (gerakan dasar terbatas)", "Hitungan beban otomatis di training card", "Pola pernapasan (Breathing Pattern)", "Panduan nutrisi terbatas (hanya untuk Hipertensi)", "Panduan jam olahraga terbatas (hanya untuk Hipertensi)"]'::jsonb,
    is_active = TRUE
WHERE tier = 'sf_tier_2' AND billing_period = 'monthly';

-- 3. Update Tier 2 Quarterly Plan
UPDATE payment_plans
SET name = 'SF Tier 2 — Level 5 & 6 (3 Bulan)',
    description = 'Bayar 3 bulan di muka, hemat 15%.',
    price = 1272000.00,
    features = '["Otomatis: Level 5 & 6 (bisa jalan & bergerak dinamis)", "Training card otomatis sesuai 1 kondisi medis (5 klasifikasi)", "Sequence durasi otomatis sesuai klasifikasi (maksimal 2 kartu)", "Full program dan daily reset", "Movement dasar (gerakan dasar terbatas)", "Hitungan beban otomatis di training card", "Pola pernapasan (Breathing Pattern)", "Panduan nutrisi terbatas (hanya untuk Hipertensi)", "Panduan jam olahraga terbatas (hanya untuk Hipertensi)"]'::jsonb,
    is_active = TRUE
WHERE tier = 'sf_tier_2' AND billing_period = 'quarterly';

-- 4. Update Tier 3 Monthly Plan (799rb)
UPDATE payment_plans
SET name = 'SF Tier 3 — System Active (Medical & Preventive)',
    description = 'Program lengkap dengan training card otomatis preventive & klasifikasi medis lengkap, sequence waktu otomatis (FC 15m, CC 20m, MC 20m, CD 5m), hitungan beban berbasis profil lengkap, tempo/BPM otomatis, dan panduan gizi lengkap untuk semua kondisi.',
    price = 799000.00,
    features = '["Training card otomatis preventive & klasifikasi medis", "Sequence waktu otomatis (Preventive FC 15m, CC 20m, MC 20m, CD 5m)", "Full program dan daily reset", "Semua gerakan dibuka bebas untuk dipilih (Full Movement)", "Hitungan beban otomatis berbasis gender, umur, dan tinggi badan", "Rekomendasi rentang tempo/BPM otomatis di masing-masing set (FC 3 set, CC 2 set, MC 3 set)", "Pola pernapasan (Breathing Pattern)", "Panduan nutrisi lengkap untuk semua kondisi kesehatan"]'::jsonb,
    is_active = TRUE
WHERE tier = 'sf_tier_3' AND billing_period = 'monthly';

-- 5. Update Tier 3 Quarterly Plan
UPDATE payment_plans
SET name = 'SF Tier 3 — System Active (3 Bulan)',
    description = 'Bayar 3 bulan di muka, hemat 15%. Lab Consultation tetap dibayar terpisah Rp 350.000.',
    price = 2037000.00,
    features = '["Training card otomatis preventive & klasifikasi medis", "Sequence waktu otomatis (Preventive FC 15m, CC 20m, MC 20m, CD 5m)", "Full program dan daily reset", "Semua gerakan dibuka bebas untuk dipilih (Full Movement)", "Hitungan beban otomatis berbasis gender, umur, dan tinggi badan", "Rekomendasi rentang tempo/BPM otomatis di masing-masing set (FC 3 set, CC 2 set, MC 3 set)", "Pola pernapasan (Breathing Pattern)", "Panduan nutrisi lengkap untuk semua kondisi kesehatan"]'::jsonb,
    is_active = TRUE
WHERE tier = 'sf_tier_3' AND billing_period = 'quarterly';

-- +migrate Down
UPDATE payment_plans
SET is_active = TRUE
WHERE tier IN ('sf_tier_1', 'sf_tier_4_waitlist');

UPDATE payment_plans
SET name = 'SF Tier 2 — Performance Program',
    description = 'Pria atau wanita usia 35-60, tanpa kondisi medis aktif. Gender & age specific.',
    price = 499000,
    features = '["Semua fitur Tier 1","Women''s Performance ATAU Men''s Performance Program","Sub-program spesifik usia: 35-45 atau 46-60","Nutrition Guidance khusus performance & hormonal optimization","Progress metrics: stamina, kapasitas, komposisi tubuh","Monthly program progression"]'::jsonb
WHERE tier = 'sf_tier_2' AND billing_period = 'monthly';

UPDATE payment_plans
SET name = 'SF Tier 2 — Performance Program (3 Bulan)',
    description = 'Bayar 3 bulan di muka, hemat 15%.',
    price = 1272000
WHERE tier = 'sf_tier_2' AND billing_period = 'quarterly';

UPDATE payment_plans
SET name = 'SF Tier 3 — System Active',
    description = 'Untuk Level 4-5 dengan kondisi medis aktif. Program dikurasi Health Consultant. Wajib Lab Consultation Rp 350.000 sebelum program aktif.',
    price = 799000,
    features = '["Semua fitur Tier 1","Lab Consultation wajib (Rp 350.000): pembacaan biomarker oleh Consultant","Program dikurasi Consultant: generate + edit + approve Session Card","Full Program 60 mnt + Daily Reset 30 mnt sesuai kondisi medis spesifik","Akses Health Consultant: pesan tidak terbatas (response 48 jam)","Laporan progres mingguan ke Consultant dashboard","Reassessment 90 hari oleh Consultant","Medical Flag monitoring"]'::jsonb
WHERE tier = 'sf_tier_3' AND billing_period = 'monthly';

UPDATE payment_plans
SET name = 'SF Tier 3 — System Active (3 Bulan)',
    description = 'Bayar 3 bulan di muka, hemat 15%. Lab Consultation tetap dibayar terpisah Rp 350.000.',
    price = 2037000
WHERE tier = 'sf_tier_3' AND billing_period = 'quarterly';
