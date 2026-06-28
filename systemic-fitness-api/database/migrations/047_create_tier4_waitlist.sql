-- +migrate Up
-- ════════════════════════════════════════════════════════════════════
--  047: SF Tier 4 Waitlist — daftarkan minat saat Tier 4 (System Elite,
--  trainer on-site) belum tersedia. Juga dipakai oleh Phase A waitlist
--  screen untuk Level 0–3 (akses program belum dibuka).
--
--  Reference: SF Master Spec §05 (Tier 4 WAITLIST) + halaman 154-155
--  (Level 0-3 waitlist copy).
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS tier4_waitlist_entries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- User_id optional (anonymous public form bisa juga submit nanti)
    user_id         UUID REFERENCES users(id) ON DELETE SET NULL,

    full_name       VARCHAR(120) NOT NULL,
    email           VARCHAR(255) NOT NULL,
    phone           VARCHAR(32),
    city            VARCHAR(80),  -- 'bandung' | 'jakarta' | other

    -- Source: tier4 (Trainer on-site) atau level_0_3 (mobility waitlist).
    source          VARCHAR(32) NOT NULL DEFAULT 'tier4'
        CHECK (source IN ('tier4','level_0_3','other')),

    -- Optional reference ke assessment v2 yang trigger join.
    assessment_id   UUID REFERENCES assessments(id) ON DELETE SET NULL,

    -- Free-form note dari user
    note            TEXT,

    -- Admin handling
    status          VARCHAR(20) NOT NULL DEFAULT 'new'
        CHECK (status IN ('new','contacted','converted','closed')),
    admin_note      TEXT,
    contacted_at    TIMESTAMPTZ,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_tier4_waitlist_email
        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TRIGGER set_tier4_waitlist_entries_updated_at
    BEFORE UPDATE ON tier4_waitlist_entries
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

CREATE INDEX IF NOT EXISTS idx_tier4_waitlist_status_created
    ON tier4_waitlist_entries (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tier4_waitlist_email
    ON tier4_waitlist_entries (LOWER(email));
CREATE INDEX IF NOT EXISTS idx_tier4_waitlist_user
    ON tier4_waitlist_entries (user_id)
    WHERE user_id IS NOT NULL;

-- +migrate Down
DROP TABLE IF EXISTS tier4_waitlist_entries;
