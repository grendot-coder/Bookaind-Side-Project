-- ============================================================================
-- BOOKAIND (Nusantara Cultural Heritage & Discovery)
-- Supabase PostgreSQL Schema & Security Policies
-- ============================================================================

-- 1. PROVINCES
CREATE TABLE IF NOT EXISTS provinces (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  local_name TEXT NOT NULL,
  capital TEXT NOT NULL,
  tagline TEXT,
  hero_image_url TEXT,
  latitude DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  longitude DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CULTURAL CATEGORIES
CREATE TABLE IF NOT EXISTS cultural_categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  icon_name TEXT,
  accent_color_key TEXT DEFAULT 'coral', -- 'coral', 'saffron', 'teal', 'blue'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. DESTINATIONS
CREATE TABLE IF NOT EXISTS destinations (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  province_id TEXT REFERENCES provinces(id) ON DELETE SET NULL,
  city_or_regency TEXT NOT NULL,
  tagline TEXT,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL,
  rating DOUBLE PRECISION DEFAULT 4.5,
  entry_fee_range TEXT,
  is_featured BOOLEAN DEFAULT FALSE,
  latitude DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  longitude DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  type TEXT DEFAULT 'structure', -- 'structure', 'nature', 'marine', 'village'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. CULTURAL ENTRIES (Living crafts, culinary, arts, ceremonies)
CREATE TABLE IF NOT EXISTS cultural_entries (
  id TEXT PRIMARY KEY,
  category_id TEXT REFERENCES cultural_categories(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  local_name TEXT,
  summary TEXT,
  description TEXT NOT NULL,
  province_ids TEXT[] DEFAULT '{}',
  image_url TEXT NOT NULL,
  is_unesco_recognized BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Public has READ-ONLY access. Writes are reserved for admins (Service Role).
-- ============================================================================

ALTER TABLE provinces ENABLE ROW LEVEL SECURITY;
ALTER TABLE cultural_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE destinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE cultural_entries ENABLE ROW LEVEL SECURITY;

-- Allow public anonymous read access
CREATE POLICY "Allow public read access for provinces" ON provinces FOR SELECT USING (true);
CREATE POLICY "Allow public read access for cultural_categories" ON cultural_categories FOR SELECT USING (true);
CREATE POLICY "Allow public read access for destinations" ON destinations FOR SELECT USING (true);
CREATE POLICY "Allow public read access for cultural_entries" ON cultural_entries FOR SELECT USING (true);
