@echo off
title Avvio Completo Sistema MQTT e Dashboard
chcp 65001 >nul
cls

set "BASE_DIR=%~dp0"
if not exist "%BASE_DIR%server\bin\nanomq.exe" (
    set "BASE_DIR=C:\Users\curto.riccardo\esp32-mqtt-broker\"
)

echo ==========================================================
echo        AVVIO COMPLETO SISTEMA MQTT E WEB DASHBOARD        
echo ==========================================================
echo.
echo [i] Indirizzi IP locali rilevati per questo PC:
powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.IPAddress -notlike '169.254*' } | ForEach-Object { Write-Host ('   -> ' + $_.InterfaceAlias + ': ' + $_.IPAddress) -ForegroundColor Green }"
echo.
echo 1. Avvio del broker MQTT locale (NanoMQ)...
start "NanoMQ MQTT Broker" /d "%BASE_DIR%server\bin" "%BASE_DIR%server\bin\nanomq.exe" start --conf "%BASE_DIR%server\config\nanomq.conf"

echo 2. Apertura della Web Dashboard di controllo nel browser...
start "" "%BASE_DIR%server\dashboard\index.html"

echo.
echo ==========================================================
echo   SISTEMA AVVIATO CON SUCCESSO!                           
echo   - Broker MQTT attivo su porta 1883                      
echo   - WebSocket MQTT attivo su porta 8083 (/mqtt)           
echo   - Dashboard aperta nel browser                          
echo ==========================================================
echo.
echo Premi un tasto per chiudere questa finestra (il server rimarra' attivo).
pause >nul
