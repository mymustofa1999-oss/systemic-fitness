-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  037: Create Promotions table
--
--  Stores promotional banners / carousel items for the mobile app.
--  Each promotion has a badge, deep-link route, date range, and
--  sort order so the client can display active promos in a carousel.
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS promotions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    image_url   TEXT,
    badge       VARCHAR(50),
    route       VARCHAR(200),
    status      VARCHAR(20) NOT NULL DEFAULT 'active',
    start_date  TIMESTAMPTZ,
    end_date    TIMESTAMPTZ,
    sort_order  INT NOT NULL DEFAULT 0,
    created_by  UUID REFERENCES users(id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_promotions_status ON promotions (status);
CREATE INDEX idx_promotions_active ON promotions (status, start_date, end_date) WHERE status = 'active';

-- +migrate Down
DROP TABLE IF EXISTS promotions;
