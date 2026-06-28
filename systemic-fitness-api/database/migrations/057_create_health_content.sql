-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  057: Create Health Content tables (Articles & Videos)
-- ═══════════════════════════════════════════════════════════════════

-- ─── health_articles ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS health_articles (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title         TEXT NOT NULL,
    content       TEXT NOT NULL,
    image_url     TEXT NOT NULL,
    source        TEXT NOT NULL DEFAULT 'Systemic Fitness',
    is_published  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_health_articles_published_created ON health_articles (is_published, created_at DESC);

-- ─── doctor_videos ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS doctor_videos (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title             TEXT NOT NULL,
    description       TEXT NOT NULL DEFAULT '',
    video_url         TEXT NOT NULL,
    thumbnail_url     TEXT NOT NULL,
    doctor_name       TEXT NOT NULL,
    doctor_specialty  TEXT NOT NULL DEFAULT 'Spesialis Kesehatan',
    is_published      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_doctor_videos_published_created ON doctor_videos (is_published, created_at DESC);

-- ─── Seed Menus and Privileges ──────────────────────────────────────
INSERT INTO menus (id, parent_id, code, label, icon, href, sort_order) VALUES
  ('a0000000-0000-0000-0000-000000000057', NULL, 'health-news', 'Health News', 'Megaphone', '/health-news', 34),
  ('a0000000-0000-0000-0000-000000000058', NULL, 'doctor-videos', 'Doctor Videos', 'HeartPulse', '/doctor-videos', 35)
ON CONFLICT (code) DO NOTHING;

-- Privileges: Owner
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'owner'::user_role, true FROM menus WHERE code IN ('health-news', 'doctor-videos')
ON CONFLICT (menu_id, role) DO NOTHING;

-- Privileges: Admin
INSERT INTO menu_role_privileges (menu_id, role, can_access)
SELECT id, 'admin'::user_role, true FROM menus WHERE code IN ('health-news', 'doctor-videos')
ON CONFLICT (menu_id, role) DO NOTHING;

-- ─── Dummy Data ─────────────────────────────────────────────────────
INSERT INTO health_articles (title, content, image_url, source) VALUES
  ('Hidrasi Tepat: Kunci Utama Performa Maksimal',
   'Minum air yang cukup bukan sekadar menghilangkan rasa haus. Saat kita berolahraga, tubuh kehilangan cairan dan elektrolit melalui keringat. Kekurangan cairan hingga 2% dari berat badan dapat menurunkan performa atletik secara drastis, memicu kram otot, dan mempercepat kelelahan. Direkomendasikan untuk mengonsumsi 500ml air 2 jam sebelum latihan, dan 150-200ml setiap 15-20 menit selama latihan intensitas tinggi.',
   'https://images.unsplash.com/photo-1548690312-e3b507d8c110?q=80&w=600&auto=format&fit=crop',
   'dr. Andi Wijaya, Sp.KO'),
  ('Pentingnya Tidur Berkualitas Bagi Pertumbuhan Otot',
   'Banyak orang mengira otot tumbuh saat mereka mengangkat beban di gym. Faktanya, latihan beban merobek serat otot (micro-tears), dan proses perbaikan serta pertumbuhan otot yang sebenarnya terjadi saat kita beristirahat, terutama selama fase deep sleep. Selama tidur nyenyak, tubuh melepaskan hormon pertumbuhan (Human Growth Hormone) yang sangat krusial untuk pemulihan jaringan. Kurang tidur kronis terbukti meningkatkan hormon stres kortisol yang justru bersifat katabolik (memecah otot).',
   'https://images.unsplash.com/photo-1511295742364-92b9345f8e00?q=80&w=600&auto=format&fit=crop',
   'dr. Budi Utomo, Sp.N'),
  ('Strategi Mengatur Asupan Protein Harian',
   'Protein adalah makronutrisi pembangun utama tubuh. Bagi individu aktif, kebutuhan protein berkisar antara 1.6 hingga 2.2 gram per kilogram berat badan setiap hari. Dibandingkan mengonsumsi seluruh protein dalam satu kali makan besar, membagi asupan protein menjadi 20-40 gram per sesi makan setiap 3-4 jam terbukti lebih efektif untuk menstimulasi sintesis protein otot secara berkelanjutan sepanjang hari.',
   'https://images.unsplash.com/photo-1532550907401-a500c9a57435?q=80&w=600&auto=format&fit=crop',
   'dr. Sarah Smith, Sp.GK')
ON CONFLICT DO NOTHING;

INSERT INTO doctor_videos (title, description, video_url, thumbnail_url, doctor_name, doctor_specialty) VALUES
  ('Tips Latihan Kardio Aman untuk Jantung',
   'Panduan bagi pemula dan penderita hipertensi dalam melakukan latihan kardiovaskular secara aman dan terkontrol.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ',
   'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=600&auto=format&fit=crop',
   'dr. Andi Wijaya, Sp.JP',
   'Spesialis Jantung & Pembuluh Darah'),
  ('Mengapa Diet Ketat Sering Gagal?',
   'Penjelasan mendalam dari kacamata medis mengenai metabolisme tubuh saat menghadapi defisit kalori yang terlalu ekstrem.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ',
   'https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=600&auto=format&fit=crop',
   'dr. Sarah Smith, Sp.GK',
   'Spesialis Gizi Klinik')
ON CONFLICT DO NOTHING;

-- +migrate Down
DROP TABLE IF EXISTS doctor_videos;
DROP TABLE IF EXISTS health_articles;
DELETE FROM menu_role_privileges WHERE menu_id IN ('a0000000-0000-0000-0000-000000000057', 'a0000000-0000-0000-0000-000000000058');
DELETE FROM menus WHERE id IN ('a0000000-0000-0000-0000-000000000057', 'a0000000-0000-0000-0000-000000000058');
