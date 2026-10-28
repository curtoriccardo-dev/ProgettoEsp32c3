@echo off
title Invia comandi MQTT a ESP32
chcp 65001 >nul
:menu
cls
echo ==========================================================
echo             INVIA COMANDO A ESP32 (MQTT)                  
echo ==========================================================
echo  1. Accendi LED   (invia 'ON' su riky_esp32/commands)
echo  2. Spegni LED    (invia 'OFF' su riky_esp32/commands)
echo  3. Invia messaggio testuale personalizzato
echo  4. Esci
echo ==========================================================
set /p choice="Scegli un'opzione (1-4): "

if "%choice%"=="1" (
    echo.
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "ON"
    echo [Comando 'ON' inviato con successo!]
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="2" (
    echo.
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "OFF"
    echo [Comando 'OFF' inviato con successo!]
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="3" (
    echo.
    set /p custom_msg="Inserisci il testo da inviare: "
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "%custom_msg%"
    echo [Messaggio inviato!]
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="4" (
    exit /b
)
goto menu
