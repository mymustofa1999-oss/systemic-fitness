-- +migrate Up
-- ════════════════════════════════════════════════════════════════════
--  045: SF Payment Plans v2 — 4 Tier baru sesuai SF Master Spec §05.
--
--  Strategy: ADDITIVE.
--    - Plan lama (basic/pro/elite) di-flag is_legacy=true dan di-set
--      is_active=false agar tidak muncul di mobile/web subscription page.
--      Subscription existing user yang masih aktif tidak terdampak
--      (mereka punya FK ke plan_id yang tetap valid).
--    - INSERT 4 plan v2:
--        Free        — 0 / bulan
--        Tier 1      — Rp 399.000 / bulan (Preventive Auto)
--        Tier 2      — Rp 499.000 / bulan (Performance Program)
--        Tier 3      — Rp 799.000 / bulan (System Active, Lab wajib)
--        Tier 4      — Rp 1.499.000 / bulan (System Elite, WAITLIST)
--      Plus 4 plan annual (Tier 1-3 diskon 15%, Tier 4 sama).
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE payment_plans
    ADD COLUMN IF NOT EXISTS is_legacy BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN payment_plans.is_legacy IS
    'TRUE = plan lama (pre-SF v2), tidak muncul di subscription page baru.';

-- Mark legacy plans
UPDATE payment_plans
SET is_legacy = TRUE,
    is_active = FALSE
WHERE tier IN ('basic', 'pro', 'elite');

-- ─── Insert v2 plans (idempotent via name uniqueness) ───────────────

-- Free
INSERT INTO payment_plans
    (name, description, price, billing_period, tier,
     duration_months, features, is_active, is_popular, sort_order)
VALUES (
    'SF Free — System Check',
    'Akses gratis selamanya. Asesmen lengkap (Phase A/B/C) + System Score awal + Chronobiology Window personal.',
    0,
    'lifetime',
    'sf_free',
    1200,
    '["SF System Assessment lengkap (Phase A + B + C)","System Score awal (Movement + Rest + Nutrition)","Chronobiology Window — rekomendasi waktu sesi","Akses modul gratis: Gerakan dari Kursi (Level 0-3)","Waitlist program berbayar"]'::jsonb,
    TRUE, FALSE, 10
)
ON CONFLICT DO NOTHING;

-- Tier 1 — Preventive Auto (monthly)
INSERT INTO payment_plans
    (name, description, price, billing_period, tier,
     duration_months, features, is_active, is_popular, sort_order)
VALUES (
    'SF Tier 1 — Preventive Auto',
    'Untuk Level 5 tanpa kondisi medis — fully automated, scale tanpa Consultant.',
    399000,
    'monthly',
    'sf_tier_1',
    1,
    '["Semua fitur Free","Full Program 60 mnt, 2x/minggu (automated Session Card)","Daily Reset 30 mnt, 2-3x/minggu","Session Card dengan video gerakan + metronome BPM + breathing guide","Nutrition Guidance otomatis berbasis AI","System Score update setiap minggu","Mode Didampingi (Guided View) untuk setiap sesi"]'::jsonb,
    TRUE, FALSE, 20
)
ON CONFLICT DO NOTHING;

-- Tier 1 annual (3 bulan, hemat 15%)
INSERT INTO payment_plans
    (name, description, price, billing_period, tier,
     duration_months, original_price, discount_pct, features, is_active, is_popular, sort_order)
VALUES (
    'SF Tier 1 — Preventive Auto (3 Bulan)',
    'Bayar 3 bulan di muka, hemat 15%.',
    1017000,
    'quarterly',
    'sf_tier_1',
    3,
    1197000, 15,
    '["Semua fitur Tier 1 monthly","Hemat Rp 180.000 dibanding bayar bulanan"]'::jsonb,
    TRUE, FALSE, 21
)
ON CONFLICT DO NOTHING;

-- Tier 2 — Performance Program (monthly)
INSERT INTO payment_plans
    (name, description, price, billing_period, tier,
     duration_months, features, is_active, is_popular, sort_order)
VALUES (
    'SF Tier 2 — Performance Program',
    'Pria atau wanita usia 35-60, tanpa kondisi medis aktif. Gender & age specific.',
    499000,
    'monthly',
    'sf_tier_2',
    1,
    '["Semua fitur Tier 1","Women''s Performance ATAU Men''s Performance Program","Sub-program spesifik usia: 35-45 atau 46-60","Nutrition Guidance khusus performance & hormonal optimization","Progress metrics: stamina, kapasitas, komposisi tubuh","Monthly program progression"]'::jsonb,
    TRUE, TRUE, 30
)
ON CONFLICT DO NOTHING;

-- Tier 2 annual
INSERT INTO payment_plans
    (name, description, price, billing_period, tier,
     duration_months, original_price, discount_pct, features, is_active, is_popular, sort_order)
VALUES (
    'SF Tier 2 — Performance Program (3 Bulan)',
    'Bayar 3 bulan di muka, hemat 15%.',
    1272000,
    'quarterly',
    'sf_tier_2',
    3,
    1497000, 15,
    '["Semua fitur Tier 2 monthly","Hemat Rp 225.000 dibanding bayar bulanan"]'::jsonb,
    TRUE, FALSE, 31
)
ON CONFLICT DO NOTHING;

-- Tier 3 — System Active (monthly), wajib Lab Consultation
INSERT INTO payment_plans
    (name, description, price, billing_period, tier,
     duration_months, features, is_active, is_popular, sort_order)
VALUES (
    'SF Tier 3 — System Active',
    'Untuk Level 4-5 dengan kondisi medis aktif. Program dikurasi Health Consultant. Wajib Lab Consultation Rp 350.000 sebelum program aktif.',
    799000,
    'monthly',
    'sf_tier_3',
    1,
    '["Semua fitur Tier 1","Lab Consultation wajib (Rp 350.000): pembacaan biomarker oleh Consultant","Program dikurasi Consultant: generate + edit + approve Session Card","Full Program 60 mnt + Daily Reset 30 mnt sesuai kondisi medis spesifik","Akses Health Consultant: pesan tidak terbatas (response 48 jam)","Laporan progres mingguan ke Consultant dashboard","Reassessment 90 hari oleh Consultant","Medical Flag monitoring"]'::jsonb,
    TRUE, FALSE, 40
)
ON CONFLICT DO NOTHING;

-- Tier 3 annual
INSERT INTO payment_plans
    (name, description, price, billing_period, tier,
     duration_months, original_price, discount_pct, features, is_active, is_popular, sort_order)
VALUES (
    'SF Tier 3 — System Active (3 Bulan)',
    'Bayar 3 bulan di muka, hemat 15%. Lab Consultation tetap dibayar terpisah Rp 350.000.',
    2037000,
    'quarterly',
    'sf_tier_3',
    3,
    2397000, 15,
    '["Semua fitur Tier 3 monthly","Hemat Rp 360.000 dibanding bayar bulanan"]'::jsonb,
    TRUE, FALSE, 41
)
ON CONFLICT DO NOTHING;

-- Tier 4 — System Elite (Trainer on-site), WAITLIST
INSERT INTO payment_plans
    (name, description, price, billing_period, tier,
     duration_months, features, is_active, is_popular, sort_order)
VALUES (
    'SF Tier 4 — System Elite (Coming Soon)',
    'Tersedia di Bandung & Jakarta. Daftar minat sekarang, kami hubungi ketika quota terbuka. Estimasi harga Rp 1.499.000/bulan saat dibuka.',
    1499000,
    'monthly',
    'sf_tier_4_waitlist',
    1,
    '["Semua fitur Tier 3","4 sesi Trainer on-site per bulan (60 menit per sesi)","Trainer hadir langsung di lokasi klien","Session Card dijalankan oleh Trainer bersertifikat","Laporan sesi Trainer langsung ke Consultant dashboard","Priority Consultant response (2 jam)"]'::jsonb,
    TRUE, FALSE, 50
)
ON CONFLICT DO NOTHING;

-- Lab Consultation add-on (sekali bayar, wajib Tier 3, opsional Tier 1-2)
INSERT INTO payment_plans
    (name, description, price, billing_period, tier,
     duration_months, features, is_active, is_popular, sort_order)
VALUES (
    'SF Lab Consultation (Add-on)',
    'Sekali bayar sebelum program aktif. Wajib Tier 3, opsional Tier 1-2. Mencakup pembacaan hasil lab + penilaian kondisi menyeluruh oleh Consultant + rekomendasi program awal.',
    350000,
    'one_time',
    'sf_lab_consultation',
    1200,
    '["Pembacaan biomarker / hasil lab oleh Consultant","Penilaian kondisi menyeluruh (riwayat medis, gaya hidup)","Rekomendasi program awal yang dipersonalisasi","Sesi 30-45 menit via online atau onsite (Bandung & Jakarta)"]'::jsonb,
    TRUE, FALSE, 60
)
ON CONFLICT DO NOTHING;

-- +migrate Down
ALTER TABLE payment_plans DROP COLUMN IF EXISTS is_legacy;
DELETE FROM payment_plans WHERE tier IN (
    'sf_free','sf_tier_1','sf_tier_2','sf_tier_3',
    'sf_tier_4_waitlist','sf_lab_consultation'
);
UPDATE payment_plans SET is_active = TRUE WHERE tier IN ('basic','pro','elite');
