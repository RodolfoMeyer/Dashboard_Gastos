-- =========================================================
-- TOLED Dashboard — Tabla de snapshots diarios
-- Ejecutar en Supabase SQL Editor (una sola vez)
-- =========================================================

CREATE TABLE IF NOT EXISTS backups (
  id           BIGSERIAL PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fecha        DATE NOT NULL,
  timestamp    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  data         JSONB NOT NULL,
  mes_count    INT,
  row_count    INT
);

-- 1 backup por usuario por día (upsert sobrescribe el del mismo día)
CREATE UNIQUE INDEX IF NOT EXISTS backups_user_fecha ON backups (user_id, fecha);

-- Row Level Security: cada usuario solo ve sus propios backups
ALTER TABLE backups ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "backups_own" ON backups;
CREATE POLICY "backups_own" ON backups
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
