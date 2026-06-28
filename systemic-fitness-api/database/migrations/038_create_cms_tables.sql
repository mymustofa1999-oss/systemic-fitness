-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  038: Create CMS tables (Phase 1 — Foundation)
--
--  Landing page CMS: editable content stored per-locale.
--  - cms_content        singleton sections (hero, nav, ...) as JSONB
--  - cms_testimonials   collection — admin can add/remove/reorder
--  - cms_programs       collection
--  - cms_pricing_tiers  collection
--  - cms_media          media library (populated in Phase 3)
--  - cms_settings       global key/value settings (populated in Phase 4)
-- ═══════════════════════════════════════════════════════════════════

-- ─── cms_media (created first so FKs resolve) ────────────────────────
CREATE TABLE IF NOT EXISTS cms_media (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename    TEXT NOT NULL,
    url         TEXT NOT NULL,
    mime        VARCHAR(64) NOT NULL,
    width       INTEGER,
    height      INTEGER,
    size_bytes  BIGINT NOT NULL DEFAULT 0,
    alt         TEXT,
    tag         VARCHAR(64),
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_cms_media_tag_created ON cms_media (tag, created_at DESC);

-- ─── cms_content (singleton sections, draft/published as JSONB) ──────
CREATE TABLE IF NOT EXISTS cms_content (
    section_key    VARCHAR(64) NOT NULL,
    locale         VARCHAR(8)  NOT NULL,
    draft_data     JSONB       NOT NULL DEFAULT '{}'::jsonb,
    published_data JSONB,
    published_at   TIMESTAMPTZ,
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by     UUID REFERENCES users(id) ON DELETE SET NULL,
    PRIMARY KEY (section_key, locale)
);

-- ─── cms_testimonials (collection) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS cms_testimonials (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    locale      VARCHAR(8) NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    name        TEXT NOT NULL,
    role        TEXT NOT NULL,
    title       TEXT NOT NULL,
    description TEXT NOT NULL,
    rating      SMALLINT NOT NULL DEFAULT 5,
    image_id    UUID REFERENCES cms_media(id) ON DELETE SET NULL,
    image_url   TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_cms_testimonials_locale_active_order
    ON cms_testimonials (locale, is_active, order_index);

-- ─── cms_programs (collection) ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS cms_programs (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    locale       VARCHAR(8) NOT NULL,
    order_index  INTEGER NOT NULL DEFAULT 0,
    tier_label   TEXT NOT NULL,
    tier_color   VARCHAR(16) NOT NULL DEFAULT '',
    name         TEXT NOT NULL,
    description  TEXT NOT NULL,
    features     JSONB NOT NULL DEFAULT '[]'::jsonb,
    meta         JSONB NOT NULL DEFAULT '[]'::jsonb,
    image_id     UUID REFERENCES cms_media(id) ON DELETE SET NULL,
    image_url    TEXT,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_cms_programs_locale_active_order
    ON cms_programs (locale, is_active, order_index);

-- ─── cms_pricing_tiers (collection) ──────────────────────────────────
CREATE TABLE IF NOT EXISTS cms_pricing_tiers (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    locale          VARCHAR(8) NOT NULL,
    order_index     INTEGER NOT NULL DEFAULT 0,
    name            TEXT NOT NULL,
    for_whom        TEXT NOT NULL,
    amount_monthly  TEXT NOT NULL,
    per_monthly     TEXT NOT NULL,
    amount_yearly   TEXT,
    per_yearly      TEXT,
    equiv_yearly    TEXT,
    original_yearly TEXT,
    savings_yearly  TEXT,
    features        JSONB NOT NULL DEFAULT '[]'::jsonb,
    cta_label       TEXT NOT NULL,
    cta_style       VARCHAR(16) NOT NULL DEFAULT 'solid',
    is_featured     BOOLEAN NOT NULL DEFAULT FALSE,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_cms_pricing_tiers_locale_active_order
    ON cms_pricing_tiers (locale, is_active, order_index);

-- ─── cms_settings (global key/value store) ───────────────────────────
CREATE TABLE IF NOT EXISTS cms_settings (
    key        VARCHAR(64) PRIMARY KEY,
    value      JSONB NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL
);

-- +migrate Down
DROP TABLE IF EXISTS cms_settings;
DROP TABLE IF EXISTS cms_pricing_tiers;
DROP TABLE IF EXISTS cms_programs;
DROP TABLE IF EXISTS cms_testimonials;
DROP TABLE IF EXISTS cms_content;
DROP TABLE IF EXISTS cms_media;
