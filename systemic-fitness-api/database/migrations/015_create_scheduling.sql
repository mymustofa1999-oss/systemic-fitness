-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  015: Scheduling (Calendar, Availability, Event Types)
--  Calendar events, trainer availability, and event type definitions
-- ═══════════════════════════════════════════════════════════════════

CREATE TYPE event_category AS ENUM (
    'one_on_one', 'group_class', 'personal'
);

CREATE TYPE event_status AS ENUM (
    'scheduled', 'cancelled', 'completed'
);

-- ─── Event Types ──────────────────────────────────────────────────

CREATE TABLE event_types (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100)  NOT NULL,
    description     TEXT,
    category        event_category NOT NULL DEFAULT 'one_on_one',
    duration_min    INT           NOT NULL DEFAULT 60 CHECK (duration_min > 0),
    color           VARCHAR(20),
    is_active       BOOLEAN       NOT NULL DEFAULT true,
    created_by      UUID          REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_event_types_name CHECK (char_length(name) >= 1)
);

CREATE INDEX idx_event_types_category ON event_types (category);

CREATE TRIGGER trg_event_types_updated_at
    BEFORE UPDATE ON event_types
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Calendar Events ──────────────────────────────────────────────

CREATE TABLE calendar_events (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type_id   UUID          REFERENCES event_types(id) ON DELETE SET NULL,
    title           VARCHAR(200)  NOT NULL,
    description     TEXT,
    category        event_category NOT NULL DEFAULT 'one_on_one',
    status          event_status  NOT NULL DEFAULT 'scheduled',
    start_at        TIMESTAMPTZ   NOT NULL,
    end_at          TIMESTAMPTZ   NOT NULL,
    location        VARCHAR(200),
    max_participants INT          CHECK (max_participants > 0),
    created_by      UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_calendar_events_times CHECK (end_at > start_at),
    CONSTRAINT chk_calendar_events_title CHECK (char_length(title) >= 1)
);

CREATE INDEX idx_calendar_events_creator  ON calendar_events (created_by);
CREATE INDEX idx_calendar_events_start    ON calendar_events (start_at);
CREATE INDEX idx_calendar_events_range    ON calendar_events (start_at, end_at);
CREATE INDEX idx_calendar_events_status   ON calendar_events (status) WHERE status = 'scheduled';

CREATE TRIGGER trg_calendar_events_updated_at
    BEFORE UPDATE ON calendar_events
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Event Participants ───────────────────────────────────────────

CREATE TABLE event_participants (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id    UUID          NOT NULL REFERENCES calendar_events(id) ON DELETE CASCADE,
    user_id     UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rsvp_status VARCHAR(20)   NOT NULL DEFAULT 'pending',
    joined_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_event_participants UNIQUE (event_id, user_id),
    CONSTRAINT chk_rsvp_status CHECK (rsvp_status IN ('pending', 'accepted', 'declined'))
);

CREATE INDEX idx_event_participants_event ON event_participants (event_id);
CREATE INDEX idx_event_participants_user  ON event_participants (user_id);

-- ─── Trainer Availability ─────────────────────────────────────────

CREATE TABLE trainer_availability (
    id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    trainer_id      UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    day_of_week     INT           NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    start_time      TIME          NOT NULL,
    end_time        TIME          NOT NULL,
    is_active       BOOLEAN       NOT NULL DEFAULT true,

    CONSTRAINT chk_availability_times CHECK (end_time > start_time)
);

CREATE INDEX idx_trainer_availability ON trainer_availability (trainer_id, day_of_week);

-- +migrate Down
DROP TABLE IF EXISTS trainer_availability CASCADE;
DROP TABLE IF EXISTS event_participants CASCADE;
DROP TABLE IF EXISTS calendar_events CASCADE;
DROP TABLE IF EXISTS event_types CASCADE;
DROP TYPE IF EXISTS event_status CASCADE;
DROP TYPE IF EXISTS event_category CASCADE;
