-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  018: Announcements
--  Broadcast announcements to all or specific user groups
-- ═══════════════════════════════════════════════════════════════════

CREATE TYPE announcement_status AS ENUM (
    'draft', 'published', 'archived'
);

CREATE TABLE announcements (
    id              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    title           VARCHAR(200)        NOT NULL,
    body            TEXT                NOT NULL,
    image_url       TEXT,
    status          announcement_status NOT NULL DEFAULT 'draft',
    target_roles    user_role[]         NOT NULL DEFAULT '{}',
    published_at    TIMESTAMPTZ,
    created_by      UUID                NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_announcements_title CHECK (char_length(title) >= 1)
);

CREATE INDEX idx_announcements_status     ON announcements (status);
CREATE INDEX idx_announcements_published  ON announcements (published_at DESC) WHERE status = 'published';
CREATE INDEX idx_announcements_creator    ON announcements (created_by);

CREATE TRIGGER trg_announcements_updated_at
    BEFORE UPDATE ON announcements
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Announcement Read Tracking ───────────────────────────────────

CREATE TABLE announcement_reads (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID          NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
    user_id         UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    read_at         TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_announcement_reads UNIQUE (announcement_id, user_id)
);

CREATE INDEX idx_announcement_reads_announcement ON announcement_reads (announcement_id);
CREATE INDEX idx_announcement_reads_user         ON announcement_reads (user_id);

-- +migrate Down
DROP TABLE IF EXISTS announcement_reads CASCADE;
DROP TABLE IF EXISTS announcements CASCADE;
DROP TYPE IF EXISTS announcement_status CASCADE;
