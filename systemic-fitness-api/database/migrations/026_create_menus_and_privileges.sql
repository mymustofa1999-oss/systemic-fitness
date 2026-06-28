-- +migrate Up

-- ════════════════════════════════════════════════════════════════════
--  Menus: Dynamic menu configuration stored in database
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE menus (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id   UUID REFERENCES menus(id) ON DELETE CASCADE,
    code        VARCHAR(50)  NOT NULL UNIQUE,
    label       VARCHAR(100) NOT NULL,
    icon        VARCHAR(50),
    href        VARCHAR(255),
    sort_order  INT          NOT NULL DEFAULT 0,
    is_active   BOOLEAN      NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_menus_parent_id  ON menus(parent_id);
CREATE INDEX idx_menus_sort_order ON menus(sort_order);
CREATE INDEX idx_menus_is_active  ON menus(is_active);

CREATE TRIGGER trg_menus_updated_at
    BEFORE UPDATE ON menus
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ════════════════════════════════════════════════════════════════════
--  Menu Role Privileges: which roles can access which menus
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE menu_role_privileges (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_id    UUID      NOT NULL REFERENCES menus(id) ON DELETE CASCADE,
    role       user_role NOT NULL,
    can_access BOOLEAN   NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(menu_id, role)
);

CREATE INDEX idx_menu_role_priv_menu_id ON menu_role_privileges(menu_id);
CREATE INDEX idx_menu_role_priv_role    ON menu_role_privileges(role);


-- +migrate Down

DROP TABLE IF EXISTS menu_role_privileges;
DROP TABLE IF EXISTS menus;
