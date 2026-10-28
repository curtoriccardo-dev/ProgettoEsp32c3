@echo off
title Invio Aggiornamenti su GitHub
chcp 65001 >nul
cls

echo ==========================================================
echo          INVIO CODICE SU GITHUB (ProgettoEsp32c3)         
echo ==========================================================
echo.
cd /d "C:\Users\curto.riccardo\esp32-mqtt-broker"

echo 1. Verifica stato repository...
git remote -v
echo.

echo 2. Aggiunta file modificati e nuove funzionalita'...
git add -A

echo 3. Creazione commit...
git commit -m "Upgrade v2.1: Web Dashboard, Zero-Latency Ping Engine, LWT and 1-Click Flasher"

echo 4. Invio delle modifiche su GitHub (git push)...
git push origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================================
    echo  SUCCESSO! Il tuo codice e' aggiornato su GitHub!         
    echo  Link: https://github.com/curtoriccardo-dev/ProgettoEsp32c3
    echo ==========================================================
) else (
    echo.
    echo [!] Errore durante l'invio su GitHub.
    echo     Se viene richiesta l'autenticazione, effettua l'accesso.
)

echo.
pause
