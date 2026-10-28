@echo off
title Apri Web Dashboard ESP32
chcp 65001 >nul
cls

echo ==========================================================
echo          APERTURA DASHBOARD WEB MQTT (ESP32-C3)           
echo ==========================================================
echo.
echo Apertura nel browser predefinito...
start "" "%~dp0dashboard\index.html"
echo.
echo [OK] Dashboard avviata!
timeout /t 2 >nul
exit /b
