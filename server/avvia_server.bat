@echo off
title MQTT Server Locale (NanoMQ)
chcp 65001 >nul
cls
echo ==========================================================
echo           MQTT BROKER LOCALE PER ESP32 (NanoMQ)           
echo ==========================================================
echo.
echo [i] Indirizzi IP locali rilevati per questo PC:
powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.IPAddress -notlike '169.254*' } | ForEach-Object { Write-Host ('   -> ' + $_.InterfaceAlias + ': ' + $_.IPAddress) -ForegroundColor Green }"
echo.
echo [!] IMPORTANTE:
echo     1. L'ESP32 e questo PC devono essere sulla STESSA rete Wi-Fi / Hotspot.
echo     2. Nel codice ESP32 imposta 'mqtt_server' con l'IP corrispondente.
echo     3. Porta MQTT: 1883
echo ==========================================================
echo.
echo Avvio del broker in ascolto su 0.0.0.0:1883...
echo Per terminare il server chiudi questa finestra o premi CTRL+C.
echo.
"%~dp0bin\nanomq.exe" start --conf "%~dp0config\nanomq.conf"
pause
