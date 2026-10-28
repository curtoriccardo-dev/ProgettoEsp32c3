@echo off
title Avvio Completo Sistema MQTT & Dashboard
chcp 65001 >nul
cls

echo ==========================================================
echo        AVVIO COMPLETO SISTEMA MQTT & WEB DASHBOARD        
echo ==========================================================
echo.
echo [i] Indirizzi IP locali rilevati per questo PC:
powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.IPAddress -notlike '169.254*' } | ForEach-Object { Write-Host ('   -> ' + $_.InterfaceAlias + ': ' + $_.IPAddress) -ForegroundColor Green }"
echo.
echo 1. Avvio del broker MQTT locale (NanoMQ)...
start "NanoMQ MQTT Broker" "%~dp0server\bin\nanomq.exe" start --conf "%~dp0server\config\nanomq.conf"

echo 2. Apertura della Web Dashboard di controllo nel browser...
start "" "%~dp0server\dashboard\index.html"

echo.
echo ==========================================================
echo   SISTEMA AVVIATO CON SUCCESSO!                           
echo   - Broker MQTT attivo su porta 1883                      
echo   - WebSocket MQTT attivo su porta 8083 (/mqtt)           
echo   - Dashboard aperta nel browser                          
echo ==========================================================
echo.
echo Premi un tasto per chiudere questo menu (il server rimarra' attivo).
pause >nul
