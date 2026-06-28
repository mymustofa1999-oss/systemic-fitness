-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  035: Payment Gateway Support
--
--  Adds support for two payment flows:
--    1. Manual Bank Transfer — admin-managed bank accounts, customer
--       transfers manually & uploads proof, admin verifies.
--    2. Midtrans Snap        — generated snap_token + redirect_url,
--       webhook updates payment_records on completion.
--
--  Notes:
--    - payment_type column is intentionally TEXT (not enum) to allow
--      easy extension (qris, ewallet, etc.) without future migrations.
--    - external_id, paid_at, metadata columns already exist (010).
-- ═══════════════════════════════════════════════════════════════════

-- ─── Bank Accounts (manual transfer destinations) ──────────────────

CREATE TABLE bank_accounts (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    bank_name       VARCHAR(100) NOT NULL,
    account_number  VARCHAR(50)  NOT NULL,
    account_holder  VARCHAR(100) NOT NULL,
    branch          VARCHAR(100),
    notes           TEXT,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    sort_order      INT          NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_bank_accounts_bank_name      CHECK (char_length(bank_name) >= 1),
    CONSTRAINT chk_bank_accounts_account_number CHECK (char_length(account_number) >= 1),
    CONSTRAINT chk_bank_accounts_account_holder CHECK (char_length(account_holder) >= 1)
);

CREATE INDEX idx_bank_accounts_active ON bank_accounts (is_active, sort_order)
    WHERE is_active = TRUE;

CREATE TRIGGER trg_bank_accounts_updated_at
    BEFORE UPDATE ON bank_accounts
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

COMMENT ON TABLE bank_accounts IS
    'Bank accounts customers transfer to for manual payments. Managed by admin.';

-- Seed a placeholder so the manual flow works out of the box.
INSERT INTO bank_accounts (bank_name, account_number, account_holder, branch, sort_order)
VALUES ('BCA', '0000000000', 'PT FitCoach Indonesia', 'KCP Jakarta Pusat', 1);

-- ─── Extend payment_records for both flows ─────────────────────────

ALTER TABLE payment_records
    ADD COLUMN payment_type        VARCHAR(30),
    ADD COLUMN bank_account_id     UUID REFERENCES bank_accounts(id) ON DELETE SET NULL,
    ADD COLUMN proof_image_url     TEXT,
    ADD COLUMN proof_uploaded_at   TIMESTAMPTZ,
    ADD COLUMN snap_token          VARCHAR(255),
    ADD COLUMN snap_redirect_url   TEXT,
    ADD COLUMN gateway_status      VARCHAR(50),
    ADD COLUMN gateway_response    JSONB;

COMMENT ON COLUMN payment_records.payment_type IS
    'Payment flow type: manual_transfer | midtrans_snap | midtrans_va | midtrans_qris | midtrans_ewallet';
COMMENT ON COLUMN payment_records.proof_image_url IS
    'Manual transfer: URL of uploaded transfer receipt image (uploads service).';
COMMENT ON COLUMN payment_records.snap_token IS
    'Midtrans Snap: unique token for the transaction (frontend uses this).';
COMMENT ON COLUMN payment_records.snap_redirect_url IS
    'Midtrans Snap: full redirect URL where user completes the payment.';
COMMENT ON COLUMN payment_records.gateway_status IS
    'Midtrans transaction_status: pending | settlement | capture | deny | cancel | expire | refund | chargeback';
COMMENT ON COLUMN payment_records.gateway_response IS
    'Last raw webhook payload from Midtrans (for debugging & audit).';

CREATE INDEX idx_payment_records_proof
    ON payment_records (proof_uploaded_at DESC)
    WHERE proof_image_url IS NOT NULL;

CREATE INDEX idx_payment_records_gateway_status
    ON payment_records (gateway_status)
    WHERE gateway_status IS NOT NULL;

-- +migrate Down
DROP INDEX IF EXISTS idx_payment_records_gateway_status;
DROP INDEX IF EXISTS idx_payment_records_proof;

ALTER TABLE payment_records
    DROP COLUMN IF EXISTS gateway_response,
    DROP COLUMN IF EXISTS gateway_status,
    DROP COLUMN IF EXISTS snap_redirect_url,
    DROP COLUMN IF EXISTS snap_token,
    DROP COLUMN IF EXISTS proof_uploaded_at,
    DROP COLUMN IF EXISTS proof_image_url,
    DROP COLUMN IF EXISTS bank_account_id,
    DROP COLUMN IF EXISTS payment_type;

DROP TABLE IF EXISTS bank_accounts CASCADE;
