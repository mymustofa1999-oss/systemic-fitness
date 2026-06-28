-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  010: Payment Plans, Subscriptions & Payment Records
--  Billing infrastructure with external payment gateway support
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE payment_plans (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100)  NOT NULL,
    description     TEXT,
    price           DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    currency        VARCHAR(3)    NOT NULL DEFAULT 'IDR',
    duration_months INT           NOT NULL CHECK (duration_months >= 1),
    features        JSONB         NOT NULL DEFAULT '[]',
    max_clients     INT           CHECK (max_clients > 0),
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_payment_plans_name     CHECK (char_length(name) >= 1),
    CONSTRAINT chk_payment_plans_currency CHECK (char_length(currency) = 3)
);

COMMENT ON COLUMN payment_plans.features IS
    'JSON array of feature strings, e.g. ["Unlimited workouts", "Nutrition plans", "1-on-1 messaging"]';

CREATE INDEX idx_payment_plans_active ON payment_plans (is_active) WHERE is_active = TRUE;

CREATE TRIGGER trg_payment_plans_updated_at
    BEFORE UPDATE ON payment_plans
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Subscriptions ──────────────────────────────────────────────

CREATE TABLE subscriptions (
    id              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID                NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id         UUID                NOT NULL REFERENCES payment_plans(id) ON DELETE RESTRICT,
    status          subscription_status NOT NULL DEFAULT 'active',
    started_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMPTZ         NOT NULL,
    cancelled_at    TIMESTAMPTZ,
    payment_method  VARCHAR(50),
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_subscriptions_dates CHECK (expires_at > started_at)
);

CREATE INDEX idx_subscriptions_user        ON subscriptions (user_id);
CREATE INDEX idx_subscriptions_user_status ON subscriptions (user_id, status);
CREATE INDEX idx_subscriptions_status      ON subscriptions (status);
CREATE INDEX idx_subscriptions_expires     ON subscriptions (expires_at) WHERE status = 'active';
CREATE INDEX idx_subscriptions_plan        ON subscriptions (plan_id);

CREATE TRIGGER trg_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Payment Records ────────────────────────────────────────────

CREATE TABLE payment_records (
    id              UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID            NOT NULL REFERENCES subscriptions(id) ON DELETE RESTRICT,
    user_id         UUID            NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount          DECIMAL(12,2)   NOT NULL CHECK (amount >= 0),
    currency        VARCHAR(3)      NOT NULL DEFAULT 'IDR',
    status          payment_status  NOT NULL DEFAULT 'pending',
    payment_method  VARCHAR(50),
    external_id     VARCHAR(255),
    paid_at         TIMESTAMPTZ,
    failed_at       TIMESTAMPTZ,
    refunded_at     TIMESTAMPTZ,
    metadata        JSONB           DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_payment_records_currency CHECK (char_length(currency) = 3)
);

COMMENT ON COLUMN payment_records.external_id IS
    'Payment gateway transaction ID (Midtrans, Stripe, etc.)';

CREATE INDEX idx_payment_records_subscription ON payment_records (subscription_id);
CREATE INDEX idx_payment_records_user         ON payment_records (user_id);
CREATE INDEX idx_payment_records_status       ON payment_records (status);
CREATE INDEX idx_payment_records_external     ON payment_records (external_id) WHERE external_id IS NOT NULL;
CREATE INDEX idx_payment_records_paid_at      ON payment_records (paid_at DESC) WHERE paid_at IS NOT NULL;

CREATE TRIGGER trg_payment_records_updated_at
    BEFORE UPDATE ON payment_records
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- +migrate Down
DROP TABLE IF EXISTS payment_records CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS payment_plans CASCADE;
