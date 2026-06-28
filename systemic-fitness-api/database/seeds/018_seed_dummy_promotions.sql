-- ════════════════════════════════════════════════════════════════════
--  Seed: Dummy Promotions / Banners
--  Sample promotional banners for mobile app carousel.
--  created_by = admin (admin@fitcoach.app). Placeholder UUID di bawah
--  diganti via UPDATE di akhir file supaya portable antar environment.
-- ════════════════════════════════════════════════════════════════════

INSERT INTO promotions (id, title, description, image_url, badge, route, status, start_date, end_date, sort_order, created_by) VALUES

  -- 1. New Member Promo
  ('b0000000-0000-0000-0000-000000000001',
   'New Member Special - 50% Off!',
   'Join now and get 50% off your first month subscription. Limited time offer for new members only!',
   'https://placehold.co/1200x400/FF6B35/ffffff?text=NEW+MEMBER+50%25+OFF&font=montserrat',
   'HOT',
   '/payments/plans',
   'active',
   '2026-04-01T00:00:00Z',
   '2026-06-30T23:59:59Z',
   1,
   (SELECT id FROM users WHERE email = 'admin@fitcoach.app' LIMIT 1)),

  -- 2. Summer Body Challenge
  ('b0000000-0000-0000-0000-000000000002',
   'Summer Body Challenge 2026',
   'Join our 8-week summer body transformation challenge! Includes personalized workout & meal plans.',
   'https://placehold.co/1200x400/1E90FF/ffffff?text=SUMMER+BODY+CHALLENGE&font=montserrat',
   'NEW',
   '/challenges',
   'active',
   '2026-04-10T00:00:00Z',
   '2026-07-31T23:59:59Z',
   2,
   (SELECT id FROM users WHERE email = 'admin@fitcoach.app' LIMIT 1)),

  -- 3. Free Nutrition Guide
  ('b0000000-0000-0000-0000-000000000003',
   'Free Nutrition Guide Download',
   'Download our comprehensive nutrition guide for free. Learn meal prep, macros, and healthy eating habits.',
   'https://placehold.co/1200x400/2ECC71/ffffff?text=FREE+NUTRITION+GUIDE&font=montserrat',
   'FREE',
   '/nutrition-guidance',
   'active',
   '2026-04-01T00:00:00Z',
   '2026-12-31T23:59:59Z',
   3,
   (SELECT id FROM users WHERE email = 'admin@fitcoach.app' LIMIT 1)),

  -- 4. Personal Training Discount
  ('b0000000-0000-0000-0000-000000000004',
   'Personal Training - Book 10 Get 2 Free',
   'Book 10 personal training sessions and get 2 extra sessions absolutely free!',
   'https://placehold.co/1200x400/9B59B6/ffffff?text=PT+SESSION+DEAL&font=montserrat',
   'DEAL',
   '/scheduling/calendar',
   'active',
   '2026-04-15T00:00:00Z',
   '2026-05-31T23:59:59Z',
   4,
   (SELECT id FROM users WHERE email = 'admin@fitcoach.app' LIMIT 1)),

  -- 5. Upcoming Event (draft)
  ('b0000000-0000-0000-0000-000000000005',
   'Fitness Expo 2026 - Coming Soon',
   'Get ready for the biggest fitness expo this year! Free entry for all premium members.',
   'https://placehold.co/1200x400/E74C3C/ffffff?text=FITNESS+EXPO+2026&font=montserrat',
   'SOON',
   '/announcements',
   'draft',
   '2026-08-01T00:00:00Z',
   '2026-08-15T23:59:59Z',
   5,
   (SELECT id FROM users WHERE email = 'admin@fitcoach.app' LIMIT 1)),

  -- 6. Ended promo (for testing filter)
  ('b0000000-0000-0000-0000-000000000006',
   'March Madness - 30% Off All Plans',
   'Our March promotion has ended. Stay tuned for more exciting offers!',
   'https://placehold.co/1200x400/95A5A6/ffffff?text=MARCH+MADNESS+ENDED&font=montserrat',
   'ENDED',
   '/payments/plans',
   'ended',
   '2026-03-01T00:00:00Z',
   '2026-03-31T23:59:59Z',
   6,
   (SELECT id FROM users WHERE email = 'admin@fitcoach.app' LIMIT 1))

ON CONFLICT (id) DO NOTHING;
