-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  072: Systemic Session Logs
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS systemic_session_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_date DATE NOT NULL,
    session_number INTEGER NOT NULL,
    medication_status VARCHAR(255),
    
    -- Blood Pressure & Heart Rate (Pre/Post)
    bp_systolic_pre INTEGER,
    bp_diastolic_pre INTEGER,
    hr_pre INTEGER,
    bp_systolic_post INTEGER,
    bp_diastolic_post INTEGER,
    hr_post INTEGER,

    -- Deltas
    delta_sbp INTEGER,
    delta_dbp INTEGER,
    delta_hr INTEGER,

    -- Symptoms
    symptom VARCHAR(255),
    symptom_notes TEXT,
    session_stopped BOOLEAN DEFAULT false,
    resolved_under_5_min BOOLEAN DEFAULT true,

    -- SYSTEMIC SCORE (P1, P2, P3)
    p1_score NUMERIC(3,1),
    p2_score NUMERIC(3,1),
    p3_score NUMERIC(3,1),
    total_systemic_score NUMERIC(3,1),
    systemic_status VARCHAR(50), 

    -- DIETARY RISK SCREENING
    dr_low_fiber_intake BOOLEAN DEFAULT false,
    dr_cakes_pastries BOOLEAN DEFAULT false,
    dr_starchy_foods BOOLEAN DEFAULT false,
    dr_sugary_drinks BOOLEAN DEFAULT false,
    dr_butter_fatty BOOLEAN DEFAULT false,
    dr_large_carb_portion BOOLEAN DEFAULT false,
    dr_seafood_organ_meats BOOLEAN DEFAULT false,
    dr_none_of_above BOOLEAN DEFAULT false,
    dr_food_detail TEXT,
    dr_risk_count INTEGER,
    dr_risk_status VARCHAR(50),
    dr_risk_score NUMERIC(3,1),

    -- HYDRATION
    hydration VARCHAR(50),
    hydration_status VARCHAR(50),
    hydration_notes TEXT,
    hydration_score NUMERIC(3,1),

    -- SLEEP RECOVERY
    sleep_recovery VARCHAR(255),
    sleep_status VARCHAR(50),
    sleep_notes TEXT,
    sleep_score NUMERIC(3,1),

    -- DAILY ACTIVITY
    daily_activity VARCHAR(255),
    activity_status VARCHAR(50),
    activity_notes TEXT,
    activity_score NUMERIC(3,1),

    -- LIFESTYLE TOTAL
    total_habit_score NUMERIC(3,1),
    lifestyle_status VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_systemic_session_logs_user_date
    ON systemic_session_logs (user_id, session_date DESC);

-- +migrate Down
DROP TABLE IF EXISTS systemic_session_logs CASCADE;
