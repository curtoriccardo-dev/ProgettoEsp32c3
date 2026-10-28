@echo off
title Caricamento Firmware su ESP32-C3
chcp 65001 >nul
cls

echo ==========================================================
echo       CARICAMENTO FIRMWARE ESP32-C3 (ZERO IDE)            
echo ==========================================================
echo.

set "CLI_PATH=C:\Program Files\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"
if not exist "%CLI_PATH%" (
    where arduino-cli >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "CLI_PATH=arduino-cli"
    ) else (
        echo [!] ERRORE: arduino-cli non trovato.
        echo     Assicurati che Arduino IDE 2.x sia installato in Program Files.
        pause
        exit /b 1
    )
)

echo [1/3] Rilevamento porta seriale ESP32-C3...
set "COMPORT=COM5"
for /f "tokens=1" %%i in ('"%CLI_PATH%" board list ^| findstr /i "esp32"') do (
    set "COMPORT=%%i"
)
echo      Porta rilevata: %COMPORT%
echo.

echo [2/3] Compilazione firmware ottimizzato per ESP32-C3...
"%CLI_PATH%" compile --fqbn esp32:esp32:esp32c3 "%~dp0esp32_mqtt"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Errore durante la compilazione!
    pause
    exit /b %ERRORLEVEL%
)
echo      Compilazione completata con successo!
echo.

echo [3/3] Caricamento su ESP32-C3 (%COMPORT%)...
"%CLI_PATH%" upload -p %COMPORT% --fqbn esp32:esp32:esp32c3 "%~dp0esp32_mqtt"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================================
    echo   SUCCESSO! Firmware caricato e avviato sull'ESP32-C3!    
    echo ==========================================================
    echo.
    echo Ora l'ESP32 si connettera' in automatico al Wi-Fi e a NanoMQ.
) else (
    echo.
    echo [!] Errore durante l'upload su %COMPORT%.
    echo     Suggerimento: se la porta e' occupata, chiudi il monitor seriale
    echo     o scollega e ricollega il cavo USB dell'ESP32.
)

echo.
pause
