@echo off
title Server MQTT per IoT MQTT Panel (ESP32-C3)
chcp 65001 >nul
cls

set "BASE_DIR=%~dp0"
if not exist "%BASE_DIR%server\bin\nanomq.exe" (
    set "BASE_DIR=C:\Users\curto.riccardo\esp32-mqtt-broker\"
)

:: Termina eventuali istanze residue di nanomq
taskkill /f /im nanomq.exe >nul 2>&1

:: Avvia il broker NanoMQ in background
start "NanoMQ_Service" /min "%BASE_DIR%server\bin\nanomq.exe" start --conf "%BASE_DIR%server\config\nanomq.conf"
timeout /t 1 >nul

cls
echo ==========================================================
echo    SERVER MQTT ATTIVO PER APP IOT MQTT PANEL (ESP32-C3)   
echo ==========================================================
echo.
echo [i] DATI DI CONNESSIONE DA INSERIRE NELL'APP SUL TELEFONO:
powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.IPAddress -notlike '169.254*' } | ForEach-Object { Write-Host ('    * IP Broker (' + $_.InterfaceAlias + '): ' + $_.IPAddress) -ForegroundColor Green }"
echo     * Porta MQTT: 1883
echo     * Protocollo: TCP
echo.
echo [i] WIDGET DA CONFIGURARE SULL'APP IOT MQTT PANEL:
echo     1. Interruttore LED (Switch):
echo        - Topic di invio:   riky_esp32/commands  (Payload: ON / OFF)
echo        - Topic di stato:   riky_esp32/led
echo     2. Segnale Wi-Fi (Text):
echo        - Topic:            riky_esp32/rssi
echo     3. Tempo Uptime (Text):
echo        - Topic:            riky_esp32/uptime
echo.
echo ==========================================================
echo  [MONITOR IN DIRETTA] In ascolto su riky_esp32/# ...
echo  (I comandi inviati dallo smartphone e i dati della scheda
echo   appariranno qui sotto in tempo reale)
echo ==========================================================
echo.

"%BASE_DIR%server\bin\nanomq_cli.exe" sub -t "riky_esp32/#" -v
pause
