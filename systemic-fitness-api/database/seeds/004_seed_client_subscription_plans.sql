-- ═══════════════════════════════════════════════════════════════════
--  Seed: Client Subscription Plans (3 tiers × 2 billing periods)
--
--  Pricing Strategy:
--    Basic  → entry point (pemula, self-guided)
--    Pro    → sweet spot / most recommended
--    Elite  → hybrid coaching, mendekati personal trainer
--
--  Annual plans get ~16–17% discount (lock cashflow + reduce churn)
-- ═══════════════════════════════════════════════════════════════════

-- Deactivate old plans that don't have tier info
UPDATE payment_plans SET is_active = FALSE WHERE tier IS NULL;

-- ─── Basic Plans ────────────────────────────────────────────────

INSERT INTO payment_plans (name, description, price, currency, duration_months, features, is_active,
                           tier, billing_period, original_price, discount_pct, is_popular, sort_order)
VALUES
('Basic', 'Cocok untuk pemula yang ingin mulai latihan mandiri.',
 99000, 'IDR', 1,
 '["Akses video workout library", "1 program latihan dasar", "Progress tracking", "Panduan latihan pemula"]'::JSONB,
 TRUE, 'basic', 'monthly', NULL, 0, FALSE, 1),

('Basic Annual', 'Basic plan — hemat 16% dengan pembayaran tahunan.',
 999000, 'IDR', 12,
 '["Semua fitur Basic", "Hemat 16%", "Akses penuh 12 bulan"]'::JSONB,
 TRUE, 'basic', 'annual', 1188000, 16, FALSE, 2);

-- ─── Pro Plans (Most Popular) ───────────────────────────────────

INSERT INTO payment_plans (name, description, price, currency, duration_months, features, is_active,
                           tier, billing_period, original_price, discount_pct, is_popular, sort_order)
VALUES
('Pro', 'Paling populer — untuk kamu yang serius ingin transformasi.',
 299000, 'IDR', 1,
 '["Semua fitur Basic", "Program terstruktur (bulking, cutting, dll)", "Nutrition tracking", "Body metrics & progress foto", "Chat terbatas dengan coach", "Akses komunitas"]'::JSONB,
 TRUE, 'pro', 'monthly', NULL, 0, TRUE, 3),

('Pro Annual', 'Pro plan — hemat 30% dengan pembayaran tahunan.',
 2499000, 'IDR', 12,
 '["Semua fitur Pro", "Hemat 30%", "Bonus: 2 sesi konsultasi gratis", "Akses penuh 12 bulan"]'::JSONB,
 TRUE, 'pro', 'annual', 3588000, 30, FALSE, 4);

-- ─── Elite Plans (Hybrid Coaching) ──────────────────────────────

INSERT INTO payment_plans (name, description, price, currency, duration_months, features, is_active,
                           tier, billing_period, original_price, discount_pct, is_popular, sort_order)
VALUES
('Elite', 'Mendekati personal trainer — custom plan + review mingguan.',
 799000, 'IDR', 1,
 '["Semua fitur Pro", "Custom workout plan", "Custom meal plan", "Review progress mingguan", "Chat langsung dengan coach", "Prioritas support"]'::JSONB,
 TRUE, 'elite', 'monthly', NULL, 0, FALSE, 5),

('Elite Annual', 'Elite plan — hemat 27% dengan pembayaran tahunan.',
 6999000, 'IDR', 12,
 '["Semua fitur Elite", "Hemat 27%", "Bonus: 1-on-1 video call per bulan", "Akses penuh 12 bulan"]'::JSONB,
 TRUE, 'elite', 'annual', 9588000, 27, FALSE, 6);
