@echo off
title Sblocca Firewall Windows per IoT MQTT Panel
chcp 65001 >nul
cls

echo ==========================================================
echo    SBLOCCO FIREWALL PER IOT MQTT PANEL (PORTA 1883)       
echo ==========================================================
echo.
echo Richiesta permessi di amministratore...
echo (Clicca 'SI' nella finestra di conferma di Windows)
echo.

powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -Command \"New-NetFirewallRule -DisplayName ''NanoMQ Broker Port 1883'' -Direction Inbound -LocalPort 1883 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue; Get-NetFirewallRule -DisplayName ''nanomq.exe'' -ErrorAction SilentlyContinue | Set-NetFirewallRule -Action Allow; Write-Host ''===================================================='' -ForegroundColor Green; Write-Host ''  PORTA 1883 SBLOCCATA CON SUCCESSO NEL FIREWALL!  '' -ForegroundColor Green; Write-Host ''  Ora l''''app IoT MQTT Panel puo'''' connettersi!        '' -ForegroundColor Green; Write-Host ''===================================================='' -ForegroundColor Green; Start-Sleep -Seconds 3\"'"

exit /b
