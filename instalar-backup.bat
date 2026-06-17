@echo off
setlocal enabledelayedexpansion
title TOLED — Instalador de Backup Local
color 0A

echo.
echo  ============================================
echo   TOLED Dashboard — Instalador de Backup
echo  ============================================
echo.

:: ── 1. Verificar Node.js ─────────────────────────────────────
echo  [1/4] Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  Node.js no encontrado. Instalando via winget...
    winget install OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements
    if %errorlevel% neq 0 (
        echo.
        echo  ERROR: No se pudo instalar Node.js automaticamente.
        echo  Instala manualmente desde https://nodejs.org y vuelve a ejecutar este archivo.
        pause
        exit /b 1
    )
    :: Refrescar PATH para que node quede disponible
    call refreshenv >nul 2>&1
    node --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo.
        echo  Node.js instalado. REINICIA el PC y vuelve a ejecutar este archivo.
        pause
        exit /b 0
    )
)
for /f "tokens=*" %%v in ('node --version') do set NODE_VER=%%v
echo  OK — Node.js !NODE_VER! encontrado

:: ── 2. Crear carpeta de respaldos ────────────────────────────
echo.
echo  [2/4] Creando carpeta de respaldos...
set BACKUP_DIR=%USERPROFILE%\TOLED_Backups
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
    echo  Carpeta creada: %BACKUP_DIR%
) else (
    echo  OK — Carpeta ya existe: %BACKUP_DIR%
)

:: ── 3. Agregar al inicio de Windows ──────────────────────────
echo.
echo  [3/4] Configurando inicio automatico con Windows...
set STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set BAT_ORIGEN=%~dp0start-backup-server.bat
set BAT_DESTINO=%STARTUP%\toled-backup-server.bat

:: Crear acceso directo en startup (copiamos el bat de arranque)
if exist "%BAT_ORIGEN%" (
    copy /y "%BAT_ORIGEN%" "%BAT_DESTINO%" >nul
    echo  OK — Servidor configurado para iniciar con Windows
) else (
    echo  AVISO — No se encontro start-backup-server.bat en %~dp0
    echo         El servidor NO se iniciara automaticamente con Windows.
)

:: ── 4. Iniciar servidor ahora ─────────────────────────────────
echo.
echo  [4/4] Iniciando servidor de backup...
echo.
echo  ============================================
echo   Instalacion completada exitosamente
echo   Carpeta: %BACKUP_DIR%
echo   Puerto:  7432
echo   El servidor arrancara solo al iniciar Windows
echo  ============================================
echo.

cd /d "%~dp0"
start "TOLED Backup Server" /min node backup-server.js

echo  Servidor iniciado en segundo plano.
echo  Puedes cerrar esta ventana.
echo.
timeout /t 4 >nul
