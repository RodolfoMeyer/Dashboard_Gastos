# TOLED · Operaciones · La Negra

Sistema web de control operativo y financiero orientado a la gestión de viáticos, combustible, parking, bodegas y gastos asociados a eventos y montajes técnicos.

El proyecto funciona completamente en frontend mediante un único archivo HTML con persistencia local y exportación/importación de respaldos JSON.

Basado en la interfaz incluida en `index_v2.html` 
y estructura de datos observada en `respaldo_toled_20260511_0138.json` 

---

# Características

* Dashboard financiero interactivo
* Gestión mensual de operaciones
* Registro diario de eventos y funciones
* Control de:

  * Viáticos
  * Desayunos
  * Trasnoches
  * Combustible
  * Parking
  * Bodega
* KPIs automáticos
* Tabla estilo Excel editable
* Exportación e importación JSON
* Exportación XLSX
* Gráficos dinámicos con Chart.js
* Persistencia local
* UI responsive
* Modal de edición y confirmación
* Navegación lateral administrativa

---

# Tecnologías

* HTML5
* CSS3
* JavaScript Vanilla
* Chart.js
* SheetJS (xlsx)

CDN utilizados:

```html
https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.0/chart.umd.min.js
https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js
```

---

# Estructura del Proyecto

```bash
/
├── index_v2.html
├── respaldo_toled_20260511_0138.json
└── README.md
```

---

# Modelo de Datos

Ejemplo de estructura JSON:

```json
{
  "version": "toled_v2",
  "fecha": "2026-05-11T05:38:57.159Z",
  "mesesOrden": [
    "OCTUBRE",
    "NOVIEMBRE"
  ],
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
  }
}
```

Fuente: `respaldo_toled_20260511_0138.json` 

---

# Instalación

No requiere instalación.

1. Descargar el repositorio
2. Abrir `index_v2.html` en navegador moderno

Opcionalmente puede ejecutarse mediante servidor local:

```bash
python -m http.server 8080
```

Luego abrir:

```bash
http://localhost:8080
```

---

# Uso

## Registro Operacional

Cada fila representa una jornada operacional:

* Fecha
* Evento
* Función
* Desayuno
* Viático
* Trasnoche
* Parking
* Combustible
* Bodega

Los totales son calculados automáticamente.

---

## Gestión Mensual

El sistema permite:

* Cambiar entre meses
* Visualizar KPIs
* Revisar saldos
* Consultar históricos
* Analizar gastos

---

## Exportación

Puede exportarse:

* Respaldo JSON
* Excel XLSX

Ideal para:

* auditorías
* respaldos
* contabilidad
* análisis externos

---

# Interfaz

El sistema incluye:

* Sidebar administrativa
* Dashboard KPI
* Gráficos financieros
* Tabla tipo spreadsheet
* Barra de fórmulas
* Tabs mensuales
* Modales de edición
* Toast notifications

---

# Compatibilidad

Probado para:

* Google Chrome
* Microsoft Edge
* Brave
* Firefox

---

# Seguridad y Persistencia

[Inferencia] El sistema utiliza almacenamiento local y archivos JSON para persistencia de datos, ya que no se observa integración backend directa en el archivo HTML revisado. 

---

# Roadmap Sugerido

Mejoras posibles:

* Backend Node.js / Firebase
* Login multiusuario
* Control de permisos
* Base de datos SQL
* Reportes PDF
* Integración contable
* Sincronización cloud
* Modo offline PWA

---

# Captura General

[No verificado] No puedo generar una captura real de la interfaz desde el archivo proporcionado sin renderizar el HTML en navegador.

---

# Autor

Rodolfo Meyer

---

# Licencia

Uso privado / interno.
Modificar según necesidades del proyecto.
