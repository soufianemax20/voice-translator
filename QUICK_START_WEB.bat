@echo off
chcp 65001 >nul
cls

color 0D

echo ╔════════════════════════════════════════════════════════════╗
echo ║       🌐 VoiceTranslator - Démarrage Web Rapide 🌐        ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

REM Vérification rapide de Flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter non installé! Exécutez INSTALL_AND_RUN.bat
    pause
    exit /b 1
)

echo ✅ Flutter détecté
echo.
echo 🚀 Démarrage rapide sur le Web...
echo.

REM Installer dépendances (rapide si déjà installées)
flutter pub get >nul 2>&1

REM Lancer sur Chrome avec port personnalisé
echo 🌐 Lancement sur http://localhost:8080
echo.
start "VoiceTranslator" cmd /k "flutter run -d chrome --web-port=8080 --web-renderer html"

REM Attendre le démarrage
timeout /t 12 /nobreak >nul

REM Ouvrir le navigateur
start http://localhost:8080

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                  ✅ Application lancée! ✅                 ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 🌐 URL : http://localhost:8080
echo 🛑 Pour arrêter : Fermez la fenêtre Flutter
echo.

timeout /t 5
exit
