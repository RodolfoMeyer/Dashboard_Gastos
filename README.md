# TOLED · Sistema de Operaciones · La Negra

Sistema web de control operativo y financiero para la gestión de viáticos, combustible, parking, bodega y gastos asociados a eventos y montajes técnicos.

**Producción:** [toled-gastos.vercel.app](https://toled-gastos.vercel.app)

---

## Características v3.0

### Core
- Dashboard financiero interactivo con KPIs, gráficos y últimas transferencias
- Planilla mensual estilo Excel (editable, fila por fila)
- Control de viáticos, desayunos, trasnoches, combustible, parking y bodega
- Gestión de saldos: transferencias y ajuste manual
- Vista consolidada por año (Períodos & Años)

### Modo Edición Excel
- Selección de rangos con Shift+Clic y Shift+↑↓←→
- Selección de fila completa haciendo clic en el número de fila
- Seleccionar todo con Ctrl+A
- Copiar rangos con Ctrl+C (formato TSV — compatible con Excel y Google Sheets)
- Pegar desde portapapeles con Ctrl+V (desde Excel, otra pestaña o entre meses)
- Escape limpia la selección

### Nube y Sincronización
- Autenticación con Supabase Auth (email + contraseña)
- Datos almacenados en PostgreSQL vía Supabase (tabla `gastos`, `transferencias`, `data_meses`)
- Guardado automático 3 s después del último cambio
- Dashboard se actualiza automáticamente al editar una celda (sin botón de sincronizar)

### Sistema de Respaldo — 3 Capas
| Capa | Dónde | Cuándo |
|------|-------|--------|
| Nube (Supabase) | PostgreSQL remoto | 3 s tras cada cambio |
| Snapshots automáticos | localStorage del navegador | Login, cierre de página, cada 20 s |
| JSON diario | Descarga automática | Una vez por día al iniciar sesión |

- Hasta 5 snapshots locales accesibles desde el botón **Respaldos**
- Restaurar desde archivo JSON con el botón **Cargar**

### Exportación
- Excel XLSX con grupos, totales horizontales y saldo al pie
- Importación desde CSV / Excel
- Respaldo manual JSON (todos los meses)

---

## Stack Técnico

| Capa | Tecnología |
|------|-----------|
| Frontend | HTML5 + CSS3 + JavaScript Vanilla |
| Backend / Auth | Supabase (PostgreSQL + Auth + RLS) |
| Hosting | Vercel (deploy automático desde GitHub) |
| Gráficos | Chart.js 4.4 |
| Excel | SheetJS (xlsx 0.18) |

---

## Estructura del Proyecto

```
DashBoard Poto/
├── index/
│   └── index_cloud.html   # Archivo principal — todo el sistema (~800 KB)
└── README.md
```

El sistema es un único archivo HTML autocontenido. No tiene dependencias locales ni proceso de build.

---

## Modelo de Datos (JSON de respaldo)

```json
{
  "version": "toled_v3",
  "fecha": "2026-06-16T12:00:00.000Z",
  "mesesOrden": ["OCTUBRE", "NOVIEMBRE"],
  "xlData": {
    "OCTUBRE": [
      {
        "fecha": "01/10/2025",
        "evento": "EVENTO JUAN QUIROZ",
        "funcion": "MONTAJE, EVENTO",
        "desayuno": 0,
        "viatico": 10000,
        "trasnoche": 0,
        "parking": 0,
        "combustible": 20000,
        "bodega": 0,
        "totalViatico": 10000,
        "total": 30000
      }
    ]
  },
  "DATA_MESES": { "OCTUBRE": { "transferido": 0, "ajuste": 0 } },
  "transferencias": { "OCTUBRE": [] }
}
```

---

## Despliegue

El sitio se despliega automáticamente en Vercel al hacer push a `main`.

Para desarrollo local:

```bash
# Clonar
git clone https://github.com/RodolfoMeyer/Dashboard_Gastos.git

# Abrir con servidor local (necesario para CORS de Supabase)
cd Dashboard_Gastos
python -m http.server 8080
# → http://localhost:8080/index/index_cloud.html
```

Para que el login funcione en local, agregar `http://localhost:8080` a los **Redirect URLs** en Supabase Auth → URL Configuration.

---

## Variables de Entorno / Configuración

Las credenciales de Supabase están embebidas en `index_cloud.html` (hardcoded, proyecto privado). Para cambiarlas buscar:

```javascript
const SUPABASE_URL = 'https://...supabase.co';
const SUPABASE_KEY = 'eyJ...';
```

---

## Navegación con Teclado

| Tecla | Acción |
|-------|--------|
| Tab / Shift+Tab | Avanzar / retroceder entre celdas |
| Enter | Bajar una fila en la misma columna |
| ↑ ↓ → ← | Mover celda activa |
| Shift+↑↓←→ | Extender selección |
| Ctrl+A | Seleccionar todo el mes |
| Ctrl+C | Copiar selección |
| Ctrl+V | Pegar desde portapapeles |
| Escape | Limpiar selección |

---

## Autor

Rodolfo Meyer

---

## Licencia

Uso privado / interno.
