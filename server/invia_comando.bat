@echo off
title Console Comandi ESP32-C3
chcp 65001 >nul
:menu
cls
echo ==========================================================
echo         PANNELLO DI CONTROLLO MQTT ESP32-C3               
echo ==========================================================
echo  1. Accendi LED           (invia 'ON')
echo  2. Spegni LED            (invia 'OFF')
echo  3. Commuta Stato (Toggle) (invia 'TOGGLE')
echo  4. Lampeggia 3 volte     (invia 'BLINK:3:150')
echo  5. Test Ping di Latenza  (invia timestamp su riky_esp32/ping)
echo  6. Richiedi Stato        (invia 'STATUS')
echo  7. Riavvia ESP32         (invia 'REBOOT')
echo  8. Invia messaggio testuale personalizzato
echo  9. Esci
echo ==========================================================
set /p choice="Scegli un'opzione (1-9): "

if "%choice%"=="1" (
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "ON"
    echo [Comando 'ON' inviato!]
    timeout /t 1 >nul
    goto menu
)
if "%choice%"=="2" (
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "OFF"
    echo [Comando 'OFF' inviato!]
    timeout /t 1 >nul
    goto menu
)
if "%choice%"=="3" (
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "TOGGLE"
    echo [Comando 'TOGGLE' inviato!]
    timeout /t 1 >nul
    goto menu
)
if "%choice%"=="4" (
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "BLINK:3:150"
    echo [Comando 'BLINK' inviato!]
    timeout /t 1 >nul
    goto menu
)
if "%choice%"=="5" (
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/ping" -m "ping_cli_test"
    echo [Ping inviato su riky_esp32/ping! Controlla 'ascolta_messaggi.bat' o la Dashboard per la risposta PONG]
    pause
    goto menu
)
if "%choice%"=="6" (
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "STATUS"
    echo [Richiesta di stato inviata!]
    timeout /t 1 >nul
    goto menu
)
if "%choice%"=="7" (
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "REBOOT"
    echo [Comando di riavvio inviato all'ESP32!]
    pause
    goto menu
)
if "%choice%"=="8" (
    echo.
    set /p custom_msg="Inserisci il payload da inviare: "
    "%~dp0bin\nanomq_cli.exe" pub -t "riky_esp32/commands" -m "%custom_msg%"
    echo [Messaggio inviato!]
    timeout /t 2 >nul
    goto menu
)
if "%choice%"=="9" (
    exit /b
)
goto menu
