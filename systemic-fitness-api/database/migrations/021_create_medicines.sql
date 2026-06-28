-- 021: Medicines (Daftar Obat)
-- Master data for medicine/drug reference library.

CREATE TABLE IF NOT EXISTS medicines (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(200)  NOT NULL,
    category    VARCHAR(200),
    main_function TEXT,
    side_effects  TEXT,
    detail_url    VARCHAR(500),
    image_url     VARCHAR(500),
    is_system   BOOLEAN       NOT NULL DEFAULT FALSE,
    created_by  UUID          REFERENCES users(id),
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE TRIGGER set_medicines_updated_at
    BEFORE UPDATE ON medicines
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- Trigram index for name search
CREATE INDEX IF NOT EXISTS idx_medicines_name_trgm ON medicines USING gin (name gin_trgm_ops);
-- Index on category for filtering
CREATE INDEX IF NOT EXISTS idx_medicines_category ON medicines (category);
