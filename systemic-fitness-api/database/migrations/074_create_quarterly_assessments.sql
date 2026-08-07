-- Migration 074: Create quarterly_assessments table
CREATE TABLE IF NOT EXISTS quarterly_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quarter VARCHAR(10) NOT NULL, -- e.g., 'Q1', 'Q2', etc.
    period_range VARCHAR(50), -- e.g., 'Jan-Mar 2026'
    current_level SMALLINT NOT NULL,
    functional_criteria_met BOOLEAN NOT NULL DEFAULT FALSE,
    movement_quality_met BOOLEAN NOT NULL DEFAULT FALSE,
    avg_systemic_score NUMERIC(4,2) NOT NULL,
    score_status_met BOOLEAN NOT NULL DEFAULT FALSE,
    decision VARCHAR(20) NOT NULL, -- 'PROGRESS', 'HOLD', 'INCOMPLETE'
    new_level SMALLINT,
    
    height_cm NUMERIC(5,2),
    weight_kg NUMERIC(5,2),
    gender VARCHAR(20),
    bmi NUMERIC(5,2),
    bmi_category VARCHAR(50),
    waist_circumference_cm NUMERIC(5,2),
    waist_status VARCHAR(50),
    medical_condition TEXT,
    lab_report_link TEXT,
    
    review_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_quarterly_assessments_client_id ON quarterly_assessments(client_id);
