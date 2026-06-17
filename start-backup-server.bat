@echo off
:: ============================================================
:: TOLED Backup Server — arranque automático
:: Colocar en Inicio de Windows o ejecutar manualmente
::
:: Para agregar al inicio de Windows:
::   1. Win+R → shell:startup
::   2. Copiar un acceso directo de este .bat en esa carpeta
:: ============================================================

cd /d "%~dp0"

:: Carpeta de respaldos (modificar si se desea otra ruta)
:: Por defecto usa %USERPROFILE%\TOLED_Backups
:: set TOLED_BACKUP_DIR=C:\Respaldos\TOLED

echo [TOLED] Iniciando servidor de backup...
node backup-server.js
pause
