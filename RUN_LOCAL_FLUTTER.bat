@echo off
chcp 65001 >nul
cls

color 0B

echo ╔════════════════════════════════════════════════════════════╗
echo ║    🚀 VoiceTranslator - Lancement avec Flutter Local 🚀  ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Naviguer vers le dossier du projet
cd /d "%~dp0"

echo 📂 Dossier du projet : %CD%
echo.

REM ══════════════════════════════════════════════════════════════
REM Configuration du Flutter local
REM ══════════════════════════════════════════════════════════════
set FLUTTER_ROOT=%CD%\flutter
set PATH=%FLUTTER_ROOT%\bin;%PATH%

echo ══════════════════════════════════════════════════════════════
echo 🔍 Vérification de Flutter local
echo ══════════════════════════════════════════════════════════════
echo.

if not exist "%FLUTTER_ROOT%\bin\flutter.bat" (
    echo ❌ Flutter n'est pas trouvé dans : %FLUTTER_ROOT%
    echo.
    echo 💡 Extraction en cours... Veuillez patienter.
    echo.
    echo Si l'extraction est terminée, relancez ce script.
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter trouvé dans le projet!
echo 📁 Chemin : %FLUTTER_ROOT%
echo.

flutter --version
echo.

REM ══════════════════════════════════════════════════════════════
REM Installer les dépendances
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 📦 Installation des dépendances
echo ══════════════════════════════════════════════════════════════
echo.

echo ⏳ Installation des packages Flutter...
flutter pub get

if %errorlevel% neq 0 (
    echo.
    echo ❌ Erreur lors de l'installation des dépendances!
    pause
    exit /b 1
)

echo.
echo ✅ Dépendances installées!
echo.

REM ══════════════════════════════════════════════════════════════
REM Vérifier les appareils
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 📱 Appareils disponibles
echo ══════════════════════════════════════════════════════════════
echo.

flutter devices

echo.

REM ══════════════════════════════════════════════════════════════
REM Lancer l'application
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo ✅ Tout est prêt!
echo ══════════════════════════════════════════════════════════════
echo.

echo 🎉 VoiceTranslator avec Scribe V2 Realtime est prêt!
echo.
echo 📋 Choisissez le mode de lancement :
echo.
echo [1] 🌐 Web (Chrome) - Avec Hot Reload 🔥
echo [2] 📱 Android
echo [3] 🖥️  Windows Desktop
echo [0] ❌ Quitter
echo.

set /p choice="Votre choix : "

if "%choice%"=="1" goto launch_web
if "%choice%"=="2" goto launch_android
if "%choice%"=="3" goto launch_windows
goto end

:launch_web
echo.
echo ══════════════════════════════════════════════════════════════
echo 🌐 Lancement sur Chrome avec Hot Reload
echo ══════════════════════════════════════════════════════════════
echo.
echo ✨ Fonctionnalités :
echo    🔥 Hot Reload - Sauvegardez et voyez les changements!
echo    📊 Scribe V2 Realtime - Transcription instantanée
echo    🎨 Interface ultra-moderne
echo.
echo ⏳ Démarrage...
timeout /t 2 /nobreak >nul
echo.

flutter run -d chrome --web-port=8080

goto end

:launch_android
echo.
echo ══════════════════════════════════════════════════════════════
echo 📱 Lancement sur Android
echo ══════════════════════════════════════════════════════════════
echo.

flutter run

goto end

:launch_windows
echo.
echo ══════════════════════════════════════════════════════════════
echo 🖥️  Lancement sur Windows Desktop
echo ══════════════════════════════════════════════════════════════
echo.

flutter run -d windows

goto end

:end
echo.
echo ══════════════════════════════════════════════════════════════
echo ✅ Application terminée
echo ══════════════════════════════════════════════════════════════
echo.
pause
