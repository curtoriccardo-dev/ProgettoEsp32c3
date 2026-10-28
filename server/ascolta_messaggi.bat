@echo off
title Monitor MQTT - Ricezione messaggi ESP32
chcp 65001 >nul
cls
echo ==========================================================
echo             MONITOR MESSAGGI MQTT (ESP32)                 
echo ==========================================================
echo In ascolto su tutti i topic 'riky_esp32/#' (127.0.0.1:1883)...
echo.
echo Qui vedrai i dati di telemetria e lo stato inviati dall'ESP32.
echo Premi CTRL+C per fermare il monitor.
echo ==========================================================
echo.
"%~dp0bin\nanomq_cli.exe" sub -t "riky_esp32/#" -v
pause
