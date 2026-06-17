// ============================================================
// TOLED Backup Server — servidor local para respaldos en disco
// Puerto: 7432   Carpeta: ~/TOLED_Backups  (o TOLED_BACKUP_DIR)
//
// Uso:
//   node backup-server.js
//
// Endpoints:
//   POST /backup          — guarda snapshot JSON en disco
//   GET  /list            — lista respaldos disponibles
//   GET  /restore?fecha=YYYYMMDD — devuelve un respaldo específico
//   GET  /health          — status del servidor
// ============================================================

const http = require('http');
const fs   = require('fs');
const path = require('path');
const os   = require('os');

const PORT       = process.env.TOLED_BACKUP_PORT || 7432;
const BACKUP_DIR = process.env.TOLED_BACKUP_DIR  || path.join(os.homedir(), 'TOLED_Backups');

// Crear carpeta si no existe
if (!fs.existsSync(BACKUP_DIR)) {
  fs.mkdirSync(BACKUP_DIR, { recursive: true });
  console.log('[TOLED] Carpeta creada:', BACKUP_DIR);
}

console.log('[TOLED] Backup server iniciado');
console.log('[TOLED] Puerto:', PORT);
console.log('[TOLED] Carpeta:', BACKUP_DIR);

// ── helpers ──────────────────────────────────────────────────

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin':  'null',   // file:// origin
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json; charset=utf-8'
  };
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end',  () => resolve(body));
    req.on('error', reject);
  });
}

function fname(fecha) {
  return path.join(BACKUP_DIR, `toled_backup_${fecha.replace(/-/g, '')}.json`);
}

// ── rutas ─────────────────────────────────────────────────────

const routes = {

  // POST /backup  { fecha: 'YYYY-MM-DD', data: { ... } }
  'POST /backup': async (req, res) => {
    try {
      const raw = await readBody(req);
      const body = JSON.parse(raw);
      if (!body.fecha || !body.data) throw new Error('Faltan campos fecha o data');
      const file = fname(body.fecha);
      fs.writeFileSync(file, JSON.stringify(body.data, null, 2), 'utf8');
      console.log('[TOLED] Backup guardado:', path.basename(file));
      res.end(JSON.stringify({ ok: true, file: path.basename(file) }));
    } catch(e) {
      res.writeHead(400);
      res.end(JSON.stringify({ ok: false, error: e.message }));
    }
  },

  // GET /list  → [ { fecha, archivo, size_kb }, ... ]
  'GET /list': async (req, res) => {
    try {
      const files = fs.readdirSync(BACKUP_DIR)
        .filter(f => f.startsWith('toled_backup_') && f.endsWith('.json'))
        .sort().reverse()
        .map(f => {
          const stat = fs.statSync(path.join(BACKUP_DIR, f));
          const raw  = f.replace('toled_backup_', '').replace('.json', '');
          const fecha = raw.length === 8
            ? `${raw.slice(0,4)}-${raw.slice(4,6)}-${raw.slice(6,8)}`
            : raw;
          return { fecha, archivo: f, size_kb: Math.round(stat.size / 1024) };
        });
      res.end(JSON.stringify({ ok: true, backups: files }));
    } catch(e) {
      res.writeHead(500);
      res.end(JSON.stringify({ ok: false, error: e.message }));
    }
  },

  // GET /restore?fecha=YYYYMMDD  → devuelve el JSON del backup
  'GET /restore': async (req, res) => {
    try {
      const url    = new URL(req.url, `http://localhost:${PORT}`);
      const fecha  = url.searchParams.get('fecha') || '';
      // Aceptar YYYY-MM-DD o YYYYMMDD
      const clean  = fecha.replace(/-/g, '');
      if (!/^\d{8}$/.test(clean)) throw new Error('Formato de fecha inválido');
      const file   = fname(clean.slice(0,4) + '-' + clean.slice(4,6) + '-' + clean.slice(6,8));
      if (!fs.existsSync(file)) throw new Error('Backup no encontrado para ' + fecha);
      const data   = fs.readFileSync(file, 'utf8');
      res.end(JSON.stringify({ ok: true, data: JSON.parse(data) }));
    } catch(e) {
      res.writeHead(404);
      res.end(JSON.stringify({ ok: false, error: e.message }));
    }
  },

  // GET /health
  'GET /health': async (req, res) => {
    res.end(JSON.stringify({
      ok: true, port: PORT, backup_dir: BACKUP_DIR,
      backups: fs.readdirSync(BACKUP_DIR).filter(f => f.endsWith('.json')).length
    }));
  }
};

// ── servidor HTTP ─────────────────────────────────────────────

const server = http.createServer(async (req, res) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(200, corsHeaders());
    res.end();
    return;
  }

  res.writeHead(200, corsHeaders());

  const urlPath = req.url.split('?')[0];
  const key = `${req.method} ${urlPath}`;
  const handler = routes[key];

  if (handler) {
    await handler(req, res);
  } else {
    res.writeHead(404);
    res.end(JSON.stringify({ ok: false, error: 'Ruta no encontrada: ' + key }));
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`[TOLED] Listo en http://127.0.0.1:${PORT}`);
});

server.on('error', err => {
  if (err.code === 'EADDRINUSE') {
    console.error(`[TOLED] Puerto ${PORT} ocupado — ¿ya está corriendo el servidor?`);
  } else {
    console.error('[TOLED] Error:', err.message);
  }
  process.exit(1);
});
