-- ═══════════════════════════════════════════════════════════════════
--  TOLED Dashboard · Supabase Schema
--  Ejecutar en: Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════════

-- ── 1. TABLA: meses ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS meses (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  clave        TEXT NOT NULL,          -- 'OCTUBRE', 'MAYO_2026', etc.
  label        TEXT,
  anio         INTEGER,
  orden        INTEGER DEFAULT 0,      -- posición en MESES_ORDEN
  total_viatico INTEGER DEFAULT 0,
  desayuno     INTEGER DEFAULT 0,
  viatico      INTEGER DEFAULT 0,
  trasnoche    INTEGER DEFAULT 0,
  parking      INTEGER DEFAULT 0,
  combustible  INTEGER DEFAULT 0,
  bodega       INTEGER DEFAULT 0,
  otros        INTEGER DEFAULT 0,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, clave)
);

-- ── 2. TABLA: gastos (filas de planilla) ─────────────────────────
CREATE TABLE IF NOT EXISTS gastos (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  mes_clave    TEXT NOT NULL,          -- clave del mes al que pertenece
  fecha        TEXT DEFAULT '',        -- formato DD/MM/YYYY
  fecha_iso    DATE,                   -- para ordenar correctamente
  evento       TEXT DEFAULT '',
  funcion      TEXT DEFAULT '',
  desayuno     INTEGER DEFAULT 0,
  viatico      INTEGER DEFAULT 0,
  trasnoche    INTEGER DEFAULT 0,
  parking      INTEGER DEFAULT 0,
  combustible  INTEGER DEFAULT 0,
  bodega       INTEGER DEFAULT 0,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- ── 3. TABLA: transferencias ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS transferencias (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  mes_clave    TEXT NOT NULL,
  fecha        TEXT DEFAULT '',        -- formato YYYY-MM-DD
  concepto     TEXT DEFAULT '',
  monto        INTEGER DEFAULT 0,
  tipo         TEXT CHECK (tipo IN ('recibida', 'rendicion')),
  created_at   TIMESTAMPTZ DEFAULT now()
);

-- ── 4. TABLA: profiles ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id           UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  nombre       TEXT DEFAULT 'Usuario',
  apodo        TEXT DEFAULT '',
  cargo        TEXT DEFAULT '',
  avatar_url   TEXT DEFAULT '',
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════
--  ROW LEVEL SECURITY — cada usuario solo ve sus datos
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE meses         ENABLE ROW LEVEL SECURITY;
ALTER TABLE gastos        ENABLE ROW LEVEL SECURITY;
ALTER TABLE transferencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles      ENABLE ROW LEVEL SECURITY;

-- meses
CREATE POLICY "meses_own" ON meses
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- gastos
CREATE POLICY "gastos_own" ON gastos
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- transferencias
CREATE POLICY "transferencias_own" ON transferencias
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- profiles
CREATE POLICY "profiles_own" ON profiles
  FOR ALL USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- ═══════════════════════════════════════════════════════════════════
--  TRIGGER — crear perfil automáticamente al registrar usuario
-- ═══════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nombre)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'nombre',
      split_part(NEW.email, '@', 1)
    )
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ═══════════════════════════════════════════════════════════════════
--  ÍNDICES — para consultas rápidas
-- ═══════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_gastos_user_mes      ON gastos(user_id, mes_clave);
CREATE INDEX IF NOT EXISTS idx_transferencias_user  ON transferencias(user_id, mes_clave);
CREATE INDEX IF NOT EXISTS idx_meses_user_orden     ON meses(user_id, orden);

-- ═══════════════════════════════════════════════════════════════════
--  VERIFICACIÓN — debe retornar las 4 tablas
-- ═══════════════════════════════════════════════════════════════════

SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('meses', 'gastos', 'transferencias', 'profiles')
ORDER BY table_name;
