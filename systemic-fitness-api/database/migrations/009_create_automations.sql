-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  009: Automations & Automation Logs
--  Event-driven workflow automation with execution tracking
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE automations (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100)  NOT NULL,
    description     TEXT,
    trigger_type    trigger_type  NOT NULL,
    trigger_config  JSONB         NOT NULL DEFAULT '{}',
    action_type     action_type   NOT NULL,
    action_config   JSONB         NOT NULL DEFAULT '{}',
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
    created_by      UUID          REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_automations_name CHECK (char_length(name) >= 1)
);

COMMENT ON COLUMN automations.trigger_config IS
    'Trigger-specific config. Examples:
     on_inactive_days: {"inactive_days": 3}
     scheduled: {"cron": "0 8 * * 1"}
     on_milestone: {"milestone": "100_workouts"}';

COMMENT ON COLUMN automations.action_config IS
    'Action-specific config. Examples:
     send_message: {"message": "Hey {{user.name}}!"}
     assign_program: {"program_id": "uuid-here"}
     send_email: {"template": "welcome", "subject": "Welcome!"}';

CREATE INDEX idx_automations_trigger_type ON automations (trigger_type);
CREATE INDEX idx_automations_is_active    ON automations (is_active) WHERE is_active = TRUE;
CREATE INDEX idx_automations_created_by   ON automations (created_by);

CREATE TRIGGER trg_automations_updated_at
    BEFORE UPDATE ON automations
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Automation Execution Logs ──────────────────────────────────

CREATE TABLE automation_logs (
    id              UUID                  PRIMARY KEY DEFAULT gen_random_uuid(),
    automation_id   UUID                  NOT NULL REFERENCES automations(id) ON DELETE CASCADE,
    user_id         UUID                  REFERENCES users(id) ON DELETE SET NULL,
    triggered_at    TIMESTAMPTZ           NOT NULL DEFAULT NOW(),
    status          automation_log_status NOT NULL,
    result          JSONB                 DEFAULT '{}',
    error_message   TEXT
);

CREATE INDEX idx_automation_logs_automation  ON automation_logs (automation_id, triggered_at DESC);
CREATE INDEX idx_automation_logs_user        ON automation_logs (user_id);
CREATE INDEX idx_automation_logs_status      ON automation_logs (status);
CREATE INDEX idx_automation_logs_triggered   ON automation_logs (triggered_at DESC);

-- +migrate Down
DROP TABLE IF EXISTS automation_logs CASCADE;
DROP TABLE IF EXISTS automations CASCADE;
