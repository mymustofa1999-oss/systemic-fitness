-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  008: Conversations, Members & Messages
--  Direct + group messaging with read tracking
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE conversations (
    id          UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
    type        conversation_type NOT NULL DEFAULT 'direct',
    name        VARCHAR(100),
    created_at  TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ       NOT NULL DEFAULT NOW(),

    -- Group conversations must have a name
    CONSTRAINT chk_conversations_group_name CHECK (
        type = 'direct' OR (type = 'group' AND name IS NOT NULL)
    )
);

CREATE TRIGGER trg_conversations_updated_at
    BEFORE UPDATE ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Conversation Members ───────────────────────────────────────

CREATE TABLE conversation_members (
    conversation_id UUID              NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id         UUID              NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at       TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    role            conversation_role NOT NULL DEFAULT 'member',
    is_muted        BOOLEAN           NOT NULL DEFAULT FALSE,
    last_read_at    TIMESTAMPTZ,

    PRIMARY KEY (conversation_id, user_id)
);

CREATE INDEX idx_conversation_members_user ON conversation_members (user_id);

-- ─── Messages ───────────────────────────────────────────────────

CREATE TABLE messages (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID          NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id       UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content         TEXT,
    type            message_type  NOT NULL DEFAULT 'text',
    media_url       TEXT,
    is_read         BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    -- Text messages must have content, media messages must have URL
    CONSTRAINT chk_messages_content CHECK (
        (type = 'text' AND content IS NOT NULL AND char_length(content) > 0) OR
        (type IN ('image', 'voice') AND media_url IS NOT NULL) OR
        (type = 'system' AND content IS NOT NULL)
    )
);

CREATE INDEX idx_messages_conversation_created ON messages (conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender               ON messages (sender_id);
CREATE INDEX idx_messages_unread               ON messages (conversation_id, is_read) WHERE is_read = FALSE;

-- Trigger: update conversation.updated_at when a new message arrives
CREATE OR REPLACE FUNCTION fn_message_update_conversation()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET updated_at = NOW()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_messages_update_conversation
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION fn_message_update_conversation();

-- +migrate Down
DROP TRIGGER IF EXISTS trg_messages_update_conversation ON messages;
DROP FUNCTION IF EXISTS fn_message_update_conversation();
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS conversation_members CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
