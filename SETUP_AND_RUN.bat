@echo off
chcp 65001 >nul
cls

color 0B

echo ╔══════════════════════════════════════════════════════════════╗
echo ║   🚀 Installation Automatique de Flutter + Lancement App   ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Naviguer vers le dossier du projet
cd /d "%~dp0"

echo 📂 Dossier du projet : %CD%
echo.

REM ══════════════════════════════════════════════════════════════
REM Étape 1 : Vérifier si Flutter est installé
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 🔍 Vérification de Flutter...
echo ══════════════════════════════════════════════════════════════
echo.

where flutter >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Flutter est déjà installé!
    flutter --version
    goto install_deps
)

echo ❌ Flutter n'est pas installé.
echo.

REM ══════════════════════════════════════════════════════════════
REM Étape 2 : Proposer l'installation de Flutter
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 💾 Installation de Flutter
echo ══════════════════════════════════════════════════════════════
echo.
echo Flutter n'est pas installé sur votre système.
echo.
echo Pour utiliser cette application Flutter, vous devez installer Flutter.
echo.
echo 📋 Options :
echo.
echo [1] Ouvrir le site de téléchargement de Flutter
echo [2] Continuer sans Flutter (annuler)
echo.
set /p install_choice="Votre choix (1 ou 2) : "

if "%install_choice%"=="1" goto download_flutter
if "%install_choice%"=="2" goto no_flutter

:download_flutter
echo.
echo ══════════════════════════════════════════════════════════════
echo 📥 Téléchargement de Flutter
echo ══════════════════════════════════════════════════════════════
echo.
echo 🌐 Ouverture du site officiel de Flutter...
echo.
echo 📖 Suivez ces étapes :
echo.
echo   1. Téléchargez Flutter SDK pour Windows
echo   2. Extrayez le ZIP dans C:\src\flutter
echo   3. Ajoutez C:\src\flutter\bin au PATH
echo   4. Ouvrez un NOUVEAU terminal
echo   5. Relancez ce script
echo.
timeout /t 3 /nobreak >nul

REM Ouvrir le site de téléchargement
start https://docs.flutter.dev/get-started/install/windows

REM Ouvrir aussi le lien direct de téléchargement
timeout /t 2 /nobreak >nul
start https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip

echo.
echo ✅ Les liens de téléchargement sont ouverts dans votre navigateur
echo.
echo ⚠️  IMPORTANT : Après l'installation de Flutter :
echo.
echo    1. Fermez TOUTES les fenêtres de commande
echo    2. Ouvrez un NOUVEAU terminal
echo    3. Relancez ce script
echo.
pause
exit

:no_flutter
echo.
echo ❌ Installation annulée.
echo.
echo Pour utiliser cette application Flutter, vous devez installer Flutter.
echo Relancez ce script après avoir installé Flutter.
echo.
pause
exit

REM ══════════════════════════════════════════════════════════════
REM Étape 3 : Installer les dépendances Flutter
REM ══════════════════════════════════════════════════════════════
:install_deps
echo.
echo ══════════════════════════════════════════════════════════════
echo 📦 Installation des dépendances Flutter...
echo ══════════════════════════════════════════════════════════════
echo.

flutter pub get

if %errorlevel% neq 0 (
    echo.
    echo ❌ Erreur lors de l'installation des dépendances!
    echo.
    echo 💡 Essayez de nettoyer le projet :
    echo    flutter clean
    echo    flutter pub get
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Dépendances installées avec succès!
echo.

REM ══════════════════════════════════════════════════════════════
REM Étape 4 : Vérifier les appareils disponibles
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 📱 Appareils disponibles :
echo ══════════════════════════════════════════════════════════════
echo.

flutter devices

echo.

REM ══════════════════════════════════════════════════════════════
REM Étape 5 : Proposer le mode de lancement
REM ══════════════════════════════════════════════════════════════
echo ══════════════════════════════════════════════════════════════
echo 🚀 Lancement de l'application
echo ══════════════════════════════════════════════════════════════
echo.
echo Choisissez le mode de lancement :
echo.
echo [1] 🌐 Web (Chrome) - Recommandé pour développement rapide
echo [2] 📱 Android - Si appareil/émulateur connecté
echo [3] 🖥️  Windows Desktop - Application native Windows
echo.
set /p launch_choice="Votre choix (1, 2 ou 3) : "

if "%launch_choice%"=="1" goto launch_web
if "%launch_choice%"=="2" goto launch_android
if "%launch_choice%"=="3" goto launch_windows

:launch_web
echo.
echo ══════════════════════════════════════════════════════════════
echo 🌐 Lancement sur Chrome...
echo ══════════════════════════════════════════════════════════════
echo.
echo ✨ Fonctionnalités activées :
echo    🔥 Hot Reload - Modifiez le code et voyez les changements instantanément!
echo    🎨 DevTools - Outils de développement intégrés
echo    📊 Performance metrics
echo.
echo ⏳ Démarrage du serveur Flutter...
timeout /t 2 /nobreak >nul

REM Lancer Flutter sur Chrome
flutter run -d chrome --web-port=8080

goto end

:launch_android
echo.
echo ══════════════════════════════════════════════════════════════
echo 📱 Lancement sur Android...
echo ══════════════════════════════════════════════════════════════
echo.
echo ⚠️  Vérifiez que :
echo    - Votre téléphone est connecté en USB
echo    - Le mode développeur est activé
echo    - Le débogage USB est activé
echo    - OU un émulateur Android est lancé
echo.
pause

flutter run

goto end

:launch_windows
echo.
echo ══════════════════════════════════════════════════════════════
echo 🖥️  Lancement sur Windows...
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
