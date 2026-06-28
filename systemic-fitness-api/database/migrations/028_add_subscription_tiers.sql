-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  028: Add Subscription Tier Columns to Payment Plans
--  Support tiered client subscriptions (Basic, Pro, Elite)
--  with monthly & annual billing periods
-- ═══════════════════════════════════════════════════════════════════

-- Add tier and billing columns
ALTER TABLE payment_plans
    ADD COLUMN tier            VARCHAR(20),
    ADD COLUMN billing_period  VARCHAR(20)  DEFAULT 'monthly',
    ADD COLUMN original_price  DECIMAL(12,2),
    ADD COLUMN discount_pct    INT          DEFAULT 0 CHECK (discount_pct >= 0 AND discount_pct <= 100),
    ADD COLUMN is_popular      BOOLEAN      NOT NULL DEFAULT FALSE,
    ADD COLUMN sort_order      INT          NOT NULL DEFAULT 0;

COMMENT ON COLUMN payment_plans.tier IS
    'Subscription tier: basic, pro, elite';
COMMENT ON COLUMN payment_plans.billing_period IS
    'Billing cycle: monthly or annual';
COMMENT ON COLUMN payment_plans.original_price IS
    'Original price before discount (used for annual plans to show savings)';
COMMENT ON COLUMN payment_plans.discount_pct IS
    'Discount percentage for annual plans (e.g. 20 = 20%% off)';
COMMENT ON COLUMN payment_plans.is_popular IS
    'Whether to highlight this plan as recommended/most popular';

CREATE INDEX idx_payment_plans_tier ON payment_plans (tier) WHERE tier IS NOT NULL;
CREATE INDEX idx_payment_plans_sort ON payment_plans (sort_order, price);

-- +migrate Down
DROP INDEX IF EXISTS idx_payment_plans_sort;
DROP INDEX IF EXISTS idx_payment_plans_tier;

ALTER TABLE payment_plans
    DROP COLUMN IF EXISTS tier,
    DROP COLUMN IF EXISTS billing_period,
    DROP COLUMN IF EXISTS original_price,
    DROP COLUMN IF EXISTS discount_pct,
    DROP COLUMN IF EXISTS is_popular,
    DROP COLUMN IF EXISTS sort_order;
