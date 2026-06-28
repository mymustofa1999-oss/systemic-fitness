-- ═══════════════════════════════════════════════════════════════
--  011: Device Tokens & Notifications (FCM)
-- ═══════════════════════════════════════════════════════════════

-- Notification types
CREATE TYPE notification_status AS ENUM ('unread', 'read', 'dismissed');

-- ── Device Tokens (for push notifications via FCM) ─────────────
CREATE TABLE device_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token           TEXT NOT NULL,
    platform        VARCHAR(20) NOT NULL DEFAULT 'android',  -- android, ios, web
    device_name     VARCHAR(100),
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One token per device per user
CREATE UNIQUE INDEX idx_device_tokens_token ON device_tokens(token);
CREATE INDEX idx_device_tokens_user ON device_tokens(user_id) WHERE is_active = true;

CREATE TRIGGER trg_device_tokens_updated
    BEFORE UPDATE ON device_tokens
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ── Notifications (in-app notification history) ────────────────
CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(200) NOT NULL,
    body            TEXT NOT NULL,
    type            VARCHAR(50) NOT NULL DEFAULT 'general',  -- workout_reminder, payment_due, subscription_expiring, new_message, program_reminder, milestone, promo, general
    data            JSONB,              -- deep link payload: {"type": "...", "target_id": "..."}
    status          notification_status NOT NULL DEFAULT 'unread',
    sent_via_push   BOOLEAN NOT NULL DEFAULT false,
    push_sent_at    TIMESTAMPTZ,
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_status ON notifications(user_id, status) WHERE status = 'unread';
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);

-- ── Promo / Broadcast Notifications ────────────────────────────
CREATE TABLE broadcast_notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title           VARCHAR(200) NOT NULL,
    body            TEXT NOT NULL,
    type            VARCHAR(50) NOT NULL DEFAULT 'promo',  -- promo, announcement, maintenance
    data            JSONB,              -- optional deep link payload
    target_roles    TEXT[],             -- null = all users, or ['client'], ['trainer','client']
    image_url       TEXT,               -- optional promo image
    scheduled_at    TIMESTAMPTZ,        -- null = send immediately
    sent_at         TIMESTAMPTZ,
    sent_count      INT DEFAULT 0,
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
