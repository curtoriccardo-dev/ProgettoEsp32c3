@echo off
title Carica Progetto su GitHub
chcp 65001 >nul
cls

echo ==========================================================
echo          CARICAMENTO AUTOMATICO SU GITHUB                 
echo ==========================================================
echo.

cd /d "%~dp0"

:: 1. Verifica configurazione Git di base
git config user.name >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [i] Configurazione iniziale Git (solo la prima volta):
    set /p git_user="Inserisci il tuo nome o username GitHub: "
    set /p git_email="Inserisci la tua email GitHub: "
    git config --global user.name "%git_user%"
    git config --global user.email "%git_email%"
    echo [OK] Nome ed email salvati.
    echo.
)

:: 2. Inizializzazione Repository
if not exist ".git" (
    echo [1/4] Inizializzazione repository Git...
    git init
    git branch -M main
) else (
    echo [1/4] Repository Git gia' presente.
)

:: 3. Aggiunta file e Commit
echo [2/4] Preparazione file da salvare...
git add .
git commit -m "Release: ESP32 Local MQTT System with Zero Latency"
echo.

:: 4. Gestione Remote URL di GitHub
echo [3/4] Collegamento con GitHub:
set /p repo_url="Incolla l'URL del tuo repository GitHub (es. https://github.com/tuo-username/tuo-repo.git): "

if "%repo_url%"=="" (
    echo [!] Nessun URL inserito. Commit locale salvato con successo!
    echo     Puoi caricare su GitHub in qualsiasi momento rieseguendo questo script.
    pause
    exit /b
)

git remote get-url origin >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    git remote set-url origin %repo_url%
) else (
    git remote add origin %repo_url%
)

:: 5. Push su GitHub
echo.
echo [4/4] Invio file a GitHub (Push su main)...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================================
    echo  COMPLETATO CON SUCCESSO! Il tuo codice e' ora su GitHub! 
    echo ==========================================================
) else (
    echo.
    echo [!] Errore durante il push.
    echo     Se GitHub ti chiede l'autenticazione, effettua l'accesso
    echo     nella finestra del browser o inserisci un Personal Access Token.
)

echo.
pause
