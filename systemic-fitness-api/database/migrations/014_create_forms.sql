-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  014: Forms (Master Library → Others → Forms)
--  Form builder: form definitions, fields, and client responses
-- ═══════════════════════════════════════════════════════════════════

CREATE TYPE form_field_type AS ENUM (
    'text', 'textarea', 'number', 'select', 'multi_select',
    'checkbox', 'radio', 'date', 'rating', 'file_upload'
);

CREATE TYPE form_status AS ENUM (
    'draft', 'published', 'archived'
);

-- ─── Forms ────────────────────────────────────────────────────────

CREATE TABLE forms (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(150)  NOT NULL,
    description TEXT,
    status      form_status   NOT NULL DEFAULT 'draft',
    is_system   BOOLEAN       NOT NULL DEFAULT false,
    created_by  UUID          REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_forms_name CHECK (char_length(name) >= 1)
);

CREATE INDEX idx_forms_status     ON forms (status);
CREATE INDEX idx_forms_created_by ON forms (created_by);

CREATE TRIGGER trg_forms_updated_at
    BEFORE UPDATE ON forms
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Form Fields ──────────────────────────────────────────────────

CREATE TABLE form_fields (
    id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    form_id     UUID            NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
    label       VARCHAR(200)    NOT NULL,
    field_type  form_field_type NOT NULL,
    required    BOOLEAN         NOT NULL DEFAULT false,
    options     JSONB,
    sort_order  INT             NOT NULL DEFAULT 0,

    CONSTRAINT chk_form_fields_label CHECK (char_length(label) >= 1)
);

CREATE INDEX idx_form_fields_form ON form_fields (form_id, sort_order);

-- ─── Form Responses ───────────────────────────────────────────────

CREATE TABLE form_responses (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    form_id     UUID          NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
    user_id     UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    answers     JSONB         NOT NULL DEFAULT '{}',
    submitted_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_form_responses_form ON form_responses (form_id);
CREATE INDEX idx_form_responses_user ON form_responses (user_id);

-- +migrate Down
DROP TABLE IF EXISTS form_responses CASCADE;
DROP TABLE IF EXISTS form_fields CASCADE;
DROP TABLE IF EXISTS forms CASCADE;
DROP TYPE IF EXISTS form_status CASCADE;
DROP TYPE IF EXISTS form_field_type CASCADE;
