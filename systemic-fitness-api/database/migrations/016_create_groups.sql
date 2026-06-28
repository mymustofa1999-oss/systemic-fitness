-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  016: Groups (Client Groups — separate from messaging groups)
--  Grouping clients for program assignments, scheduling, etc.
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE groups (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100)  NOT NULL,
    description TEXT,
    image_url   TEXT,
    max_members INT           CHECK (max_members > 0),
    created_by  UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_groups_name CHECK (char_length(name) >= 1)
);

CREATE INDEX idx_groups_created_by ON groups (created_by);

CREATE TRIGGER trg_groups_updated_at
    BEFORE UPDATE ON groups
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Group Members ────────────────────────────────────────────────

CREATE TABLE group_members (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id    UUID          NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id     UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role        VARCHAR(20)   NOT NULL DEFAULT 'member',
    joined_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_group_members UNIQUE (group_id, user_id),
    CONSTRAINT chk_group_member_role CHECK (role IN ('admin', 'member'))
);

CREATE INDEX idx_group_members_group ON group_members (group_id);
CREATE INDEX idx_group_members_user  ON group_members (user_id);

-- +migrate Down
DROP TABLE IF EXISTS group_members CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
