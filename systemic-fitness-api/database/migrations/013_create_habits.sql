-- +migrate Up
-- ═══════════════════════════════════════════════════════════════════
--  013: Habits (Master Library → Habits)
--  Habit folders for categorisation + habit definitions + client tracking
-- ═══════════════════════════════════════════════════════════════════

-- ─── Habit Folders (categories) ───────────────────────────────────

CREATE TABLE habit_folders (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100)  NOT NULL,
    sort_order  INT           NOT NULL DEFAULT 0,
    created_by  UUID          REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_habit_folders_name CHECK (char_length(name) >= 1)
);

CREATE INDEX idx_habit_folders_sort ON habit_folders (sort_order);

CREATE TRIGGER trg_habit_folders_updated_at
    BEFORE UPDATE ON habit_folders
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Habits ───────────────────────────────────────────────────────

CREATE TABLE habits (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    folder_id   UUID          REFERENCES habit_folders(id) ON DELETE SET NULL,
    name        VARCHAR(150)  NOT NULL,
    description TEXT,
    icon        VARCHAR(50),
    is_system   BOOLEAN       NOT NULL DEFAULT false,
    created_by  UUID          REFERENCES users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_habits_name CHECK (char_length(name) >= 1)
);

CREATE INDEX idx_habits_folder    ON habits (folder_id);
CREATE INDEX idx_habits_name      ON habits (name);
CREATE INDEX idx_habits_is_system ON habits (is_system) WHERE is_system = true;

CREATE TRIGGER trg_habits_updated_at
    BEFORE UPDATE ON habits
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ─── Client Habit Tracking ────────────────────────────────────────

CREATE TABLE habit_logs (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    habit_id    UUID          NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    logged_at   DATE          NOT NULL DEFAULT CURRENT_DATE,
    completed   BOOLEAN       NOT NULL DEFAULT true,
    notes       TEXT,

    CONSTRAINT uq_habit_logs_user_habit_date UNIQUE (user_id, habit_id, logged_at)
);

CREATE INDEX idx_habit_logs_user    ON habit_logs (user_id, logged_at DESC);
CREATE INDEX idx_habit_logs_habit   ON habit_logs (habit_id);

-- +migrate Down
DROP TABLE IF EXISTS habit_logs CASCADE;
DROP TABLE IF EXISTS habits CASCADE;
DROP TABLE IF EXISTS habit_folders CASCADE;
