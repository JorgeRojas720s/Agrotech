@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    EJECUTOR MAESTRO - MÁXIMA VELOCIDAD
echo ========================================

REM Configuración
set CONTAINER_NAME=oracle19c
set DB_USER=sys
set DB_PASS=Oracle123

echo.
echo 🔍 Verificando contenedor...
docker ps | findstr "%CONTAINER_NAME%" >nul


echo ✅ Contenedor listo
echo.

echo 🚀 EJECUTANDO SCRIPT MAESTRO...
echo ⏰ Esto tomará aproximadamente 2-3 minutos...
echo.

REM Ejecutar script maestro
docker exec -i %CONTAINER_NAME% sqlplus -S %DB_USER%/%DB_PASS% as sysdba @/app/master_script.sql

if !errorlevel! equ 0 (
    echo.
    echo 🎉 BASE DE DATOS CONSTRUIDA EXITOSAMENTE
) else (
    echo.
    echo ❌ Error en la ejecución
)

pause