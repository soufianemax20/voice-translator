@echo off
chcp 65001 >nul
cls

REM ═══════════════════════════════════════════════════════════════
REM  🚀 VoiceTranslator - Lanceur Principal
REM  Double-cliquez sur ce fichier pour démarrer l'application!
REM ═══════════════════════════════════════════════════════════════

color 0B
title VoiceTranslator - Lanceur Principal

:menu
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                                                               ║
echo ║         🎤 VoiceTranslator - Lanceur Principal 🎤            ║
echo ║              Application de Traduction Vocale                 ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo ══════════════════════════════════════════════════════════════
echo   Que voulez-vous faire ?
echo ══════════════════════════════════════════════════════════════
echo.
echo   [1] 🚀 Démarrer l'application (Web - Chrome)
echo   [2] 📱 Démarrer sur Android
echo   [3] 🔧 Installation complète et démarrage
echo   [4] ⚡ Démarrage web rapide
echo   [5] 💾 Installer Flutter
echo   [6] 🧹 Nettoyer le projet
echo   [7] 📖 Ouvrir la documentation
echo   [8] 🔍 Vérifier Flutter
echo   [0] ❌ Quitter
echo.
echo ══════════════════════════════════════════════════════════════
set /p menu_choice="  Votre choix : "

if "%menu_choice%"=="1" goto start_web
if "%menu_choice%"=="2" goto start_android
if "%menu_choice%"=="3" goto install_run
if "%menu_choice%"=="4" goto quick_web
if "%menu_choice%"=="5" goto install_flutter
if "%menu_choice%"=="6" goto clean
if "%menu_choice%"=="7" goto docs
if "%menu_choice%"=="8" goto check_flutter
if "%menu_choice%"=="0" goto quit
echo.
echo ❌ Choix invalide!
timeout /t 2 >nul
goto menu

:start_web
cls
echo.
echo 🚀 Démarrage de l'application...
echo.
call START_APP.bat
goto menu

:start_android
cls
echo.
echo 📱 Démarrage sur Android...
echo.
call RUN_ON_ANDROID.bat
goto menu

:install_run
cls
echo.
echo 🔧 Installation et démarrage...
echo.
call INSTALL_AND_RUN.bat
goto menu

:quick_web
cls
echo.
echo ⚡ Démarrage rapide...
echo.
call QUICK_START_WEB.bat
goto menu

:install_flutter
cls
echo.
echo 💾 Installation de Flutter...
echo.
call INSTALL_FLUTTER.bat
goto menu

:clean
cls
echo.
echo ══════════════════════════════════════════════════════════════
echo 🧹 Nettoyage du projet...
echo ══════════════════════════════════════════════════════════════
echo.
flutter clean
echo.
echo ✅ Nettoyage terminé!
echo.
pause
goto menu

:docs
cls
echo.
echo ══════════════════════════════════════════════════════════════
echo 📖 Documentation
echo ══════════════════════════════════════════════════════════════
echo.
echo [1] README.md
echo [2] QUICK_START.md
echo [3] ARCHITECTURE.md
echo [4] COMMANDS.md
echo [5] Retour au menu
echo.
set /p doc_choice="Votre choix : "

if "%doc_choice%"=="1" start README.md
if "%doc_choice%"=="2" start QUICK_START.md
if "%doc_choice%"=="3" start ARCHITECTURE.md
if "%doc_choice%"=="4" start COMMANDS.md
if "%doc_choice%"=="5" goto menu

goto docs

:check_flutter
cls
echo.
echo ══════════════════════════════════════════════════════════════
echo 🔍 Vérification de Flutter...
echo ══════════════════════════════════════════════════════════════
echo.
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas installé!
    echo.
    echo 💡 Utilisez l'option [5] pour installer Flutter
) else (
    echo ✅ Flutter trouvé!
    echo.
    flutter --version
    echo.
    echo ══════════════════════════════════════════════════════════════
    echo 📊 Diagnostic complet :
    echo ══════════════════════════════════════════════════════════════
    echo.
    flutter doctor -v
)
echo.
pause
goto menu

:quit
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║                                                               ║
echo ║              Merci d'avoir utilisé VoiceTranslator!           ║
echo ║                                                               ║
echo ║                    À bientôt! 👋                             ║
echo ║                                                               ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
timeout /t 3
exit
