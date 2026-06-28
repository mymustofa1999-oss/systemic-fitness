-- 019_create_uploads.sql
-- File upload tracking with WebP conversion support.

CREATE TABLE IF NOT EXISTS uploads (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_name   TEXT        NOT NULL,
    stored_name     TEXT        NOT NULL,
    mime_type       TEXT        NOT NULL,
    size_bytes      BIGINT      NOT NULL,
    width           INT,
    height          INT,
    path            TEXT        NOT NULL,
    url             TEXT        NOT NULL,
    uploaded_by     UUID        NOT NULL REFERENCES users(id),
    entity_type     TEXT,                       -- e.g. 'user', 'food', 'exercise', 'group', 'challenge', 'announcement', 'message'
    entity_id       UUID,                       -- FK to the related entity (optional, set after linking)
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_uploads_uploaded_by  ON uploads (uploaded_by)  WHERE deleted_at IS NULL;
CREATE INDEX idx_uploads_entity       ON uploads (entity_type, entity_id) WHERE deleted_at IS NULL;
